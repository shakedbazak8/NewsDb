import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Stats extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  List<dynamic> statsData = [];
  bool isLoading = true;
  String error = '';

  Future<void> fetchStats() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8003/stats'));
      if (response.statusCode == 200) {
        setState(() {
          statsData = json.decode(response.body);
        });
      } else {
        setState(() {
          error = 'Failed to load stats';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load stats';
      });
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Map<String, dynamic> getTop10AndRemaining(List<dynamic> histogramData) {
    if (histogramData == null || histogramData.isEmpty) {
      return {'top10': [], 'remainingCount': 0};
    }

    histogramData.sort((a, b) => b['cnt'].compareTo(a['cnt']));
    final top10 = histogramData.take(10).toList();
    final remainingCount = histogramData.length - top10.length;

    return {'top10': top10, 'remainingCount': remainingCount};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : error.isNotEmpty
            ? Center(child: Text(error, style: TextStyle(color: Colors.red)))
            : ListView.builder(
          itemCount: statsData.length,
          itemBuilder: (context, index) {
            final stat = statsData[index];
            final groupsHistogram = getTop10AndRemaining(stat['groups_histogram']);
            final wordsHistogram = getTop10AndRemaining(stat['words_histogram']);

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Words: ${stat['words']}'),
                    Text('Groups: ${stat['groups']}'),
                    Text('Lines: ${stat['lines']}'),
                    Text('Paragraphs: ${stat['paragraphs']}'),
                    SizedBox(height: 15),
                    Text('Groups Histogram:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...groupsHistogram['top10'].map((item) => Text('${item['term']}: ${item['cnt']}')).toList(),
                    if (groupsHistogram['remainingCount'] > 0)
                      Text('And ${groupsHistogram['remainingCount']} more...'),
                    SizedBox(height: 10),
                    Text('Words Histogram:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...wordsHistogram['top10'].map((item) => Text('${item['term']}: ${item['cnt']}')).toList(),
                    if (wordsHistogram['remainingCount'] > 0)
                      Text('And ${wordsHistogram['remainingCount']} more...'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
