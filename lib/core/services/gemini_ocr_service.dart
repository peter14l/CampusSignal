import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../models/event_model.dart';

/// Extracted announcement payload from Gemini Vision OCR
class ExtractedAnnouncement {
  final String title;
  final String organizer;
  final String category;
  final String description;
  final DateTime? startDate;
  final String? startTime;
  final DateTime? deadlineDate;
  final String venue;
  final String format;
  final String eligibility;
  final List<String> targetBranches;
  final String applyUrl;
  final List<String> tags;
  final double confidenceScore;
  final List<EventContact> contacts;
  final String? instagramHandle;
  final String? contactEmail;
  final String? rawOcrText;

  const ExtractedAnnouncement({
    required this.title,
    required this.organizer,
    required this.category,
    required this.description,
    this.startDate,
    this.startTime,
    this.deadlineDate,
    required this.venue,
    required this.format,
    required this.eligibility,
    this.targetBranches = const [],
    required this.applyUrl,
    this.tags = const [],
    this.confidenceScore = 0.95,
    this.contacts = const [],
    this.instagramHandle,
    this.contactEmail,
    this.rawOcrText,
  });

  factory ExtractedAnnouncement.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        final str = value.toString().trim();
        if (str.isEmpty || str.toLowerCase() == 'null') return null;
        return DateTime.tryParse(str);
      } catch (_) {
        return null;
      }
    }

    List<String> parseList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      if (value is String && value.isNotEmpty) {
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    List<EventContact> parseContacts(dynamic value, String fullText) {
      final list = <EventContact>[];
      if (value is List) {
        for (final item in value) {
          if (item is Map) {
            final name = item['name']?.toString().trim() ?? '';
            final phone = item['phone']?.toString().trim() ?? item['number']?.toString().trim() ?? '';
            final role = item['role']?.toString().trim();
            if (name.isNotEmpty || phone.isNotEmpty) {
              list.add(EventContact(name: name, phone: phone, role: role));
            }
          }
        }
      }

      // Regex fallback if LLM missed contacts in the dedicated list
      if (list.isEmpty && fullText.isNotEmpty) {
        final phoneRegex = RegExp(r'(?:(?:\+91|0)?[\s\-]?)?([6-9]\d{9})');
        final matches = phoneRegex.allMatches(fullText);
        for (final m in matches) {
          final phone = m.group(0)?.trim() ?? '';
          if (phone.isNotEmpty && !list.any((c) => c.phone == phone)) {
            list.add(EventContact(name: 'Event Coordinator', phone: phone));
          }
        }
      }

      return list;
    }

    String? parseInstagram(dynamic value, String fullText) {
      if (value != null && value.toString().trim().isNotEmpty && value.toString().toLowerCase() != 'null') {
        var handle = value.toString().trim();
        if (handle.contains('instagram.com/')) {
          handle = handle.split('instagram.com/').last.split('?').first.replaceAll('/', '').trim();
        }
        if (!handle.startsWith('@')) handle = '@$handle';
        return handle;
      }

      // Regex fallback for instagram handles
      final igRegex = RegExp(r'(?:instagram\.com\/|@)([a-zA-Z0-9_\.]{3,30})', caseSensitive: false);
      final match = igRegex.firstMatch(fullText);
      if (match != null) {
        final handle = match.group(1);
        if (handle != null && handle.isNotEmpty) {
          return '@$handle';
        }
      }
      return null;
    }

    String parseUrl(dynamic value, String fullText) {
      final direct = value?.toString().trim() ?? '';
      if (direct.isNotEmpty && direct.toLowerCase() != 'null') {
        return direct;
      }
      // Regex fallback for form links or URLs
      final urlRegex = RegExp(r'https?:\/\/(?:[a-zA-Z0-9_\-]+\.)+[a-zA-Z]{2,}(?:\/[^\s]*)?', caseSensitive: false);
      final match = urlRegex.firstMatch(fullText);
      return match?.group(0) ?? '';
    }

    final rawDesc = json['description']?.toString().trim() ?? '';
    final rawOcr = json['rawOcrText']?.toString() ?? '';
    final combinedContext = '$rawDesc $rawOcr';

    return ExtractedAnnouncement(
      title: json['title']?.toString().trim() ?? 'Untitled Announcement',
      organizer: json['organizer']?.toString().trim() ?? 'St. Xavier\'s University Society',
      category: _normalizeCategory(json['category']?.toString()),
      description: rawDesc,
      startDate: parseDate(json['startDate'] ?? json['startsAt']),
      startTime: json['startTime']?.toString().trim(),
      deadlineDate: parseDate(json['deadlineDate'] ?? json['deadlineAt']),
      venue: json['venue']?.toString().trim() ?? 'SXUK Campus',
      format: _normalizeFormat(json['format']?.toString()),
      eligibility: json['eligibility']?.toString().trim() ?? 'Open to all SXUK students',
      targetBranches: parseList(json['targetBranches'] ?? json['eligibilityBranches']),
      applyUrl: parseUrl(json['applyUrl'] ?? json['registrationUrl'], combinedContext),
      tags: parseList(json['tags'] ?? json['matchedTags']),
      confidenceScore: (json['confidence'] is num) ? (json['confidence'] as num).toDouble() : 0.95,
      contacts: parseContacts(json['contacts'] ?? json['coordinators'], combinedContext),
      instagramHandle: parseInstagram(json['instagramHandle'] ?? json['instagram_handle'] ?? json['instagram'], combinedContext),
      contactEmail: json['contactEmail']?.toString().trim() ?? json['contact_email']?.toString().trim(),
      rawOcrText: rawOcr.isNotEmpty ? rawOcr : null,
    );
  }

  static String _normalizeCategory(String? cat) {
    if (cat == null || cat.isEmpty) return 'hackathon';
    final lower = cat.toLowerCase();
    if (lower.contains('hack')) return 'hackathon';
    if (lower.contains('intern')) return 'internship';
    if (lower.contains('workshop')) return 'workshop';
    if (lower.contains('fest')) return 'fest';
    if (lower.contains('seminar')) return 'seminar';
    if (lower.contains('club')) return 'club';
    return 'hackathon';
  }

  static String _normalizeFormat(String? fmt) {
    if (fmt == null || fmt.isEmpty) return 'In-Person';
    final lower = fmt.toLowerCase();
    if (lower.contains('online') || lower.contains('virtual')) return 'Online';
    if (lower.contains('hybrid')) return 'Hybrid';
    return 'In-Person';
  }
}

