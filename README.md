# CarRent • Modern Vehicle Rental Platform

CarRent adalah aplikasi rental/sewa mobil modern berbasis **Flutter** (Android, iOS, Web) dengan backend **Supabase PostgreSQL**, dilengkapi sistem otorisasi **Row Level Security (RLS)**, Availability Engine anti-bentrok, dan Admin Dashboard Web.

---

## 1. Project Overview
- **Frontend**: Flutter (Dart 3, Material 3, Clean Architecture, Riverpod, GoRouter).
- **Backend**: Supabase (PostgreSQL, Supabase Auth, Storage Buckets, RPC Functions, RLS).
- **Admin**: Flutter Web Dashboard responsif untuk desktop dan tablet.
- **Data Catalog**: Arsitektur katalog kendaraan scalable dengan atribusi legal dan proteksi lisensi.

---

## 2. Requirements & Prerequisites
- **Flutter SDK**: 3.24+ / 3.47+
- **Dart SDK**: 3.5+ / 3.13+
- **Akun Supabase**: Proyek Supabase PostgreSQL aktif
- **Git**: Terpasang di sistem operasi

---

## 3. Environment Variables
Buat file `.env` di root direktori proyek (gunakan template [`.env.example`](file:///.env.example)):

```ini
SUPABASE_URL=https://gexthzhezjbhrrvyrzmg.supabase.co
SUPABASE_ANON_KEY=sb_publishable__t0Detnnhg5JttX5Ub1mAg_FEjUvUtd
APP_NAME=CarRent
APP_ENV=development
```

> [!CAUTION]
> **JANGAN PERNAH** memasukkan `service_role` key ke dalam aplikasi Flutter atau mengunggah file `.env` ke GitHub. `.env` telah dilindungi dalam `.gitignore`.

---

## 4. Database Setup & Migrations
Skema database lengkap (14 tabel relasional, fungsi ketersediaan, kalkulasi harga, trigger user auth, dan RLS) tersedia di:
`supabase/migrations/20260929000000_carrent_core_schema.sql`

### Langkah Migrasi:
1. Buka Dashboard Supabase Anda: `https://supabase.com/dashboard/project/gexthzhezjbhrrvyrzmg`
2. Masuk ke menu **SQL Editor**.
3. Buka file [`supabase/migrations/20260929000000_carrent_core_schema.sql`](file:///supabase/migrations/20260929000000_carrent_core_schema.sql), salin seluruh isinya, lalu klik **Run**.
4. Semua tabel, relasi foreign key, indeks performa, dan fungsi RPC akan otomatis aktif.

---

## 5. Storage Buckets Setup
Buat bucket penyimpanan di Supabase Storage:
1. `car-images` (Public bucket)
2. `brand-logos` (Public bucket)
3. `avatars` (Public bucket)
4. `documents` (Private bucket)

---

## 6. Running Locally

### Mendapatkan Dependencies:
```bash
flutter pub get
```

### Menjalankan di Chrome (Web):
```bash
flutter run -d chrome
```

### Menjalankan di Android Emulator / Device:
```bash
flutter run -d android
```

### Menjalankan Admin Dashboard secara Spesifik:
Akses route `/admin` di URL browser:
```
http://localhost:<port>/#/admin
```

---

## 7. Building Production Applications

### Build Web (Admin & Web App):
```bash
flutter build web --release
```

### Build Android APK:
```bash
flutter build apk --release
```

### Build Android App Bundle (Play Store):
```bash
flutter build appbundle --release
```

### Build iOS (Membutuhkan macOS & Xcode):
```bash
flutter build ipa --release
```

---

## 8. GitHub CI/CD & Automated Builds
Repository terhubung ke GitHub:
`git@github.com:ENDY1807/Sewa-Mobil.git` atau `https://github.com/ENDY1807/Sewa-Mobil.git`

GitHub Actions otomatis berjalan di setiap `push` dan `pull_request` pada branch `main`:
1. Menjalankan analisis kode (`flutter analyze`).
2. Menjalankan rangkaian pengujian (`flutter test`).
3. Meng-compile build **Web** dan **Android APK**.
4. Mengunggah hasil build sebagai file artifact yang dapat diunduh langsung dari tab **Actions** di GitHub.

---

## 9. Struktur Kode (Clean Architecture)
```
lib/
├── core/         # Config, theme, constants, router, error handler, utilities
├── features/     # Modul fitur: auth, home, cars, booking, favorites, profile, admin
└── shared/       # Reusable components (widgets, models, repositories)
```

---

## 10. Lisensi & Legalitas Data Kendaraan
Seluruh data armada wajib menyertakan:
- `source_name`
- `source_url`
- `source_id`
- `license`
- `attribution`
- `is_demo` (untuk data demo/pengujian)
