import 'dart:async';
import 'dart:convert';
import 'package:dictionary/database/myDataBase.dart';
import 'package:dictionary/model/word.dart';
import 'package:dictionary/pages/wordDetails.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF444EC7),
    statusBarColor: Color(0xFFEB6434),
    statusBarBrightness: Brightness.light, // Set the status bar icons to dark
    statusBarIconBrightness:
        Brightness.light, // Set the status bar icons to dark
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //fontFamily: "PTSans",
        useMaterial3: false,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSkeleton = true;
  SqlDb db = SqlDb();
  String randomWord = "";
  late Timer fetchDataTimer;
  late DateTime lastFetchTime = DateTime.now();
  Word myWord = Word(
      value: 'value',
      phonetic: "phonetic",
      audio: 'audio',
      origin: 'origin',
      definitions: ['definition']);
  final TextEditingController searchController = TextEditingController();

  void _showInvalidWordToast() {
    Fluttertoast.showToast(
      msg: "Invalid word",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<List<Map<String, dynamic>>> fetchRecentWords() async {
    // Fetch all rows from 'word' table
    return await db.readData('SELECT * FROM word ORDER BY wordId DESC LIMIT 5');
  }

  Future<void> getWord() async {
    try {
      var req = await http.get(
        Uri.https('random-word-form.herokuapp.com', 'random/noun'),
      );

      print(req.statusCode);

      if (req.statusCode == 200) {
        var jsonData = jsonDecode(req.body);
        setState(() {
          randomWord = jsonData[0];
          print(jsonData[0]);
        });
      }
    } catch (error) {
      setState(() {});
      print("Error fetching word: $error");
    }
  }

  Future<void> getDictionary(String word) async {
    try {
      var req = await http.get(
        Uri.https('api.dictionaryapi.dev', 'api/v2/entries/en/$word'),
      );

      if (req.statusCode == 200) {
        var jsonData = jsonDecode(req.body);

        // Find the first phonetic entry with audio
        String audioUrl = '';
        for (var phonetic in jsonData[0]["phonetics"]) {
          if (phonetic["audio"] != null && phonetic["audio"].isNotEmpty) {
            audioUrl = phonetic["audio"];
            break;
          }
        }

        // Get the phonetic value
        String phoneticValue = jsonData[0]["phonetic"] ?? '';
        // If the phonetic value is still empty, look into phonetics array
        if (phoneticValue.isEmpty) {
          for (var phonetic in jsonData[0]["phonetics"]) {
            if (phonetic["text"] != null && phonetic["text"].isNotEmpty) {
              phoneticValue = phonetic["text"];
              break;
            }
          }
        }

        // Collect all definitions
        List<String> definitions = [];
        for (var meaning in jsonData[0]["meanings"]) {
          for (var definition in meaning["definitions"]) {
            definitions.add(definition["definition"]);
          }
        }

        setState(() {
          myWord = Word(
            value: jsonData[0]["word"],
            phonetic: phoneticValue,
            audio: audioUrl,
            origin: jsonData[0]["origin"] ?? '',
            definitions: definitions,
          );
          isSkeleton = false;
          lastFetchTime = DateTime.now();
        });
      }
    } catch (error) {
      setState(() {});
      print("Error fetching word: $error");
    }

    print(myWord.printIt());
  }

  Future<void> fetchData() async {
    await getWord(); // Await the random word
    await getDictionary(randomWord); // Await fetching data using random word
  }

  void navigateToWordDetails(String word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailsPage(word: word),
      ),
    ).then((value) {
      if (value == "bad") _showInvalidWordToast();

      print("then called"); // Call the function here
    });
  }

  void fetchDataIfNeeded() {
    const fetchTimeout =
        Duration(seconds: 10); // Define your fetch timeout duration

    if (isSkeleton) {
      Duration timeElapsed = DateTime.now().difference(lastFetchTime);
      if (timeElapsed > fetchTimeout) {
        print("Fetching data again due to timeout");
        fetchData();
      }
    }
  }

  @override
  void initState() {
    fetchData(); // Initial data fetch
    fetchDataTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchDataIfNeeded(); // Check every 10 seconds if data fetch is needed
    });
    super.initState();
  }

  @override
  void dispose() {
    fetchDataTimer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: const Color(0xFFEB6434),
              height: MediaQuery.of(context).size.height,
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              child: ClipPath(
                clipper: BottomClipper(),
                child: Container(
                  color: const Color(0xFF444EC7),
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "My english-english dictionary",
                      style: TextStyle(
                          fontFamily: "PTSans",
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search word...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              if (searchController.text.isNotEmpty) {
                                navigateToWordDetails(searchController.text);
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            navigateToWordDetails(value);
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Skeletonizer(
                      enabled: isSkeleton,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WordDetailsPage(word: myWord.value),
                            ),
                          );

                          db.saveRecentLine(
                              myWord.value, myWord.definitions[0]);
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Random word",
                                style: TextStyle(color: Colors.purple),
                              ),
                              Text(
                                myWord.value,
                                style: const TextStyle(
                                    fontFamily: "PTSans",
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                              myWord.phonetic != ""
                                  ? Text(
                                      myWord.phonetic,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                myWord.definitions[0],
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Recents",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 150,
                      child: FutureBuilder(
                        future: fetchRecentWords(),
                        builder: (context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Container();
                          } else {
                            return SizedBox(
                              height: 150,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  String value = snapshot.data![index]['value'];
                                  String description =
                                      snapshot.data![index]['description'];
                                  return Row(
                                    children: [
                                      RecentBox(
                                        tapFunc: () {
                                          navigateToWordDetails(value);
                                        },
                                        value: value,
                                        description: description,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentBox extends StatelessWidget {
  final String value;
  final String description;
  final Function tapFunc;

  const RecentBox({
    required this.value,
    required this.description,
    Key? key,
    required this.tapFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tapFunc();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: "PTSans",
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              description,
              maxLines: 5, // Maximum lines before truncating
              overflow: TextOverflow.ellipsis, // Adds ellipsis when overflow
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 100);
    path.quadraticBezierTo(size.width / 4, 4, size.width, 50);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
