import 'dart:ui';
import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {
  final TextEditingController startController;
  final TextEditingController destinationController;
  final Function(String) fetchSearchResultsDebounced;
  final List<dynamic> searchResults;
  final Function(dynamic result, TextEditingController activeController) selectSearchResult;
  final void Function(BuildContext context, void Function()) checkAndShowBottomSheet;
  final void Function() deleteRoadandMarker;
  final void Function() startLocationTracking;
  SearchInput({
    required this.startController,
    required this.destinationController,
    required this.fetchSearchResultsDebounced,
    required this.searchResults,
    required this.selectSearchResult,
    required this.checkAndShowBottomSheet,
    required this.deleteRoadandMarker,
    required this.startLocationTracking,
  });

  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  FocusNode _startFocusNode = FocusNode();
  FocusNode _destinationFocusNode = FocusNode();
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _activeController = widget.startController; // Initially, startController is active

    // Add listeners to the focus nodes
    _startFocusNode.addListener(() {
      if (_startFocusNode.hasFocus) {
        setState(() {
          _activeController = widget.startController;
        });
      }
    });

    _destinationFocusNode.addListener(() {
      if (_destinationFocusNode.hasFocus) {
        setState(() {
          _activeController = widget.destinationController;
        });
      }
    });
  }

  @override
  void dispose() {
    _startFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Glass-morphic Search Container
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Start Location Field
                            _buildSearchField(
                              controller: widget.startController,
                              focusNode: _startFocusNode,
                              onChanged: (query) {
                                if (query.isNotEmpty && query != "Your location") {
                                  widget.fetchSearchResultsDebounced(query);
                                }
                              },
                              hintText: 'Start location',
                              prefixIcon: Icons.my_location,
                            ),
                            const SizedBox(height: 12),
                            // Destination Location Field with red prefix icon
                            _buildSearchField(
                              controller: widget.destinationController,
                              focusNode: _destinationFocusNode,
                              onChanged: (query) {
                                if (query.isNotEmpty) {
                                  widget.fetchSearchResultsDebounced(query);
                                }
                              },
                              hintText: 'Where to?',
                              prefixIcon: Icons.location_on, // Red prefix icon
                              prefixIconColor: Colors.red, // Set the color to red
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Search Results
                if (widget.searchResults.isNotEmpty)
                  _buildSearchResults(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String) onChanged,
    required String hintText,
    required IconData prefixIcon,
    Color prefixIconColor = Colors.blue, // Added optional color for prefix icon
  }) {
    return GestureDetector(
        onTap: () {
      FocusScope.of(context).requestFocus(focusNode);
    },
      child:Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(prefixIcon, color: prefixIconColor),
          suffixIcon: controller.text.isNotEmpty || focusNode.hasFocus
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              controller.clear();
              widget.searchResults.clear();
              widget.deleteRoadandMarker();
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
      return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4 - MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: widget.searchResults.length + (_activeController == widget.startController ? 1 : 0), // Add 1 if it's the start controller
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              if (_activeController == widget.startController && index == 0) {
                // If it's the start controller and this is the first item, show "Your Location"
                return ListTile(
                  onTap: () {
                    // Handle tap for "Your Location"
                    // You might want to call a specific function or set a specific location
                    widget.selectSearchResult({'description': 'Your Location'}, _activeController!);

                  },
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.my_location, color: Colors.blue), // Icon for "Your Location"
                  ),
                  title: Text('Your Location', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                );
              } else {
                // For other items in search results
                final result = widget.searchResults[index - (_activeController == widget.startController ? 1 : 0)]; // Adjust index
                return ListTile(
                  onTap: () {
                    // Ensure the result goes into the active controller
                    widget.selectSearchResult(result, _activeController!);
                    widget.checkAndShowBottomSheet(context,widget.startLocationTracking);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on_outlined, color: Colors.blue),
                  ),
                  title: Text(result['description']!, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                );
              }
            },
          ),
        ),

      );
  }

}
