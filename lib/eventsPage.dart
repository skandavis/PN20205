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
  static const int _imagesPerLoad = 10; // Increased for better batching
  static const double _scrollThreshold = 300;
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Data structures
  static List<String> totalCategories = [];
  static List<selectableCategoryLabel> _categoryWidgets = [];
  static final Map<int, List<Uint8List>> _imageCache = {}; // Changed to Map for O(1) lookup
  List<dynamic> shownEvents = [];
  
  // Filter states
  String _searchQuery = "";
  bool _onlyFavorites = false;
  bool _showOld = true;
  Set<String> categoriesChosen = {}; // Changed to Set for O(1) operations
  
  // Loading states
  bool _isLoadingImages = false;
  bool _isInitialized = false;
  int _lastLoadedImageIndex = 0;

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
    if (_isInitialized) return;
    
    try {
      await _loadEventsAndCategories();
      _filterEvents();
      await _loadInitialImages();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  Future<void> _loadEventsAndCategories() async {
    // Load both concurrently
    final futures = await Future.wait([
      _loadEvents(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadEvents() async {
    if (eventsPage.totalEvents.isNotEmpty) return;
    
    try {
      final response = await utils.getRoute('events');
      if (response?.containsKey('events') == true) {
        eventsPage.totalEvents = response!["events"];
      }
    } catch (e) {
      debugPrint("Error loading events: $e");
    }
  }

  Future<void> _loadCategories() async {
    if (totalCategories.isNotEmpty) return;
    
    try {
      final response = await utils.getRoute('categories');
      if (response?.containsKey('categories') == true) {
        final categories = (response!["categories"] as List)
            .map((category) => category["category"] as String)
            .toList();
        
        totalCategories = categories;
        _categoryWidgets = _buildCategoryWidgets();
      }
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

  void _filterEvents() {
    final now = DateTime.now().toLocal();
    final query = _searchQuery.toLowerCase().trim();
    
    shownEvents = eventsPage.totalEvents.where((event) {
      // Favorite filter
      if (_onlyFavorites && !(event["favorite"] ?? false)) return false;
      
      // Time filter  
      if (!_showOld) {
        final startTime = DateTime.parse(event["startTime"]).toLocal();
        if (startTime.isBefore(now)) return false;
      }
      
      // Category filter
      if (categoriesChosen.isNotEmpty) {
        final eventCategory = event["category"]?["category"];
        if (eventCategory == null || !categoriesChosen.contains(eventCategory)) {
          return false;
        }
      }
      
      // Search filter
      if (query.isNotEmpty) {
        final name = event["name"]?.toString().toLowerCase() ?? "";
        final categoryName = event["category"]?["category"]?.toString().toLowerCase() ?? "";
        if (!name.contains(query) && !categoryName.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // Reset image loading state when events change
    _lastLoadedImageIndex = 0;
    
    debugPrint('Filtered: ${shownEvents.length}/${eventsPage.totalEvents.length} events');
  }

  Future<void> _loadInitialImages() async {
    await _loadImagesForRange(0, (_imagesPerLoad).clamp(0, shownEvents.length));
  }

  Future<void> _loadImagesForRange(int startIndex, int endIndex) async {
    if (_isLoadingImages || startIndex >= shownEvents.length) return;
    
    _isLoadingImages = true;
    
    try {
      final futures = <Future<void>>[];
      
      for (int i = startIndex; i < endIndex && i < shownEvents.length; i++) {
        if (!_imageCache.containsKey(shownEvents[i]["id"])) {
          futures.add(_loadEventImages(shownEvents[i]));
        }
      }
      
      if (futures.isNotEmpty) {
        await Future.wait(futures);
        if (mounted) setState(() {});
      }
      
      _lastLoadedImageIndex = endIndex;
    } finally {
      _isLoadingImages = false;
    }
  }

  Future<void> _loadEventImages(dynamic event) async {
    final int eventID = event["id"];
    
    // Skip if already cached
    if (_imageCache.containsKey(eventID)) return;

    try {
      final eventResponse = await utils.getRoute('events/$eventID');
      if (eventResponse?.containsKey('event') != true) {
        _imageCache[eventID] = <Uint8List>[];
        return;
      }
      
      final images = eventResponse!["event"]["images"] as List? ?? [];
      if (images.isEmpty) {
        _imageCache[eventID] = <Uint8List>[];
        return;
      }
      
      // Load images concurrently with error handling
      final imageFutures = images
          .map((img) => utils.getImage(img["url"] as String).catchError((_) => Uint8List(0)))
          .toList();
      
      final loadedImages = await Future.wait(imageFutures);
      final validImages = loadedImages.where((img) => img.isNotEmpty).toList();
      
      _imageCache[eventID] = validImages;
      
    } catch (e) {
      debugPrint('Error loading images for event $eventID: $e');
      _imageCache[eventID] = <Uint8List>[];
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - _scrollThreshold) {
      
      final nextBatchEnd = (_lastLoadedImageIndex + _imagesPerLoad)
          .clamp(0, shownEvents.length);
      
      if (_lastLoadedImageIndex < nextBatchEnd) {
        _loadImagesForRange(_lastLoadedImageIndex, nextBatchEnd);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
      _filterEvents();
    });
  }

  void _updateCategories(bool chosen, String category) {
    setState(() {
      if (chosen) {
        categoriesChosen.add(category);
      } else {
        categoriesChosen.remove(category);
      }
      _categoryWidgets = _buildCategoryWidgets();
      _filterEvents();
    });
  }

  void _toggleFavorites() {
    setState(() {
      _onlyFavorites = !_onlyFavorites;
      _filterEvents();
    });
  }

  void _toggleOld() {
    setState(() {
      _showOld = !_showOld;
      _filterEvents();
    });
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = "";
      _onlyFavorites = false;
      _showOld = false;
      categoriesChosen.clear();
      _categoryWidgets = _buildCategoryWidgets();
      _filterEvents();
    });
  }

  Future<void> _refreshData() async {
    try {
      final response = await utils.getRoute('events');
      if (response?.containsKey('events') == true) {
        setState(() {
          eventsPage.totalEvents = response!["events"];
          _filterEvents();
        });
        
        // Load images for visible events
        await _loadInitialImages();
      }
    } catch (e) {
      debugPrint("Error refreshing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterRow(),
        if (_categoryWidgets.isNotEmpty) _buildCategoryList(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildFilterButton(
            icon: Icons.favorite,
            isActive: _onlyFavorites,
            onTap: _toggleFavorites,
            activeColor: Colors.red,
          ),
          const SizedBox(width: 8),
          _buildFilterButton(
            icon: Icons.lock_clock,
            isActive: _showOld,
            onTap: _toggleOld,
            activeColor: globals.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isActive ? activeColor : Colors.white,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : activeColor,
          size: 24,
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
        itemCount: _categoryWidgets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _categoryWidgets[index],
      ),
    );
  }

  Widget _buildEventsList() {
    return Expanded(
      child: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : shownEvents.isEmpty
              ? _buildEmptyState()
              : _buildEventsListView(),
    );
  }

  Widget _buildEmptyState() {
    final hasActiveFilters = _searchQuery.isNotEmpty || 
                            categoriesChosen.isNotEmpty || 
                            _onlyFavorites || 
                            _showOld;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveFilters ? Icons.search_off : Icons.event_busy,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters 
                ? "No events match your filters."
                : "No events available.",
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
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: shownEvents.length,
        itemBuilder: (context, index) {
          final event = shownEvents[index];
          final images = _imageCache[event["id"]] ?? <Uint8List>[];
          
          return Column(
            children: [
              eventCard(
                event: event,
                images: images,
              ),
              const SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }
}