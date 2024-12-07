import 'package:flutter/material.dart';
import 'upload_database.dart';
import 'download_database.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Color(0xFF3498DB), // Blue theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to the homepage of NewsDb!",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Here you'll find the latest updates on world events, tech, sports, and more.",
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            SizedBox(height: 30),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: UploadDatabase(),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: DownloadDatabase(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
