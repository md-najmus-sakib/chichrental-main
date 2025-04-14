import 'package:flutter/material.dart';
import './card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilterOptions = false;
  bool _isSearching = false;
  List<String> _recentSearches = [
    "Wedding dress",
    "Party outfit",
    "Traditional wear",
    "Haldi dress",
  ];

  // Filter values
  RangeValues _priceRange = const RangeValues(500, 10000);
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Wedding",
    "Party",
    "Casual",
    "Traditional",
    "Haldi",
  ];

  // Mock search results (in a real app, this would come from an API or database)
  final List<Map<String, dynamic>> _allDresses = [
    {
      "id": "1",
      "title": "Red Wedding Dress",
      "price": 8500.0,
      "category": "Wedding",
      "imagePath": "assets/image/wedding/1.jpeg",
    },
    {
      "id": "2",
      "title": "Blue Party Dress",
      "price": 3500.0,
      "category": "Party",
      "imagePath": "assets/image/party/1.jpeg",
    },
    {
      "id": "3",
      "title": "Yellow Haldi Outfit",
      "price": 4500.0,
      "category": "Haldi",
      "imagePath": "assets/image/haldi/1.jpeg",
    },
    {
      "id": "4",
      "title": "Traditional Saree",
      "price": 6500.0,
      "category": "Traditional",
      "imagePath": "assets/image/traditional/1.jpeg",
    },
    {
      "id": "5",
      "title": "Casual Summer Dress",
      "price": 2500.0,
      "category": "Casual",
      "imagePath": "assets/image/casual/1.jpeg",
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // Filter based on search query and current filters
    setState(() {
      _isSearching = true;
      _searchResults =
          _allDresses.where((dress) {
            // Apply text search
            final titleMatch = dress["title"].toLowerCase().contains(
              query.toLowerCase(),
            );

            // Apply category filter
            final categoryMatch =
                _selectedCategory == "All" ||
                dress["category"] == _selectedCategory;

            // Apply price filter
            final priceMatch =
                dress["price"] >= _priceRange.start &&
                dress["price"] <= _priceRange.end;

            return titleMatch && categoryMatch && priceMatch;
          }).toList();

      // Add to recent searches if not already there
      if (!_recentSearches.contains(query) && query.isNotEmpty) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Dresses"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for dresses, outfits...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showFilterOptions
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    color: Colors.blue.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilterOptions = !_showFilterOptions;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter options
          if (_showFilterOptions)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Options",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Price Range Slider
                  Row(
                    children: [
                      const Text("Price Range: "),
                      Text(
                        "৳${_priceRange.start.toInt()} - ৳${_priceRange.end.toInt()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 500,
                    max: 10000,
                    divisions: 19,
                    labels: RangeLabels(
                      "৳${_priceRange.start.toInt()}",
                      "৳${_priceRange.end.toInt()}",
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                        if (_searchController.text.isNotEmpty) {
                          _performSearch(_searchController.text);
                        }
                      });
                    },
                  ),

                  // Category Filter
                  const Text("Category:"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _categories.map((category) {
                          return FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                if (_searchController.text.isNotEmpty) {
                                  _performSearch(_searchController.text);
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade700,
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _priceRange = const RangeValues(500, 10000);
                            _selectedCategory = "All";
                            if (_searchController.text.isNotEmpty) {
                              _performSearch(_searchController.text);
                            }
                          });
                        },
                        child: const Text("Reset Filters"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Search results or recent searches
          Expanded(
            child:
                _isSearching ? _buildSearchResults() : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try different keywords or filters",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .53,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final dress = _searchResults[index];
        return ItemCard(
          imagePath: dress["imagePath"],
          title: dress["title"],
          price: dress["price"],
          onRentPressed: () {
            // Handle rent action
          },
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Text(
          "Search for dresses, outfits and more",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Searches",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches = [];
                  });
                },
                child: const Text("Clear All"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(_recentSearches[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.north_west, size: 18),
                    onPressed: () {
                      _searchController.text = _recentSearches[index];
                      _performSearch(_recentSearches[index]);
                    },
                  ),
                  onTap: () {
                    _searchController.text = _recentSearches[index];
                    _performSearch(_recentSearches[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
