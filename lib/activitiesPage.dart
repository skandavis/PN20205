import 'package:PN2025/activity.dart';
import 'package:PN2025/category.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/selectableCategoryLabel.dart';
import 'package:PN2025/activityCard.dart';
import 'package:PN2025/globals.dart' as globals;
import 'utils.dart' as utils;

class activitiesPage extends StatefulWidget {
  const activitiesPage({super.key});

  @override
  State<activitiesPage> createState() => activitiesPageState();
}

class activitiesPageState extends State<activitiesPage> {
  final TextEditingController searchController = TextEditingController();

  List<Activity> filteredActivities = [];
  static List<ActivityCategory> allCategories = [];
  Set<String> selectedCategories = {};

  String searchQuery = "";
  bool onlyFavorites = false;
  bool showOld = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if(globals.totalActivities.isEmpty)
    {
      final activityRes = await utils.getMultipleRoute('activities');
      debugPrint("activities: $activityRes");
      globals.totalActivities = activityRes.map((item) => Activity.fromJson(item)).toList();
    }
    if(allCategories.isEmpty)
    {
      final catRes = await utils.getMultipleRoute('categories');
      allCategories = catRes.map((item) => ActivityCategory.fromJson(item)).toList();
    }

    applyFilters();    
  }

  void applyFilters() {
    final now = DateTime.now();

    setState(() {
      filteredActivities = globals.totalActivities.where((activity) {
        if (onlyFavorites && !(activity.favoritized)) return false;

        if (!showOld) {
          final startTime = activity.startTime;
          if (startTime.isBefore(now)) return false;
        }

        if (selectedCategories.isNotEmpty) {
          final category = activity.category;
          if (!selectedCategories.contains(category)) return false;
        }

        if (searchQuery.isNotEmpty) {
          final name = activity.name.toLowerCase();
          final category = activity.category.toLowerCase();
          if (!name.contains(searchQuery) && !category.contains(searchQuery)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void onSearchChanged(String query) {
    searchQuery = query.toLowerCase().trim();
    applyFilters();
  }

  void toggleFavorites() {
    onlyFavorites = !onlyFavorites;
    applyFilters();
  }

  void toggleOld() {
    showOld = !showOld;
    applyFilters();
  }

  void onCategoryChanged(bool selected, ActivityCategory category) {
    if (selected) {
      selectedCategories.add(category.name);
    } else {
      selectedCategories.remove(category.name);
    }
    applyFilters();
  }

  void clearFilters() {
    searchController.clear();
    searchQuery = "";
    onlyFavorites = false;
    showOld = false;
    selectedCategories.clear();
    applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*.05,
        title: Text(
          'Activities',
          style: TextStyle(
            fontSize:Theme.of(context).textTheme.displaySmall?.fontSize
          ),
        ),
        backgroundColor: globals.backgroundColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      body: Column(
        children: [
          buildSearchBar(),
          buildFilterRow(),
          if (allCategories.isNotEmpty) buildCategoryList(),
          buildEventList(),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search events...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                  onPressed: () => onSearchChanged(""),
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

  Widget buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          buildFilterButton(
            icon: Icons.favorite,
            active: onlyFavorites,
            onTap: toggleFavorites,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          buildFilterButton(
            icon: Icons.lock_clock,
            active: showOld,
            onTap: toggleOld,
            color: globals.accentColor,
          ),
        ],
      ),
    );
  }

  Widget buildFilterButton({
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

  Widget buildCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: allCategories.length,
        separatorBuilder: (_,__ ) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = allCategories[index];
          return selectableCategoryLabel(
            category: cat,
            chosen: selectedCategories.contains(cat.name),
            chooseCategory: onCategoryChanged,
          );
        },
      ),
    );
  }

  Widget buildEventList() {
    return Expanded(
      child: filteredActivities.isEmpty
          ? buildEmptyState()
          : SizedBox(
            width: MediaQuery.of(context).size.width*.9,
            child: ListView.builder(
                itemCount: filteredActivities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: activityCard(activity: filteredActivities[index]),
                  );
                },
              ),
          ),
    );
  }

  Widget buildEmptyState() {
    final filtered = searchQuery.isNotEmpty ||
        selectedCategories.isNotEmpty ||
        onlyFavorites ||
        showOld;

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
              onPressed: clearFilters,
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
