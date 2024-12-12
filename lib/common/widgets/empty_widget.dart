import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.onRefresh,
    this.height,
    this.titleText,
  });
  final Future<void> Function()? onRefresh;
  final double? height;
  final String? titleText;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        if (onRefresh != null) {
          await onRefresh!();
        }
      },
      child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: displayHeight(context) * 0.1,
              ),
              Image.asset(
                Images.emptyCartImage,
                width: 300,
                height: 300,
              ),
              SizedBox(
                height: Sizes.paddingWidget(context),
              ),
              Text(
                titleText ?? 'No Data Available at this moment...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
