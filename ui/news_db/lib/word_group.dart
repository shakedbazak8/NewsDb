import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordGroup extends StatefulWidget {
  @override
  _WordGroupState createState() => _WordGroupState();
}

class _WordGroupState extends State<WordGroup> {
  String name = ''; // Group name state
  List<String> words = []; // List to store words (chips)
  List<Map<String, dynamic>> wordGroups = []; // List of word groups
  List<String> availableWords = []; // Available words fetched from API
  bool isLoading = false; // Loading state
  String error = ''; // Error message

  // Fetch words from API
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

  // Handle adding a word to the list
  void handleAddWord(String word) {
    if (word.isNotEmpty && !words.contains(word)) {
      setState(() {
        words.add(word);
      });
    }
  }

  // Handle removing a word from the list
  void handleRemoveWord(String wordToRemove) {
    setState(() {
      words.remove(wordToRemove);
    });
  }

  // Handle form submission to create a new word group
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
          // Refresh word groups
          fetchWords();
          setState(() {
            name = ''; // Clear group name
            words = []; // Clear words list
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

  // Fetch words on initialization
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
            // Error message
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            // Word group name input
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

            // Word input field
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

            // Chips display
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

            // Available words from API
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

            // Create Word Group button
            ElevatedButton(
              onPressed: handleCreateWordGroup,
              child: Text('Create Word Group'),
            ),

            SizedBox(height: 20),

            // Display existing word groups as cards
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
