import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';

// A model to represent a toy product
class Toy {
  final String id;
  final String name;
  final String category;
  final String rfidUid;
  final double price;
  final String imageUrl;

  Toy({
    required this.id,
    required this.name,
    required this.category,
    required this.rfidUid,
    required this.price,
    required this.imageUrl,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // --- NEW TOY CATALOG ---
  // 3 toys for each of the 4 categories
  static final List<Toy> _toys = [
    // Toy Guns
    Toy(id: 'TG01', name: 'Laser Ray Gun', category: 'Toy Guns', rfidUid: 'TG01_UID', price: 29.99, imageUrl: 'https://via.placeholder.com/150?text=Ray+Gun'),
    Toy(id: 'TG02', name: 'Water Blaster 3000', category: 'Toy Guns', rfidUid: 'TG02_UID', price: 19.99, imageUrl: 'https://via.placeholder.com/150?text=Water+Blaster'),
    Toy(id: 'TG03', name: 'Foam Dart Pistol', category: 'Toy Guns', rfidUid: 'TG03_UID', price: 14.99, imageUrl: 'https://via.placeholder.com/150?text=Foam+Pistol'),
    // Action Figures
    Toy(id: 'AF01', name: 'Galaxy Commander', category: 'Action Figures', rfidUid: 'AF01_UID', price: 12.99, imageUrl: 'https://via.placeholder.com/150?text=Galaxy+Commander'),
    Toy(id: 'AF02', name: 'Jungle Explorer', category: 'Action Figures', rfidUid: 'AF02_UID', price: 11.99, imageUrl: 'https://via.placeholder.com/150?text=Jungle+Explorer'),
    Toy(id: 'AF03', name: 'Ninja Warrior', category: 'Action Figures', rfidUid: 'AF03_UID', price: 13.99, imageUrl: 'https://via.placeholder.com/150?text=Ninja+Warrior'),
    // Dolls
    Toy(id: 'DL01', name: 'Princess Star', category: 'Dolls', rfidUid: 'DL01_UID', price: 22.99, imageUrl: 'https://via.placeholder.com/150?text=Princess+Star'),
    Toy(id: 'DL02', name: 'Fashionista Doll', category: 'Dolls', rfidUid: 'DL02_UID', price: 24.99, imageUrl: 'https://via.placeholder.com/150?text=Fashionista'),
    Toy(id: 'DL03', name: 'Baby Joy', category: 'Dolls', rfidUid: 'DL03_UID', price: 18.99, imageUrl: 'https://via.placeholder.com/150?text=Baby+Joy'),
    // Puzzles
    Toy(id: 'PZ01', name: '1000pc World Map', category: 'Puzzles', rfidUid: 'PZ01_UID', price: 15.99, imageUrl: 'https://via.placeholder.com/150?text=World+Map'),
    Toy(id: 'PZ02', name: '3D Wooden Dinosaur', category: 'Puzzles', rfidUid: 'PZ02_UID', price: 17.99, imageUrl: 'https://via.placeholder.com/150?text=Dino+Puzzle'),
    Toy(id: 'PZ03', name: 'Mystery Box Puzzle', category: 'Puzzles', rfidUid: 'PZ03_UID', price: 21.99, imageUrl: 'https://via.placeholder.com/150?text=Mystery+Box'),
  ];

  // --- NEW WORKER ASSIGNMENT LOGIC ---
  String _getAssignedPerson(String category) {
    switch (category) {
      case 'Toy Guns':
        return 'John Marwin';
      case 'Action Figures':
        return 'Jannalyn';
      case 'Dolls':
        return 'Marl Prince';
      case 'Puzzles':
        return 'Renz';
      default:
        return 'Unassigned';
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showOrderConfirmation(BuildContext context, Toy toy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text('Do you want to buy the ${toy.name} for \$${toy.price}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () {
              final provider = Provider.of<AppProvider>(context, listen: false);
              final assignedPerson = _getAssignedPerson(toy.category); // Get the correct worker

              provider.createOrder(
                toyId: toy.id,
                toyName: toy.name,
                category: toy.category,
                rfidUid: toy.rfidUid, // Corrected the typo here
                assignedPerson: assignedPerson, // Use the hardcoded worker name
                totalAmount: toy.price,
              );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _toys.map((t) => t.category).toSet().toList();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Toy Store'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((category) {
            final categoryToys = _toys.where((t) => t.category == category).toList();
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categoryToys.length,
              itemBuilder: (ctx, i) => _buildToyCard(context, categoryToys[i]),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildToyCard(BuildContext context, Toy toy) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              toy.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.toys, size: 80, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              toy.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '\$${toy.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showOrderConfirmation(context, toy),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
}
