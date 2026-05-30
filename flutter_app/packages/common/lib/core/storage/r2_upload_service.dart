import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── R2 Configuration (injected at build time via --dart-define) ──────────────
const _kR2AccountId = String.fromEnvironment('R2_ACCOUNT_ID', defaultValue: '');
const _kR2Bucket    = String.fromEnvironment('R2_BUCKET',     defaultValue: 'gomandap-vendor-kyc');
const _kR2AccessKey = String.fromEnvironment('R2_ACCESS_KEY', defaultValue: '');
const _kR2SecretKey = String.fromEnvironment('R2_SECRET_KEY', defaultValue: '');
const _kR2PublicUrl = String.fromEnvironment('R2_PUBLIC_URL', defaultValue: '');

/// Cloudflare R2 upload service using the S3-compatible API with AWS Signature V4.
///
/// Usage:
///   final url = await ref.read(r2UploadServiceProvider).uploadBytes(
///     vendorId: 'abc-123',
///     field:    'portfolio_1',
///     bytes:    fileBytes,
///     ext:      'jpg',
///     mimeType: 'image/jpeg',
///   );
class R2UploadService {
  /// Whether R2 credentials are available in the current build.
  bool get isConfigured =>
      _kR2AccountId.isNotEmpty &&
      _kR2AccessKey.isNotEmpty &&
      _kR2SecretKey.isNotEmpty;

  /// The base endpoint for this R2 bucket.
  String get _endpoint =>
      'https://$_kR2AccountId.r2.cloudflarestorage.com/$_kR2Bucket';

  /// Upload raw bytes to R2. Returns the public URL of the uploaded object.
  ///
  /// [vendorId]  — used as the folder prefix.
  /// [field]     — logical field name (e.g. 'kyc_doc', 'portfolio_0').
  /// [bytes]     — raw file bytes.
  /// [ext]       — file extension without dot (e.g. 'jpg', 'pdf').
  /// [mimeType]  — MIME type (e.g. 'image/jpeg', 'application/pdf').
  Future<String> uploadBytes({
    required String vendorId,
    required String field,
    required Uint8List bytes,
    required String ext,
    String mimeType = 'application/octet-stream',
  }) async {
    if (!isConfigured) {
      // In dev mode without credentials: return a plausible mock URL
      debugPrint('[R2] Not configured — returning mock URL for field: $field');
      return 'https://mock-r2.gomandap.com/vendors/$vendorId/$field.$ext';
    }

    final objectKey = 'vendors/$vendorId/$field.$ext';
    final uri = Uri.parse('$_endpoint/$objectKey');

    // Build the signed PUT request
    final headers = _buildSignedHeaders(
      method: 'PUT',
      uri: uri,
      body: bytes,
      contentType: mimeType,
    );

    try {
      final response = await http.put(uri, headers: headers, body: bytes);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Use custom public domain if provided, else construct from account
        final baseUrl = _kR2PublicUrl.isNotEmpty
            ? _kR2PublicUrl
            : 'https://pub-$_kR2AccountId.r2.dev';
        final publicUrl = '$baseUrl/$_kR2Bucket/$objectKey';
        debugPrint('[R2] Upload success: $publicUrl');
        return publicUrl;
      } else {
        debugPrint('[R2] Upload failed: ${response.statusCode} ${response.body}');
        throw R2UploadException(
          'Upload failed: HTTP ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is R2UploadException) rethrow;
      debugPrint('[R2] Network error: $e');
      throw R2UploadException('Network error: $e', 0);
    }
  }

  // ─── AWS Signature V4 ──────────────────────────────────────────────────────

  Map<String, String> _buildSignedHeaders({
    required String method,
    required Uri uri,
    required Uint8List body,
    required String contentType,
  }) {
    final now = DateTime.now().toUtc();
    final dateStamp    = _formatDate(now);           // YYYYMMDD
    final amzDate      = _formatAmzDate(now);        // YYYYMMDDTHHMMSSZ
    final payloadHash  = _sha256Hex(body);
    const region       = 'auto';                     // R2 uses 'auto'
    const service      = 's3';

    final headers = <String, String>{
      'host':               uri.host,
      'x-amz-date':         amzDate,
      'x-amz-content-sha256': payloadHash,
      'content-type':       contentType,
    };

    // Canonical request
    final sortedHeaderKeys = headers.keys.toList()..sort();
    final canonicalHeaders =
        sortedHeaderKeys.map((k) => '$k:${headers[k]}\n').join();
    final signedHeadersStr = sortedHeaderKeys.join(';');

    final canonicalUri = uri.path.isEmpty ? '/' : Uri.encodeFull(uri.path);
    const canonicalQueryString = '';

    final canonicalRequest = [
      method,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeadersStr,
      payloadHash,
    ].join('\n');

    // String to sign
    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      _sha256Hex(utf8.encode(canonicalRequest)),
    ].join('\n');

    // Signing key
    final signingKey = _deriveSigningKey(dateStamp, region, service);
    final signature  = _hmacHex(signingKey, stringToSign);

    // Authorization header
    final authorization =
        'AWS4-HMAC-SHA256 Credential=$_kR2AccessKey/$credentialScope, '
        'SignedHeaders=$signedHeadersStr, Signature=$signature';

    return {
      ...headers,
      'authorization': authorization,
    };
  }

  // ─── Crypto helpers ────────────────────────────────────────────────────────

  String _sha256Hex(List<int> data) =>
      sha256.convert(data).toString();

  String _hmacHex(List<int> key, String data) =>
      Hmac(sha256, key).convert(utf8.encode(data)).toString();

  List<int> _hmacBytes(List<int> key, String data) =>
      Hmac(sha256, key).convert(utf8.encode(data)).bytes;

  List<int> _deriveSigningKey(String dateStamp, String region, String service) {
    final kDate    = _hmacBytes(utf8.encode('AWS4$_kR2SecretKey'), dateStamp);
    final kRegion  = _hmacBytes(kDate, region);
    final kService = _hmacBytes(kRegion, service);
    final kSigning = _hmacBytes(kService, 'aws4_request');
    return kSigning;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}'
      '${dt.month.toString().padLeft(2, '0')}'
      '${dt.day.toString().padLeft(2, '0')}';

  String _formatAmzDate(DateTime dt) =>
      '${_formatDate(dt)}T'
      '${dt.hour.toString().padLeft(2, '0')}'
      '${dt.minute.toString().padLeft(2, '0')}'
      '${dt.second.toString().padLeft(2, '0')}Z';
}

class R2UploadException implements Exception {
  final String message;
  final int statusCode;
  R2UploadException(this.message, this.statusCode);
  @override
  String toString() => 'R2UploadException: $message (HTTP $statusCode)';
}

// ─── Riverpod Provider ────────────────────────────────────────────────────────
final r2UploadServiceProvider = Provider<R2UploadService>((_) => R2UploadService());
