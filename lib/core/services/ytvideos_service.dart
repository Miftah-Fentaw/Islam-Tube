// lib/core/services/videos_service.dart

import 'dart:convert';
import 'package:deen_stream/core/models/yt_videos.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideosService {
  final String apiKey;
  final Map<String, String> channelUploads;

  VideosService({required this.apiKey, required this.channelUploads});

  Future<List<YoutubeVideo>> fetchVideos({int maxResults = 50}) async {
    final List<YoutubeVideo> videos = [];
    final client = http.Client();

    debugPrint('Starting fetch of normal (non-Shorts) videos...');

    for (final entry in channelUploads.entries) {
      if (videos.length >= maxResults) break;

      final playlistId = entry.value;

      try {
        final jsonData = await _fetchPlaylist(client, playlistId);
        final parsedVideos = _parseVideos(jsonData);

        // Filter out Shorts
        final normalVideos = parsedVideos.where((v) => !_isShort(v)).toList();

        videos.addAll(normalVideos);

        debugPrint('From ${entry.key}: ${normalVideos.length} normal videos added → Total: ${videos.length}');
      } catch (e) {
        debugPrint('Error fetching playlist ${entry.key}: $e');
      }
    }

    client.close();
    debugPrint('FINAL: ${videos.length} normal Islamic videos loaded');
    return videos.take(maxResults).toList();
  }

  Future<Map<String, dynamic>> _fetchPlaylist(http.Client client, String playlistId) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/playlistItems'
      '?part=snippet'
      '&playlistId=$playlistId'
      '&maxResults=50'
      '&key=$apiKey',
    );

    final response = await client.get(url);

    if (response.statusCode != 200) {
      debugPrint('HTTP ${response.statusCode} for playlist $playlistId');
      throw Exception('Failed to load playlist: ${response.statusCode}');
    }

    return json.decode(response.body);
  }

  List<YoutubeVideo> _parseVideos(Map<String, dynamic> jsonData) {
    final items = jsonData['items'] as List<dynamic>? ?? [];

    return items.map((item) {
      final snippet = item['snippet'] as Map<String, dynamic>;
      final resourceId = snippet['resourceId'] as Map<String, dynamic>?;
      final thumbs = snippet['thumbnails'] as Map<String, dynamic>? ?? {};

      return YoutubeVideo(
        videoId: resourceId?['videoId'] as String? ?? '',
        title: snippet['title'] as String? ?? 'Untitled',
        description: snippet['description'] as String? ?? '',
        channelId: snippet['channelId'] as String? ?? '',
        channelTitle: snippet['channelTitle'] as String? ?? 'Unknown Channel',
        thumbnailUrl: thumbs['high']?['url'] as String? ??
            thumbs['medium']?['url'] as String? ??
            thumbs['default']?['url'] as String? ??
            'https://i.ytimg.com/vi/default.jpg',
        publishedAt: DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ?? DateTime.now(),
      );
    }).where((v) => v.videoId.isNotEmpty).toList(); // Safety: skip broken items
  }

  // Super accurate Shorts filter
  bool _isShort(YoutubeVideo video) {
    final lowerTitle = video.title.toLowerCase();
    final lowerDesc = video.description.toLowerCase();

    return lowerTitle.contains('#shorts') ||
        lowerTitle.contains('#short') ||
        lowerTitle.contains('shorts') ||
        lowerTitle.contains('short') ||
        lowerDesc.contains('#shorts') ||
        lowerDesc.contains('#short') ||
        lowerTitle.length < 80 ||
        lowerTitle.startsWith('short:') ||
        lowerTitle.startsWith('short -') ||
        lowerTitle.startsWith('short |');
  }
}