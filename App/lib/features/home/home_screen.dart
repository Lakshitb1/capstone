import 'package:cap_1/components/buttons.dart';
import 'package:cap_1/components/slider_items.dart';
import 'package:cap_1/features/google_map/map_screen/google_map_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Bump Buster",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView(
              children: [
                CarouselSlider(
                  items: const [
                    SliderItem(imagePath: 'assets/image2.png'),
                    SliderItem(imagePath: 'assets/image1.jpg'),
                  ],
                  options: CarouselOptions(
                    height: 250.0,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 1,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    scrollDirection: Axis.horizontal,
                    viewportFraction: 1,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          CustomButton(
            text: 'Start Monitoring',
            onPressed: _navigateToMapScreen,
          ),
          const SizedBox(
            height: 30,
          ),
          CustomButton(
            text: 'View History',
            onPressed: () {},
          ),
          const Spacer(),
        ]),
      ),
    );
  }
}
