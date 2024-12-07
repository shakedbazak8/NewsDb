import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordGroup extends StatefulWidget {
  @override
  _WordGroupState createState() => _WordGroupState();
}

class _WordGroupState extends State<WordGroup> {
  String name = '';
  List<String> words = [];
  List<Map<String, dynamic>> wordGroups = [];
  List<String> availableWords = [];
  bool isLoading = false;
  String error = '';

  Future<void> fetchWords() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:8003/groups'));

      if (response.statusCode == 200) {
        List<dynamic> groups = json.decode(response.body);
        setState(() {
          wordGroups = List<Map<String, dynamic>>.from(groups);
        });
      } else {
        setState(() {
          error = 'Failed to fetch words from the API.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching words: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleAddWord(String word) {
    if (word.isNotEmpty && !words.contains(word)) {
      setState(() {
        words.add(word);
      });
    }
  }

  void handleRemoveWord(String wordToRemove) {
    setState(() {
      words.remove(wordToRemove);
    });
  }

  void handleCreateWordGroup() async {
    if (name.isNotEmpty && words.isNotEmpty) {
      final newGroup = {'name': name, 'words': words};

      try {
        final response = await http.post(
          Uri.parse('http://localhost:8003/groups'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newGroup),
        );

        if (response.statusCode == 200) {
          fetchWords();
          setState(() {
            name = '';
            words = [];
          });
        } else {
          setState(() {
            error = 'Failed to create word group.';
          });
        }
      } catch (e) {
        setState(() {
          error = 'Error creating word group: $e';
        });
      }
    } else {
      setState(() {
        error = 'Please provide a name and add some words.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Word Groups')),
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
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Word Group Name',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            TextField(
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  handleAddWord(value);
                }
              },
              decoration: InputDecoration(
                labelText: 'Add Word (Press Enter)',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            Wrap(
              spacing: 8.0,
              children: words.map((word) {
                return Chip(
                  label: Text(word),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () => handleRemoveWord(word),
                );
              }).toList(),
            ),

            isLoading
                ? CircularProgressIndicator()
                : availableWords.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: availableWords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(availableWords[index]),
                    onTap: () => handleAddWord(availableWords[index]),
                  );
                },
              ),
            )
                : Center(child: Text('No available words')),

            ElevatedButton(
              onPressed: handleCreateWordGroup,
              child: Text('Create Word Group'),
            ),

            SizedBox(height: 20),

            if (wordGroups.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: wordGroups.length,
                  itemBuilder: (context, index) {
                    final group = wordGroups[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Wrap(
                              spacing: 8.0,
                              children: (group['words'] as List)
                                  .map<Widget>((word) => Chip(label: Text(word)))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Center(child: Text('No word groups created yet')),
          ],
        ),
      ),
    );
  }
}
