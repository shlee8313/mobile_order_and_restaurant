import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';

class BottomNavigation extends GetView<NavigationController> {
  const BottomNavigation({super.key});

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        icon,
        size: 26,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex,
            onTap: controller.animateToPage,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.home, controller.currentIndex == 0),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                    Icons.document_scanner, controller.currentIndex == 1),
                label: 'QR스캔',
              ),
              BottomNavigationBarItem(
                icon:
                    _buildIcon(Icons.restaurant, controller.currentIndex == 2),
                label: '주문',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.list_alt, controller.currentIndex == 3),
                label: '주문내역',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.person, controller.currentIndex == 4),
                label: '프로필',
              ),
            ],
          )),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import '../controllers/navigation_controller.dart';

// class BottomNavigation extends GetView<NavigationController> {
//   BottomNavigation({super.key});

//   final GlobalKey<CurvedNavigationBarState> _navigationKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return DecoratedBox(
//       decoration: const BoxDecoration(
//         color: Colors.blueAccent,
//       ),
//       child: SizedBox(
//         height: 60,
//         child: Obx(() => CurvedNavigationBar(
//               key: _navigationKey,
//               index: controller.currentIndex,
//               height: 55,
//               items: <Widget>[
//                 _buildCircularIcon(Icons.home, 0),
//                 _buildCircularIcon(Icons.document_scanner, 1),
//                 _buildCircularIcon(Icons.restaurant, 2),
//                 _buildCircularIcon(Icons.list_alt, 3),
//                 _buildCircularIcon(Icons.person, 4),
//               ],
//               color: Colors.white,
//               buttonBackgroundColor: Colors.white,
//               backgroundColor: Colors.blueAccent,
//               animationCurve: Curves.easeInOut,
//               animationDuration: const Duration(milliseconds: 300),
//               onTap: (index) => controller.animateToPage(index),
//               letIndexChange: (index) => true,
//             )),
//       ),
//     );
//   }

//   Widget _buildCircularIcon(IconData icon, int index) {
//     return Obx(() => Padding(
//           padding: const EdgeInsets.only(bottom: 1),
//           child: Icon(
//             icon,
//             size: 30,
//             color:
//                 controller.currentIndex == index ? Colors.black : Colors.black,
//           ),
//         ));
//   }
// }
