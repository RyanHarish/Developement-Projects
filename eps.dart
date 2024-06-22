import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting date

// ignore: unused_import
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
  int age = 0; // New age field
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
      if (dateOfBirth.isNotEmpty) {
        age = _calculateAge(DateFormat('yyyy-MM-dd').parse(dateOfBirth));
      }
    });
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
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
                  : const AssetImage('assets/profile_placeholder.png'),
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
                label: 'Age', value: age.toString(), icon: Icons.cake),
            _buildProfileRow(
                label: 'Location', value: location, icon: Icons.location_on),
            _buildProfileRow(label: 'Address', value: address, icon: Icons.home),
            _buildProfileRow(
                label: 'Phone Number', value: phoneNumber, icon: Icons.phone),
            _buildProfileRow(
                label: 'User ID', value: userId, icon: Icons.perm_identity),
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
                  style: const TextStyle(
                    color: Colors.black87, // Dark black color
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0, // Adjusted font size
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
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
}

// EditProfileScreen for updating profile details
class EditProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final String profilePicUrl;
  final String dateOfBirth;
  final String location;
  final String address;
  final String phoneNumber;
  final String userId;

  const EditProfileScreen({
    required this.username,
    required this.email,
    required this.profilePicUrl,
    required this.dateOfBirth,
    required this.location,
    required this.address,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _profilePicUrlController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _userIdController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _profilePicUrlController = TextEditingController(text: widget.profilePicUrl);
    _dateOfBirthController = TextEditingController(text: widget.dateOfBirth);
    _locationController = TextEditingController(text: widget.location);
    _addressController = TextEditingController(text: widget.address);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
    _userIdController = TextEditingController(text: widget.userId);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _profilePicUrlController.dispose();
    _dateOfBirthController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('profile_pic_url', _profilePicUrlController.text);
    await prefs.setString('date_of_birth', _dateOfBirthController.text);
    await prefs.setString('location', _locationController.text);
    await prefs.setString('address', _addressController.text);
    await prefs.setString('phone_number', _phoneNumberController.text);
    await prefs.setString('user_id', _userIdController.text);
    Navigator.pop(context);
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime initialDate = DateTime.tryParse(_dateOfBirthController.text) ?? DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_usernameController, 'Username', Icons.person),
            _buildTextField(_emailController, 'Email', Icons.email),
                      _buildTextField(_profilePicUrlController, 'Profile Picture URL', Icons.image),
            _buildTextField(_locationController, 'Location', Icons.location_on),
            _buildTextField(_addressController, 'Address', Icons.home),
            _buildTextField(_phoneNumberController, 'Phone Number', Icons.phone),
            _buildTextField(_userIdController, 'User ID', Icons.perm_identity),
            _buildDatePickerField(context, _dateOfBirthController, 'Date of Birth', Icons.date_range),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _selectDateOfBirth(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                controller.text.isEmpty ? 'Select date' : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? Colors.grey : Colors.black,
                  fontSize: 16.0,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

