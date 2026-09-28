import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Shimmer/Skeleton loading placeholder widget.
class LoadingSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shapeBorder;

  const LoadingSkeleton({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
    this.shapeBorder,
  }) : super(key: key);

  const LoadingSkeleton.circular({
    Key? key,
    required double size,
  }) : this(
          key: key,
          width: size,
          height: size,
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.rFull)),
        );

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: widget.shapeBorder != null
                ? ShapeDecoration(
                    color: baseColor,
                    shape: widget.shapeBorder!,
                  )
                : BoxDecoration(
                    color: baseColor,
                    borderRadius: widget.borderRadius ?? AppSizes.radiusMd,
                  ),
          ),
        );
      },
    );
  }
}
