class YoutubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String channelId;
  final String channelTitle;
  final String thumbnailUrl;
  final DateTime publishedAt;

  YoutubeVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.channelId,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.publishedAt,
  });
}