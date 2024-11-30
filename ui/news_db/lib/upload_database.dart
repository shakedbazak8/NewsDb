import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb

class UploadDatabase extends StatefulWidget {
  @override
  _UploadDatabaseState createState() => _UploadDatabaseState();
}

class _UploadDatabaseState extends State<UploadDatabase> {
  File? _file; // Holds the selected file (mobile)
  Uint8List? _fileBytes; // Holds the selected file's bytes (web)
  String? _fileName; // Holds the selected file name
  bool _isUploading = false; // Track upload state
  String? _error; // Track error message

  // Handle file selection
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'], // Restrict file selection to XML files
    );

    if (result != null) {
      if (kIsWeb) {
        // Web specific: Use file bytes
        if (result.files.single.bytes != null) {
          setState(() {
            _fileBytes = result.files.single.bytes;
            _fileName = result.files.single.name;
            _error = null; // Clear previous errors
          });
        }
      } else {
        // Mobile specific: Use file path
        if (result.files.single.path != null) {
          setState(() {
            _file = File(result.files.single.path!);
            _error = null; // Clear previous errors
          });
        }
      }
    } else {
      setState(() {
        _error = "No file selected.";
      });
    }
  }

  // Handle file upload
  Future<void> uploadFile() async {
    if (_file == null && _fileBytes == null) {
      setState(() {
        _error = "Please select a file to upload.";
      });
      return;
    }

    if (_file != null && !_file!.path.endsWith(".xml")) {
      setState(() {
        _error = "Please select a valid XML file.";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:8003/import-db'), // Replace with actual endpoint
      );

      // For web, send file as bytes
      if (kIsWeb && _fileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file', // Field name for the file in the request
          _fileBytes!,
          filename: _fileName,
        ));
      } else if (!kIsWeb && _file != null) {
        // For mobile, send file from path
        request.files.add(await http.MultipartFile.fromPath(
          'file', // Field name for the file in the request
          _file!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Database uploaded successfully!")),
        );
        setState(() {
          _file = null; // Reset file state after successful upload
          _fileBytes = null;
          _fileName = null;
        });
      } else {
        setState(() {
          _error = "Error uploading database.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error uploading database: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
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
            "Upload Database",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 15.0),
          ElevatedButton(
            onPressed: pickFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3498DB), // Blue color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              (kIsWeb ? (_fileBytes != null ? "Change File" : "Select File") : (_file != null ? "Change File" : "Select File")),
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
          if (kIsWeb && _fileBytes != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Selected File: $_fileName",
                style: TextStyle(fontSize: 14.0, color: Colors.black54),
              ),
            ),
          if (!kIsWeb && _file != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "Selected File: ${_file!.path.split('/').last}",
                style: TextStyle(fontSize: 14.0, color: Colors.black54),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ),
          SizedBox(height: 15.0),
          ElevatedButton(
            onPressed: _isUploading ? null : uploadFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isUploading ? Colors.grey : Color(0xFF3498DB),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            child: Text(
              _isUploading ? "Uploading..." : "Upload Database",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
