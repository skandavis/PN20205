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
  final searchController = TextEditingController();
  static List<ActivityCategory>? allCategories;
  static Map<String, Widget> activityCardCache = {};
  
  Set<String> selectedCategories = {};
  String searchQuery = "";
  bool onlyFavorites = false;
  bool showOld = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final futures = <Future>[];
    if (globals.totalActivities == null) {
      futures.add(_loadActivities(false));
    }
    if (allCategories == null) {
      futures.add(_loadCategories());
    }
    await Future.wait(futures);

    setState(() => isLoading = false);
  }

  Future<void> _loadActivities(bool forceRefresh) async {
    final data = await NetworkService().getMultipleRoute('activities', context, forceRefresh: forceRefresh);
    if (data == null) return;
    
    globals.totalActivities = data.map((item) => Activity.fromJson(item)).toList();
    activityCardCache.clear();
    
    for (var activity in globals.totalActivities!) {
      activityCardCache[activity.id] = Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: activityCard(activity: activity),
      );
    }
  }

  Future<void> _refreshActivities() async {
    await _loadActivities(true);
    setState(() {});
  }

  Future<void> _loadCategories() async {
    if (allCategories != null) return;
    
    final data = await NetworkService().getMultipleRoute('categories', context);
    if (data == null) return;
    
    allCategories = data.map((item) => ActivityCategory.fromJson(item)).toList();
  }

  List<Activity> get _filteredActivities {
    if (globals.totalActivities == null) return [];
    
    return globals.totalActivities!.where((activity) {
      if (onlyFavorites && !activity.favoritized) return false;
      if (!showOld && activity.startTime.isBefore(DateTime.now())) return false;
      if (selectedCategories.isNotEmpty && !selectedCategories.contains(activity.category)) return false;
      
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return activity.name.toLowerCase().contains(query) || 
               activity.category.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      searchController.clear();
      searchQuery = "";
      onlyFavorites = false;
      showOld = false;
      selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterRow(),
        if (allCategories != null) _buildCategoryList(),
        Expanded(
          child: isLoading ? loadingScreen() : _buildActivityList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        onChanged: (query) => setState(() => searchQuery = query.toLowerCase().trim()),
        style: TextStyle(color: Colors.white, fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize),
        decoration: InputDecoration(
          hintText: "Search events...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.8)),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = "");
                  },
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
          backgoundDynamicIcon(
            icon: Icons.favorite,
            active: onlyFavorites,
            onTap: (val) => setState(() => onlyFavorites = val),
            foregroundColor: Colors.red,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 8),
          backgoundDynamicIcon(
            icon: Icons.lock_clock,
            active: showOld,
            onTap: (val) => setState(() => showOld = val),
            foregroundColor: globals.accentColor,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: allCategories!.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = allCategories![index];
          return selectableCategoryLabel(
            category: cat,
            chosen: selectedCategories.contains(cat.name),
            chooseCategory: (selected, category) {
              setState(() {
                selected ? selectedCategories.add(category.name) : selectedCategories.remove(category.name);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = _filteredActivities;
    
    if (activities.isEmpty) {
      final hasFilters = searchQuery.isNotEmpty || selectedCategories.isNotEmpty || onlyFavorites || showOld;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasFilters ? Icons.search_off : Icons.event_busy, size: 64, color: Colors.white54),
            const SizedBox(height: 12),
            Text(
              hasFilters ? "No events match your filters." : "No events available.",
              style: TextStyle(color: Colors.white70),
            ),
            if (hasFilters)
              TextButton(
                onPressed: _clearFilters,
                child: Text("Clear all filters", style: TextStyle(color: Colors.white70)),
              ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshActivities,
      color: globals.accentColor,
      child: Container(
        width: MediaQuery.of(context).size.width * .9,
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) => activityCardCache[activities[index].id]!,
        ),
      ),
    );
  }
}