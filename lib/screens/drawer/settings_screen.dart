import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedUnit = 'Kilometers';

  final List<String> _languages = ['English', 'Spanish', 'French', 'Hindi'];
  final List<String> _units = ['Kilometers', 'Miles'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkModeEnabled ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        title: Text(
          "Settings", 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App Preferences Section
          _buildSectionTitle("App Preferences", context),
          _buildSwitchTile(
            "Dark Mode", 
            _darkModeEnabled, 
            (value) => setState(() => _darkModeEnabled = value),
            context,
          ),
          _buildDropdownTile(
            "Language", 
            _selectedLanguage, 
            _languages, 
            (value) => setState(() => _selectedLanguage = value!),
            context,
          ),
          _buildDropdownTile(
            "Distance Unit", 
            _selectedUnit, 
            _units, 
            (value) => setState(() => _selectedUnit = value!),
            context,
          ),

          Divider(color: Colors.blueAccent.shade100),

          // Notifications Section
          _buildSectionTitle("Notifications", context),
          _buildSwitchTile(
            "Enable Notifications", 
            _notificationsEnabled, 
            (value) => setState(() => _notificationsEnabled = value),
            context,
          ),
          _buildListTile(
            Icons.notifications_active, 
            "Notification Preferences", 
            () {}, 
            context,
          ),

          Divider(color: Colors.blueAccent.shade100),

          // Driving Behavior Section
          _buildSectionTitle("Driving Behavior", context),
          _buildListTile(
            Icons.speed, 
            "Speed Alerts", 
            () {}, 
            context,
          ),
          _buildListTile(
            Icons.directions_car, 
            "Driving Habits Analysis", 
            () {}, 
            context,
          ),
          _buildListTile(
            Icons.eco, 
            "Eco-Driving Tips", 
            () {}, 
            context,
          ),

          Divider(color: Colors.blueAccent.shade100),

          // Account Section
          _buildSectionTitle("Account", context),
          _buildListTile(
            Icons.person, 
            "Manage Profile", 
            () {}, 
            context,
          ),
          _buildListTile(
            Icons.lock, 
            "Change Password", 
            () {}, 
            context,
          ),
          _buildListTile(
            Icons.help, 
            "Support", 
            () {}, 
            context,
          ),
          _buildListTile(
            Icons.logout, 
            "Logout", 
            () => _logout(context), 
            context,
          ),
          _buildListTile(
            Icons.delete, 
            "Delete Account", 
            () => _showDeleteAccountDialog(context), 
            context,
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    // Navigate to login screen
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement account deletion logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title, 
    bool value, 
    Function(bool) onChanged, 
    BuildContext context,
  ) {
    return ListTile(
      title: Text(
        title, 
        style: TextStyle(
          color: _darkModeEnabled ? Colors.white : Colors.black,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: Colors.blueAccent,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title, 
    String selectedValue, 
    List<String> options, 
    Function(String?) onChanged,
    BuildContext context,
  ) {
    return ListTile(
      title: Text(
        title, 
        style: TextStyle(
          color: _darkModeEnabled ? Colors.white : Colors.black,
        ),
      ),
      trailing: DropdownButton<String>(
        value: selectedValue,
        dropdownColor: _darkModeEnabled ? Colors.grey[800] : Colors.white,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color: _darkModeEnabled ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile(
    IconData icon, 
    String title, 
    VoidCallback onTap, 
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(
        icon, 
        color: Colors.blueAccent,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _darkModeEnabled ? Colors.white : Colors.black,
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios, 
        size: 16, 
        color: Colors.grey,
      ),
    );
  }
}