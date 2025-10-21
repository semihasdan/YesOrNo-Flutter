
import 'package:flutter/material.dart';
import 'package:yes_or_no/core/theme/app_colors.dart';

class BackgroundGradient extends StatelessWidget {
  const BackgroundGradient({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDark2,
            AppColors.backgroundDark3,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
