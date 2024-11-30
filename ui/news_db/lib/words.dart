import 'package:flutter/material.dart';

class Words extends StatefulWidget {
  @override
  _WordsState createState() => _WordsState();
}

class _WordsState extends State<Words> {
  String searchWord = ''; // Search for words
  String searchDefinition = ''; // Search for definitions
  List<Map<String, String>> allWords = [
    {'word': 'JavaScript', 'definition': 'A programming language used to create dynamic web content.'},
    {'word': 'React', 'definition': 'A JavaScript library for building user interfaces.'},
    {'word': 'Node.js', 'definition': 'A JavaScript runtime built on Chrome\'s V8 JavaScript engine.'},
    {'word': 'Frontend', 'definition': 'The part of the website or web application that users interact with.'},
    {'word': 'Backend', 'definition': 'The server-side part of the application that processes data and handles logic.'},
    {'word': 'API', 'definition': 'Application Programming Interface, a set of rules for interacting with software components.'},
  ];

  List<Map<String, String>> filteredWords = []; // Filtered list of words based on search

  @override
  void initState() {
    super.initState();
    filteredWords = allWords; // Initialize with all words
  }

  // Function to filter words based on search parameters
  void filterWords() {
    setState(() {
      filteredWords = allWords.where((word) {
        final wordMatch = word['word']!.toLowerCase().contains(searchWord.toLowerCase());
        final definitionMatch = word['definition']!.toLowerCase().contains(searchDefinition.toLowerCase());
        return wordMatch && definitionMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Words List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search form
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Search Words and Definitions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchWord = value;
                });
                filterWords();
              },
              decoration: InputDecoration(
                labelText: 'Search by Word',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchDefinition = value;
                });
                filterWords();
              },
              decoration: InputDecoration(
                labelText: 'Search by Definition',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: filterWords,
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            // Display the list of filtered words
            Expanded(
              child: filteredWords.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredWords.length,
                itemBuilder: (context, index) {
                  final wordItem = filteredWords[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wordItem['word']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(wordItem['definition']!),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Center(child: Text('No words found')),
            ),
          ],
        ),
      ),
    );
  }
}
