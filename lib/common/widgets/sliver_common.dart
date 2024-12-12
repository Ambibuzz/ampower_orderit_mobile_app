import 'package:flutter/cupertino.dart';

class CustomSliverSizedBox extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;
  const CustomSliverSizedBox({super.key, this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: height,
        key: key,
        width: width,
        child: child,
      ),
    );
  }
}
