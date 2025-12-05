import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/youtube/v3.dart' as ytb;
import 'package:deen_stream/core/constants/youtube sources.dart';
import 'package:deen_stream/apikeys.dart';

const  String _apiKey = youtubeshortsapikey;

class YoutubeService {
  

  Future<List<ytb.Video>> getIslamicShorts({int maxResults = 50}) async {
    final List<ytb.Video> shorts = [];
    final client = http.Client();

    debugPrint('Starting Islamic Shorts fetch (November 19, 2025 Fix)');

    for (final entry in channelUploads.entries) {
      if (shorts.length >= maxResults) break;

      final channelId = entry.key;
      final uploadsId = entry.value;

      try {
        final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/playlistItems'
          '?part=snippet'
          '&playlistId=$uploadsId'
          '&maxResults=50'
          '&key=$_apiKey',
        );

        final response = await client.get(url);

        if (response.statusCode != 200) {
          debugPrint('HTTP ${response.statusCode} for $channelId');
          continue;
        }

        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        for (var item in items) {
          if (shorts.length >= maxResults) break;

          final snippet = item['snippet'] as Map<String, dynamic>;
          final title = (snippet['title'] as String?) ?? '';
          final description = (snippet['description'] as String?) ?? '';
          final lowerTitle = title.toLowerCase();
          final lowerDesc = description.toLowerCase();

          bool isShort = lowerTitle.contains('#shorts') ||
              lowerTitle.contains('short') ||
              lowerDesc.contains('#shorts') ||
              lowerDesc.contains('short') ||
              title.length < 85;

          if (!isShort) continue;

          final videoId = snippet['resourceId']['videoId'] as String;
          final thumbs = snippet['thumbnails'] as Map<String, dynamic>;

          shorts.add(ytb.Video(
            id: videoId,
            snippet: ytb.VideoSnippet(
              title: title,
              channelTitle: snippet['channelTitle'] as String?,
              publishedAt: DateTime.tryParse(snippet['publishedAt'] as String? ?? ''),
              thumbnails: ytb.ThumbnailDetails(
                high: ytb.Thumbnail(url: thumbs['high']?['url'] ?? thumbs['medium']?['url'] ?? ''),
                medium: ytb.Thumbnail(url: thumbs['medium']?['url'] ?? ''),
                default_: ytb.Thumbnail(url: thumbs['default']?['url'] ?? ''),
              ),
            ),
          ));
        }

        debugPrint('From $channelId: ${items.length} videos → ${shorts.length} Shorts total');
      } catch (e) {
        debugPrint('Error $channelId: $e');
      }
    }

    client.close();
    debugPrint('FINAL: ${shorts.length} REAL Islamic Shorts loaded!');
    return shorts;
  }
}