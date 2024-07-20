import 'package:flutter/material.dart';

class SliderItem extends StatelessWidget {
  final String imagePath;
  const SliderItem({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(64.0),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          )),
    );
  }
}
