import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranTrackerScreen extends StatefulWidget {
  const QuranTrackerScreen({super.key});

  @override
  _QuranTrackerScreenState createState() => _QuranTrackerScreenState();
}

class _QuranTrackerScreenState extends State<QuranTrackerScreen> {
  late String quranName; // Name of the Quran being read
  int totalPages = 604; // Total pages in the Quran
  int pagesRead = 0;
  Set<int> bookmarks = {}; // Set to store bookmarked page numbers

  // List of suggested Muslim books
  List<String> suggestedBooks = [
    'Sahih Al-Bukhari',
    'Sahih Muslim',
    'Riyad as-Salihin',
    'Tafsir Ibn Kathir',
    'The Sealed Nectar',
  ];

  // Book data structure to hold start and finish dates
  Map<String, String?> startDates = {};
  Map<String, String?> finishDates = {};
  Map<String, double> ratings = {};
  Map<String, String> notes = {};
  Map<String, int> currentPages = {}; // Map to store the current page for each book

  Set<String> favoriteBooks = {};
  Set<String> wishlistBooks = {};

  @override
  void initState() {
    super.initState();
    _loadPagesRead();
    quranName = 'Quran'; // Default name, can be set dynamically
    _loadDates();
    _loadFavorites();
    _loadWishlist();
    _loadRatings();
    _loadNotes();
    _loadCurrentPages(); // Load current pages
  }

  _loadPagesRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pagesRead = prefs.getInt('pagesRead') ?? 0;
      // Load bookmarks from SharedPreferences if needed
    });
  }

  void _loadDates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String bookName in suggestedBooks) {
      setState(() {
        startDates[bookName] = prefs.getString('$bookName-startDate');
        finishDates[bookName] = prefs.getString('$bookName-finishDate');
      });
    }
  }

  _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteBooks = prefs.getStringList('favoriteBooks')?.toSet() ?? {};
    });
  }

  _loadWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      wishlistBooks = prefs.getStringList('wishlistBooks')?.toSet() ?? {};
    });
  }

  _loadRatings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String bookName in suggestedBooks) {
        ratings[bookName] = prefs.getDouble('$bookName-rating') ?? 0.0;
      }
    });
  }

  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String bookName in suggestedBooks) {
        notes[bookName] = prefs.getString('$bookName-notes') ?? '';
      }
    });
  }

  _loadCurrentPages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String bookName in suggestedBooks) {
        currentPages[bookName] = prefs.getInt('$bookName-currentPage') ?? 0;
      }
    });
  }

  _updatePagesRead(int pages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pagesRead += pages;
      prefs.setInt('pagesRead', pagesRead);
    });
  }

  _toggleBookmark(int page) {
    setState(() {
      if (bookmarks.contains(page)) {
        bookmarks.remove(page);
      } else {
        bookmarks.add(page);
      }
      // Save bookmarks to SharedPreferences if needed
    });
  }

  _sharePages() {
    // Implement sharing functionality using share package or custom implementation
    // Example:
    // Share.share('I have read $pagesRead pages of $quranName.');
  }

  _toggleFavoriteBook(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteBooks.contains(bookName)) {
        favoriteBooks.remove(bookName);
      } else {
        favoriteBooks.add(bookName);
      }
      prefs.setStringList('favoriteBooks', favoriteBooks.toList());
    });
  }

  _toggleWishlistBook(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (wishlistBooks.contains(bookName)) {
        wishlistBooks.remove(bookName);
      } else {
        wishlistBooks.add(bookName);
      }
      prefs.setStringList('wishlistBooks', wishlistBooks.toList());
    });
  }

  void _logStartDate(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    await prefs.setString('$bookName-startDate', now.toIso8601String());
    setState(() {
      startDates[bookName] = now.toIso8601String();
    });
  }

  void _logFinishDate(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    await prefs.setString('$bookName-finishDate', now.toIso8601String());
    setState(() {
      finishDates[bookName] = now.toIso8601String();
    });
  }

  _updateRating(String bookName, double rating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ratings[bookName] = rating;
      prefs.setDouble('$bookName-rating', rating);
    });
  }

  _updateNotes(String bookName, String note) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes[bookName] = note;
      prefs.setString('$bookName-notes', note);
    });
  }

  _updateCurrentPage(String bookName, int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPages[bookName] = page;
      prefs.setInt('$bookName-currentPage', page);
    });
  }

  _showStatistics() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reading Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pages Read: $pagesRead'),
              Text('Pages Left: ${totalPages - pagesRead}'),
              Text(
                  'Progress: ${(pagesRead / totalPages * 100).toStringAsFixed(2)}%'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quran Tracker - $quranName',
          style: TextStyle(
            fontFamily: 'ArabicFont',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showStatistics,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Quran Reading Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'ArabicFont', // Change to your Arabic font
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Current Reading Books',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 2, // Two sections: Current reading books and suggested books
                itemBuilder: (context, sectionIndex) {
                  if (sectionIndex == 0) {
                    // Display current reading books section
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: currentPages.keys.map((bookName) {
                        bool isBookmarked =
                            bookmarks.contains(currentPages[bookName]);
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              bookName,
                              style: TextStyle(
                                fontFamily: 'Roboto', // Updated to Roboto
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Current Page: ${currentPages[bookName]}',
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked ? Colors.orange : null,
                              ),
                                                          onPressed: () {
                                _toggleBookmark(currentPages[bookName] ?? 0);
                              },
                            ),
                            onTap: () {
                              _showBookDialog(context, bookName);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    // Display suggested books section
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Suggested Books',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: suggestedBooks.length,
                          itemBuilder: (context, index) {
                            String bookName = suggestedBooks[index];
                            bool isFavorite = favoriteBooks.contains(bookName);
                            bool isInWishlist =
                                wishlistBooks.contains(bookName);
                            int currentPage = currentPages[bookName] ?? 0;

                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  bookName,
                                  style: TextStyle(
                                    fontFamily: 'Roboto', // Updated to Roboto
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text('Current Page: $currentPage'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : null,
                                      ),
                                      onPressed: () {
                                        _toggleFavoriteBook(bookName);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isInWishlist
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color:
                                            isInWishlist ? Colors.orange : null,
                                      ),
                                      onPressed: () {
                                        _toggleWishlistBook(bookName);
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _showBookDialog(context, bookName);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookDialog(BuildContext context, String bookName) {
    TextEditingController pageController = TextEditingController(
      text: currentPages[bookName].toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(bookName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Rating (0.0 - 5.0)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  double rating = double.tryParse(value) ?? 0.0;
                  _updateRating(bookName, rating);
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
                maxLines: 3,
                onChanged: (value) {
                  _updateNotes(bookName, value);
                },
              ),
              TextField(
                controller: pageController,
                decoration: InputDecoration(
                  labelText: 'Current Page',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int page = int.tryParse(value) ?? 0;
                  _updateCurrentPage(bookName, page);
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text('Log Start Date'),
                    onPressed: () {
                      _logStartDate(bookName);
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Log Finish Date'),
                    onPressed: () {
                      _logFinishDate(bookName);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
