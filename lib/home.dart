import './profile.dart';
import './search.dart';
import './my_orders.dart';
import 'package:flutter/material.dart';
import './sectionBuilder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BuildBody(),
    const SearchPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Dress Rental",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade700,
        height: 70,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: "Search",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _screens[_selectedIndex],
    );
  }
}

class BuildBody extends StatefulWidget {
  const BuildBody({super.key});

  @override
  State<BuildBody> createState() => _BuildBodyState();
}

class _BuildBodyState extends State<BuildBody> {
  // Define product data for each category
  final Map<String, List<Map<String, dynamic>>> categoryProducts = {
    'couple_dress': [
      {
        'title': 'Traditional Couple Outfit',
        'price': 5999.0,
        'imagePath': 'assets/images/couple_dress/1.jpeg',
      },
      {
        'title': 'Wedding Couple Set',
        'price': 7999.0,
        'imagePath': 'assets/images/couple_dress/2.jpeg',
      },
      {
        'title': 'Elegant Couple Collection',
        'price': 6499.0,
        'imagePath': 'assets/images/couple_dress/3.jpeg',
      },
    ],
    'haldi': [
      {
        'title': 'Yellow Haldi Dress',
        'price': 3999.0,
        'imagePath': 'assets/images/haldi/1.jpeg',
      },
      {
        'title': 'Designer Haldi Outfit',
        'price': 4599.0,
        'imagePath': 'assets/images/haldi/2.jpeg',
      },
      {
        'title': 'Premium Haldi Collection',
        'price': 5299.0,
        'imagePath': 'assets/images/haldi/3.jpeg',
      },
    ],
    'jewellery': [
      {
        'title': 'Bridal Jewellery Set',
        'price': 12999.0,
        'imagePath': 'assets/images/jewellery/1.jpeg',
      },
      {
        'title': 'Wedding Necklace Collection',
        'price': 9999.0,
        'imagePath': 'assets/images/jewellery/2.jpeg',
      },
      {
        'title': 'Designer Earrings',
        'price': 7599.0,
        'imagePath': 'assets/images/jewellery/3.jpeg',
      },
    ],
    'mehendi': [
      {
        'title': 'Green Mehendi Dress',
        'price': 4299.0,
        'imagePath': 'assets/images/mehendi/1.jpeg',
      },
      {
        'title': 'Designer Mehendi Collection',
        'price': 5199.0,
        'imagePath': 'assets/images/mehendi/2.jpeg',
      },
      {
        'title': 'Premium Mehendi Outfit',
        'price': 6099.0,
        'imagePath': 'assets/images/mehendi/3.jpeg',
      },
    ],
    'reception': [
      {
        'title': 'Elegant Reception Dress',
        'price': 8999.0,
        'imagePath': 'assets/images/reception/1.jpeg',
      },
      {
        'title': 'Premium Reception Outfit',
        'price': 10999.0,
        'imagePath': 'assets/images/reception/2.jpeg',
      },
      {
        'title': 'Designer Reception Collection',
        'price': 12599.0,
        'imagePath': 'assets/images/reception/3.jpeg',
      },
    ],
    'wedding': [
      {
        'title': 'Premium Wedding Dress',
        'price': 15999.0,
        'imagePath': 'assets/images/wedding/1.jpeg',
      },
      {
        'title': 'Designer Wedding Outfit',
        'price': 18999.0,
        'imagePath': 'assets/images/wedding/2.jpeg',
      },
      {
        'title': 'Luxury Wedding Collection',
        'price': 21999.0,
        'imagePath': 'assets/images/wedding/3.jpeg',
      },
    ],
  };

  // Function to handle rent button press
  Future<void> _handleRentNow(
    Map<String, dynamic> product,
    String category,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show confirmation dialog
      bool confirm =
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirm Order'),
                  content: Text(
                    'Do you want to rent "${product['title']}" for BDT ${product['price'].toStringAsFixed(2)}?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Rent Now',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
          ) ??
          false;

      if (!confirm) return;

      // Save to Firestore
      final orderData = {
        'title': product['title'],
        'price': product['price'],
        'imagePath': product['imagePath'],
        'category': category,
        'orderedAt': Timestamp.now(),
      };

      // Add to user's orders collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .add(orderData);

      // Update order count in user profile
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'orderCount': FieldValue.increment(1)},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with gradient background and welcome message
          FutureBuilder<DocumentSnapshot>(
            future: _getUserDocument(),
            builder: (context, snapshot) {
              String userName = 'User';

              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null && userData.containsKey('name')) {
                  userName = userData['name'].toString().split(' ')[0];
                }
              }

