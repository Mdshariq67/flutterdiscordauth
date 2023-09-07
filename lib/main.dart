import 'package:flutter/material.dart';
import 'package:social_share1/discord_login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _codeVerifier;
  late String _codeChallenge;
  @override
  void initState() {
    super.initState();

    _codeVerifier = generateCodeVerifier();
    _codeChallenge = generateCodeChallenge(_codeVerifier);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Social Share'),
        ),
        body: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      try {
                        DiscordAuth()
                            .startDiscordLogin(_codeChallenge, _codeVerifier);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text("Discord")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
