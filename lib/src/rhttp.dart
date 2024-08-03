import 'dart:async';
import 'dart:convert';

import 'package:rhttp/src/client.dart';
import 'package:rhttp/src/model/request.dart';
import 'package:rhttp/src/model/response.dart';
import 'package:rhttp/src/rust/api/http.dart' as rust;
import 'package:rhttp/src/rust/frb_generated.dart';
import 'package:rhttp/src/util/digest_headers.dart';

export 'package:rhttp/src/rust/api/http_types.dart' show HttpHeaderName;

class Rhttp {
  /// Initializes the Rust library.
  static Future<void> init() async {
    await RustLib.init();
  }

  /// Makes an HTTP request.
  static Future<HttpResponse> requestGeneric({
    ClientSettings? settings,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
    required HttpExpectBody expectBody,
  }) async {
    headers = digestHeaders(
      headers: headers,
      body: body,
    );

    if (expectBody == HttpExpectBody.stream) {
      final responseCompleter = Completer<rust.HttpResponse>();
      final stream = rust.makeHttpRequestReceiveStream(
        settings: settings?.toRustType(),
        method: method._toRustType(),
        url: url,
        query: query?.entries.map((e) => (e.key, e.value)).toList(),
        headers: headers?._toRustType(),
        body: body?._toRustType(),
        onResponse: (r) => responseCompleter.complete(r),
      );

      final response = await responseCompleter.future;

      return parseHttpResponse(
        response,
        bodyStream: stream,
      );
    } else {
      final response = await rust.makeHttpRequest(
        settings: settings?.toRustType(),
        method: method._toRustType(),
        url: url,
        query: query?.entries.map((e) => (e.key, e.value)).toList(),
        headers: headers?._toRustType(),
        body: body?._toRustType(),
        expectBody: expectBody.toRustType(),
      );

      return parseHttpResponse(response);
    }
  }

  /// Alias for [requestText].
  static Future<HttpTextResponse> request({
    ClientSettings? settings,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    return await requestText(
      settings: settings,
      method: method,
      url: url,
      query: query,
      headers: headers,
      body: body,
    );
  }

  static Future<HttpTextResponse> requestText({
    ClientSettings? settings,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    final response = await requestGeneric(
      settings: settings,
      method: method,
      url: url,
      query: query,
      headers: headers,
      body: body,
      expectBody: HttpExpectBody.text,
    );
    return response as HttpTextResponse;
  }

  static Future<HttpBytesResponse> requestBytes({
    ClientSettings? settings,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    final response = await requestGeneric(
      settings: settings,
      method: method,
      url: url,
      query: query,
      headers: headers,
      body: body,
      expectBody: HttpExpectBody.bytes,
    );
    return response as HttpBytesResponse;
  }

  static Future<HttpStreamResponse> requestStream({
    ClientSettings? settings,
    required HttpMethod method,
    required String url,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    final response = await requestGeneric(
      settings: settings,
      method: method,
      url: url,
      query: query,
      headers: headers,
      body: body,
      expectBody: HttpExpectBody.stream,
    );
    return response as HttpStreamResponse;
  }

  /// Makes an HTTP GET request.
  static Future<HttpTextResponse> get(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
    HttpHeaders? headers,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.get,
      url: url,
      query: query,
      headers: headers,
    );
  }

  /// Makes an HTTP POST request.
  static Future<HttpTextResponse> post(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.post,
      url: url,
      query: query,
      headers: headers,
      body: body,
    );
  }

  /// Makes an HTTP PUT request.
  static Future<HttpTextResponse> put(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.put,
      url: url,
      query: query,
      headers: headers,
      body: body,
    );
  }

  /// Makes an HTTP DELETE request.
  static Future<HttpTextResponse> delete(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.delete,
      url: url,
      query: query,
      headers: headers,
      body: body,
    );
  }

  /// Makes an HTTP HEAD request.
  static Future<HttpTextResponse> head(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.head,
      url: url,
      query: query,
    );
  }

  /// Makes an HTTP PATCH request.
  static Future<HttpTextResponse> patch(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.patch,
      url: url,
      query: query,
      headers: headers,
      body: body,
    );
  }

  /// Makes an HTTP OPTIONS request.
  static Future<HttpTextResponse> options(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.options,
      url: url,
      query: query,
      headers: headers,
      body: body,
    );
  }

  /// Makes an HTTP TRACE request.
  static Future<HttpTextResponse> trace(
    String url, {
    ClientSettings? settings,
    HttpVersionPref? httpVersion,
    Map<String, String>? query,
    HttpHeaders? headers,
    HttpBody? body,
  }) async {
    return await request(
      settings: settings,
      method: HttpMethod.trace,
      url: url,
      query: query,
      headers: headers,
      body: body,
    );
  }
}

extension on HttpMethod {
  rust.HttpMethod _toRustType() {
    return switch (this) {
      HttpMethod.options => rust.HttpMethod.options,
      HttpMethod.get => rust.HttpMethod.get_,
      HttpMethod.post => rust.HttpMethod.post,
      HttpMethod.put => rust.HttpMethod.put,
      HttpMethod.delete => rust.HttpMethod.delete,
      HttpMethod.head => rust.HttpMethod.head,
      HttpMethod.trace => rust.HttpMethod.trace,
      HttpMethod.connect => rust.HttpMethod.connect,
      HttpMethod.patch => rust.HttpMethod.patch,
    };
  }
}

extension on HttpHeaders {
  rust.HttpHeaders _toRustType() {
    return switch (this) {
      HttpHeaderMap map => rust.HttpHeaders.map(map.map),
      HttpHeaderRawMap rawMap => rust.HttpHeaders.rawMap(rawMap.map),
      HttpHeaderList list => rust.HttpHeaders.list(list.list),
    };
  }
}

extension on HttpBody {
  rust.HttpBody _toRustType() {
    return switch (this) {
      HttpBodyText text => rust.HttpBody.text(text.text),
      HttpBodyJson json => rust.HttpBody.text(jsonEncode(json.json)),
      HttpBodyBytes bytes => rust.HttpBody.bytes(bytes.bytes),
      HttpBodyForm form => rust.HttpBody.form(form.form),
    };
  }
}
