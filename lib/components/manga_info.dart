import "dart:ui";

import "package:flutter/material.dart";
import "package:karaage/api/models.dart";
import "package:karaage/db/app_database.dart";
import "package:karaage/theme.dart";

class MangaInfoSection extends StatefulWidget {
  final Manga manga;
  const MangaInfoSection({super.key, required this.manga});

  @override
  _MangaInfoSectionState createState() => _MangaInfoSectionState();
}

class _MangaInfoSectionState extends State<MangaInfoSection> {
  bool _isExpanded = false;
  bool _isBookmarked = false; // Track bookmark state

  final AppDatabase db = AppDatabase.instance;

  @override
  void initState() {
    super.initState();
    _fetchBookmarkStatus(); // Load bookmark status when widget initializes
  }

  /// Fetches bookmark status from database
  Future<void> _fetchBookmarkStatus() async {
    try {
      Manga? manga = await db.getMangaById(widget.manga.id);
      if (manga != null) {
        setState(() {
          _isBookmarked = manga.isFavorite;
        });
      }
    } catch (e) {
      print("Error fetching bookmark status: $e");
    }
  }

  /// Toggles bookmark status and updates the database
  Future<void> _toggleBookmark() async {
    try {
      bool newStatus = !_isBookmarked;

      // Update UI
      setState(() {
        _isBookmarked = newStatus;
      });

      // Update Database entry with new fav status
      await db.updateIsFavorite(widget.manga.id, newStatus);
    } catch (e) {
      print("Error updating bookmark status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<KaraageColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                widget.manga.thumbnail,
                width: 120,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Image(
                    image: AssetImage("assets/images/defaultThumbnail.jpg"),
                    width: 120,
                    height: 180,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // About Information Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.manga.hasEnglishName
                        ? widget.manga.englishName!
                        : widget.manga.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 2),

                  // Authors
                  Text(
                    widget.manga.authors.isNotEmpty
                        ? widget.manga.authors[0].toUpperCase()
                        : "N/A",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),

                  const SizedBox(height: 10),

                  // Releasing Status
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.manga.status ?? "N/A",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Average Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        widget.manga.averageScore.toString() != "null"
                            ? "${widget.manga.averageScore} %"
                            : "N/A",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Left-Aligned Square Bookmark Button with Glass Effect
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Rounded edges for the glass effect
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 20,
                          sigmaY: 20,
                        ), // Glass blur effect
                        child: GestureDetector(
                          onTap: _toggleBookmark,
                          child: Container(
                            width: 45, // Square shape
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.2,
                              ), // Transparent white
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              color:
                                  _isBookmarked
                                      ? themeColors.accent
                                      : themeColors.textSecondary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Horizontally Scrollable Genres Section
        SizedBox(
          height: 25,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.manga.genres.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ), // Glass effect
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ), // Light transparent white
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Text(
                      widget.manga.genres.isNotEmpty
                          ? widget.manga.genres[index]
                          : "N/A",
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Summary Header Section
        Text(
          "Summary".toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Expandable Summary Content Section
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.manga.description ?? "N/A",
                  maxLines: _isExpanded ? null : 2,
                  overflow:
                      _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        _isExpanded ? "less" : "more",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
