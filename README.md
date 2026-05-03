# Banking App

<p align="center">
  <img src="/assets/images/logo.png" width="150" alt="Nova Logo" />
</p>

> Ứng dụng ngân hàng hiện đại được xây dựng bằng **Flutter** (đa nền tảng) và **Appwrite** (Backend-as-a-Service), hỗ trợ quản lý tài khoản, chuyển tiền và theo dõi giao dịch.  
>
> Xem Demo trên Mobile View (F12 → Toggle Device Toolbar)
> - 🔗 https://e-banking-app-umber.vercel.app

[![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Appwrite](https://img.shields.io/badge/Appwrite-1.5+-F02E65?logo=appwrite&logoColor=white)](https://appwrite.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-22C55E.svg)](LICENSE)

---

## 📋 Mục lục

- [Tính năng](#-tính-năng)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Cấu trúc thư mục](#-cấu-trúc-thư-mục)
- [Giao diện ứng dụng](#-giao-diện-ứng-dụng-screenshots)
- [Yêu cầu hệ thống](#-yêu-cầu-hệ-thống)
- [Cài đặt](#-cài-đặt)
- [Cấu hình Appwrite](#-cấu-hình-appwrite)
- [Chạy ứng dụng](#-chạy-ứng-dụng)

---

## ✨ Tính năng

- 🔐 Đăng nhập / Đăng ký với Appwrite Auth (Email, OAuth2)
- 💰 Xem số dư tài khoản theo thời gian thực
- 📊 Thống kê & biểu đồ chi tiêu hàng tháng
- 💸 Chuyển tiền nội bộ và liên ngân hàng
- 🧾 Lịch sử giao dịch chi tiết (lưu trên Appwrite Database)
- 📱 Giao diện native trên Android & iOS, hỗ trợ Flutter Web
- 🔔 Thông báo giao dịch tức thì qua Appwrite Realtime
- 🤳 Thanh toán & nhận tiền bằng mã QR
- 💳 Quản lý thẻ vật lý và thẻ ảo
- 🛡️ Smart OTP xác thực giao dịch ngay trong app
- 🌐 Đa ngôn ngữ (Tiếng Việt, Tiếng Anh)
- 🎨 Tùy chỉnh Theme, Background và Avatar cá nhân

---

## 🛠 Công nghệ sử dụng

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Backend-as-a-Service | Appwrite |
| Authentication | Appwrite Auth |
| Database | Appwrite Databases |
| Storage | Appwrite Storage |
| Realtime | Appwrite Realtime |
| State Management | Riverpod / Bloc |
| SDK | appwrite (Flutter package) |

---

## 📁 Cấu trúc thư mục

```bash
banking-app/
├── assets/                           # Tài nguyên (hình ảnh, media)
│
├── lib/
│   ├── core/                         # Cấu hình chung, theme, đa ngôn ngữ
│   │   ├── config/
│   │   │   └── app_config.dart       # Endpoint Appwrite, Project ID
│   │   ├── l10n/
│   │   │   └── app_lang.dart         # Đa ngôn ngữ (i18n)
│   │   └── theme/                    # Màu sắc & typography
│
│   ├── data/                         # Tầng dữ liệu (models, repositories, services)
│   │   ├── models/                   # Các model dữ liệu
│   │   ├── repositories/             # Xử lý logic truy xuất dữ liệu
│   │   └── services/                 # Giao tiếp API / Appwrite
│
│   ├── features/                     # Các module theo tính năng
│   │   ├── analytics/
│   │   │   ├── bloc/                 # Quản lý state (BLoC)
│   │   │   └── screens/              # Giao diện
│   │   │
│   │   ├── auth/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   │
│   │   ├── cards/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   │
│   │   ├── home/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   │
│   │   ├── notifications/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   │
│   │   ├── payments/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   │
│   │   ├── profile/
│   │   │   ├── bloc/
│   │   │   └── screens/
│   │   │
│   │   ├── security/
│   │   │   └── screens/
│   │   │
│   │   └── utilities/
│   │       └── screens/
│
│   ├── providers/                    # State toàn cục (theme, user, ngôn ngữ)
│
│   ├── widgets/                      # Component UI tái sử dụng
│   │   ├── nova_button.dart
│   │   ├── nova_textfield.dart
│   │   ├── balance_card.dart
│   │   ├── nav_bar.dart
│   │   └── ...
│
│   └── main.dart                     # Điểm khởi chạy ứng dụng
│
├── test/
│   └── widget_test.dart              # Kiểm thử widget
│
├── Makefile                          # Lệnh build/run nhanh
├── vercel.json                       # Cấu hình deploy Flutter Web
├── pubspec.yaml                      # Khai báo dependencies
└── README.md
```
---

## 📱 Giao diện ứng dụng (Screenshots)

### Splash (Màn hình khởi động)

Giao diện khởi động khi lần đầu mở ứng dụng.

<img src="https://github.com/user-attachments/assets/2c4a4c18-a4f2-4756-8419-f9fe5df98859" width="200" alt="Splash 2" />

---

### Login & SignUp (Đăng nhập & Đăng ký)

Giao diện đăng nhập và đăng ký tài khoản.

<img src="https://github.com/user-attachments/assets/4d5991cc-4f19-47b5-b298-ac1238c3c490" width="200" alt="Login" /> <img src="https://github.com/user-attachments/assets/f0510d6e-751d-4edd-a63d-84c3f68747f2" width="200" alt="Signup" /> <img src="https://github.com/user-attachments/assets/e1da43d4-f7aa-430b-a2bf-ee1d62ef70ab" width="200" alt="Setup Password" /> <img src="https://github.com/user-attachments/assets/8c6cf6b5-76fd-46af-bb29-3b2e484fbf8b" width="200" alt="Personal Info" /> 

--- 

### Verify & Reset Password (Xác thực & Khôi phục mật khẩu)

<img width="200" src="https://github.com/user-attachments/assets/924577ef-42b0-4c61-84eb-1e0bcdc9b60d" /> <img width="200" src="https://github.com/user-attachments/assets/26d3334a-4aea-41ff-8fc9-8a00cd38e3df" /> <img width="200" src="https://github.com/user-attachments/assets/fe922290-ee5e-4c3d-bdff-036d3bdde142" /> <img width="200" src="https://github.com/user-attachments/assets/b9688f9b-9e11-4c35-8d82-c581d7dd4110" />

---

### Home (Trang chủ)

Giao diện màn hình chính tổng hợp thông tin bao gồm số dư tài khoản, các phím tắt nhanh, thống kê chi tiêu và giao dịch gần đây.

<img src="https://github.com/user-attachments/assets/7a5d3716-c88a-4483-a4d5-96839cdcd04b" width="200" /> <img src="https://github.com/user-attachments/assets/e4e86626-8bdc-4d85-80ed-67d45d8faf7a" width="200" /> 

---

### Analytics (Thống kê)

Giao diện thống kê, theo dõi dòng tiền và thói quen tiêu dùng bằng biểu đồ.

<img src="https://github.com/user-attachments/assets/6b226a9d-d2d7-4022-a9b5-eae42ff79e3c" width="200" /> <img src="https://github.com/user-attachments/assets/cb3cd8f1-92aa-47ec-a941-9e90761d3d04" width="200" /> <img src="https://github.com/user-attachments/assets/0837dc2e-4686-4aab-8d21-cd4ade855f78" width="200" /> <img src="https://github.com/user-attachments/assets/cf1e288c-ab3a-4526-b19b-fe314fba463a" width="200" /> 

---

### Cards Management (Quản lý thẻ)

Giao diện hiển thị thông tin và thiết lập cho thẻ vật lý cũng như thẻ ảo.

<img  width="200" src="https://github.com/user-attachments/assets/fe9238a1-029a-4417-ad83-6f0caf07f39f" /> <img  width="200" src="https://github.com/user-attachments/assets/14dba3d1-b68c-4d71-aa36-6727cc629df5" /> <img  width="200" src="https://github.com/user-attachments/assets/b4365ec8-3de0-44ba-904d-28196cd7d784" />

---

### Profile (Hồ sơ)

Giao diện quản lý thông tin cá nhân của người dùng.

<img width="200" src="https://github.com/user-attachments/assets/99ee5398-32f5-4439-8565-9ccb89d949bb" /> <img  width="200" src="https://github.com/user-attachments/assets/b45796c2-ec40-4d0e-b633-5e5fa90a1746" /> <img width="200" src="https://github.com/user-attachments/assets/19fc9ea5-ce9b-49b3-ba82-f080ca42b6cc" />

---

### Transfers (Chuyển tiền)

Giao diện chuyển tiền nội bộ.

<img  width="200" src="https://github.com/user-attachments/assets/788f4db7-5ef0-409c-99b3-05555807472d" /> <img  width="200" src="https://github.com/user-attachments/assets/23e998ff-7614-4169-9ad2-64b1818982ed" /> <img width="200" src="https://github.com/user-attachments/assets/2f0b5a4e-32bb-45da-b498-50c30f9d026f" /> <img  width="200" src="https://github.com/user-attachments/assets/758748ef-1602-4e1b-a65e-117895f1ca14" /> <img width="200" src="https://github.com/user-attachments/assets/6741900c-504f-4854-aad5-2c6404bd2f18" />

---

### QR Payment (Thanh toán bằng mã QR)

Giao diện hiển thị mã QR cá nhân và chuyển tiền bằng cách quét mã QR.

<img width="200" src="https://github.com/user-attachments/assets/6e3bf952-33e6-4ab3-911f-15b429997313" /> <img width="200" src="https://github.com/user-attachments/assets/373ec9d0-0776-4b89-9315-1799a9bd2b7a" />

---

### Transaction (Lịch sử giao dịch)

Giao diện hiển thị lịch sử giao dịch thu - chi.

<img width="200" src="https://github.com/user-attachments/assets/b188cb75-539a-4a8a-94c9-9fb66dccb4f9" />

---

### Utilities (Tiện ích)

<img width="200" src="https://github.com/user-attachments/assets/00615898-806b-4a92-8c48-d11534d88411" /> <img width="200" src="https://github.com/user-attachments/assets/edc62166-45ba-4cef-9de1-9b26e3b68636" /> <img width="200" src="https://github.com/user-attachments/assets/ebf3e83d-33c1-451a-ae78-9f29f8dc36b2" /> 

---

### Notifications (Thông báo)

Giao diện thông báo hiển thị thông báo từ hệ thống và biến động giao dịch.

<img width="200" src="https://github.com/user-attachments/assets/72b994d7-b93e-482a-a11f-c151ac6ead6e" /> <img width="200" src="https://github.com/user-attachments/assets/f2f3899e-c550-48ed-8dbf-7d7331e156df" />

---

### Smart OTP

Giao diện tạo mã OTP xác thực giao dịch khi thực hiện luồng chuyển tiền nội bộ.

<img width="200" src="https://github.com/user-attachments/assets/daf56c4e-5102-477a-84e6-784e1549466e" /> <img width="200" src="https://github.com/user-attachments/assets/e887b17d-c52c-4353-9e66-86cd3bc41952" /> <img width="200" src="https://github.com/user-attachments/assets/9b494a81-54a3-4707-adb2-96834864a87a" /> <img width="200" src="https://github.com/user-attachments/assets/484d723e-f78b-44c4-9ac6-d71ba2dd4ab6" /> <img width="200" src="https://github.com/user-attachments/assets/6625e669-bf9b-424b-a418-1f6f5f530773" />

---

### Change Password (Đổi mật khẩu)

Giao diện thay đổi mật khẩu.

<img width="200" src="https://github.com/user-attachments/assets/70fd5141-e734-47c4-b388-dbdd6f431987" /> <img width="200" src="https://github.com/user-attachments/assets/ed3411d0-d07f-42fd-91a7-8183c477a062" /> <img width="200" src="https://github.com/user-attachments/assets/d3f3675c-eab3-4ef0-a8c5-7a030b860357" /> <img width="200" src="https://github.com/user-attachments/assets/b68ab0fa-174c-419c-8b98-d17afa965164" />

---

### Multi Languages (Đa ngôn ngữ)

Tính năng đa ngôn ngữ.

<img width="200" src="https://github.com/user-attachments/assets/d71afad5-0de3-4ec1-89ff-e3405f0ba2d7" /> <img width="200" src="https://github.com/user-attachments/assets/cd115c8c-b1dc-48e8-9c9c-50a1ed1de338" /> 

---

### Change Avatar & Theme & Background (Đổi ảnh đại diện & Giao diện & Hình nền)

Giao diện đổi ảnh đại diện & theme màu của hệ thống & hình nền đăng nhập

<img width="200" src="https://github.com/user-attachments/assets/3ffa83a2-3dfd-45ad-a63d-e6b727017060" /> <img width="200" src="https://github.com/user-attachments/assets/ab9c334e-8a97-4e3e-82bb-6d4a34cd5a30" /> <img width="200" src="https://github.com/user-attachments/assets/d592d097-18a4-4e03-85d2-0a649dc53bd2" />

---

## 🖥 Yêu cầu hệ thống

| Công cụ | Phiên bản tối thiểu |
|---|---|
| Flutter SDK | >= 3.10.x |
| Dart | >= 3.0.x |
| Appwrite Server | >= 1.5.x (self-hosted hoặc Cloud) |
| Xcode Simulator / VS Code | Mới nhất |
| Git | Bất kỳ |

---

## 🚀 Cài đặt

### 1. Clone dự án

```bash
git clone https://github.com/your-username/banking-app.git
cd banking-app
```

### 2. Cài đặt Flutter dependencies

```bash
flutter pub get
```

### 3. Kiểm tra môi trường Flutter

```bash
flutter doctor
```

Đảm bảo không có lỗi đỏ. Nếu thiếu Android SDK hoặc Xcode, làm theo hướng dẫn in ra trên terminal.

---

## ⚙️ Cấu hình Appwrite

### Bước 1 — Tạo project trên Appwrite

- Truy cập [Appwrite Cloud](https://cloud.appwrite.io) hoặc tự host Appwrite.
- Tạo **Project mới**, đặt tên `banking-app`.
- Lấy **Project ID** từ trang Settings của project.

### Bước 2 — Tạo Platform

Trong project Appwrite, vào **Settings → Platforms → Add Platform**:

- **Android:** nhập `Application ID` (ví dụ: `com.example.bankingapp`)
- **iOS:** nhập `Bundle ID`
- **Flutter Web:** nhập hostname (ví dụ: `localhost`)

### Bước 3 — Tạo Database & Collections

Vào **Databases → Create Database** → đặt tên `banking_db`.

Tạo các Collection cần thiết:

| Collection | Mô tả |
|---|---|
| `users` | Tài khoản người dùng |
| `wallets` | Ví người dùng |
| `transactions` | Lịch sử giao dịch |
| `cards` | Thẻ ngân hàng |
| `notifications` | Thông báo hệ thống, biến động giao dịch |

### Bước 4 — Cấu hình constants trong Flutter

Tạo file `lib/core/constants/appwrite_constants.dart`:

```dart
class AppwriteConstants {
  static const String projectId    = 'YOUR_PROJECT_ID';
  static const String endpoint     = 'https://cloud.appwrite.io/v1'; // hoặc URL self-hosted
  static const String databaseId   = 'YOUR_DATABASE_ID';

  // Collection IDs
  static const String accountsCollection     = 'YOUR_ACCOUNTS_COLLECTION_ID';
  static const String transactionsCollection = 'YOUR_TRANSACTIONS_COLLECTION_ID';
  static const String usersProfileCollection = 'YOUR_USERS_PROFILE_COLLECTION_ID';

  // Storage
  static const String avatarBucketId = 'YOUR_BUCKET_ID';
}
```

> 🔒 **Lưu ý bảo mật:** Không commit file chứa Project ID và secret lên public repository. Dùng `--dart-define` hoặc file `.env` được gitignore để truyền giá trị khi build.

---

## ▶️ Chạy ứng dụng

### Chạy trên Android / iOS

```bash
# Xem danh sách thiết bị đang kết nối
flutter devices

# Chạy trên thiết bị cụ thể
flutter run -d <device_id>
```

### Chạy trên Web (để preview trên trình duyệt)

```bash
flutter run -d chrome
```

Ứng dụng sẽ mở tại: **http://localhost:PORT**

### Build Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```
---
