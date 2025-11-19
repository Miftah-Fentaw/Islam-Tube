import 'package:deen_stream/core/services/youtube_shorts_service.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart' as yt;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class ShortsScreen extends StatefulWidget {
  const ShortsScreen({Key? key}) : super(key: key);

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  late Future<List<yt.Video>> _shortsFuture;
  final YoutubeService _youtubeService = YoutubeService();

  @override
  void initState() {
    super.initState();
    _shortsFuture = _youtubeService.getIslamicShorts(maxResults: 50);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<List<yt.Video>>(
          future: _shortsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _shortsFuture = _youtubeService.getIslamicShorts(maxResults: 50);
                  });
                },
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final video = snapshot.data![index];
                
                    return ShortVideoPlayer(
                      videoId: video.id!,
                      title: video.snippet?.title ?? "Islamic Short",
                      channel: video.snippet?.channelTitle ?? "Unknown",
                      thumbnailUrl: video.snippet?.thumbnails?.high?.url ??
                          video.snippet?.thumbnails?.medium?.url ??
                          video.snippet?.thumbnails?.default_?.url ??
                          '',
                    );
                  },
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white70, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _shortsFuture = _youtubeService.getIslamicShorts(maxResults: 50);
                      }),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}

class ShortVideoPlayer extends StatefulWidget {
  final String videoId;
  final String title;
  final String channel;
  final String thumbnailUrl;

  const ShortVideoPlayer({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: true,
        enableCaption: false,
        showLiveFullscreenButton: false,
        hideThumbnail: true,
      ),
    )..addListener(() {
        if (_controller.value.isReady && !_isPlayerReady) {
          setState(() => _isPlayerReady = true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        YoutubePlayer(
          controller: _controller,
          aspectRatio: 9 / 16,
          showVideoProgressIndicator: false,
        ),

        if (!_isPlayerReady)
          Image.network(widget.thumbnailUrl, fit: BoxFit.cover),

        Positioned(
          left: 12,
          right: 70,
          bottom: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                widget.channel,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        Positioned(
          right: 12,
          bottom: 160,
          child: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(widget.thumbnailUrl),
          ),
        ),
      ],
    );
  }
}