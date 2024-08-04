import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:rhttp/src/rust/api/http.dart' as rust;

sealed class HttpResponse {
  final HttpVersion version;
  final int statusCode;
  final List<(String, String)> headers;

  Map<String, String> get headerMap => {
        for (final entry in headers) entry.$1: entry.$2,
      };

  const HttpResponse({
    required this.version,
    required this.statusCode,
    required this.headers,
  });
}

class HttpTextResponse extends HttpResponse {
  final String body;

  const HttpTextResponse({
    required super.version,
    required super.statusCode,
    required super.headers,
    required this.body,
  });

  @override
  String toString() {
    return 'HttpTextResponse(${version.name}, status: $statusCode)';
  }
}

class HttpBytesResponse extends HttpResponse {
  final Uint8List body;

  const HttpBytesResponse({
    required super.version,
    required super.statusCode,
    required super.headers,
    required this.body,
  });

  @override
  String toString() {
    return 'HttpBytesResponse(${version.name}, status: $statusCode)';
  }
}

class HttpStreamResponse extends HttpResponse {
  final Stream<Uint8List> body;

  const HttpStreamResponse({
    required super.version,
    required super.statusCode,
    required super.headers,
    required this.body,
  });

  @override
  String toString() {
    return 'HttpStreamResponse(${version.name}, status: $statusCode)';
  }
}

enum HttpVersion {
  http09,
  http1_0,
  http1_1,
  http2,
  http3,
  other,
  ;
}

@internal
HttpResponse parseHttpResponse(
  rust.HttpResponse response, {
  Stream<Uint8List>? bodyStream,
}) {
  assert((response.body is rust.HttpResponseBody_Stream &&
          bodyStream != null) ||
      (response.body is! rust.HttpResponseBody_Stream && bodyStream == null));

  return switch (response.body) {
    rust.HttpResponseBody_Text text => HttpTextResponse(
        version: parseHttpVersion(response.version),
        statusCode: response.statusCode,
        headers: response.headers,
        body: text.field0,
      ),
    rust.HttpResponseBody_Bytes bytes => HttpBytesResponse(
        version: parseHttpVersion(response.version),
        statusCode: response.statusCode,
        headers: response.headers,
        body: bytes.field0,
      ),
    rust.HttpResponseBody_Stream _ => HttpStreamResponse(
        version: parseHttpVersion(response.version),
        statusCode: response.statusCode,
        headers: response.headers,
        body: bodyStream!,
      ),
  };
}

@internal
HttpVersion parseHttpVersion(rust.HttpVersion version) {
  return switch (version) {
    rust.HttpVersion.http09 => HttpVersion.http09,
    rust.HttpVersion.http10 => HttpVersion.http1_0,
    rust.HttpVersion.http11 => HttpVersion.http1_1,
    rust.HttpVersion.http2 => HttpVersion.http2,
    rust.HttpVersion.http3 => HttpVersion.http3,
    rust.HttpVersion.other => HttpVersion.other,
  };
}