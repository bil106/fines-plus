import 'package:flutter/material.dart';

class TrendIcon extends StatelessWidget {
  final bool isUp; 

  const TrendIcon({super.key, required this.isUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUp ? Colors.redAccent : Colors.greenAccent, 
      ),
      child: Center(
        child: Transform.rotate(
          angle: isUp ? -0.7854 : 0.7854, 
          child: Icon(Icons.arrow_forward, size: 26, color: Colors.white),
        ),
      ),
    );
  }
}
