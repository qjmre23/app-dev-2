import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://qcczvwfccyslhfjtnpnl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFjY3p2d2ZjY3lzbGhmanRucG5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4ODkyNjMsImV4cCI6MjA3NjQ2NTI2M30.uKSoy6RvasLbGL41hXuqGgGM0ro6pQBJYQaNftToCyg';

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user != null) {
        await client.from('users').insert({
          'id': response.user!.id,
          'username': username,
          'email': email,
          'department': 'General',
        });

        return {
          'user': {
            'id': response.user!.id,
            'username': username,
            'email': email,
            'department': 'General',
          },
          'token': response.session?.accessToken ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        return {
          'user': userData,
          'token': response.session?.accessToken ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  String _getAssignedPerson(String category) {
    switch (category) {
      case 'Toy Guns':
        return 'John Marwin Ebona';
      case 'Action Figures':
        return 'Jannalyn Cruz';
      case 'Dolls':
        return 'Prince Marl Lizandrelle Mirasol';
      case 'Puzzles':
        return 'Renz Christiane Ming';
      default:
        return 'Unassigned';
    }
  }

  Future<Map<String, dynamic>?> createOrder({
    required String toyId,
    required String toyName,
    required String category,
    required String rfidUid,
    required double totalAmount,
  }) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final assignedPerson = _getAssignedPerson(category);

      final response = await client.from('orders').insert({
        'user_id': userId,
        'toy_id': toyId,
        'toy_name': toyName,
        'category': category,
        'rfid_uid': rfidUid,
        'assigned_person': assignedPerson,
        'status': 'PENDING',
        'total_amount': totalAmount,
      }).select().single();

      return response;
    } catch (e) {
      print('Create order error: $e');
      throw Exception('Order creation failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Get orders error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getToys() async {
    try {
      final response = await client
          .from('toys')
          .select()
          .order('category', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Get toys error: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> watchUserOrders() {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
