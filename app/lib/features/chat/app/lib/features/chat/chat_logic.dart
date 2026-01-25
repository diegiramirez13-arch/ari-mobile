class ChatLogic {
  int step = 0;
  String? name;

  String nextMessage(String userInput) {
    final input = userInput.trim();

    switch (step) {
      case 0:
        step++;
        return "Hola 👋 Soy ARI. ¿Cómo te llamás?";

      case 1:
        name = input.isEmpty ? "amigo" : input;
        step++;
        return "Mucho gusto, $name. ¿En qué sos bueno o a qué te dedicás?";

      case 2:
        step++;
        return "Perfecto. Vamos a enfocarnos en eso para generar resultados concretos. ¿Querés que ARI te arme un plan de 7 días? (sí/no)";

      case 3:
        step++;
        final yes = input.toLowerCase().startsWith("s");
        if (yes) {
          return "Listo. Día 1: elegí un objetivo simple y medible. Decime: ¿qué querés lograr en 7 días?";
        } else {
          return "Ok. Entonces empecemos por algo más chico: ¿qué es lo más urgente que querés resolver hoy?";
        }

      default:
        return "Seguimos paso a paso. Decime qué querés priorizar ahora: trabajo, estudio, salud o dinero.";
    }
  }
}
