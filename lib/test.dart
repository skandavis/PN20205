import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() => runApp(MaterialApp(home: HighlightVisibleItems()));

class HighlightVisibleItems extends StatefulWidget {
  const HighlightVisibleItems({super.key});

  @override
  _HighlightVisibleItemsState createState() => _HighlightVisibleItemsState();
}

class _HighlightVisibleItemsState extends State<HighlightVisibleItems> {
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();

  Set<int> _visibleIndices = {};

  @override
  void initState() {
    super.initState();

    itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  void _onScroll() {
    final positions = itemPositionsListener.itemPositions.value;
    final visible = positions
        .where((item) => item.itemTrailingEdge > 0 && item.itemLeadingEdge < 1)
        .map((e) => e.index)
        .toSet();

    // Only rebuild if visibility has changed
    if (visible.difference(_visibleIndices).isNotEmpty ||
        _visibleIndices.difference(visible).isNotEmpty) {
      setState(() {
        _visibleIndices = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visible Item Highlighter')),
      body: ScrollablePositionedList.builder(
        itemCount: 50,
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemBuilder: (context, index) {
          final isVisible = _visibleIndices.contains(index);
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            color: isVisible ? Colors.blue[100] : Colors.grey[300],
            height: 80,
            alignment: Alignment.center,
            child: Text(
              'Item $index',
              style: TextStyle(
                fontSize: 20,
                color: isVisible ? Colors.red : Colors.green,
                fontWeight: isVisible ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
