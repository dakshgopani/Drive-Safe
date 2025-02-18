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
  final List<Map<String, String>> savedPlaces;
  SearchInput({
    required this.startController,
    required this.destinationController,
    required this.fetchSearchResultsDebounced,
    required this.searchResults,
    required this.selectSearchResult,
    required this.checkAndShowBottomSheet,
    required this.deleteRoadandMarker,
    required this.startLocationTracking,
    required this.savedPlaces,
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
                if (widget.searchResults.isNotEmpty || widget.savedPlaces.isNotEmpty)
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

  // Widget _buildSearchResults(BuildContext context) {
  //   // Combine saved places and search results
  //   final combinedResults = [...widget.savedPlaces, ...widget.searchResults];
  //
  //   return ListView.separated(
  //     shrinkWrap: true,
  //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //     itemCount: combinedResults.length,
  //     separatorBuilder: (context, index) => Divider(
  //       height: 16,
  //       color: Colors.grey[300],
  //       thickness: 1,
  //     ),
  //     itemBuilder: (context, index) {
  //       // Determine if the current item is a saved place or a search result
  //       final isSavedPlace = index < widget.savedPlaces.length;
  //       final result = combinedResults[index];
  //
  //       return ListTile(
  //         contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //         onTap: () {
  //           widget.selectSearchResult(result, _activeController!);
  //           widget.checkAndShowBottomSheet(context, widget.startLocationTracking);
  //         },
  //         leading: Container(
  //           padding: EdgeInsets.all(10),
  //           decoration: BoxDecoration(
  //             color: Colors.blue.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: Icon(
  //             isSavedPlace ? Icons.bookmark : Icons.location_on_outlined,
  //             color: Colors.blue,
  //             size: 28,
  //           ),
  //         ),
  //         title: Text(
  //           result['description'] ?? result['name'] ?? 'Unknown Place',
  //           style: TextStyle(
  //             fontWeight: FontWeight.w600,
  //             fontSize: 18,
  //           ),
  //         ),
  //         subtitle: isSavedPlace
  //             ? Text(
  //           result['formatted_address'] ?? '',
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Colors.grey[600],
  //           ),
  //         )
  //             : null,
  //       );
  //     },
  //   );
  // }

  Widget _buildSearchResults(BuildContext context) {
    // Get the current query from the active controller
    String query = _activeController?.text.toLowerCase() ?? '';

    // Filter saved places based on the query
    List<Map<String, String>> filteredSavedPlaces = widget.savedPlaces.where((place) {
      final name = place['name']?.toLowerCase() ?? '';
      final address = place['formatted_address']?.toLowerCase() ?? '';
      return name.contains(query) || address.contains(query);
    }).toList();

    // Determine the number of items to display
    final int filteredSavedPlacesCount = filteredSavedPlaces.length;
    final int searchResultsCount = widget.searchResults.length;
    final int totalItemCount = filteredSavedPlacesCount + searchResultsCount + (_activeController == widget.startController ? 1 : 0);

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: totalItemCount,
      separatorBuilder: (context, index) => Divider(
        height: 16,
        color: Colors.grey[300],
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        // Display "Your Location" option if applicable
        if (_activeController == widget.startController && index == 0) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            onTap: () {
              widget.selectSearchResult({'description': 'Your Location'}, _activeController!);
            },
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.my_location, color: Colors.blue, size: 28),
            ),
            title: Text(
              'Your Location',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          );
        }

        // Adjust index if "Your Location" is present
        final adjustedIndex = (_activeController == widget.startController) ? index - 1 : index;

        // Display filtered saved places
        if (adjustedIndex < filteredSavedPlacesCount) {
          final place = filteredSavedPlaces[adjustedIndex];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            onTap: () {
              widget.selectSearchResult({
                'description': place['name']!,
                'place_id': place['place_id']!,
              }, _activeController!);
              widget.checkAndShowBottomSheet(context, widget.startLocationTracking);
            },
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.history, color: Colors.blueAccent, size: 28),
            ),
            title: Text(
              place['name']!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              place['formatted_address']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        // Display search results
        final searchResultIndex = adjustedIndex - filteredSavedPlacesCount;
        final result = widget.searchResults[searchResultIndex];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          onTap: () {
            widget.selectSearchResult(result, _activeController!);
            widget.checkAndShowBottomSheet(context, widget.startLocationTracking);

          },
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on_outlined, color: Colors.blueAccent, size: 28),
          ),
          title: Text(
            result['description']!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        );
      },
    );
  }
}
