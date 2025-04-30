import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String welcomeMessage = "Default welcome message";
  bool showBanner = false;

  @override
  void initState() {
    super.initState();
    _fetchRemoteConfigData();
  }


/*  Future<void> _fetchRemoteConfigData() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      // Set default values (optional)
      await remoteConfig.setDefaults(const {
        'welcomeMessage': 'Welcome to our app!',
        'showBanner': true,
      });

      // Fetch and activate new values
      await remoteConfig.fetchAndActivate();

      setState(() {
        welcomeMessage = remoteConfig.getString('welcomeMessage');
        showBanner = remoteConfig.getBool('showBanner');
      });
    } catch (e) {
      debugPrint("Failed to fetch remote config: $e");
    }
  }*/


  Future<void> _fetchRemoteConfigData() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      // Set default values
      await remoteConfig.setDefaults(const {
        'welcomeMessage': 'Default welcome message',
        'showBanner': false,
      });


      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0),
      ));

      // Fetch and activate
      await remoteConfig.fetchAndActivate();

      setState(() {
        welcomeMessage = remoteConfig.getString('welcomeMessage');
        showBanner = remoteConfig.getBool('showBanner');
      });
    } catch (e) {
      debugPrint("Failed to fetch remote config: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Remote Config Example")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showBanner)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blueAccent,
              child: Text(
                welcomeMessage,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          const Text("This text is static."),
        ],
      ),
    );
  }
}
