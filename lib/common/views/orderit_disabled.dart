import 'package:flutter/material.dart';
import 'package:orderit/common/services/logout_api_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';

class OrderitDisabled extends StatelessWidget {
  const OrderitDisabled({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
        child: Center(
          child: SizedBox(
            height: displayHeight(context) * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  Images.warningRedIcon,
                  height: 80,
                ),
                SizedBox(
                  height: Sizes.paddingWidget(context),
                ),
                Text(
                  'Oops!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  height: Sizes.paddingWidget(context),
                ),
                const Text(
                  'OrderIT is currently disabled. Please enable it from the configuration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: Sizes.paddingWidget(context) * 1.5,
                ),
                logoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logoutButton(BuildContext context) {
    return SizedBox(
      width: displayWidth(context) < 600
          ? displayWidth(context)
          : displayWidth(context) * 0.5,
      height: Sizes.buttonHeightWidget(context),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.secondary)),
        onPressed: () async {
          await locator.get<LogoutService>().logOut(context);
        },
        child: const Text('Logout'),
      ),
    );
  }
}
