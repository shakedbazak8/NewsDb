import 'dart:html' as html; // For web-based download functionality
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DownloadDatabase extends StatelessWidget {
  Future<void> handleDownload() async {
    try {
      // Initialize Dio for HTTP requests
      Dio dio = Dio();

      // File URL
      String url = "http://localhost:8003/export-db";

      // Fetch the file from the server
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // Create a Blob and trigger the download
        final blob = html.Blob([response.data], 'application/octet-stream');
        final downloadUrl = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: downloadUrl)
          ..target = 'blank'
          ..download = "backup.xml" // File name for the downloaded file
          ..click();
        html.Url.revokeObjectUrl(downloadUrl); // Clean up the URL
      } else {
        print("Failed to download file: ${response.statusMessage}");
      }
    } catch (error) {
      print("Error downloading file: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Download Database",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 15.0),
          ElevatedButton(
            onPressed: handleDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3498DB), // Blue color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              "Download Database",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
