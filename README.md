# AAS - Authentication as a Service

A Flutter-based authentication service with Supabase backend.

## Project Structure

```
aas/
├── .editorconfig          # Editor configuration
├── .gitignore            # Git ignore rules
├── README.md             # This file
├── supabase/
│   ├── migrations/       # Database migration files (.sql)
│   └── config.toml      # Supabase configuration
└── aas_app/
    ├── lib/             # Flutter app source code
    └── pubspec.yaml     # Flutter dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Supabase CLI
- Node.js (for Supabase CLI)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd aas
   ```

2. **Install Flutter dependencies**
   ```bash
   cd aas_app
   flutter pub get
   ```

3. **Setup Supabase**
   ```bash
   cd ../supabase
   supabase init
   supabase start
   ```

4. **Run the Flutter app**
   ```bash
   cd ../aas_app
   flutter run
   ```

## Development

### Database Migrations

Add new migrations in `supabase/migrations/`:
```bash
supabase migration new <migration_name>
```

Apply migrations:
```bash
supabase db push
```

### Flutter Development

The Flutter app is located in `aas_app/`. Key directories:
- `lib/` - Main application code
- `test/` - Unit and widget tests
- `pubspec.yaml` - Dependencies and app configuration

## Features

- [ ] User authentication (sign up, sign in, sign out)
- [ ] Password reset
- [ ] Email verification
- [ ] Social authentication
- [ ] User profile management
- [ ] Role-based access control
- [ ] API key management

## Tech Stack

- **Frontend**: Flutter/Dart
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **Authentication**: Supabase Auth
- **Database**: PostgreSQL
- **API**: Supabase REST API

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

[Add your license here]
