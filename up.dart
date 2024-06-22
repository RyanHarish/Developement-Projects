
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:works/eps.dart'; // Import the new edit profile screen

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String username = '';
  String email = '';
  String profilePicUrl = ''; // Assuming profile picture is stored as URL
  String dateOfBirth = '';
  String location = '';
  String address = '';
  String phoneNumber = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      profilePicUrl = prefs.getString('profile_pic_url') ?? '';
      dateOfBirth = prefs.getString('date_of_birth') ?? '';
      location = prefs.getString('location') ?? '';
      address = prefs.getString('address') ?? '';
      phoneNumber = prefs.getString('phone_number') ?? '';
      userId = prefs.getString('user_id') ?? '';
    });
  }

  Future<void> _showEditProfileScreen(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          username: username,
          email: email,
          profilePicUrl: profilePicUrl,
          dateOfBirth: dateOfBirth,
          location: location,
          address: address,
          phoneNumber: phoneNumber,
          userId: userId,
        ),
      ),
    ).then((_) {
      // Handle callback if needed upon returning from edit profile screen
      _loadProfile(); // Reload profile after editing
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileScreen(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: profilePicUrl.isNotEmpty
                  ? NetworkImage(profilePicUrl)
                  : AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 20),
            _buildProfileRow(
                label: 'Username', value: username, icon: Icons.person),
            _buildProfileRow(label: 'Email', value: email, icon: Icons.email),
            _buildProfileRow(
                label: 'Date of Birth',
                value: dateOfBirth,
                icon: Icons.date_range),
            _buildProfileRow(
                label: 'Location', value: location, icon: Icons.location_on),
            _buildProfileRow(label: 'Address', value: address, icon: Icons.home),
            _buildProfileRow(
                label: 'Phone Number', value: phoneNumber, icon: Icons.phone),
            _buildProfileRow(label: 'User ID', value: userId, icon: Icons.perm_identity),
          ],
        ),
      ),
    );
  }
Widget _buildProfileRow(
      {required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).iconTheme.color, // Match icon color with app's theme
            size: 24.0, // Adjusted icon size
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black87, // Dark black color
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0, // Adjusted font size
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87, // Dark black color
                    fontSize: 16.0, // Adjusted font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showeps(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          username: username,
          email: email,
          profilePicUrl: profilePicUrl,
          dateOfBirth: dateOfBirth,
          location: location,
          address: address,
          phoneNumber: phoneNumber,
          userId: userId,
        ),
      ),
    ).then((_) {
      // Handle callback if needed upon returning from edit profile screen
      _loadProfile(); // Reload profile after editing
    });
  }

  Widget eps (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileScreen(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: profilePicUrl.isNotEmpty
                  ? NetworkImage(profilePicUrl)
                  : AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 20),
            _buildProfileRow(
                label: 'Username', value: username, icon: Icons.person),
            _buildProfileRow(label: 'Email', value: email, icon: Icons.email),
            _buildProfileRow(
                label: 'Date of Birth',
                value: dateOfBirth,
                icon: Icons.date_range),
            _buildProfileRow(
                label: 'Location', value: location, icon: Icons.location_on),
            _buildProfileRow(label: 'Address', value: address, icon: Icons.home),
            _buildProfileRow(
                label: 'Phone Number', value: phoneNumber, icon: Icons.phone),
            _buildProfileRow(label: 'User ID', value: userId, icon: Icons.perm_identity),
          ],
        ),
      ),
    );
  }
}

  
