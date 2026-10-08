import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GithubLogo extends StatelessWidget {
  const GithubLogo({
    super.key,
    this.size = 20,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/github.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
