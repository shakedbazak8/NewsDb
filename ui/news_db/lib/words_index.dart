import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordsIndex extends StatefulWidget {
  @override
  _WordsIndexState createState() => _WordsIndexState();
}

class _WordsIndexState extends State<WordsIndex> {
  final _formKey = GlobalKey<FormState>();

  List<String> titles = [];
  String? paragraph;
  String? line;

  bool isLoading = false;
  List indices = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchIndices();
  }

  Future<void> fetchIndices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final params = {
        "articles": titles.join(";"),
        "paragraph": paragraph,
        "line": line,
      };

      params.removeWhere((key, value) => value == null || value.isEmpty);

      final uri = Uri.http('localhost:8003', '/index/words', params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          indices = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = "Error: Unable to fetch indices.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addKeyword(String keyword) {
    if (keyword.isNotEmpty && !titles.contains(keyword)) {
      setState(() {
        titles.add(keyword);
      });
    }
  }

  void removeKeyword(String keyword) {
    setState(() {
      titles.remove(keyword);
    });
  }

  Widget buildTitlesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Article"),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: "Add an Article",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            addKeyword(value);
          },
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: titles.map((keyword) {
            return Chip(
              label: Text(keyword),
              onDeleted: () => removeKeyword(keyword),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildIndexList() {
    return ListView.builder(
      itemCount: indices.length,
      itemBuilder: (context, index) {
        final idx = indices[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idx,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Words By Indices"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    buildTextField("Paragraph", (value) => paragraph = value),
                    buildTextField("Line", (value) => line = value),
                    buildTitlesInput(),
                  ],
                ),
              ),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: fetchIndices,
                  child: Text("Search"),
                ),
              if (errorMessage != null) ...[
                SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              Expanded(
                child: indices.isNotEmpty
                    ? buildIndexList()
                    : Text(
                  "No Index found.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
