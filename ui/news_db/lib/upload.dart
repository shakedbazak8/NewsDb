import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadFile extends StatefulWidget {
  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  final _formKey = GlobalKey<FormState>();
  String? title, page, author, publishDate, subject, paperName;
  File? selectedFile;
  bool isUploading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      if (file.lengthSync() > 5 * 1024 * 1024) {
        // File size validation
        setState(() {
          errorMessage = "File size should not exceed 5MB.";
        });
      } else {
        setState(() {
          selectedFile = file;
          errorMessage = null; // Clear any previous error
        });
      }
    }
  }

  Future<void> uploadFile() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        errorMessage = "Please fill all fields correctly.";
      });
      return;
    }

    if (selectedFile == null) {
      setState(() {
        errorMessage = "Please select a file to upload.";
      });
      return;
    }

    setState(() {
      isUploading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse('http://localhost:8003/articles'));

      request.fields['article'] = jsonEncode({
        "page": page,
        "author": author,
        "paperName": paperName,
        "subject": subject,
        "publishDate": publishDate,
        "title": title,
      });

      request.files.add(await http.MultipartFile.fromPath('file', selectedFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          successMessage = "File uploaded successfully!";
          selectedFile = null;
        });
      } else {
        setState(() {
          errorMessage = "Error uploading file. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred while uploading the file.";
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload File"),
        backgroundColor: Color(0xFF3498DB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                onChanged: (value) => title = value,
                validator: (value) => value!.isEmpty ? "Title is required" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Page"),
                onChanged: (value) => page = value,
                validator: (value) => value!.isEmpty ? "Page is required" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Author"),
                onChanged: (value) => author = value,
                validator: (value) => value!.isEmpty ? "Author is required" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Publish Date"),
                onChanged: (value) => publishDate = value,
                validator: (value) => value!.isEmpty ? "Publish Date is required" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Subject"),
                onChanged: (value) => subject = value,
                validator: (value) => value!.isEmpty ? "Subject is required" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Paper Name"),
                onChanged: (value) => paperName = value,
                validator: (value) => value!.isEmpty ? "Paper Name is required" : null,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: selectFile,
                child: Text("Select File"),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF3498DB),
                  padding: EdgeInsets.all(16),
                ),
              ),
              if (selectedFile != null)
                Text(
                  "Selected File: ${selectedFile!.path.split('/').last}",
                  style: TextStyle(color: Colors.green),
                ),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              if (successMessage != null)
                Text(
                  successMessage!,
                  style: TextStyle(color: Colors.green),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isUploading ? null : uploadFile,
                child: isUploading ? CircularProgressIndicator() : Text("Upload File"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
