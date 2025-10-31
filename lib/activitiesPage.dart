import 'package:PN2025/activity.dart';
import 'package:PN2025/category.dart';
import 'package:PN2025/backgroundDynamicIcon.dart';
import 'package:PN2025/loadingScreen.dart';
import 'package:PN2025/networkService.dart';
import 'package:flutter/material.dart';
import 'package:PN2025/selectableCategoryLabel.dart';
import 'package:PN2025/activityCard.dart';
import 'package:PN2025/globals.dart' as globals;

class activitiesPage extends StatefulWidget {
  const activitiesPage({super.key});

  @override
  State<activitiesPage> createState() => activitiesPageState();
}

class activitiesPageState extends State<activitiesPage> {
  final TextEditingController searchController = TextEditingController();

  List<Activity> filteredActivities = [];
  static List<ActivityCategory>? allCategories;
  Set<String> selectedCategories = {};

  String searchQuery = "";
  bool onlyFavorites = false;
  bool showOld = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadActivities() async {
    if(globals.totalActivities == null)
    {
      final activityRes = await NetworkService().getMultipleRoute('activities');
      if(activityRes == null) return;
      globals.totalActivities = activityRes.map((item) => Activity.fromJson(item)).toList();
    }
  }
  Future<void> loadCategories() async {
    if(allCategories ==null)
    {
      final catRes = await NetworkService().getMultipleRoute('categories');
      if(catRes == null) return;
      allCategories = catRes.map((item) => ActivityCategory.fromJson(item)).toList();
    }
  }
  Future<void> loadData() async {
    await Future.wait([
      loadActivities(),
      loadCategories()
    ]);
    
    applyFilters();    
  }

  void applyFilters() {
    if(globals.totalActivities == null) return;
    final now = DateTime.now();
    setState(() {
      filteredActivities = globals.totalActivities!.where((activity) {
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

  void toggleFavorites(bool value) {
    onlyFavorites = value;
    applyFilters();
  }

  void toggleOld(bool value) {
    showOld = value;
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
    return Column(
      children: [
        buildSearchBar(),
        buildFilterRow(),
        if (allCategories != null) buildCategoryList(),
        buildEventList(),
      ],
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: TextStyle(color: Colors.white,fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize),
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
          backgoundDynamicIcon(
            icon: Icons.favorite,
            active: onlyFavorites,
            onTap: toggleFavorites,
            foregroundColor: Colors.red,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 8),
          backgoundDynamicIcon(
            icon: Icons.lock_clock,
            active: showOld,
            onTap: toggleOld,
            foregroundColor: globals.accentColor,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget buildCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: allCategories!.length,
        separatorBuilder: (_,__ ) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = allCategories![index];
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

    return globals.totalActivities == null ? const loadingScreen() : Center(
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
