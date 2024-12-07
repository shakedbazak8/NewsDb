import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Phrases extends StatefulWidget {
  @override
  _PhrasesState createState() => _PhrasesState();
}

class _PhrasesState extends State<Phrases> {
  String phrase = "";
  String definition = "";
  List<Map<String, dynamic>> phrasesList = [];
  bool isLoading = false;
  String error = "";

  Future<void> fetchPhrases() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:8003/phrases'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          phrasesList = List<Map<String, dynamic>>.from(data.map((item) {
            return {'phrase': item['phrase'], 'definition': item['definition']};
          }));
        });
      } else {
        setState(() {
          error = "Failed to load phrases.";
        });
      }
    } catch (e) {
      setState(() {
        error = "Error fetching phrases: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handlePhraseChange(String value) {
    setState(() {
      phrase = value;
    });
  }

  void handleDefinitionChange(String value) {
    setState(() {
      definition = value;
    });
  }

  Future<void> handleAddPhrase() async {
    if (phrase.isNotEmpty && definition.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('http://localhost:8003/phrases'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'phrase': phrase, 'definition': definition}),
        );

        fetchPhrases();

        setState(() {
          phrase = "";
          definition = "";
        });
      } catch (e) {
        setState(() {
          error = "Failed to add phrase.";
        });
      }
    } else {
      setState(() {
        error = "Please provide both a phrase and its definition.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPhrases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phrases')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            TextField(
              onChanged: handlePhraseChange,
              decoration: InputDecoration(
                labelText: 'Phrase',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            TextField(
              onChanged: handleDefinitionChange,
              decoration: InputDecoration(
                labelText: 'Definition',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: handleAddPhrase,
              child: Text('Add Phrase'),
            ),

            SizedBox(height: 20),

            if (isLoading)
              Center(child: CircularProgressIndicator()),

            if (!isLoading)
              phrasesList.isNotEmpty
                  ? Expanded(
                child: ListView.builder(
                  itemCount: phrasesList.length,
                  itemBuilder: (context, index) {
                    final item = phrasesList[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['phrase']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(item['definition']!),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
                  : Center(child: Text('No phrases available')),
          ],
        ),
      ),
    );
  }
}
