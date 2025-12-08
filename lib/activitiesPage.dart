import 'package:NagaratharEvents/activity.dart';
import 'package:NagaratharEvents/category.dart';
import 'package:NagaratharEvents/backgroundDynamicIcon.dart';
import 'package:NagaratharEvents/loadingScreen.dart';
import 'package:NagaratharEvents/networkService.dart';
import 'package:flutter/material.dart';
import 'package:NagaratharEvents/selectableCategoryLabel.dart';
import 'package:NagaratharEvents/activityCard.dart';
import 'package:NagaratharEvents/globals.dart' as globals;

class activitiesPage extends StatefulWidget {
  final ValueNotifier<bool> isVisible;
  const activitiesPage({super.key, required this.isVisible});

  @override
  State<activitiesPage> createState() => activitiesPageState();
}

class activitiesPageState extends State<activitiesPage> {
  final searchController = TextEditingController();
  static List<ActivityCategory>? allCategories;
  
  Set<String> selectedCategories = {};
  String searchQuery = "";
  bool onlyFavorites = false;
  bool showOld = false;
  bool isLoading = true;
  bool onlyToday = false;

  @override
  void initState() {
    super.initState();
    widget.isVisible.addListener(_onVisibilityChanged);
  }
  void _onVisibilityChanged() {
    if (widget.isVisible.value) {
      _loadData();
    } else {
      // is not visible
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      if (globals.totalActivities == null) _loadActivities(false),
      if (allCategories == null) _loadCategories(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadActivities(bool forceRefresh) async {
    final data = await NetworkService().getMultipleRoute('activities', forceRefresh: forceRefresh);
    if (data != null) {
      globals.totalActivities = data.map((item) => Activity.fromJson(item)).toList();
    }
  }

  Future<void> _refreshActivities() async {
    await _loadActivities(true);
    if (mounted) setState(() {});
  }

  Future<void> _loadCategories() async {
    final data = await NetworkService().getMultipleRoute('categories');
    if (data != null) {
      allCategories = data
        .map((item) => ActivityCategory.fromJson(item))
        .fold<Map<String, ActivityCategory>>({}, (map, category) {
          map[category.name] = category;
          return map;
        })
    .values
    .toList();

    }
  }

  List<Activity> get _filteredActivities {
    if (globals.totalActivities == null) return [];
    
    final now = DateTime.now();
    final query = searchQuery.toLowerCase();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return globals.totalActivities!.where((activity) {

      if (onlyFavorites && !activity.favoritized) return false;

      if (!showOld && activity.startTime.isBefore(now)) return false;

      if (onlyToday) {
        if (!(activity.startTime.isAfter(today.subtract(const Duration(milliseconds: 1))) &&
              activity.startTime.isBefore(tomorrow))) {
          return false;
        }
      }

      if (selectedCategories.isNotEmpty && !selectedCategories.contains(activity.main)) return false;

      if (query.isNotEmpty && !activity.name.toLowerCase().contains(query) && !activity.category.toLowerCase().contains(query)) return false;

      return true;
    }).toList();
  }

  void _clearFilters() => setState(() {
    searchController.clear();
    searchQuery = "";
    onlyFavorites = false;
    showOld = false;
    onlyToday = false;
    selectedCategories.clear();
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterRow(),
        if (allCategories != null) _buildCategoryList(),
        Expanded(child: isLoading ? loadingScreen() : _buildActivityList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        onChanged: (query) => setState(() => searchQuery = query.toLowerCase().trim()),
        style: TextStyle(color: Colors.white, fontSize: globals.bodyFontSize),
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
          const SizedBox(width: 8),
          backgoundDynamicIcon(
            icon: Icons.today,
            active: onlyToday,
            onTap: (val) => setState(() => onlyToday = val),
            foregroundColor: Colors.blue,
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
            chooseCategory: (selected, category) => setState(() {
              selected ? selectedCategories.add(category.name) : selectedCategories.remove(category.name);
            }),
          );
        },
      ),
    );
  }

  Widget _buildActivityList() {
    List<Activity> activities = _filteredActivities;
    final hasFilters = searchQuery.isNotEmpty || selectedCategories.isNotEmpty || onlyFavorites || showOld;
    
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasFilters ? Icons.search_off : Icons.event_busy, size: 64, color: Colors.white54),
            const SizedBox(height: 12),
            Text(
              hasFilters ? "No activities match your filters." : "No activities available.",
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
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .9,
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: activityCard(
              activity: activities[index], 
            ),
          ),
        ),
      ),
    );
  }
}