// main.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snake_game/components/ad.dart';
import 'package:snake_game/game_screen.dart';
// import 'package:admob_easy/admob_easy.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const MenuScreen(),
    themeMode: ThemeMode.dark,
    theme: ThemeData.dark().copyWith(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        primary: Colors.green,
      ),
    ),
  ));
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;

  // Dropdown options and selected values
  final List<int> boardSizes = [30, 20, 10];
  final List<String> speedNames = ['Slow', 'Medium', 'Fast'];
  final List<int> speeds = [500, 250, 100];
  int selectedBoardSize = 20;
  String selectedSpeed = 'Medium';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _titleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    MobileAds.instance.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AdRequest request = const AdRequest(keywords: ['car', 'tesla', 'byd', 'ev']);

  void startGame() async {
    _createRewardAd(
      onReward: (ad, reward) {
        print('reward ${reward.type} = ${reward.amount}');
      },
      onClose: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => GameScreen(
                boardSize: selectedBoardSize,
                speed: speeds[speedNames.indexOf(selectedSpeed)]),
          ),
        )
            .then((_) {
          _createInterstitialAd(onClose: () {}, onFail: () {});
        });
      },
      onFail: () {
        print('ads fail to load');
      },
    );
  }

  _createRewardAd(
      {required Function() onClose,
      required Function() onFail,
      required OnUserEarnedRewardCallback onReward}) {
    // RewardedAd.load(
    //   adUnitId: 'ca-app-pub-3940256099942544/5224354917',
    //   request: request,
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       ad
    //         ..setImmersiveMode(false)
    //         ..fullScreenContentCallback = FullScreenContentCallback(
    //           onAdWillDismissFullScreenContent: (_) => onClose(),
    //         )
    //         ..show(onUserEarnedReward: onReward);
    //     },
    //     onAdFailedToLoad: (e) {
    //       print('RewardedAd failed to load: $e');
    //       onFail();
    //     },
    //   ),
    RewardedInterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5354046379',
      request: request,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad
            ..setImmersiveMode(true)
            ..fullScreenContentCallback = FullScreenContentCallback(
              onAdWillDismissFullScreenContent: (_) => onClose(),
            )
            ..show(onUserEarnedReward: onReward);
        },
        onAdFailedToLoad: (e) {
          print('RewardedInterstitialAd failed to load: $e');
          onFail();
        },
      ),
    );
  }

  _createInterstitialAd({required Function onClose, required Function onFail}) {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            ad
              ..setImmersiveMode(true)
              ..fullScreenContentCallback = FullScreenContentCallback(
                onAdWillDismissFullScreenContent: (_) => onClose(),
              )
              ..show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            onFail();
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _titleAnimation,
              child: Text(
                'Snake Game',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Dropdown for Board Size
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: DropdownButtonFormField<int>(
                value: selectedBoardSize,
                items: boardSizes.map((int size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Text('Board Size: $size'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedBoardSize = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown for Speed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: DropdownButtonFormField<String>(
                value: selectedSpeed,
                items: speedNames.map((String speed) {
                  return DropdownMenuItem<String>(
                    value: speed,
                    child: Text('Speed: $speed'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedSpeed = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Start Game Button
            FilledButton(
              onPressed: startGame,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                // backgroundColor: Colors.green,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(30),
                // ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 24),
              ),
            ),

            const SizedBox(height: 20),
            AdaptiveAdWidget(),
          ],
        ),
      ),
    );
  }
}
