# Supabase Integration Setup Guide

This guide will help you set up Supabase for your AAS (All Africa Supplies) Flutter application.

## Prerequisites

1. **Supabase Account**: Create an account at [supabase.com](https://supabase.com)
2. **Flutter SDK**: Ensure you have Flutter installed and configured
3. **Supabase CLI** (optional): For local development and migrations

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: `aas-app` (or your preferred name)
   - **Database Password**: Choose a strong password
   - **Region**: Select the closest region to your users
5. Click "Create new project"
6. Wait for the project to be created (this may take a few minutes)

## Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project-ref.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

## Step 3: Configure Environment Variables

1. Copy the `env.example` file to `.env`:
   ```bash
   cp env.example .env
   ```

2. Edit the `.env` file and replace the placeholder values:
   ```env
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-actual-anon-key-here
   ```

3. **Important**: Add `.env` to your `.gitignore` file to keep your credentials secure:
   ```bash
   echo ".env" >> .gitignore
   ```

## Step 4: Set Up Database Schema

### Option A: Using Supabase Dashboard (Recommended for beginners)

1. Go to your Supabase dashboard → **SQL Editor**
2. Create the database schema by running the SQL from `docs/AAS_DATABASE_SCHEMA.md`

### Option B: Using Supabase CLI (Advanced)

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref your-project-ref
   ```

4. Push the schema:
   ```bash
   supabase db push
   ```

## Step 5: Configure Authentication

1. Go to **Authentication** → **Settings** in your Supabase dashboard
2. Configure the following settings:

### Site URL
- **Development**: `http://localhost:3000` (for web)
- **Production**: Your production domain

### Redirect URLs
Add these URLs for authentication redirects:
- `http://localhost:3000/auth/callback`
- `your-production-domain.com/auth/callback`

### Email Templates
Customize the email templates for:
- Email confirmation
- Password reset
- Magic link

## Step 6: Set Up Storage Buckets

1. Go to **Storage** in your Supabase dashboard
2. Create the following buckets:

### order-files
- **Public bucket**: ✅ Yes
- **File size limit**: 50MB
- **Allowed MIME types**: `image/*, application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document`

### profile-images
- **Public bucket**: ✅ Yes
- **File size limit**: 10MB
- **Allowed MIME types**: `image/*`

### part-images
- **Public bucket**: ✅ Yes
- **File size limit**: 10MB
- **Allowed MIME types**: `image/*`

## Step 7: Configure Row Level Security (RLS)

The database schema includes RLS policies. Make sure they're enabled:

1. Go to **Authentication** → **Policies**
2. Verify that RLS is enabled for all tables
3. Check that the policies from the schema are applied

## Step 8: Test the Integration

1. Run the Flutter app:
   ```bash
   flutter run
   ```

2. Test authentication:
   - Try signing up with a new email
   - Verify email confirmation works
   - Test sign in functionality

3. Test file uploads:
   - Try uploading a profile image
   - Test document uploads for orders

## Step 9: Environment-Specific Configuration

### Development
For development, you can use the default values in `supabase_config.dart` or set environment variables.

### Production
For production builds, set the environment variables:

```bash
flutter build web --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Troubleshooting

### Common Issues

1. **"Invalid API key" error**
   - Check that your anon key is correct
   - Ensure the key is not the service role key

2. **"Project not found" error**
   - Verify your project URL is correct
   - Check that your project is active

3. **Authentication not working**
   - Verify redirect URLs are configured
   - Check email templates are set up
   - Ensure RLS policies are correct

4. **File uploads failing**
   - Check bucket permissions
   - Verify file size limits
   - Check MIME type restrictions

### Debug Mode

Enable debug logging by setting `kDebugMode` to true in your app. This will show detailed logs for:
- Authentication operations
- Database queries
- File uploads/downloads
- Real-time subscriptions

## Security Best Practices

1. **Never commit credentials**: Always use `.env` files and add them to `.gitignore`
2. **Use RLS**: Row Level Security is enabled by default - don't disable it
3. **Limit permissions**: Use the anon key for client operations, service role key only for admin operations
4. **Validate inputs**: Always validate user inputs before sending to Supabase
5. **Monitor usage**: Keep an eye on your Supabase usage and billing

## Next Steps

1. **Set up real-time subscriptions** for live updates
2. **Configure edge functions** for complex business logic
3. **Set up monitoring** and alerts
4. **Implement offline support** using local storage
5. **Add push notifications** using Supabase's notification system

## Support

- **Supabase Documentation**: [supabase.com/docs](https://supabase.com/docs)
- **Flutter Supabase Package**: [pub.dev/packages/supabase_flutter](https://pub.dev/packages/supabase_flutter)
- **Community**: [github.com/supabase/supabase/discussions](https://github.com/supabase/supabase/discussions)
