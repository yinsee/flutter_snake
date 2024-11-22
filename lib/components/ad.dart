import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdData {
  final AdManagerBannerAd ad;
  final AdSize size;

  AdData({required this.ad, required this.size});
}

class AdaptiveAdWidget extends StatelessWidget {
  const AdaptiveAdWidget({super.key});

  Future<AdData> loadAd(BuildContext context) async {
    final adWidth = MediaQuery.of(context).size.width;
    final size = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(
        adWidth.truncate());
    final Completer<AdData> completer = Completer();

    AdManagerBannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741',
      request: AdManagerAdRequest(),
      sizes: [size],
      listener: AdManagerBannerAdListener(
        onAdLoaded: (Ad ad) async {
          final adSize = await (ad as AdManagerBannerAd).getPlatformAdSize();
          print("Loaded ads (${adSize?.width} x ${adSize?.height})");
          completer.complete(AdData(ad: ad, size: adSize!));
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('banner ad failed to load $error');
          completer.completeError(error);
        },
      ),
    ).load();
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdData>(
      future: loadAd(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final adData = snapshot.data!;
          return Container(
            width: adData.size.width.toDouble(),
            height: adData.size.height.toDouble(),
            child: AdWidget(ad: adData.ad),
          );
        }
        return Text("No ads available");
      },
    );
  }
}