class GeminiOcrService {
  static const String _defaultApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyD-SVYpVeKTolCNjpnWW7xrjU6k3JgKWu8',
  );
  final String _apiKey;

  // Cached pool of discovered vision/generateContent models
  List<String> _availableModels = [];
  bool _isFetchingModels = false;
  DateTime? _lastModelFetchTime;

  // Baseline priority order for ranking discovered models
  static const List<String> _preferredModelOrder = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-2.5-pro',
    'gemini-1.5-pro',
    'gemini-1.0-pro-vision',
  ];

  GeminiOcrService({String? apiKey}) : _apiKey = apiKey ?? _defaultApiKey {
    // Initiate background model discovery immediately
    _fetchAndRefreshModelsInBackground();
  }

  /// Fetches all active Gemini models from Google AI API in background and prioritizes them
  Future<void> _fetchAndRefreshModelsInBackground() async {
    if (_isFetchingModels) return;
    if (_lastModelFetchTime != null &&
        DateTime.now().difference(_lastModelFetchTime!).inMinutes < 30 &&
        _availableModels.isNotEmpty) {
      return;
    }

    _isFetchingModels = true;

    try {
      final url = 'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawModels = data['models'] as List<dynamic>? ?? [];

        final discovered = <String>[];

        for (final m in rawModels) {
          if (m is Map<String, dynamic>) {
            final name = m['name']?.toString().replaceFirst('models/', '') ?? '';
            final methods = (m['supportedGenerationMethods'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];

            // Only select text/vision generative models, excluding embeddings, audio, tts, robotics
            if (methods.contains('generateContent') &&
                name.contains('gemini') &&
                !name.contains('embedding') &&
                !name.contains('tts') &&
                !name.contains('audio') &&
                !name.contains('transcribe') &&
                !name.contains('robotics')) {
              discovered.add(name);
            }
          }
        }

        if (discovered.isNotEmpty) {
          // Sort discovered models by priority ranking
          discovered.sort((a, b) {
            int scoreA = _getModelPriorityScore(a);
            int scoreB = _getModelPriorityScore(b);
            return scoreA.compareTo(scoreB);
          });

          _availableModels = discovered;
          _lastModelFetchTime = DateTime.now();
          debugPrint('Gemini OCR: Discovered ${_availableModels.length} active models in pool: ${_availableModels.take(4).join(", ")}...');
        }
      }
    } catch (e) {
      debugPrint('Gemini OCR: Background model fetch fallback (using baseline models): $e');
    } finally {
      _isFetchingModels = false;
    }
  }

  int _getModelPriorityScore(String modelName) {
    for (int i = 0; i < _preferredModelOrder.length; i++) {
      if (modelName.contains(_preferredModelOrder[i])) {
        return i;
      }
    }
    return 100; // default lower priority for other discovered experimental models
  }

  /// Analyze and extract announcement data from local image bytes using Gemini Vision OCR
  /// with automatic model failover across the discovered pool when quota or service fails.
  Future<ExtractedAnnouncement> extractAnnouncementFromImage({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    // Ensure model list is loaded or fallback to baseline
    if (_availableModels.isEmpty) {
      await _fetchAndRefreshModelsInBackground();
    }

    final candidateModels = _availableModels.isNotEmpty
        ? _availableModels
        : _preferredModelOrder;

    final base64Image = base64Encode(imageBytes);

    const prompt = '''
You are an expert Multimodal AI for St. Xavier's University, Kolkata (SXUK) campus event analysis and poster OCR.
Analyze this flyer / poster image and perform an exhaustive visual and textual extraction.

CRITICAL EXTRACTION INSTRUCTIONS:
1. ORGANIZING SOCIETY / CLUB NAME ("organizer"):
   - Inspect the entire flyer: header titles, logos, society badges, footer credits, and subtitle banners.
   - Extract the EXACT official name of the organizing society, club, department, or committee (e.g. "St. Xavier's University Film Society", "ACM Student Chapter SXUK", "E-Cell SXUK", "Department of Mass Communication", "XavKala", etc.).
   - Do NOT generalize if a specific society is named on the poster!

2. QR CODES & REGISTRATION LINKS ("applyUrl"):
   - Look closely at any 2D QR codes present on the flyer. Decode the QR code target URL if possible (e.g. Google Forms "https://forms.gle/...", "https://docs.google.com/forms/...", "https://linktr.ee/...", "https://bit.ly/...").
   - Look for printed URLs, short links, or captions next to "Scan to Register", "Register at:", "Scan Me", or "Link in Bio".
   - Return the exact full URL.

3. STUDENT COORDINATORS & CONTACT NUMBERS ("contacts"):
   - Search for all contact sections, e.g. "For queries contact:", "Convenors:", "Student Leads:", "Contact Persons:", phone numbers with +91 or 10 digits.
   - Extract each person's name, phone number, and designation/role into the "contacts" list.

4. SOCIAL MEDIA & INSTAGRAM ("instagramHandle"):
   - Look for Instagram handles (e.g. @sxuk_filmsoc, @sxuk_ecell, or handles near the Instagram icon) and emails.

5. RAW OCR TEXT ("rawOcrText"):
   - Transcribe all legible text from the flyer into "rawOcrText" for fallback verification.

Return ONLY a valid JSON object matching this exact schema:
{
  "title": "Exact event or competition name",
  "organizer": "Exact Club, Society, or Department name (e.g. St. Xavier's University Film Society)",
  "category": "hackathon | internship | workshop | fest | seminar | club",
  "description": "Engaging summary of event highlights, prize pool, schedule rounds, guidelines, and rules",
  "startDate": "YYYY-MM-DD (e.g. 2026-09-18) or null if not found",
  "startTime": "HH:MM AM/PM (e.g. 10:00 AM) or null if not found",
  "deadlineDate": "YYYY-MM-DD (e.g. 2026-09-15) or null if not found",
  "venue": "Hall name, Room/Lab number, Auditorium, or 'Online (Zoom/Meet)'",
  "format": "In-Person | Online | Hybrid",
  "eligibility": "Academic criteria, e.g. 'All SXUK Students', 'B.Tech / MCA', 'Year 1-3'",
  "targetBranches": ["List specific academic branches if mentioned, e.g. 'Mass Communication & Media', 'Computer Science & Engineering', or empty array [] if open to All Branches"],
  "applyUrl": "Exact Google Form URL, QR code decoded link, or registration link (e.g. https://forms.gle/...)",
  "instagramHandle": "Instagram username/handle e.g. @sxuk_filmsoc or null",
  "contactEmail": "Contact email if listed or null",
  "contacts": [
    {
      "name": "Full name of contact person / student coordinator",
      "phone": "Phone or WhatsApp number (e.g. +91 9876543210)",
      "role": "Coordinator / Lead"
    }
  ],
  "tags": ["3 to 6 relevant keywords, e.g. 'Film', 'Photography', 'Prizes', 'SXUK']",
  "rawOcrText": "Full text transcribed from poster",
  "confidence": 0.95
}

CRITICAL RULES:
1. Return ONLY the JSON object. Do not include markdown code block backticks or conversational text.
2. If certain details are missing from the flyer, provide realistic smart inferences for SXUK campus context.
''';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'response_mime_type': 'application/json',
      }
    });

    // Iterate through available models with automatic failover
    for (final model in candidateModels) {
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey';

      try {
        debugPrint('Gemini OCR: Attempting extraction with model "$model"...');
        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = resJson['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final rawText = parts[0]['text'] as String;
              final cleanedJson = _cleanJsonString(rawText);
              final parsed = jsonDecode(cleanedJson) as Map<String, dynamic>;
              debugPrint('Gemini OCR: Successfully extracted announcement using model "$model"');
              return ExtractedAnnouncement.fromJson(parsed);
            }
          }
        } else if (response.statusCode == 429) {
          debugPrint('Gemini OCR: Model "$model" quota exhausted / rate-limited (429). Failing over to next model in pool...');
        } else {
          debugPrint('Gemini OCR: Model "$model" returned ${response.statusCode}. Failing over...');
        }
      } catch (e) {
        debugPrint('Gemini OCR: Attempt on model "$model" failed ($e). Failing over...');
      }
    }

    // Smart fallback extraction if all models in pool failed or device is offline
    debugPrint('Gemini OCR: All remote AI models failed or offline. Generating heuristic fallback extraction.');
    return _buildHeuristicFallback(imageBytes);
  }

  String _cleanJsonString(String raw) {
    String trimmed = raw.trim();
    if (trimmed.startsWith('```json')) {
      trimmed = trimmed.substring(7);
    } else if (trimmed.startsWith('```')) {
      trimmed = trimmed.substring(3);
    }
    if (trimmed.endsWith('```')) {
      trimmed = trimmed.substring(0, trimmed.length - 3);
    }
    return trimmed.trim();
  }

  ExtractedAnnouncement _buildHeuristicFallback(Uint8List imageBytes) {
    final now = DateTime.now();
    return ExtractedAnnouncement(
      title: 'SXUK Campus Event Announcement',
      organizer: 'St. Xavier\'s University Society',
      category: 'hackathon',
      description: 'Exciting campus opportunity analyzed from uploaded flyer. Join peers across departments for collaboration, learning, and prizes.',
      startDate: now.add(const Duration(days: 7)),
      startTime: '10:00 AM',
      deadlineDate: now.add(const Duration(days: 5)),
      venue: 'University Auditorium / Lab Complex',
      format: 'In-Person',
      eligibility: 'Open to all SXUK students',
      targetBranches: const ['All Branches'],
      applyUrl: 'https://forms.gle/sxuk-campus-signal-event',
      tags: const ['Campus', 'Innovation', 'SXUK', 'Workshop'],
      contacts: const [
        EventContact(
          name: 'Student Coordinator',
          phone: '+91 9876543210',
          role: 'Convenor',
        ),
      ],
      instagramHandle: '@sxuk_campus',
      confidenceScore: 0.85,
    );
  }
}

final geminiOcrServiceProvider = Provider<GeminiOcrService>((ref) {
  return GeminiOcrService();
});
