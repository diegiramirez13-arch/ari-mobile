# Firebase Setup Guide for ARI Mobile

## Paso 2: Firebase Integration ✅

### 1. Crear Proyecto en Firebase Console

```bash
1. Ir a https://console.firebase.google.com
2. Click "Crear proyecto"
3. Nombre: "ari-mobile"
4. Desactivar Google Analytics (por ahora)
5. Click "Crear proyecto"
```

### 2. Agregar Aplicaciones

#### Android
```bash
1. Click "+ Agregar app" -> Android
2. Package Name: com.ari.mobile
3. Descargar google-services.json
4. Colocar en: android/app/google-services.json
```

#### iOS
```bash
1. Click "+ Agregar app" -> iOS
2. Bundle ID: com.ari.mobile
3. Descargar GoogleService-Info.plist
4. Colocar en: ios/Runner/GoogleService-Info.plist
```

#### Web (Opcional)
```bash
1. Click "+ Agregar app" -> Web
2. Nombre: ari-mobile-web
3. Copiar credenciales a firebase_options.dart
```

### 3. Configurar FlutterFire

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Ejecutar configuracion
flutterfire configure

# Esto actualizará automáticamente firebase_options.dart
```

### 4. Habilitar Autenticación

En Firebase Console:
```
1. Build -> Authentication
2. Sign-in method
3. Habilitar "Anonymous" (para desarrollo)
4. Habilitar "Email/Password" (para usuarios)
```

### 5. Crear Base de Datos Firestore

En Firebase Console:
```
1. Build -> Firestore Database
2. Click "Crear base de datos"
3. Ubicación: us-central1
4. Modo: Iniciar en modo de prueba (para desarrollo)
5. Click "Siguiente" y "Crear"
```

### 6. Reglas de Seguridad (Firestore)

Reemplace las reglas por defecto con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios solo ven sus propios datos
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Proyectos del usuario
      match /projects/{projectId=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Historial de chat
      match /chats/{chatId=**} {
        allow read, write: if request.auth.uid == userId;
      }

      // Perfil (campos en documento users/{userId})
      // No requiere subcolección adicional.
    }
  }
}
```

### 7. Instalación de dependencias

```bash
flutter pub get
flutter pub run build_runner build
```

### 8. Test de Conexión

```bash
# Ejecutar app
flutter run

# Verás:
# 1. Splash screen
# 2. Login screen
# 3. Al usar "Empezar sin cuenta" -> Autenticación anónima
# 4. Acceso a Chat y Projects (sincronizados con Firestore)
```

---

## Estructura Firestore

```
firestore/
├── users (collection)
│   └── {userId}
│       ├── name: string
│       ├── bio: string?
│       ├── occupation: string?
│       ├── createdAt: string (ISO8601)
│       ├── updatedAt: string (ISO8601)
│       ├── userId: string
│       ├── projects (subcollection)
│       │   └── {projectId}
│       │       ├── id: string
│       │       ├── title: string
│       │       ├── description: string
│       │       ├── completed: boolean
│       │       ├── createdAt: timestamp
│       │       └── updatedAt: timestamp
│       └── chats (subcollection)
│           └── {chatId}
│               ├── message: string
│               ├── isUser: boolean
│               └── timestamp: timestamp
```

---

## Troubleshooting

### Error: "PERMISSION_DENIED: Missing or insufficient permissions"
- Solución: Verifica Firestore Rules y que estés autenticado

### Error: "Firebase not initialized"
- Solución: Ejecuta `flutterfire configure` y verifica firebase_options.dart

### Error: "google-services.json not found"
- Solución: Coloca el archivo en android/app/ (no en android/ solo)

---

## Próximo Paso: Paso 3
- Implementar Profile feature
- Agregar datos más complejos de usuario
- Conectar con chat para personalización
