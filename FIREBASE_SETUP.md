# Firebase Setup Guide

Hướng dẫn cấu hình Firebase cho ứng dụng DocSave Flutter.

## Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" hoặc "Add project"
3. Nhập tên project: `docsave-flutter`
4. Chọn có/không bật Google Analytics
5. Click "Create project"

## Bước 2: Thêm ứng dụng Android

1. Trong Firebase Console, click icon Android
2. Nhập Android package name: `com.example.docsave_flutter`
3. Nhập app nickname: `DocSave Android`
4. Click "Register app"
5. Tải file `google-services.json`
6. Copy file vào thư mục: `android/app/google-services.json`

## Bước 3: Thêm ứng dụng iOS

1. Trong Firebase Console, click icon iOS
2. Nhập iOS bundle ID: `com.example.docsaveFlutter`
3. Nhập app nickname: `DocSave iOS`
4. Click "Register app"
5. Tải file `GoogleService-Info.plist`
6. Copy file vào thư mục: `ios/Runner/GoogleService-Info.plist`

## Bước 4: Cấu hình Authentication

1. Trong Firebase Console, chọn "Authentication"
2. Click "Get started"
3. Chọn tab "Sign-in method"
4. Enable "Email/Password"
5. Click "Save"

## Bước 5: Cấu hình Firestore Database

1. Trong Firebase Console, chọn "Firestore Database"
2. Click "Create database"
3. Chọn "Start in test mode" (cho development)
4. Chọn location gần nhất
5. Click "Done"

### Firestore Rules

Cập nhật rules trong Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Users can read/write their own documents
    match /documents/{documentId} {
      allow read, write: if request.auth != null &&
        (resource.data.userId == request.auth.uid || resource.data.isPublic == true);
    }
  }
}
```

## Bước 6: Cấu hình Storage

1. Trong Firebase Console, chọn "Storage"
2. Click "Get started"
3. Chọn "Start in test mode" (cho development)
4. Chọn location gần nhất
5. Click "Done"

### Storage Rules

Cập nhật rules trong Storage:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload files to their own folder
    match /documents/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Bước 7: Test ứng dụng

1. Chạy lệnh để cài đặt dependencies:
   ```bash
   flutter pub get
   ```

2. Chạy ứng dụng:
   ```bash
   flutter run
   ```

3. Test các tính năng:
   - Đăng ký tài khoản mới
   - Đăng nhập
   - Upload tài liệu
   - Xem danh sách tài liệu

## Troubleshooting

### Lỗi "google-services.json not found"
- Đảm bảo file `google-services.json` đã được copy vào `android/app/`
- Kiểm tra package name trong file có khớp với `applicationId` trong `build.gradle.kts`

### Lỗi "GoogleService-Info.plist not found"
- Đảm bảo file `GoogleService-Info.plist` đã được copy vào `ios/Runner/`
- Kiểm tra bundle ID trong file có khớp với project

### Lỗi Firebase initialization
- Kiểm tra internet connection
- Đảm bảo Firebase project đã được tạo đúng
- Kiểm tra rules trong Firestore và Storage

### Lỗi permissions
- Đảm bảo đã cấp quyền storage cho ứng dụng
- Kiểm tra Android/iOS permissions

## Production Setup

Khi deploy production:

1. Cập nhật Firestore rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /documents/{documentId} {
         allow read: if request.auth != null &&
           (resource.data.userId == request.auth.uid || resource.data.isPublic == true);
         allow write: if request.auth != null && resource.data.userId == request.auth.uid;
       }
     }
   }
   ```

2. Cập nhật Storage rules:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /documents/{userId}/{allPaths=**} {
         allow read: if request.auth != null &&
           (request.auth.uid == userId || resource.metadata.isPublic == 'true');
         allow write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

3. Cấu hình signing cho Android/iOS
4. Test kỹ các tính năng trước khi release
