import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordDetailsPage extends StatefulWidget {
  final String word;

  const WordDetailsPage({Key? key, required this.word}) : super(key: key);

  @override
  _WordDetailsPageState createState() => _WordDetailsPageState();
}

class _WordDetailsPageState extends State<WordDetailsPage> {
  Map<String, dynamic>? wordData;

  @override
  void initState() {
    super.initState();
    fetchWordDetails(widget.word);
  }

  Future<void> fetchWordDetails(String word) async {
    try {
      var req = await http.get(
        Uri.https('api.dictionaryapi.dev', 'api/v2/entries/en/$word'),
      );

      if (req.statusCode == 200) {
        var jsonData = jsonDecode(req.body);
        setState(() {
          wordData = jsonData[0];
        });
      }
    } catch (error) {
      print("Error fetching word: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEB6434),
      body: wordData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        wordData!['word'],
                        style: const TextStyle(
                          fontFamily: "PTSans",
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            wordData!['phonetic'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          wordData!['phonetics'] != null
                              ? Row(
                                  children: wordData!['phonetics']
                                      .where((phonetic) =>
                                          phonetic['audio'] != null &&
                                          phonetic['audio'].isNotEmpty)
                                      .map<Widget>((phonetic) {
                                    return IconButton(
                                      icon: const Icon(Icons.volume_up,
                                          color: Colors.white),
                                      onPressed: () async {
                                        AudioPlayer myAudioPlayer =
                                            AudioPlayer();
                                        late Source audioUrl;
                                        audioUrl = UrlSource(phonetic['audio']);
                                        myAudioPlayer.play(audioUrl);
                                        print("tapped");
                                      },
                                    );
                                  }).toList(),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
                wordData!['meanings'] != null
                    ? Expanded(
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(40),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40)),
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  wordData!['meanings'].map<Widget>((meaning) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${"{" + meaning['partOfSpeech']}}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFEB6434),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: meaning['definitions']
                                            .map<Widget>((definition) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  definition['definition'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                definition['example'] != null
                                                    ? Text(
                                                        'Example: ${definition['example']}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
    );
  }
}
/*wordData!['origin'] != null
                    ? Column(
                        children: [
                          const Text(
                            "Origin",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF444EC7),
                            ),
                          ),
                          Text(
                            wordData!['origin'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),*/