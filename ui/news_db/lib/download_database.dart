import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadDatabase extends StatelessWidget {
  Future<void> handleDownload() async {
    try {
      // Request storage permissions
      if (await Permission.storage.request().isGranted) {
        // Initialize Dio for HTTP requests
        Dio dio = Dio();

        // File URL and local save path
        String url = "http://localhost:8003/export-db";
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String savePath = "${appDocDir.path}/backup.xml";

        // Download file
        Response response = await dio.download(
          url,
          savePath,
          options: Options(responseType: ResponseType.bytes),
        );

        if (response.statusCode == 200) {
          print("File downloaded to: $savePath");
          // Optionally, show a success message to the user
        } else {
          print("Failed to download file.");
        }
      } else {
        print("Storage permission denied.");
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
