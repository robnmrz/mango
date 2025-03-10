import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:karaage/api/constants.dart';
import 'package:karaage/api/models.dart';
import 'package:karaage/api/queries.dart';

Future<ChapterPagesResponse> getChapterPages({
  required String mangaId,
  required String chapterString,
  String translationType = "sub",
  int limit = 10,
  int offset = 0,
}) async {
  Uri apiUrl = generateChapterPagesUri(
    mangaId: mangaId,
    chapterString: chapterString,
    translationType: translationType,
    limit: limit,
    offset: offset,
  );
  try {
    final response = await http.get(
      apiUrl,
      headers: {'Referer': apiReferer, 'User-Agent': apiAgent},
    );
    if (response.statusCode == 200) {
      return ChapterPagesResponse.fromJson(jsonDecode(response.body));
    } else {
      print('Panels Error: ${response.statusCode}');
      return ChapterPagesResponse(
        rawData: {},
        chapterPages: ChapterPages(edges: []),
      );
    }
  } catch (e) {
    print('Panels Exception: $e');
    return ChapterPagesResponse(
      rawData: {},
      chapterPages: ChapterPages(edges: []),
    );
  }
}

Uri generateChapterPagesUri({
  required String mangaId,
  required String translationType,
  required String chapterString,
  int limit = 10,
  int offset = 0,
}) {
  // Construct the variables map
  Map<String, dynamic> variables = {
    "mangaId": mangaId,
    "translationType": translationType,
    "chapterString": chapterString,
    "limit": limit,
    "offset": offset,
  };
  // Convert the variables map to a JSON string
  String encodedVariables = jsonEncode(variables);

  // Remove extra spaces and new lines from the query string for cleaner output
  String compactQuery =
      chapterPagesQuery.replaceAll("\n", " ").replaceAll("  ", " ").trim();

  // Encode the query for URL safety
  String encodedQuery = Uri.encodeComponent(compactQuery);

  // Construct the final request Uri
  return Uri.parse(
    "$apiBaseUrl?variables=$encodedVariables&query=$encodedQuery",
  );
}

// get only urls of chapters
Future<List<String>> getChapterPagesUrls({
  required String mangaId,
  required String chapterString,
}) async {
  final response = await getChapterPages(
    mangaId: mangaId,
    chapterString: chapterString,
  );

  if (response.chapterPages.edges.isEmpty) {
    return [];
  }

  try {
    String urlBase = response.chapterPages.edges[0].pictureUrlHead!;
    return response.chapterPages.edges[0].pictureUrls
        .map((pic) => urlBase + pic.url)
        .toList();
  } catch (e) {
    print('Panels URLs Exception: $e');
    return [];
  }
}
