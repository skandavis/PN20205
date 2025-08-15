import 'package:flutter/material.dart';
import 'package:PN2025/selectableCategoryLabel.dart';
import 'package:PN2025/event.dart';
import 'package:PN2025/globals.dart' as globals;
import 'dart:typed_data';
import 'utils.dart' as utils;

class eventsPage extends StatefulWidget {
  static List<dynamic> totalEvents = [];
  const eventsPage({super.key});

  @override
  State<eventsPage> createState() => _eventsPageState();
}

class _eventsPageState extends State<eventsPage> {
  static const int _imagesPerLoad = 5;
  static const double _scrollThreshold = 200;
  
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static List<String> totalCategories = [];
  List<selectableCategoryLabel> _categoryWidgets = [];
  static List<List<Uint8List>> totalImages = [];
  List<List<Uint8List>> shownImages = [];
  static final List<int> _imageIDs = [];
  List<dynamic> shownEvents = [];
  String _searchQuery = "";
  bool _onlyFavorites = false;
  bool _showOld = false;
  List<String> categoriesChosen = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    loadEvents().then((_)async{
      await Future.wait([
        _loadCategoriesIfNeeded(),
        _loadInitialData(),
      ]);
    });
  }

  Future<void> loadEvents() async
  {
    if(eventsPage.totalEvents.isNotEmpty) return;
    
    try {
      final response = await utils.getRoute('events');
      if(response == null) {
        return;
      }
      eventsPage.totalEvents = response["events"];
      debugPrint(eventsPage.totalEvents.toString());
    } catch (e) {
      debugPrint("error loading event data: $e");
    }
  }

  Future<void> _loadCategoriesIfNeeded() async {
    if (categoriesChosen.isNotEmpty) return;
    
    try {
      final response = await utils.getRoute('categories');
      if(response == null)
      {
        return;
      }
      final categories = (response["categories"] as List)
          .map((category) => category["category"] as String)
          .toList();
      
      if (!mounted) return;
      
      setState(() {
        totalCategories
          ..clear()
          ..addAll(categories);
        
        _categoryWidgets = _buildCategoryWidgets();
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  List<selectableCategoryLabel> _buildCategoryWidgets() {
    return totalCategories
        .map((category) => selectableCategoryLabel(
              label: category,
              chooseCategory: _updateCategories,
              chosen: categoriesChosen.contains(category),
            ))
        .toList();
  }

  Future<void> _loadInitialData() async {
    try {
      _filterEvents();
      await _loadImages();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  Future<void> _loadImages() async {
    if (_isLoading) return;
    
    final startIndex = shownImages.length;
    final endIndex = (startIndex + _imagesPerLoad)
        .clamp(0, shownEvents.length);
    
    if (startIndex >= endIndex) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _loadImagesInRange(startIndex, endIndex);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadImagesInRange(int startIndex, int endIndex) async {
    final futures = <Future<void>>[];
    
    for (int i = startIndex; i < endIndex; i++) {
      futures.add(_loadEventImages(i));
    }
    
    await Future.wait(futures);
  }

  Future<void> _loadEventImages(int eventIndex) async {
    final dynamic eventID = shownEvents[eventIndex]["id"];
    
    // Check cache first
    final int cachedIndex = _imageIDs.indexOf(eventID);
    if (cachedIndex != -1) {
      shownImages.add(totalImages[cachedIndex]);
      return;
    }

    try {
      debugPrint("loading image number$eventIndex");
      final eventResponse = await utils.getRoute('events/$eventID');
      if(eventResponse ==null) return;
      final images = eventResponse["event"]["images"] as List? ?? [];
      
      final imageFutures = images
          .map((img) => utils.getImage(img["url"] as String))
          .toList();
      
      final loadedImages = await Future.wait(imageFutures);
      final validImages = loadedImages
          .where((img) => img.isNotEmpty)
          .toList();

      totalImages.add(validImages);
      _imageIDs.add(eventID);
      shownImages.add(validImages);
      
    } catch (e) {
      debugPrint('Error loading images for event $eventIndex: $e');
      shownImages.add(<Uint8List>[]);
    }
  }

  Future<void> _refreshData() async {
    shownImages.clear();
    await _loadImages();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _scrollThreshold) {
      _loadImages();
    }
  }

  void _filterEvents() {
    shownEvents.clear();
    
    for (final event in eventsPage.totalEvents) {
      if (!_matchesFilters(event)) continue;
      shownEvents.add(event);
    }
    
    _logFilterResults();
  }

  bool _matchesFilters(Map<String, dynamic> event) {
    return _matchesFavoriteFilter(event) &&
           _matchesCategoryFilter(event) &&
           _matchesSearchFilter(event) &&
           _matchesTimeFilter(event);
  }

  bool _matchesFavoriteFilter(Map<String, dynamic> event) {
    return !_onlyFavorites || (event["favorite"]);
  }

  bool _matchesTimeFilter(Map<String, dynamic> event){
    bool isOld = DateTime.parse(event["startTime"]).toLocal().isBefore(DateTime.now().toLocal());
    return _showOld || !isOld;
  }

  bool _matchesCategoryFilter(Map<String, dynamic> event) {
    if (categoriesChosen.isEmpty) return true;
    
    final eventCategory = event["category"]?["category"];
    return eventCategory != null && 
           categoriesChosen.contains(eventCategory);
  }

  bool _matchesSearchFilter(Map<String, dynamic> event) {
    if (_searchQuery.isEmpty) return true;
    
    final query = _searchQuery.toLowerCase().trim();
    
    // Search in name
    final name = event["name"]?.toString().toLowerCase() ?? "";
    if (name.contains(query)) return true;
    
    // Search in category
    final categoryName = event["category"]?["category"]?.toString().toLowerCase() ?? "";
    return categoryName.contains(query);
  }

  void _logFilterResults() {
    debugPrint('Filtered events: ${shownEvents.length}/${eventsPage.totalEvents.length}');
    debugPrint('Search: "$_searchQuery", Categories: $categoriesChosen, Favorites: $_onlyFavorites');
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query.trim());
    _filterEvents();
    _refreshData();
  }

  void _updateCategories(bool chosen, String category) {
    setState(() {
      if (chosen) {
        categoriesChosen.add(category);
      } else {
        categoriesChosen.remove(category);
      }
      _categoryWidgets = _buildCategoryWidgets();
    });

    _filterEvents();
    _refreshData();
  }

  void _toggleFavorites() {
    setState(() {
      _onlyFavorites = !_onlyFavorites;
      _filterEvents();
    });
    _refreshData();
  }

  void _toggleOld() {
    setState(() {
      _showOld = !_showOld;
      _filterEvents();
    });
    _refreshData();
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = "";
      _onlyFavorites = false;
      categoriesChosen.clear();
      _categoryWidgets = _buildCategoryWidgets();
    });
    _filterEvents();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterRow(),
        _buildCategoryList(),
        _buildEventsList(),
      ],
    );
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _toggleFavorites,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: _onlyFavorites ? Colors.red : Colors.white,
            ),
            child: Icon(
              Icons.favorite,
              color: _onlyFavorites ? Colors.white : Colors.red,
              size: 24,
            ),
          ),
        ),
        SizedBox(width: 5,),
        GestureDetector(
          onTap: _toggleOld,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: _showOld ? globals.accentColor : Colors.white,
            ),
            child: Icon(
              Icons.lock_clock,
              color: _showOld ? Colors.white : globals.accentColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: _categoryWidgets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _categoryWidgets[index],
      ),
    );
  }

  Widget _buildEventsList() {
    return Expanded(
      child: shownEvents.isEmpty
          ? _buildEmptyState()
          : _buildEventsListView(),
    );
  }

  Widget _buildEmptyState() {
    final hasActiveFilters = _searchQuery.isNotEmpty || 
                            categoriesChosen.isNotEmpty || 
                            _onlyFavorites;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters 
                ? "No events match your filters."
                : "No events found.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                "Clear all filters",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsListView() {
    debugPrint("here");
  return RefreshIndicator(
    onRefresh: () async{
    try {
      final response = await utils.getRoute('events');
      if(response == null) {
        return;
      }
      setState(() {
        eventsPage.totalEvents = response["events"];
        _filterEvents();
      });
    } catch (e) {
      debugPrint("error loading event data: $e");
    }
    },
    child: ListView.builder(
        controller: _scrollController,
        itemCount: shownEvents.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < shownEvents.length) {
            // Ensure we have images for this index
            final images = index < shownImages.length 
                ? shownImages[index] 
                : <Uint8List>[];
                
            return Column(
              children: [
                eventCard(
                  event: shownEvents[index],
                  images: images,
                ),
                const SizedBox(height: 25),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
  );
  }
}