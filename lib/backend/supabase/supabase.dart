import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

export 'database/database.dart';

const _kSupabaseUrl = 'https://pglomkhepyjakvbuqoag.supabase.co';
const _kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbG9ta2hlcHlqYWt2YnVxb2FnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAxNzU3MzIsImV4cCI6MjAzNTc1MTczMn0.fmQXFa3o0OAF8uBR9r7Js4t-zTTRG9bC238ZQNUjZxw';

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        anonKey: _kSupabaseAnonKey,
        debug: false,
      );
}
