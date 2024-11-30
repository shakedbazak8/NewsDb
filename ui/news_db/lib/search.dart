import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();

  String? title;
  String? page;
  String? author;
  String? publishDate;
  String? subject;
  String? paperName;
  List<String> keywords = [];

  bool isLoading = false;
  List articles = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final params = {
        "title": title,
        "page": page,
        "author": author,
        "publishDate": publishDate,
        "subject": subject,
        "paperName": paperName,
        "keywords": keywords.join(','),
      };

      params.removeWhere((key, value) => value == null || value.isEmpty);

      final uri = Uri.http('localhost:8003', '/articles', params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          articles = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = "Error: Unable to fetch articles.";
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
    if (keyword.isNotEmpty && !keywords.contains(keyword)) {
      setState(() {
        keywords.add(keyword);
      });
    }
  }

  void removeKeyword(String keyword) {
    setState(() {
      keywords.remove(keyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Articles"),
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
                    buildTextField("Title", (value) => title = value),
                    buildTextField("Page", (value) => page = value),
                    buildTextField("Author", (value) => author = value),
                    buildTextField("Publish Date", (value) => publishDate = value),
                    buildTextField("Subject", (value) => subject = value),
                    buildTextField("Paper Name", (value) => paperName = value),
                    buildKeywordsInput(),
                  ],
                ),
              ),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: fetchArticles,
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
                child: articles.isNotEmpty
                    ? buildArticleList()
                    : Text(
                  "No articles found.",
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

  Widget buildKeywordsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Keywords"),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: "Add a keyword",
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
          children: keywords
              .map((keyword) => Chip(
            label: Text(keyword),
            onDeleted: () => removeKeyword(keyword),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildArticleList() {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'] ?? "Untitled",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Author: ${article['author'] ?? 'Unknown'}"),
                Text("Publish Date: ${article['publishDate'] ?? 'N/A'}"),
                Text("Subject: ${article['subject'] ?? 'N/A'}"),
                Text("Paper Name: ${article['paperName'] ?? 'N/A'}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
