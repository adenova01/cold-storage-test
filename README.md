# Cara Isi Data
1. buka data -> services -> mock_api_service.dart
2. untuk menambahkan data location tambahkan di bagian variable _locations
3. untuk menambahkan data temperature tambahkan di bagian fungsi getTemperatures

# Arsitektur & Alasan menggunakan provider
- lib/
├── data/
│   ├── models/
│   └── services/    # Mockup API
└── presentation/
    ├── providers/   # State management
    ├── screens/     # UI screens
    └── widgets/     # Reusable components
- Alasan saya menggunakan provider karena saya mudah paham dan diakui resmi oleh flutter

# Trade off
- Untuk scan SKU saya tidak menggunakan library ataupun membuka kamera, karena waktu tidak cukup, dan saya hanya implementasikan dengan random string
- Saya menambahkan feature untuk clear all list inventory
- Saya juga menambahkan validasi ketika qty dari input inbound melebihi sisa yang ada di location, maka data tidak akan tersimpan dan memunculkan snackbar

# Screenshoot
<img src="https://raw.githubusercontent.com/adenova01/cold-storage-test/refs/heads/main/screenshot/dashboard.jpg" />
<img src="https://raw.githubusercontent.com/adenova01/cold-storage-test/refs/heads/main/screenshot/add.jpg" />
<img src="https://raw.githubusercontent.com/adenova01/cold-storage-test/refs/heads/main/screenshot/list.jpg" />