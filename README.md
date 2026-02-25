# 🏃‍♂️ Run The World (RTW) - Mobile MVP

**La première League de running et de conquête blockchain.**

![React Native](https://img.shields.io/badge/React_Native-0.81-61DAFB?logo=react)
![Expo](https://img.shields.io/badge/Expo-SDK_54-000020?logo=expo)
![NativeWind](https://img.shields.io/badge/NativeWind-v4-38BDF8?logo=tailwindcss)

---

## 📱 Description

Run The World est une application mobile gamifiée qui combine le running avec la conquête territoriale et la blockchain. Chaque foulée compte, chaque parcours établit ton territoire.

### ✨ Fonctionnalités Principales

- **🆔 Player Card** : Identité unique avec avatar, grade (Starter → Élite), nationalité et validation ID
- **💰 Wallet Dual** : Gestion des monnaies RPC (in-game) et OZI (blockchain)
- **🏆 League System** : Classement par périodes mensuelles (P1-P12) avec divisions L1-L10
- **🗺️ Land Conquest** : Revendication de territoires basée sur tes parcours
- **📊 Performance Tracking** : Distance, vitesse, dénivelé convertis en points
- **🎨 UI Premium** : Design Glassmorphism avec effets de verre et animations fluides

---

## 🚀 Installation & Lancement

### Prérequis

```bash
node >= 18.x
npm >= 9.x
```

### Installation des dépendances

```bash
cd rtw_mobile
npm install
```

### Lancement de l'app

**Sur Web (recommandé pour preview) :**
```bash
npx expo start --web
```

**Sur iOS Simulator :**
```bash
npx expo start --ios
```

**Sur Android Emulator :**
```bash
npx expo start --android
```

---

## 📐 Architecture Technique

### Stack

- **Framework** : React Native avec Expo SDK 54
- **Styling** : NativeWind v4 (Tailwind CSS pour React Native)
- **Icons** : Lucide React Native
- **State Management** : React Hooks (useState, useEffect)
- **Navigation** : Tab-based navigation

### Structure du Projet

```
rtw_mobile/
├── App.js              # Composant principal avec toute la logique UI
├── global.css          # Directives Tailwind
├── tailwind.config.js  # Configuration Tailwind avec couleurs RTW
├── babel.config.js     # Config Babel avec NativeWind
├── metro.config.js     # Config Metro Bundler
└── package.json        # Dépendances et scripts
```

### Couleurs du Thème

```javascript
{
  'rtw-navy': '#0B1221',    // Fond principal
  'rtw-gold': '#FFB800',    // Accent primaire
  'rtw-orange': '#FF8A00',  // Accent secondaire
  'rtw-dark': '#05080F'     // Background alternatif
}
```

---

## 🎮 Logique Métier (White Paper)

### Système de Grades

| Grade | Patrimoine RPC | Points Cumulés | Périodes |
|-------|---------------|----------------|----------|
| **Starter** | 8 000 | 200 | 1 |
| **Débutant** | 15 000 | 500 | 2 |
| **Confirmé** | 30 000 | 800 | 3 |
| **Expert** | 200 000 | 20 000 | 5 |
| **Pro** | 1 000 000 | 50 000 | 6 |
| **Élite** | 5 000 000 | 100 000 | 12 |

### Conversion Points → RPC

```
1 Point marqué = 10 RPC
```

### Validation ID

- Renouvellement requis tous les **10 jours**
- Perte d'ID = Perte de tous les actifs

---

## 🗺️ Système de Lands

### Acquisition

- **Location** : 3 000-5 000 RPC/mois selon la période
- **Achat** : 80 000 OZI + frais de transaction (4%)
- **Option d'achat** : Débloqué au grade **Confirmé**

### Revenus

**Actifs :**
- Passage d'un joueur sur ta Land = RPC/OZI

**Passifs :**
- Location : 3% de valeur/mois en RPC
- Propriété : 3,5-4% de valeur/mois en OZI

---

## 🏆 League & Classement

### Périodes

- Durée : **1 mois (P1-P12)**
- Seuil de maintien : **10 points minimum**
- Classement : L10 (débutants) → L1 (élite)

### Prize Pool

- Buy-in proportionnel au niveau de League
- Distribution selon le classement final
- Cagnotte aléatoire pour participants actifs (minimum 2km/période)

---

## 🎨 Design System

### Composants UI

- **GlassCard** : Carte avec effet de verre (backdrop-blur)
- **Badge** : Indicateurs de statut et grade
- **ProgressBar** : Suivi de progression avec animations
- **TabBar** : Navigation bottom avec icons Lucide

### Bordures

- Cards principales : **24px**
- Boutons & badges : **12-16px**
- Avatar : **Circulaire (50%)**

---

## 📦 Dépendances Principales

```json
{
  "expo": "~54.0.32",
  "react": "19.1.0",
  "react-native": "0.81.5",
  "nativewind": "^4.2.1",
  "lucide-react-native": "^0.563.0",
  "react-native-svg": "^15.15.1",
  "tailwindcss": "^3.4.19"
}
```

---

## 🧪 Preview Web (Mockup)

Un fichier `preview.html` est inclus dans le repo parent pour une visualisation instantanée du design sans setup Expo.

**Ouvrir :**
```bash
open ../preview.html
```

---

## 🔧 Configuration Avancée

### NativeWind Setup

Le projet utilise NativeWind v4 avec la configuration suivante :

**metro.config.js :**
```javascript
const { withNativeWind } = require("nativewind/metro");
module.exports = withNativeWind(config, { input: "./global.css" });
```

**babel.config.js :**
```javascript
presets: [
  ["babel-preset-expo", { jsxImportSource: "nativewind" }],
  "nativewind/babel"
]
```

---

## 🚧 Roadmap

- [ ] Intégration API backend pour sync des données
- [ ] Connexion blockchain EOS pour les transactions OZI
- [ ] Système de notifications push
- [ ] Mode Team (jusqu'à 10 joueurs)
- [ ] Chasse aux trésors sur la map
- [ ] Collections privées (NFTs)
- [ ] Marketplace pour échange de Lands

---

## 📄 License

Projet propriétaire - **Run The World © 2026**

---

## 👥 Contributeurs

- **Jayan Grondin** - Développeur Principal
- **ELPIU Team** - Design & Stratégie

---

## 📞 Support

Pour toute question ou suggestion :
- 📧 Email : contact@runtheworld.app
- 🌐 Site : [runtheworld.app](https://runtheworld.app)
- 💬 Discord : [RTW Community](#)

---

**Made with ❤️ for runners worldwide**
