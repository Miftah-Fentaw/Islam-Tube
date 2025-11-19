import 'package:flutter/material.dart';
import 'package:deen_stream/presentation/screens/personal/personal_screen.dart';
import 'package:deen_stream/presentation/screens/search/search_screen.dart';
import 'package:deen_stream/presentation/screens/shorts/shorts_screen.dart';
import 'package:deen_stream/presentation/screens/home/home_screen.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  HomePage(),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void onItemTapped(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        allowImplicitScrolling: true,
        physics: const NeverScrollableScrollPhysics(),
        children:  [
          HomeScreen(),
          ShortsScreen(),
          SearchScreen(),
          PersonalScreen(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
    backgroundColor: Colors.blueAccent,

    items: [
      CurvedNavigationBarItem(
        child: Icon(Icons.home_outlined),
        label: 'Home',
      ),
      CurvedNavigationBarItem(
        child: Icon(Icons.video_collection_outlined),
        label: 'Shorts',
      ),
      CurvedNavigationBarItem(
        child: Icon(Icons.search_sharp),
        label: 'Search',
      ),
      CurvedNavigationBarItem(
        child: Icon(Icons.perm_identity),
        label: 'Personal',
      ),
    ],
    onTap: onItemTapped,
  ),
    );
  }
} 