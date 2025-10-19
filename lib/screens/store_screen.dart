import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/toy.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _searchQuery = '';

  // Updated toy list with image placeholders
  static final List<Toy> _toys = [
    Toy(id: 'TG01', name: 'Laser Ray Gun', category: 'Toy Guns', rfidUid: 'TG01_UID', price: 29.99, imageUrl: 'assets/images/toy_gun_1.png'),
    Toy(id: 'TG02', name: 'Water Blaster 3000', category: 'Toy Guns', rfidUid: 'TG02_UID', price: 19.99, imageUrl: 'assets/images/toy_gun_2.png'),
    Toy(id: 'TG03', name: 'Foam Dart Pistol', category: 'Toy Guns', rfidUid: 'TG03_UID', price: 14.99, imageUrl: 'assets/images/toy_gun_3.png'),
    Toy(id: 'AF01', name: 'Galaxy Commander', category: 'Action Figures', rfidUid: 'AF01_UID', price: 12.99, imageUrl: 'assets/images/action_figure_1.png'),
    Toy(id: 'AF02', name: 'Jungle Explorer', category: 'Action Figures', rfidUid: 'AF02_UID', price: 11.99, imageUrl: 'assets/images/action_figure_2.png'),
    Toy(id: 'AF03', name: 'Ninja Warrior', category: 'Action Figures', rfidUid: 'AF03_UID', price: 13.99, imageUrl: 'assets/images/action_figure_3.png'),
    Toy(id: 'DL01', name: 'Princess Star', category: 'Dolls', rfidUid: 'DL01_UID', price: 22.99, imageUrl: 'assets/images/doll_1.png'),
    Toy(id: 'DL02', name: 'Fashionista Doll', category: 'Dolls', rfidUid: 'DL02_UID', price: 24.99, imageUrl: 'assets/images/doll_2.png'),
    Toy(id: 'DL03', name: 'Baby Joy', category: 'Dolls', rfidUid: 'DL03_UID', price: 18.99, imageUrl: 'assets/images/doll_3.png'),
    Toy(id: 'PZ01', name: '1000pc World Map', category: 'Puzzles', rfidUid: 'PZ01_UID', price: 15.99, imageUrl: 'assets/images/puzzle_1.png'),
    Toy(id: 'PZ02', name: '3D Wooden Dinosaur', category: 'Puzzles', rfidUid: 'PZ02_UID', price: 17.99, imageUrl: 'assets/images/puzzle_2.png'),
    Toy(id: 'PZ03', name: 'Mystery Box Puzzle', category: 'Puzzles', rfidUid: 'PZ03_UID', price: 21.99, imageUrl: 'assets/images/puzzle_3.png'),
  ];

  String _getAssignedPerson(String category) {
    switch (category) {
      case 'Toy Guns': return 'John Marwin';
      case 'Action Figures': return 'Jannalyn';
      case 'Dolls': return 'Marl Prince';
      case 'Puzzles': return 'Renz';
      default: return 'Unassigned';
    }
  }

  void _showOrderConfirmation(BuildContext context, Toy toy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text('Do you want to buy the ${toy.name} for \$${toy.price}?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () {
              final provider = Provider.of<AppProvider>(context, listen: false);
              final assignedPerson = _getAssignedPerson(toy.category);

              provider.createOrder(
                toyId: toy.id,
                toyName: toy.name,
                category: toy.category,
                rfidUid: toy.rfidUid,
                assignedPerson: assignedPerson,
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
    final filteredToys = _toys.where((toy) {
      return toy.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toy Store'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search toys...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredToys.length,
        itemBuilder: (ctx, i) => _buildToyCard(context, filteredToys[i]),
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
            child: Image.asset(
              toy.imageUrl, // Use Image.asset for local images
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.toys, size: 80, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(toy.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('\$${toy.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: ElevatedButton(onPressed: () => _showOrderConfirmation(context, toy), child: const Text('Buy Now')),
          ),
        ],
      ),
    );
  }
}