              return _buildHeaderSection(context, userName);
            },
          ),

          // Categories section
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 25,
              bottom: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "View All",
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),

          // Categories horizontal list
          SizedBox(
            height: 110,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryItem(
                  icon: Icons.people,
                  label: "Couple",
                  color: Colors.pink.shade400,
                ),
                _buildCategoryItem(
                  icon: Icons.diamond_outlined,
                  label: "Wedding",
                  color: Colors.blue.shade400,
                ),
                _buildCategoryItem(
                  icon: Icons.spa_outlined,
                  label: "Mehendi",
                  color: Colors.green.shade400,
                ),
                _buildCategoryItem(
                  icon: Icons.sunny,
                  label: "Haldi",
                  color: Colors.amber.shade400,
                ),
                _buildCategoryItem(
                  icon: Icons.celebration_outlined,
                  label: "Reception",
                  color: Colors.purple.shade400,
                ),
                _buildCategoryItem(
                  icon: Icons.diamond,
                  label: "Jewellery",
                  color: Colors.orange.shade400,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Product sections
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionBuilder(
                  title: "Wedding Collection",
                  category: "wedding",
                  items: categoryProducts['wedding']!,
                  onRentPressed:
                      (product) => _handleRentNow(product, "Wedding"),
                ),

                SectionBuilder(
                  title: "Couple Dresses",
                  category: "couple_dress",
                  items: categoryProducts['couple_dress']!,
                  onRentPressed:
                      (product) => _handleRentNow(product, "Couple Dress"),
                ),

                SectionBuilder(
                  title: "Reception Outfits",
                  category: "reception",
                  items: categoryProducts['reception']!,
                  onRentPressed:
                      (product) => _handleRentNow(product, "Reception"),
                ),

                SectionBuilder(
                  title: "Mehendi Collection",
                  category: "mehendi",
                  items: categoryProducts['mehendi']!,
                  onRentPressed:
                      (product) => _handleRentNow(product, "Mehendi"),
                ),

                SectionBuilder(
                  title: "Haldi Specials",
                  category: "haldi",
                  items: categoryProducts['haldi']!,
                  onRentPressed: (product) => _handleRentNow(product, "Haldi"),
                ),

                SectionBuilder(
                  title: "Premium Jewellery",
                  category: "jewellery",
                  items: categoryProducts['jewellery']!,
                  onRentPressed:
                      (product) => _handleRentNow(product, "Jewellery"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.blue.shade600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade300.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Hello, $userName",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Navigate to profile when clicking avatar
                  final homeState =
                      context.findAncestorStateOfType<_HomeScreenState>();
                  if (homeState != null) {
                    homeState.setState(() {
                      homeState._selectedIndex = 2; // Profile index
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Find your perfect outfit",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search dresses, outfits...",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                suffixIcon: IconButton(
                  icon: Icon(Icons.tune, color: Colors.blue.shade700),
                  onPressed: () {},
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
              ),
              onTap: () {
                // Navigate to search when tapping on search bar
                final homeState =
                    context.findAncestorStateOfType<_HomeScreenState>();
                if (homeState != null) {
                  homeState.setState(() {
                    homeState._selectedIndex = 1; // Search index
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper function to get current user document
  static Future<DocumentSnapshot> _getUserDocument() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
    }

    // Return a placeholder if no user is logged in
    return Future.value(null);
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          setState(() {
            _userData = doc.data() as Map<String, dynamic>;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade800, Colors.blue.shade600],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _userData["name"] ?? "User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData["email"] ?? "",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.shopping_bag_outlined,
                    title: "My Orders",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrdersPage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.history_outlined,
                    title: "Order History",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: "About Us",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.logout,
                    title: "Logout",
                    textColor: Colors.red.shade700,
                    iconColor: Colors.red.shade700,
                    onTap: () {
                      Navigator.pop(context);
                      _handleLogout(context);
                    },
                  ),
                ],
              ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
