import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/providers/ad_provider.dart';

class AriBannerAd extends ConsumerWidget {
  const AriBannerAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(bannerAdProvider);

    // Si es null (Modo Pro) o hay algún fallo temprano, no ocupamos espacio en pantalla.
    if (bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      // Fondo Dark Mode especificado
      color: const Color(0xFF0A0A0F),
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      alignment: Alignment.center,
      // SafeArea interno por si se ubica en los bordes inferiores del dispositivo
      child: SafeArea(
        child: AdWidget(ad: bannerAd),
      ),
    );
  }
}
