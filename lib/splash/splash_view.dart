import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:flutter/material.dart';

class AmpowerAnimation extends StatefulWidget {
  const AmpowerAnimation({super.key});

  @override
  State<AmpowerAnimation> createState() => _AmpowerAnimationState();
}

class _AmpowerAnimationState extends State<AmpowerAnimation>
    with SingleTickerProviderStateMixin {
  double _height = 0;
  bool _heightAnimationComplete = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isCircle = false;
  bool _showLogo = false;
  bool _fillFullScreen = false;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // animation controller initialization
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    Future.delayed(const Duration(milliseconds: 500), () {
      _startAnimations();
    });
    // rotation animation controller initialization
    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * 3.14159).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ))
          ..addStatusListener((status) {
            // Step 3: Rotate the square in anticlockwise direction transform to a circle when forward animation is completed
            if (status == AnimationStatus.completed) {
              setState(() {
                _isCircle = true;
              });
              _controller.reverse();
            }
          });
    navigateToHomeView();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateToHomeView() async {
    await Future.delayed(const Duration(seconds: 3));
    if (locator.get<StorageService>().isUserCustomer) {
      await locator
          .get<NavigationService>()
          .pushReplacementNamed(itemCategoryNavBarRoute);
    } else {
      await locator
          .get<NavigationService>()
          .pushReplacementNamed(enterCustomerRoute);
    }
  }

  void _startAnimations() async {
    // Step 1: increase height of square from 0 to 100
    setState(() {
      _height = 100;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _heightAnimationComplete = true;
      });
      // Step 2: Rotate the square in clockwise direction
      _controller.forward();
    });
    // Step 4: Create fading effect and show AmPower logo
    await Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _showLogo = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
    // Step 5: Fill entire screen with background color from circle
    await Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _fillFullScreen = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: _startAnimations,
              child: _heightAnimationComplete
                  ? AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: AnimatedContainer(
                            duration: Duration(
                                milliseconds: _fillFullScreen ? 500 : 1000),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006CB5),
                                    Color(0xFF002D4C)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              // shape:
                              //     _isCircle ? BoxShape.circle : BoxShape.rectangle,
                              borderRadius:
                                  BorderRadius.circular(_fillFullScreen
                                      ? 0
                                      : _isCircle
                                          ? 50
                                          : 15),
                            ),
                            width: _fillFullScreen
                                ? MediaQuery.of(context).size.width
                                : _isCircle
                                    ? 26
                                    : 100,
                            height: _fillFullScreen
                                ? MediaQuery.of(context).size.height
                                : _isCircle
                                    ? 26
                                    : 100,
                            curve: Curves.easeInOut,
                          ),
                        );
                      },
                    )
                  : AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 100,
                      height: _height,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF006CB5), Color(0xFF002D4C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(15)),
                      curve: Curves.easeInOut,
                    ),
            ),
          ),
          _showLogo
              ? Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.065,
                        right: MediaQuery.of(context).size.height * 0.009),
                    child: AnimatedOpacity(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      opacity: _opacity,
                      child: Image.asset(
                        'assets/Ampower_Logo_192px 1.png',
                        width: 230,
                        height: 150,
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
