# Guide d'Installation Locale - Safe-solde

Bienvenue ! Ce guide vous aidera à mettre en place l'environnement de développement local pour **Safe-solde**, une application mobile de suivi et gestion des actions financières personnelles.

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **Git** (pour cloner le repository)
- **Flutter SDK** (version stable recommandée)
- **Android Studio** ou **Xcode** (selon votre plateforme cible)
- **Dart SDK** (généralement fourni avec Flutter)
- **Un émulateur ou un appareil physique** pour tester

## 🚀 Étapes d'installation

### 1. Cloner le repository

```bash
git clone https://github.com/tagne-wilfried-Dev/Safe-solde.git
cd Safe-solde
```

### 2. Basculer sur la branche develop

```bash
git checkout develop
```

### 3. Vérifier l'installation de Flutter

Vérifiez que Flutter est correctement installé et configuré :

```bash
flutter doctor
```

Assurez-vous que tous les composants nécessaires sont ✓. Sinon, suivez les instructions pour résoudre les problèmes.

### 4. Installer les dépendances du projet

```bash
flutter pub get
```

Cette commande télécharge et installe toutes les dépendances déclarées dans `pubspec.yaml`.

### 5. Générer les fichiers de configuration

Si le projet utilise la génération de code (par exemple avec `build_runner`), exécutez :

```bash
flutter pub run build_runner build
```

### 6. Configurer les variables d'environnement (si nécessaire)

Créez un fichier `.env` à la racine du projet (s'il est utilisé) :

```bash
cp .env.example .env
```

Mettez à jour les valeurs selon votre configuration locale.

## 💻 Développement

### Lancer l'application en mode développement

**Sur un émulateur ou appareil connecté :**

```bash
flutter run
```

Pour spécifier un appareil :

```bash
flutter devices                 # Liste les appareils disponibles
flutter run -d <device_id>     # Lance sur un appareil spécifique
```

### Lancer avec des options utiles

```bash
flutter run --debug              # Mode debug (par défaut)
flutter run --release            # Mode release
flutter run --profile            # Mode profiling
flutter run --hot                # Avec hot reload activé
```

## 🧪 Tests

### Exécuter les tests unitaires

```bash
flutter test
```

### Exécuter les tests d'intégration

```bash
flutter test integration_test/
```

## 🏗️ Build

### Générer un APK (Android)

```bash
flutter build apk --release
```

Le fichier APK sera disponible dans `build/app/outputs/flutter-apk/app-release.apk`.

### Générer une IPA (iOS)

```bash
flutter build ios --release
```

## 📁 Structure du projet

Voici la structure générale d'un projet Flutter :

```
Safe-solde/
├── android/          # Code spécifique Android (Kotlin)
├── ios/              # Code spécifique iOS (Swift/Objective-C)
├── lib/              # Code source principal (Dart)
│   ├── main.dart     # Point d'entrée de l'application
│   ├── models/       # Classes de modèles de données
│   ├── screens/      # Pages de l'application
│   ├── widgets/      # Composants réutilisables
│   └── services/     # Services (API, stockage, etc.)
├── test/             # Tests unitaires
├── integration_test/ # Tests d'intégration
├── pubspec.yaml      # Fichier de configuration des dépendances
└── README.md         # Documentation du projet
```

## 🔄 Flux de travail Git

Avant de contribuer au projet, suivez ce flux :

1. **Créer une branche feature** à partir de `develop` :

```bash
git checkout develop
git pull origin develop
git checkout -b feature/ma-fonctionnalite
```

2. **Développer et commiter** vos changements :

```bash
git add .
git commit -m "feat: description de la fonctionnalité"
```

3. **Pousser votre branche** :

```bash
git push origin feature/ma-fonctionnalite
```

4. **Créer une Pull Request** vers `develop` sur GitHub

5. **Attendre la révision** et effectuer les modifications demandées

## 🛠️ Commandes utiles

| Commande | Description |
|----------|-------------|
| `flutter pub get` | Installer les dépendances |
| `flutter pub upgrade` | Mettre à jour les dépendances |
| `flutter pub outdated` | Voir les dépendances obsolètes |
| `flutter clean` | Nettoyer le build |
| `flutter doctor` | Vérifier la configuration |
| `flutter analyze` | Analyser le code |
| `flutter format lib/` | Formater le code Dart |
| `dart pub global activate melos` | Activer Melos pour les monorepos |

## 🐛 Dépannage

### Problème : "Flutter not found"
**Solution :** Assurez-vous que Flutter est ajouté à votre `PATH`.

### Problème : "Gradle build failed"
**Solution :** Exécutez `flutter clean` puis `flutter pub get`.

### Problème : "Emulator not starting"
**Solution :** Vérifiez l'installation d'Android Studio et créez un nouvel émulateur via AVD Manager.

### Problème : Erreurs Pods (iOS)
**Solution :** Exécutez `cd ios && pod install --repo-update && cd ..`

## 📞 Support et questions

Pour toute question ou problème :
- Consultez la [documentation Flutter officielle](https://flutter.dev/docs)
- Ouvrez une issue sur GitHub
- Contactez l'équipe de développement

## 📝 Notes importantes

- Assurez-vous toujours que votre branche `develop` est à jour avant de créer une feature
- Testez votre code avant de faire un commit
- Respectez les conventions de code du projet
- Faites des commits clairs et descriptifs
- Utilisez les variables d'environnement pour les configurations sensibles

---

**Prêt à développer ?** Bonne chance ! 🚀
