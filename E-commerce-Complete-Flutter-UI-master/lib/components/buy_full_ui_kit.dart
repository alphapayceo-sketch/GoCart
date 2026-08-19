import 'dart:async';

import 'package:flutter/material.dart';

class BuyFullKit extends StatefulWidget {
  const BuyFullKit({super.key, required this.images});

  final List<String> images;

  @override
  State<BuyFullKit> createState() => _BuyFullKitState();
}

class _BuyFullKitState extends State<BuyFullKit> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      if (_currentPage < widget.images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      try {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // Page controller was disposed or widget unmounted
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Image.asset(
            widget.images[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
