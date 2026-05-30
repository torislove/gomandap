import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/gomandap_tokens.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: GomandapTokens.lightSlate,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: GomandapTokens.lightSlate,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
