import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import the intl package


class Words extends StatefulWidget {
  @override
  _WordsState createState() => _WordsState();
}

class _WordsState extends State<Words> {
  final _formKey = GlobalKey<FormState>();

  String? title;
  String? page;
  String? author;
  DateTime? publishDate;  // Changed to DateTime
  String? subject;
  String? paperName;
  List<dynamic>? previewData; // Holds detailed data for preview
  int? previewIndex; // Holds the index of the current word in preview
  String previewWord = "";

  bool isLoading = false;
  List words = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchWords();
  }

  Future<void> fetchWords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Format the publishDate as 'YYYY-MM-DD' (yyyy-MM-dd)
      String? formattedPublishDate = publishDate != null
          ? DateFormat('yyyy-MM-dd').format(publishDate!)  // Format as string 'YYYY-MM-DD'
          : null;

      final params = {
        "title": title,
        "page": page,
        "author": author,
        "publishDate": formattedPublishDate,  // Use formatted date
        "subject": subject,
        "paperName": paperName,
      };

      // Remove keys where values are null or empty
      params.removeWhere((key, value) => value == null || value.isEmpty);

      final uri = Uri.http('localhost:8003', '/words', params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          words = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = "Error: Unable to fetch words.";
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

  // Function to show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: publishDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != publishDate)
      setState(() {
        publishDate = picked; // Set DateTime object
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Words"),
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
                  ],
                ),
              ),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: fetchWords,
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
                child: words.isNotEmpty
                    ? buildWordList(context)
                    : Text(
                  "No words found.",
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
        onTap: () => _selectDate(context), // When tapped, open the date picker
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Publish Date",
              hintText: publishDate == null
                  ? "Select Date"
                  : "${publishDate!.toLocal()}".split(' ')[0], // Format DateTime as YYYY-MM-DD
              border: OutlineInputBorder(),
            ),
            // The TextFormField should also reflect changes in the publishDate
            controller: TextEditingController(
              text: publishDate == null
                  ? ""
                  : "${publishDate!.toLocal()}".split(' ')[0], // Display the date in the field
            ),
            readOnly: true, // Prevent manual editing, only date picker should modify it
          ),
        ),
      ),
    );
  }



  Widget buildWordList(BuildContext context) {
    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: Text(
                    word ?? "Untitled",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    showPreview(context, index);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }


  void showPreview(BuildContext context, int index) async {
    await fetchWordDetails(index);
    if (previewData != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => buildPreviewComponent(context),
      );
    }
  }

  Future<void> fetchWordDetails(int index) async {
    try {
      final word = words[index];
      final params = {
        "word": word,
      };
      final uri = Uri.http('localhost:8003', '/preview', params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          previewData = json.decode(response.body);
          previewIndex = index;
          previewWord = word;
        });
      } else {
        setState(() {
          errorMessage = "Error: Unable to fetch word details.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
      });
    }
  }

  Widget buildPreviewComponent(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        final textToDisplay = previewData != null && previewIndex != null
            ? previewData![previewIndex!]
            : ""; // Get the current preview text
        final wordToHighlight = previewWord; // Replace with the word you want to highlight

        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with Exit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Preview", // Title for the preview section
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (previewData != null && previewIndex != null) ...[
                Text.rich(
                  _highlightWord(textToDisplay, wordToHighlight),
                  style: TextStyle(fontSize: 16),
                ), // Display the current item with highlighted word
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: previewIndex! > 0
                          ? () {
                        setModalState(() {
                          previewIndex = previewIndex! - 1;
                        });
                      }
                          : null, // Disable if at the first item
                      child: Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: previewIndex! < previewData!.length - 1
                          ? () {
                        setModalState(() {
                          previewIndex = previewIndex! + 1;
                        });
                      }
                          : null, // Disable if at the last item
                      child: Text("Next"),
                    ),
                  ],
                ),
              ],
              if (previewData == null)
                Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }

  TextSpan _highlightWord(String text, String word) {
    final wordRegex = RegExp(RegExp.escape(word), caseSensitive: false);
    final matches = wordRegex.allMatches(text);

    if (matches.isEmpty) {
      // No match found, return plain text
      return TextSpan(text: text);
    }

    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      // Add the matched word with a yellow background
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));

      // Update the current index to the end of the match
      currentIndex = match.end;
    }

    // Add any remaining text after the last match
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return TextSpan(children: spans);
  }






}
