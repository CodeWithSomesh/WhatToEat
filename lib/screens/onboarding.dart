import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:what_to_eat/controllers.onboarding/onboarding_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                  image:'assets/on_boarding_images/thinking.gif',
                  title: "Can't Decide What to Eat?",
                  subTitle: "Don't worry — we've all been there. Let WhatToEat help you figure it out!",
                  backgroundColor: Color(0xFFFFE55C),
              ),
              OnBoardingPage(
                image:'assets/on_boarding_images/swipeFood.gif',
                title: "Swipe Through Tasty Options",
                subTitle: "Swipe left or right to explore nearby restaurant meals you'll love.",
                backgroundColor: Color(0xFFFF6B9D),
              ),
              OnBoardingPage(
                image:'assets/on_boarding_images/spinningFood.gif',
                title: "Spin the Wheel of Cravings",
                subTitle: "Feeling adventurous? Let the wheel choose your next delicious meal.",
                backgroundColor: Color(0xFFF00D4FF),
              ),
            ],
          ),

          ///Skip Button
          const OnBoardingSkip(),

          /// Dot Navigation SmoothPageIndicator
          const OnBoardDotNavigation(),

          /// Circular Button
          const OnBoardingNextButton(),
        ],
      ),
    );
  }
}

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;

    return Positioned(
      top: kToolbarHeight,
      right: 20,
      child: Obx(() {
        final isLastPage = controller.currentPageIndex.value == 2;
        return TextButton(
          onPressed: () {
            if (isLastPage) {
              controller.skipPage(); // Or controller.nextPage() if different
            } else {
              controller.skipPage();
            }
          },
          child: Text(isLastPage ? 'Next' : 'Skip'),
        );
      }),
    );
  }
}

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      right: 40,
      bottom: kBottomNavigationBarHeight,
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: CircleBorder(),
            backgroundColor: dark ? Colors.white: Colors.black
        ),
        child: Icon(
            Iconsax.arrow_right_3,
            size: 28,
            color: Colors.white
        ),
      ),
    );
  }
}

class OnBoardDotNavigation extends StatelessWidget {
  const OnBoardDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      bottom: kBottomNavigationBarHeight + 25,
      left: 35,
      child: SmoothPageIndicator(
          count: 3,
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          effect: ExpandingDotsEffect(activeDotColor: dark ? Colors.white: Colors.black, dotHeight: 6)
      ),
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.backgroundColor,
  });

  final String image, title, subTitle;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor, // Set the background color per page
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(5, 5),
                blurRadius: 0,
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                image,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subTitle,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}


