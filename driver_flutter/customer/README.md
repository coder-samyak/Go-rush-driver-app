# GoRush Customer Platform

This directory contains the Customer Platform artifacts:
- `frontend/`: The Flutter application.
- `backend/`: The original customer-service prototype retained for reference.

The integrated runtime backend is the shared MongoDB-backed Node.js service at
`../backend`. It now exposes customer APIs under `/api/v1` and driver APIs
under `/api`, so customer and driver accounts use the same database and
real-time ride records. The original NestJS service must not be started
alongside the shared backend for the integrated app.

## Running the Application
### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

### Shared backend (Node.js + MongoDB)
```bash
cd ../backend
npm install
npm start
```

For a physical Android device, build the customer app with the host address:

```bash
cd frontend
flutter run --dart-define=API_URL=http://<host-lan-ip>:5000/api/v1
```

The Android emulator can use the default `10.0.2.2` value. A deployed HTTPS
URL should be supplied through `API_URL` for production.
