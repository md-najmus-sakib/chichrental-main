import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'my_orders.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        // Get user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
            _isLoading = false;
          });
        } else {
          // Create a basic profile if it doesn't exist
          await _firestore.collection('users').doc(currentUser.uid).set({
            'email': currentUser.email,
            'name': currentUser.displayName ?? 'User',
            'joinDate': FieldValue.serverTimestamp(),
            'completedOrders': 0,
          });

          // Fetch the newly created profile
          DocumentSnapshot newUserDoc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();

          setState(() {
            _userData = newUserDoc.data() as Map<String, dynamic>;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        
        // Navigate back to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile data';
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    
    if (timestamp is Timestamp) {
      return DateFormat('MMMM yyyy').format(timestamp.toDate());
    }
    
    return 'Recently';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty 
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile header with user info
                      _buildProfileHeader(),

                      const SizedBox(height: 20),

                      // Stats row
                      _buildStatsRow(),

                      const SizedBox(height: 20),

                      // Account settings sections
                      _buildSettingsSection(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 30, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.blue.shade600],
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: const Icon(Icons.person, size: 80, color: Colors.white),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.blue.shade700,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userData["name"] ?? "User",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _userData["email"] ?? "",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Handle edit profile action
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Edit Profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatItem("Member Since", _formatDate(_userData["joinDate"])),
          _buildVerticalDivider(),
          _buildStatItem("Orders Completed", "${_userData["completedOrders"] ?? 0}"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            "Account Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Personal Information
        _buildSettingItem(
          context,
          icon: Icons.person_outline,
          title: "Personal Information",
          subtitle: "Manage your personal details",
          onTap: () {
            // Handle tap action
          },
        ),

        // My Orders
        _buildSettingItem(
          context,
          icon: Icons.shopping_bag_outlined,
          title: "My Orders",
          subtitle: "View history and track current orders",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyOrdersPage()),
            );
          },
        ),

        // Log out
        _buildSettingItem(
          context,
          icon: Icons.logout,
          title: "Logout",
          subtitle: "Sign out of your account",
          showDivider: false,
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
        ),

        const SizedBox(height: 32),

        // Version number
        Center(
          child: Text(
            "Version 1.0.0",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blue.shade700),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(color: Colors.grey.shade200, height: 1, indent: 70),
      ],
    );
  }
}

