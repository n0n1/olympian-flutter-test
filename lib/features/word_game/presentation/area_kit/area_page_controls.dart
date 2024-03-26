import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AreaPageControls extends StatelessWidget {
  const AreaPageControls({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: Center(
        child: AnimatedSmoothIndicator(
          activeIndex: 1,
          count: 1,
          effect: ExpandingDotsEffect(
            dotWidth: 12,
            dotHeight: 8,
            expansionFactor: 2,
            dotColor: Color.fromRGBO(169, 126, 74, 1),
            activeDotColor: Color.fromRGBO(255, 244, 205, 1),
          ),
        ),
      ),
    );
  }
}


   // Positioned(
          //   bottom: 20,
          //   left: 10,
          //   right: 10,
          //   child: Center(
          //     child: AnimatedSmoothIndicator(
          //       activeIndex: max(
          //           ((_scrollCtrl.hasClients ? _scrollCtrl.offset : 0) /
          //                   wordWidth)
          //               .floor(),
          //           0),
          //       count: groups.length,
          //       effect: const ExpandingDotsEffect(
          //         dotWidth: 12,
          //         dotHeight: 8,
          //         expansionFactor: 2,
          //         dotColor: Color.fromRGBO(169, 126, 74, 1),
          //         activeDotColor: Color.fromRGBO(255, 244, 205, 1),
          //       ),
          //     ),
          //   ),
          // )