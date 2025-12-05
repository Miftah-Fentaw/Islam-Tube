import 'package:deen_stream/apikeys.dart';
import 'package:deen_stream/core/models/yt_videos.dart';
import 'package:deen_stream/core/services/ytvideos_service.dart';
import 'package:deen_stream/presentation/screens/home/video_player_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    "All",
    "Quran",
    "Dawah",
    "Hadiths",
    "Seerah",
    "Lectures",
    "Reminders",
  ];

  int selectedIndex = 0;
  final Map<String, List<YoutubeVideo>> categoryVideos = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllVideos();
  }

  Future<void> _loadAllVideos() async {
    final service = VideosService(
      apiKey: videosapikey,
      channelUploads: {
        'UC2w3MiX-1eS5GBKk8SA8DTA': 'UUNB_OaI4524fASt8h0IL8dw',
        'UCt7K2pQVcO7o6NsF1bnsIpA': 'UUt7K2pQVcO7o6NsF1bnsIpA',
        'UCHGAqdQBKTVON_FUCIYCh3Q': 'UUHGAqdQBKTVON_FUCIYCh3Q',
        'UCVy0F5K5GhR4i_K2w2w5uLA': 'UUVy0F5K5GhR4i_K2w2w5uLA',
        'UCGsw8s3xVEnuKGu1y6q6zBQ': 'UUGsw8s3xVEnuKGu1y6q6zBQ',
        'UCtm8rtofLSnaIBi3noB0INg': 'UUtm8rtofLSnaIBi3noB0INg',
        'UC1p1m7Txi_V0spldYKcYAEg': 'UU1p1m7Txi_V0spldYKcYAEg',
        'UCb0jo2XG4z2ih8sTGUxj7zQ': 'UUb0jo2XG4z2ih8sTGUxj7zQ',
        'UCs3EQMckf2P91LEH4dM2dJg': 'UU3vHW2h22WE-pNi5WJtRIjg',
      },
    );

    try {
      final allVideos = await service.fetchVideos(maxResults: 100);

      categoryVideos["All"] = allVideos;

      for (var cat in categories.where((c) => c != "All")) {
        categoryVideos[cat] = allVideos.where((v) {
          final lowerTitle = v.title.toLowerCase();
          final lowerDesc = v.description.toLowerCase();
          final keyword = cat.toLowerCase();

          return lowerTitle.contains(keyword) || lowerDesc.contains(keyword);
        }).toList();
      }
    } catch (e) {
      debugPrint("Error loading videos: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = categories[selectedIndex];
    final videos = categoryVideos[currentCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Islam Tube",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontFamily: 'Amiri',
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 50,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final selected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue.shade700
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          width: 1.8,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.shade200,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey.shade800,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade700,
                      ),
                    )
                  : videos.isEmpty
                  ? Center(
                      child: Text(
                        "No videos in \"$currentCategory\"",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadAllVideos(),

                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VideoPlayerScreen(video: video),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.network(
                                        video.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_2,
                                              size: 16,
                                              color: Colors.blue.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              video.channelTitle,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
