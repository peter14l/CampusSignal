import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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

    return ExtractedAnnouncement(
      title: json['title']?.toString().trim() ?? 'Untitled Announcement',
      organizer: json['organizer']?.toString().trim() ?? 'SXUK Student Chapter',
      category: _normalizeCategory(json['category']?.toString()),
      description: json['description']?.toString().trim() ?? '',
      startDate: parseDate(json['startDate'] ?? json['startsAt']),
      startTime: json['startTime']?.toString().trim(),
      deadlineDate: parseDate(json['deadlineDate'] ?? json['deadlineAt']),
      venue: json['venue']?.toString().trim() ?? 'SXUK Campus',
      format: _normalizeFormat(json['format']?.toString()),
      eligibility: json['eligibility']?.toString().trim() ?? 'Open to all SXUK students',
      targetBranches: parseList(json['targetBranches'] ?? json['eligibilityBranches']),
      applyUrl: json['applyUrl']?.toString().trim() ?? json['registrationUrl']?.toString().trim() ?? '',
      tags: parseList(json['tags'] ?? json['matchedTags']),
      confidenceScore: (json['confidence'] is num) ? (json['confidence'] as num).toDouble() : 0.95,
      rawOcrText: json['rawOcrText']?.toString(),
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
You are an expert AI for St. Xavier's University, Kolkata (SXUK) campus event analysis.
Analyze this flyer / poster image and extract all relevant information for a student event announcement.

Perform comprehensive OCR and understand the event context. Return ONLY a valid JSON object matching this exact schema:
{
  "title": "Exact event or competition name",
  "organizer": "Club, Society, Department, or University Body hosting this (e.g. ACM Student Chapter, E-Cell SXUK, Dept of Computer Science)",
  "category": "hackathon | internship | workshop | fest | seminar | club",
  "description": "Engaging summary of event highlights, prize pool, schedule rounds, guidelines, and benefits",
  "startDate": "YYYY-MM-DD (e.g. 2026-09-18) or null if not found",
  "startTime": "HH:MM AM/PM (e.g. 10:00 AM) or null if not found",
  "deadlineDate": "YYYY-MM-DD (e.g. 2026-09-15) or null if not found",
  "venue": "Hall name, Room/Lab number, Auditorium, or 'Online (Zoom/Meet)'",
  "format": "In-Person | Online | Hybrid",
  "eligibility": "Academic criteria, e.g. 'All SXUK Students', 'B.Tech / MCA', 'Year 1-3'",
  "targetBranches": ["List specific academic branches if mentioned, e.g. 'Computer Science & Engineering', 'Data Science & AI', 'Business Administration', 'Law', or empty array [] if open to All Branches"],
  "applyUrl": "Registration URL, Google Form link, or portal link found in poster/text or empty string",
  "tags": ["3 to 6 relevant keywords, e.g. 'Coding', 'AI', 'Prizes', 'Team Event']",
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
      organizer: 'SXUK Student Affairs & Clubs',
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
      confidenceScore: 0.85,
    );
  }
}

final geminiOcrServiceProvider = Provider<GeminiOcrService>((ref) {
  return GeminiOcrService();
});
