# 🏏 CricBid — Cricket Player Auction App

A full-featured Flutter app for managing cricket player auctions with real-time bidding, team management, timetable generation, and group chat.

---

## ✨ Features

### 👥 Roles
| Role | Access |
|------|--------|
| **Admin** | Create groups, add teams/players, control auction, generate PDFs, manage timetable |
| **Team Owner** | View own team budget/roster, see all players, set team theme |
| **Player** | View own auction status, team roster, group chat |

### 🔨 Auction Flow
- Multi-round auction with auto-shuffled player order
- Admin controls: Sold (with team + points selection), Skip
- **Budget validation** — prevents overbidding based on remaining players
- Real-time sold/skip animations (bat for batsman 🏏, ball for bowler 🎯)
- All members see live state via Firestore real-time sync
- Auto PDF generation per round (1 player/page)
- Notifications: Auction Live, Player Sold, Player Bought

### 📅 Timetable
- Auto-generate round-robin tournament schedule
- Group stage (A/B/C/D) + Semi-finals + Final
- PDF export with date/time grid
- Upload custom timetable image/PDF
- Match reminder notifications (2 hrs before)

### 💬 Group Chat
- Real-time chat for all group members
- Role badges (ADMIN / OWNER / PLAYER)
- Date separators, message timestamps

### 🎨 Theming
- Light/Dark/System mode
- Owner sets team color → applied to all players in that group
- Compatible with both light and dark modes

---

## 🚀 Setup

### 1. Prerequisites
```bash
flutter --version  # Need Flutter 3.x
dart --version     # Need Dart 3.x
```

### 2. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create project: **CricBid**
3. Enable:
   - **Authentication** → Phone
   - **Firestore Database** → Production mode
   - **Storage** → Default bucket
   - **Cloud Messaging** (FCM)
4. Add Android app: `com.cricbid.app`
5. Add iOS app: `com.cricbid.app`
6. Download `google-services.json` → `android/app/`
7. Download `GoogleService-Info.plist` → `ios/Runner/`

### 3. FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Replace `lib/firebase_options.dart` with generated file.

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Apply Firestore Rules
In Firebase Console → Firestore → Rules, paste contents of `firestore.rules`.

Apply Storage rules from `storage.rules`.

### 6. Run
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── bindings/       # GetX initial bindings
│   ├── routes/         # AppRoutes + AppPages
│   └── theme/          # AppTheme + AppColors + ThemeController
├── core/
│   ├── constants/      # AppConstants
│   ├── utils/          # PDF generator, Excel parser, Notifications
│   └── widgets/        # Shared UI components, Responsive layout
└── features/
    ├── auth/           # Phone login, OTP
    ├── group/          # Group CRUD, role management
    ├── player/         # Player CRUD, photo upload, Excel import
    ├── team/           # Team CRUD, budget tracking, theme
    ├── auction/        # Full auction lifecycle, live state
    ├── timetable/      # Auto schedule, PDF, notifications
    ├── chat/           # Real-time group chat
    └── dashboard/      # Role-based dashboards (Admin/Owner/Player)
```

---

## 📊 Firestore Collections

| Collection | Purpose |
|------------|---------|
| `users` | User profiles + group roles |
| `groups` | Group settings, auction state |
| `groups/{id}/live_auction/state` | Real-time auction state |
| `teams` | Team info + budget tracking |
| `players` | Player profiles + auction status |
| `auctions` | Auction lifecycle |
| `auction_rounds` | Per-round player lists |
| `bids` | Auction event log (sold/skipped) |
| `messages` | Group chat messages |
| `timetables` | Tournament schedules |
| `matches` | Individual match records |
| `notifications` | Push notification log |
| `fcm_queue` | FCM send queue (for Cloud Functions) |

---

## 🔔 FCM Notifications

Notifications are queued in `fcm_queue` collection. For production, deploy a **Firebase Cloud Function** to process this queue:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendFcm = functions.firestore
  .document('fcm_queue/{docId}')
  .onCreate(async (snap) => {
    const { tokens, title, body, data } = snap.data();
    if (!tokens?.length) return;
    
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: data || {},
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    
    await snap.ref.delete(); // Clean up
  });
```

---

## 📱 Excel Import Format

### Teams Sheet (teams.xlsx)
| Column | Field |
|--------|-------|
| A | Team Name |
| B | Owner Name |
| C | Owner Phone |
| D | Owner Address (optional) |
| E | Owner Birthdate (DD/MM/YYYY) |
| F | Type (Batting/Bowling/All-Rounder) |
| G | Last Team (optional) |

### Players Sheet (players.xlsx)
| Column | Field |
|--------|-------|
| A | Player Name |
| B | Phone |
| C | Address (optional) |
| D | Birthdate (DD/MM/YYYY) |
| E | Type (Batting/Bowling/All-Rounder) |
| F | Last Team (optional) |
| G | Photo URL (optional) |

---

## 🛠️ Key Packages

| Package | Purpose |
|---------|---------|
| `get` | State management + routing |
| `firebase_*` | Auth, Firestore, Storage, FCM |
| `pdf` + `printing` | PDF generation |
| `excel` | Excel import |
| `flutter_animate` | Animations |
| `image_picker` | Camera + gallery |
| `cached_network_image` | Image caching |
| `flutter_local_notifications` | Local push notifications |
| `pinput` | OTP input UI |
| `google_fonts` | Plus Jakarta Sans typography |
| `share_plus` | PDF sharing |

---

## 📝 Notes

- **Free Firebase** tier is sufficient for small groups (< 1000 users)
- For large auctions, consider Firestore reads optimization
- FCM Cloud Function required for push notifications in production
- `flutter_colorpicker` needs to be added to `pubspec.yaml` for team theme feature

---

**Package:** `com.cricbid.app`  
**Version:** 1.0.0  
**Flutter:** 3.x | **Dart:** 3.x | **Architecture:** GetX MVC
