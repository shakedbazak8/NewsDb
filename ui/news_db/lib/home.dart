import 'package:flutter/material.dart';
import 'upload_database.dart';
import 'download_database.dart';
import 'upload.dart';
import 'search.dart';
import 'word_group.dart';
import 'phrases.dart';
import 'words.dart';
import 'stats.dart';
import 'index.dart';
import 'words_index.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    HomeContent(),
    UploadFile(),
    SearchScreen(),
    WordGroup(),
    Phrases(),
    Words(),
    Stats(),
    Index(),
    WordsIndex(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF42A5F5),
            Color(0xFFE3F2FD),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purple, Colors.blue, Colors.cyan],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: const Text(
                  "NewsDb",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            leading: Builder(
              builder: (context) => Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.purple, Colors.blue, Colors.cyan],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: IconButton(
                    icon: const Icon(Icons.apps, size: 50, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
            ),
          ),
        ),
        drawer: Drawer(
          width: 340,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 150,
                color: Colors.blueGrey,
                child: const Center(
                  child: Text(
                    'Welcome to the NewsDb',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildDrawerItem(Icons.home, 'Home', 0),
              _buildDrawerItem(Icons.upload, 'Upload', 1),
              _buildDrawerItem(Icons.search, 'Search', 2),
              _buildDrawerItem(Icons.edit, 'Word Group', 3),
              _buildDrawerItem(Icons.format_quote, 'Phrase', 4),
              _buildDrawerItem(Icons.text_fields, 'Words', 5),
              _buildDrawerItem(Icons.bar_chart, 'Stats', 6),
              _buildDrawerItem(Icons.menu_book, 'Index', 7),
              _buildDrawerItem(Icons.bookmark, 'Words Index', 8),
            ],
          ),
        ),
        body: _pages[_selectedIndex],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _onItemTapped(index),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Welcome to the homepage of NewsDb!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Explore the latest updates on world events, tech, sports, and more.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.file_upload_outlined,
                  child: UploadDatabase(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.file_download_outlined,
                  child: DownloadDatabase(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required Widget child}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
