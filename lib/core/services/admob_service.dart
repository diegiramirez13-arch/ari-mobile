import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  AdMobService._();

  /// Inicializa el SDK de Google Mobile Ads.
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Retorna el AdUnitID de prueba según la plataforma.
  /// TODO: Reemplazar con los IDs de producción mediante variables de entorno (.env) antes del release.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Plataforma no soportada para AdMob');
  }
}
