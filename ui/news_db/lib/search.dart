import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();

  String? title;
  String? page;
  String? author;
  DateTime? publishDate;
  String? subject;
  String? paperName;
  List<String> words = [];

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
      String? formattedPublishDate = publishDate != null
          ? DateFormat('yyyy-MM-dd').format(publishDate!)
          : null;

      final params = {
        "title": title,
        "page": page,
        "author": author,
        "publishDate": formattedPublishDate,
        "subject": subject,
        "paperName": paperName,
        "words": words.join(','),
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
    if (keyword.isNotEmpty && !words.contains(keyword)) {
      setState(() {
        words.add(keyword);
      });
    }
  }

  void removeKeyword(String keyword) {
    setState(() {
      words.remove(keyword);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: publishDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != publishDate)
      setState(() {
        publishDate = picked;
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
                    buildDatePicker(),
                    buildTextField("Subject", (value) => subject = value),
                    buildTextField("Paper Name", (value) => paperName = value),
                    buildwordsInput(),
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

  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Publish Date",
              hintText: publishDate == null
                  ? "Select Date"
                  : "${publishDate!.toLocal()}".split(' ')[0],
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(
              text: publishDate == null
                  ? ""
                  : "${publishDate!.toLocal()}".split(' ')[0],
            ),
            readOnly: true,
          ),
        ),
      ),
    );
  }


  Widget buildwordsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Words"),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: "Add a word",
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
          children: words
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
