import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Screen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        selectNotification(response.payload ?? '');
      },
    );
  }

  Future<void> selectNotification(String payload) async {
    debugPrint('notification payload: $payload');
  }


  void _logout() {
    // Implement logout functionality here
    debugPrint('User logged out');
  }

  void _navigateTo(String page) {
    // Implement navigation to different settings pages here
    debugPrint('Navigated to $page');
    // Example navigation logic based on page name
    switch (page) {
      case 'Account':
        // Navigate to Account settings page
        break;
      case 'Email':
        // Navigate to Email settings page
        break;
      case 'Privacy':
        // Navigate to Privacy settings page
        break;
      case 'Help':
        // Navigate to Help settings page
        break;
      case 'Language':
        // Navigate to Language settings page
        break;
      case 'Terms and Conditions':
        // Navigate to Terms and Conditions settings page
        break;
      case 'Data Storage':
        // Navigate to Data Storage settings page
        break;
      default:
        // Handle unknown pages or add more cases
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            _buildDarkModeSection(),
            const SizedBox(height: 16.0),
            _buildNotificationsSection(),
            const Divider(),
            _buildSettingsOption(
              'Account',
              Icons.account_circle,
              [
                _buildSubOption('Profile', Icons.person),
                _buildSubOption('Security', Icons.security),
                _buildSubOption('Change Password', Icons.lock),
              ],
            ),
            _buildSettingsOption(
              'Email',
              Icons.email,
              [
                _buildSubOption('Notifications', Icons.notifications),
                _buildSubOption('Forwarding', Icons.forward),
              ],
            ),
            _buildSettingsOption(
              'Privacy',
              Icons.lock,
              [
                _buildSubOption('Data Privacy', Icons.privacy_tip),
                _buildSubOption('Permissions', Icons.security),
              ],
            ),
            _buildSettingsOption(
              'Help',
              Icons.help,
              [
                _buildSubOption('FAQ', Icons.fax),
                _buildSubOption('Contact Us', Icons.contact_mail),
              ],
            ),
            _buildSettingsOption(
              'Language',
              Icons.language,
              [
                _buildSubOption('Select Language', Icons.language),
                _buildSubOption('Region', Icons.language),
              ],
            ),
            _buildSettingsOption(
              'Terms and Conditions',
              Icons.description,
              [
                _buildSubOption('Terms of Use', Icons.description),
                _buildSubOption('Privacy Policy', Icons.privacy_tip),
              ],
            ),
            _buildSettingsOption(
              'Data Storage',
              Icons.storage,
              [
                _buildSubOption('Manage Storage', Icons.storage),
                _buildSubOption('Clear Cache', Icons.delete),
              ],
            ),
            const Divider(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(String title, IconData icon, List<Widget> subOptions) {
    return ExpansionTile(
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: subOptions,
    );
  }

  Widget _buildSubOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        // Handle sub-option tap
        debugPrint('Navigated to sub-option: $title');
        if (title == 'Change Password') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
          );
        }
      },
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      leading: const Icon(
        Icons.logout,
      ),
      title: const Text(
        'Logout',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: _logout,
    );
  }

  Widget _buildDarkModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dark Mode',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        SwitchListTile(
          title: const Text('Enable Dark Mode'),
          value: _isDarkMode,
          onChanged: (bool value) async {
            setState(() {
              _isDarkMode = value;
            });
            if (value) {
              final position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);
              final sunriseSunset =
                  await _getSunriseSunset(position.latitude, position.longitude);
              final sunrise = sunriseSunset['sunrise'];
              final sunset = sunriseSunset['sunset'];
              final now = DateTime.now();
              if (now.isBefore(sunrise!) || now.isAfter(sunset!)) {
                // Enable dark mode logic
                debugPrint('Enabling Dark Mode');
              } else {
                // Disable dark mode logic
                debugPrint('Disabling Dark Mode');
              }
            }
          },
        ),
        const SizedBox(height: 16.0),
        Text(
          'Dark Mode Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ListTile(
          title: const Text('Automatic Dark Mode based on Sunset/Sunrise'),
          subtitle: const Text('Automatically switch based on your location'),
          onTap: () {
            // Navigate to detailed dark mode settings page
            _navigateTo('Dark Mode Settings');
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          value: _notificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        const SizedBox(height: 16.0),
        Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ListTile(
          title: const Text('Customize Notification Preferences'),
          subtitle: const Text('Configure how notifications appear'),
          onTap: () {
            // Navigate to detailed notification settings page
            _navigateTo('Notification Settings');
          },
        ),
      ],
    );
  }

  Future<Map<String, DateTime>> _getSunriseSunset(
      double latitude, double longitude) async {
    // Implement your sunrise and sunset API call here
     // For now, return dummy data
    final now = DateTime.now();
    return {
      'sunrise': DateTime(now.year, now.month, now.day, 6, 0),
      'sunset': DateTime(now.year, now.month, now.day, 18, 0),
    };
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _changePassword() {
    // Implement password change functionality here
    setState(() {
      _isLoading = true;
    });

    // Simulate a network request
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // For demonstration, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPasswordField(_currentPasswordController, 'Current Password'),
            const SizedBox(height: 16.0),
            _buildPasswordField(_newPasswordController, 'New Password'),
            const SizedBox(height: 16.0),
            _buildPasswordField(_confirmPasswordController, 'Confirm New Password'),
            const SizedBox(height: 32.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Change Password'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }
}
