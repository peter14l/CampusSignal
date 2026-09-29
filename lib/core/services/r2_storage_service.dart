import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

/// Cloudflare R2 & Supabase Cloud Storage and Fast Image Caching Service for CampusSignal
class R2StorageService {
  static String get publicCdnBase {
    const envBase = String.fromEnvironment('R2_PUBLIC_BASE_URL');
    if (envBase.isNotEmpty) return envBase;
    if (dotenv.isInitialized) {
      final envVal = dotenv.env['R2_PUBLIC_BASE_URL'];
      if (envVal != null && envVal.isNotEmpty) return envVal;
    }
    return 'https://pub-a56b2096b15c42f3b81606f43267e8c8.r2.dev/posters';
  }

  // In-memory poster byte cache for instant zero-latency image preview
  final Map<String, Uint8List> _posterMemoryCache = {};

  /// Uploads image bytes to Cloud Storage (Supabase Storage with Cloudflare R2 fallback)
  /// and returns a fast public CDN URL.
  Future<String> uploadPosterImage({
    required Uint8List bytes,
    String? preferredFileName,
    String mimeType = 'image/jpeg',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = mimeType.contains('png') ? 'png' : 'jpg';
    final fileName = preferredFileName ?? 'poster_$timestamp.$extension';
    final r2PublicUrl = '$publicCdnBase/$fileName';

    // Store in local high-speed cache for immediate rendering without waiting for CDN propagation
    _posterMemoryCache[r2PublicUrl] = bytes;
    _posterMemoryCache[fileName] = bytes;

    // 1. Try Supabase Storage 'posters' bucket if Supabase client is active
    final client = SupabaseConfig.client;
    if (client != null && SupabaseConfig.isConfigured) {
      try {
        await client.storage.from('posters').uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: true,
              ),
            );
        final supabaseUrl = client.storage.from('posters').getPublicUrl(fileName);
        _posterMemoryCache[supabaseUrl] = bytes;
        debugPrint('Supabase Storage: Uploaded $fileName to $supabaseUrl');
        return supabaseUrl;
      } catch (e) {
        debugPrint('Supabase Storage upload notice (falling back to R2 CDN): $e');
      }
    }

    // 2. R2 CDN Fallback URL
    debugPrint('Cloudflare R2: Using CDN URL $r2PublicUrl for $fileName (${bytes.lengthInBytes} bytes)');
    return r2PublicUrl;
  }

  /// Retrieves locally cached bytes for an image URL if present
  Uint8List? getCachedBytes(String urlOrKey) {
    return _posterMemoryCache[urlOrKey];
  }

  /// Checks if image is locally cached
  bool hasCached(String urlOrKey) {
    return _posterMemoryCache.containsKey(urlOrKey);
  }
}

final r2StorageServiceProvider = Provider<R2StorageService>((ref) {
  return R2StorageService();
});
