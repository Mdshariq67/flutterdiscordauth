import 'dart:convert';
import 'dart:math';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

String generateCodeVerifier() {
  const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  return List.generate(
      128, (i) => _charset[Random.secure().nextInt(_charset.length)]).join();
}

String generateCodeChallenge(String codeVerifier) {
  var bytes = ascii.encode(codeVerifier);
  var digest = sha256.convert(bytes);
  String codeChallenge = base64Url
      .encode(digest.bytes)
      .replaceAll("=", "")
      .replaceAll("+", "-")
      .replaceAll("/", "_");
  return codeChallenge;
}

class DiscordAuth {
  Future<void> startDiscordLogin(
      String codeChallenge, String codeverifier) async {
    final authorizationUrl = Uri.https(
      'discord.com',
      '/api/oauth2/authorize',
      {
        'response_type': 'code',
        'client_id': 'your_client_id',
        'scope': 'identify email',
        'redirect_uri': 'your_redirect_uri',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );
    print("++++++++");
    print(authorizationUrl.toString());
    try {
      final result = await FlutterWebAuth.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: 'your_scheme',
      );
      final authorizationCode = Uri.parse(result).queryParameters['code'];
      print(authorizationCode);
      final code =
          await exchangeCodeForAccessToken(authorizationCode!, codeverifier);
      final profiledata = await fetchUserProfile(code);
      return profiledata;
    } catch (e) {
      print(e);
    }

    // Extract the authorization code
  }

  Future<String> exchangeCodeForAccessToken(
      String authorizationCode, String codeverifier) async {
    final tokenUri = Uri.https('discord.com', '/api/oauth2/token');
    final response = await http.post(
      tokenUri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': 'your_client_id',
        'client_secret': 'your_client_secret',
        'grant_type': 'authorization_code',
        'code': authorizationCode,
        'redirect_uri': 'your_redirect_uri',
        'scope': 'identify',
        "code_verifier": codeverifier
      },
    );
    print("PPPPP");

    if (response.statusCode == 200) {
      final accessToken = json.decode(response.body)['access_token'];
      return accessToken;
    } else {
      throw Exception('Failed to exchange code for access token');
    }
  }

  Future<void> fetchUserProfile(String accessToken) async {
    final userProfileUri = Uri.https('discord.com', '/api/v10/users/@me');
    final response = await http.get(
      userProfileUri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      final username = userData['username'];
      final email = userData['email'];
      final avatarHash = userData['avatar'];
      final id = userData['id'];
      print(userData);
      final avatarUrl =
          'https://www.linkedin.com/redir/general-malware-page?url=https%3A%2F%2Fcdn%2ediscordapp%2ecom%2Favatars%2F%24%7BuserData%5Bid]}/$avatarHash.png';
      // Now you can use this data in your app
      print(avatarUrl);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }
}
