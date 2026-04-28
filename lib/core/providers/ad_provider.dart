import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/admob_service.dart';

/// Enum simulado para el estado del usuario (ajustalo a tu modelo real de ARI)
enum ChatMode { basic, pro }

/// Provider que maneja el estado del usuario actual
/// (Reemplazalo con tu provider de autenticación/suscripción real)
final chatModeProvider = StateProvider<ChatMode>((ref) => ChatMode.basic);

/// Provider central que gestiona el ciclo de vida del Banner.
final bannerAdProvider = Provider.autoDispose<BannerAd?>((ref) {
  final currentMode = ref.watch(chatModeProvider);

  // Regla de Negocio Crítica: Bloqueo absoluto de carga en Modo Pro.
  if (currentMode == ChatMode.pro) {
    return null;
  }

  // Inicializamos el banner solo para usuarios básicos.
  final ad = BannerAd(
    adUnitId: AdMobService.bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (_) {
        // Log para debug. En prod usar logger de la app.
        // print('ARI: Banner cargado exitosamente');
      },
      onAdFailedToLoad: (ad, error) {
        // print('ARI: Error al cargar Banner: $error');
        ad.dispose();
      },
    ),
  );

  // Disparamos la carga asíncrona
  ad.load();

  // Liberamos recursos nativos cuando el provider se destruye
  ref.onDispose(() {
    ad.dispose();
  });

  return ad;
});
