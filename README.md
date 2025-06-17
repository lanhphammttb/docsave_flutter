# DocSave Flutter App

Ứng dụng mobile quản lý tài liệu được xây dựng bằng Flutter, kết nối với Firebase backend.

## Tính năng

- 🔐 **Authentication**: Đăng ký, đăng nhập với Firebase Auth
- 📁 **Document Management**: Upload, quản lý và tổ chức tài liệu
- 🔍 **Search & Filter**: Tìm kiếm và lọc tài liệu theo loại
- 🏷️ **Tags**: Gắn thẻ cho tài liệu để dễ quản lý
- 📊 **Statistics**: Thống kê tài liệu và dung lượng sử dụng
- 🌐 **Public/Private**: Chia sẻ tài liệu công khai hoặc riêng tư
- 📱 **Mobile Optimized**: Giao diện tối ưu cho mobile

## Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── user.dart
│   └── document.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   └── document_provider.dart
├── services/                 # Firebase services
│   └── firebase_service.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       ├── home_screen.dart
│       ├── document_list_screen.dart
│       ├── upload_screen.dart
│       └── profile_screen.dart
├── widgets/                  # Reusable widgets
│   └── document_card.dart
└── utils/                    # Utilities
    └── theme.dart
```

## Setup

### 1. Cài đặt dependencies

```bash
flutter pub get
```

### 2. Cấu hình Firebase

1. Tạo project Firebase mới hoặc sử dụng project hiện có
2. Thêm ứng dụng Android/iOS vào Firebase project
3. Tải file cấu hình:
   - **Android**: `google-services.json` → `android/app/`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/`

### 3. Cấu hình Android

Thêm vào `android/app/build.gradle`:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

Thêm vào cuối file `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

Thêm vào `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

### 4. Cấu hình iOS

Thêm vào `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

### 5. Chạy ứng dụng

```bash
flutter run
```

## Firebase Collections

### Users Collection
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "User Name",
  "avatar": "avatar_url",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Documents Collection
```json
{
  "id": "document_id",
  "title": "Document Title",
  "description": "Document description",
  "fileName": "file.pdf",
  "fileUrl": "firebase_storage_url",
  "fileType": "pdf",
  "fileSize": 1024000,
  "userId": "user_id",
  "tags": ["work", "important"],
  "isPublic": false,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Dependencies

- **firebase_core**: Firebase core functionality
- **firebase_auth**: Authentication
- **cloud_firestore**: Database
- **firebase_storage**: File storage
- **provider**: State management
- **file_picker**: File selection
- **flutter_staggered_grid_view**: Grid layout
- **intl**: Date formatting
- **cached_network_image**: Image caching
- **permission_handler**: Permissions
- **url_launcher**: URL opening

## Development

### State Management
Sử dụng Provider pattern để quản lý state:
- `AuthProvider`: Quản lý authentication state
- `DocumentProvider`: Quản lý documents state

### Firebase Integration
- Authentication với email/password
- Firestore để lưu trữ dữ liệu
- Firebase Storage để lưu trữ file

### UI/UX
- Material Design 3
- Responsive layout
- Dark/Light theme support
- Loading states và error handling

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT License
