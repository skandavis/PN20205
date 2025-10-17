import 'package:PN2025/activity.dart';
import 'package:PN2025/category.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/selectableCategoryLabel.dart';
import 'package:PN2025/activityCard.dart';
import 'package:PN2025/globals.dart' as globals;
import 'dart:typed_data';
import 'utils.dart' as utils;

class activitiesPage extends StatefulWidget {
  const activitiesPage({super.key});

  @override
  State<activitiesPage> createState() => _activitiesPageState();
}

class _activitiesPageState extends State<activitiesPage> {
  final TextEditingController searchController = TextEditingController();

  List<Activity> totalActivities = [];
  List<Activity> filteredActivities = [];
  List<ActivityCategory> allCategories = [];
  Map<String, List<Uint8List>> imageCache = {};
  Set<String> selectedCategories = {};

  String _searchQuery = "";
  bool _onlyFavorites = false;
  bool _showOld = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final activityRes = await utils.getMultipleRoute('activities');
      debugPrint("activities: "+activityRes.toString());
      final catRes = await utils.getMultipleRoute('categories');

      totalActivities = activityRes.map((item) => Activity.fromJson(item)).toList();
      allCategories = catRes.map((item) => ActivityCategory.fromJson(item)).toList();


      await _loadAllImages();

      _applyFilters();
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

Future<void> _loadAllImages() async {
  final Map<String, List<Uint8List>> newImageCache = {};

  await Future.wait(totalActivities.map((event) async {
    final String id = event.id;
    if (imageCache.containsKey(id)) {
      // Already loaded
      newImageCache[id] = imageCache[id]!;
      return;
    }

    try {
      final images = [];
      final List<Uint8List> imgBytes = await Future.wait(
        images.map((img) => utils.getImage(img["url"])).toList(),
      );

      newImageCache[id] = imgBytes;
    } catch (e) {
      debugPrint("Failed to load images for event $id: $e");
      newImageCache[id] = [];
    }
  }).toList());

  // Set the updated cache
  setState(() {
    imageCache = newImageCache;
  });
}


  void _applyFilters() {
    final now = DateTime.now();

    setState(() {
      filteredActivities = totalActivities.where((activity) {
        if (_onlyFavorites && !(activity.favoritized)) return false;

        if (!_showOld) {
          final startTime = activity.startTime;
          if (startTime.isBefore(now)) return false;
        }

        if (selectedCategories.isNotEmpty) {
          final category = activity.category;
          if (!selectedCategories.contains(category)) return false;
        }

        if (_searchQuery.isNotEmpty) {
          final name = activity.name.toLowerCase();
          final category = activity.category.toLowerCase();
          if (!name.contains(_searchQuery) && !category.contains(_searchQuery)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  void _toggleFavorites() {
    _onlyFavorites = !_onlyFavorites;
    _applyFilters();
  }

  void _toggleOld() {
    _showOld = !_showOld;
    _applyFilters();
  }

  void _onCategoryChanged(bool selected, ActivityCategory category) {
    if (selected) {
      selectedCategories.add(category.name);
    } else {
      selectedCategories.remove(category.name);
    }
    _applyFilters();
  }

  void _clearFilters() {
    searchController.clear();
    _searchQuery = "";
    _onlyFavorites = false;
    _showOld = false;
    selectedCategories.clear();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterRow(),
        if (allCategories.isNotEmpty) _buildCategoryList(),
        _buildEventList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search events...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                  onPressed: () => _onSearchChanged(""),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildFilterButton(
            icon: Icons.favorite,
            active: _onlyFavorites,
            onTap: _toggleFavorites,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            icon: Icons.lock_clock,
            active: _showOld,
            onTap: _toggleOld,
            color: globals.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = allCategories[index];
          return selectableCategoryLabel(
            category: cat,
            chosen: selectedCategories.contains(cat.name),
            chooseCategory: _onCategoryChanged,
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    return Expanded(
      child: filteredActivities.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: filteredActivities.length,
              itemBuilder: (context, index) {
                final images = imageCache[filteredActivities[index].id] ?? [];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: activityCard(activity: filteredActivities[index], images: images),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    final filtered = _searchQuery.isNotEmpty ||
        selectedCategories.isNotEmpty ||
        _onlyFavorites ||
        _showOld;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(filtered ? Icons.search_off : Icons.event_busy, size: 64, color: Colors.white54),
          const SizedBox(height: 12),
          Text(
            filtered ? "No events match your filters." : "No events available.",
            style: TextStyle(color: Colors.white70),
          ),
          if (filtered)
            TextButton(
              onPressed: _clearFilters,
              child: Text(
                "Clear all filters",
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}
