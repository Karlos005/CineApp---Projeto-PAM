# CineApp

Aplicação Flutter de bilhética de cinema (Clean Architecture + Riverpod + Firebase + TMDB).

## Configuração

1. **Firebase** – cria um projeto em https://console.firebase.google.com e corre `flutterfire configure`
   (gera `lib/firebase_options.dart`, `android/app/google-services.json` e `firebase.json`, todos ignorados pelo git).
   Alternativamente copia os ficheiros `*.example` e preenche os valores.
2. **TMDB** – cria um token de leitura em https://www.themoviedb.org/settings/api e corre:

```bash
flutter pub get
flutter run --dart-define=TMDB_TOKEN=o_teu_token
```

Para testes: `flutter test`
