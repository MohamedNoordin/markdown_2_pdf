import 'dart:async';

import 'package:http/http.dart' as http;

/// Represents the source of markdown content
abstract class MarkdownSource {
  /// Get the markdown content as a string
  FutureOr<String> getContent();
}

/// Markdown source from HTTP URL
class HttpMarkdownSource extends MarkdownSource {
  HttpMarkdownSource({required this.url, this.headers, this.timeout});

  final String url;
  final Map<String, String>? headers;
  final Duration? timeout;

  @override
  Future<String> getContent() async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout ?? const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to fetch markdown: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching markdown from URL: $e');
    }
  }
}

/// Markdown source from direct string content
class StringMarkdownSource extends MarkdownSource {
  StringMarkdownSource(this.content);

  final String content;

  @override
  String getContent() => content;
}

/// Markdown source from HTTP response
class HttpResponseMarkdownSource extends MarkdownSource {
  HttpResponseMarkdownSource(this.response);

  final http.Response response;

  @override
  String getContent() {
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Invalid HTTP response: ${response.statusCode}');
    }
  }
}
