
// ignore_for_file: dead_code, unnecessary_null_comparison

import 'package:deen_stream/core/models/yt_videos.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final YoutubeVideo video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
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
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blue.shade700,
        progressColors: ProgressBarColors(
          playedColor: Colors.blue.shade700,
          handleColor: Colors.blue.shade900,
          bufferedColor: Colors.blue.shade200,
          backgroundColor: Colors.grey.shade300,
        ),
        topActions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
            onPressed: () => _controller.toggleFullScreenMode(),
          ),
        ],
        onEnded: (data) {
          // Optional: play next video
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              // YouTube Player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),

              // Video Info Section (below player)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.video.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Channel & Published
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue.shade700,
                              child: Text(
                                widget.video.channelTitle.isNotEmpty
                                    ? widget.video.channelTitle[0].toUpperCase()
                                    : "D",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.video.channelTitle,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    "Published ${widget.video.publishedAt != null ? _formatDate(widget.video.publishedAt!) : 'Recently'}",
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share_rounded, color: Colors.blue.shade700),
                              onPressed: () {
                                // Share video link
                                final link = "https://youtu.be/${widget.video.videoId}";
                                // Use share_plus package later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Link copied: $link")),
                                );
                              },
                            ),
                          ],
                        ),

                        const Divider(height: 40),

                        // Description
                        if (widget.video.description.isNotEmpty) ...[
                          const Text(
                            "Description",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.video.description,
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                          ),
                        ],

                        const SizedBox(height: 30),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _actionButton(Icons.bookmark_border_rounded, "Save"),
                            _actionButton(Icons.download_rounded, "Download"),
                            _actionButton(Icons.playlist_add_rounded, "Add to Playlist"),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: Colors.blue.shade700),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}y ago";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo ago";
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }
}