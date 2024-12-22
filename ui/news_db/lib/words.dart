import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class Words extends StatefulWidget {
  @override
  _WordsState createState() => _WordsState();
}

class _WordsState extends State<Words> {
  final _formKey = GlobalKey<FormState>();

  String? title;
  String? page;
  String? author;
  DateTime? publishDate;
  String? subject;
  String? paperName;
  List<dynamic>? previewData;
  int? previewIndex;
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
      };

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
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          setState(() {
            previewData = data;
            previewIndex = 0;
            previewWord = word;
          });
        } else {
          setState(() {
            previewData = [];
            previewIndex = null;
            errorMessage = "No preview data available for this word.";
          });
        }
      } else {
        setState(() {
          errorMessage = "Error: Unable to fetch word details.";
          previewData = null;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
        previewData = null;
      });
    }
  }


  Widget buildPreviewComponent(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        final textToDisplay = (previewData != null &&
            previewIndex != null &&
            previewIndex! >= 0 &&
            previewIndex! < previewData!.length)
            ? previewData![previewIndex!]
            : "";

        final wordToHighlight = previewWord;

        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Preview",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        previewData = null;
                        previewIndex = null;
                        previewWord = "";
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (previewData != null &&
                  previewIndex != null &&
                  previewIndex! >= 0 &&
                  previewIndex! < previewData!.length) ...[
                Text.rich(
                  _highlightWord(textToDisplay, wordToHighlight),
                  style: TextStyle(fontSize: 16),
                ),
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
                          : null,
                      child: Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: previewIndex! < previewData!.length - 1
                          ? () {
                        setModalState(() {
                          previewIndex = previewIndex! + 1;
                        });
                      }
                          : null,
                      child: Text("Next"),
                    ),
                  ],
                ),
              ],
              if (previewData == null || previewIndex == null)
                Center(child: CircularProgressIndicator()),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }




  TextSpan _highlightWord(String text, String word) {
    if (word.isEmpty) {
      return TextSpan(text: text);
    }

    final wordRegex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    final matches = wordRegex.allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(text: text);
    }

    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return TextSpan(children: spans);
  }







}
