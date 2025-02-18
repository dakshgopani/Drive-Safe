import 'package:algorithm_avengers_ves_final/screens/drawer/store_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/driving_monitor_screen.dart';
import 'package:flutter/material.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/car_game_page.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/community_chat_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/driving_behaviour_analysis.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/insurance/policy_list_page.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/leaderboard_screen.dart';
import 'package:algorithm_avengers_ves_final/screens/drawer/settings_screen.dart';

class CustomDrawer extends StatefulWidget {
  final String userId;
  final String userName;
  final String email;
  final VoidCallback onSignOut;

  const CustomDrawer({
    Key? key,
    required this.userId,
    required this.userName,
    required this.email,
    required this.onSignOut,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = -1;
  late List<DrawerItem> _menuItems; // Declare the list without initializing it


  @override
  void initState() {
    super.initState();

    // Initialize the menu items here, where widget is accessible
    _menuItems = [
      DrawerItem(
        title: "Drive Analysis",
        icon: Icons.analytics_outlined,
        route: DrivingBehaviorPage(),
        color: Colors.blueAccent,
        category: "Drive & Analysis",
      ),
      DrawerItem(
        title: "Leaderboard",
        icon: Icons.leaderboard_outlined,
        route: LeaderboardScreen(),
        color: Colors.blueAccent,
        category: "Drive & Analysis",
      ),
      DrawerItem(
        title: "Record Drive",
        icon: Icons.fiber_manual_record_outlined,
        route: DrivingMonitorScreen(),
        color: Colors.blueAccent,
        category: "Drive & Analysis",
      ),
      DrawerItem(
        title: "Insurance",
        icon: Icons.security_outlined,
        route: PolicyListPage(),
        color: Colors.blueAccent,
        category: "Services",
      ),
      DrawerItem(
        title: "Performance",
        icon: Icons.speed_outlined,
        color: Colors.blueAccent,
        category: "Services",
      ),
      DrawerItem(
        title: "Simulation",
        icon: Icons.sports_esports_outlined,
        route: CarGamePage(),
        color: Colors.blueAccent,
        category: "Entertainment",
      ),
      DrawerItem(
        title: "Community",
        icon: Icons.forum_outlined,
        route: DriverSafetyChatScreen(),
        color: Colors.blueAccent,
        category: "Entertainment",
      ),
      DrawerItem(
        title: "Store",
        icon: Icons.local_grocery_store_sharp,
        route: StoreScreen(userId: widget.userId), // ✅ No error now
        color: Colors.blueAccent,
        category: "Entertainment",
      ),
      DrawerItem(
        title: "Settings",
        icon: Icons.settings_outlined,
        route: SettingsScreen(),
        color: Colors.blueAccent,
        category: "System",
      ),
    ];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
    _controller.forward();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMenuItems(),
            ),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: [
          // Background design
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blueAccent,
                  Colors.blue.shade600,
                ],
              ),
            ),
          ),
          // Circular decorations
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Profile content
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 16),
                // Profile picture container
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white70,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.userName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // User info
                Text(
                  widget.userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    String? currentCategory;
    List<Widget> menuWidgets = [];
    
    for (int i = 0; i < _menuItems.length; i++) {
      if (currentCategory != _menuItems[i].category) {
        currentCategory = _menuItems[i].category;
        menuWidgets.add(_buildCategoryHeader(currentCategory));
      }
      menuWidgets.add(
        _buildMenuItem(i, _menuItems[i]),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(children: menuWidgets),
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, DrawerItem item) {
    final isSelected = index == _selectedIndex;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.shade50 : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: ListTile(
          onTap: () {
            setState(() => _selectedIndex = index);
            if (item.route != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item.route!),
              );
            }
          },
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: isSelected ? Colors.white : Colors.blueAccent,
              size: 22,
            ),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.black87,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onSignOut,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade400,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerItem {
  final String title;
  final IconData icon;
  final Widget? route;
  final Color color;
  final String category;

  DrawerItem({
    required this.title,
    required this.icon,
    this.route,
    required this.color,
    required this.category,
  });
}

