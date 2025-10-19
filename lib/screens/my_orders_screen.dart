import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.orders.isEmpty) {
            return const Center(child: Text('You have no orders yet.'));
          }
          return ListView.builder(
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];
              return ListTile(
                leading: const Icon(Icons.receipt),
                title: Text(order.toyName),
                subtitle: Text('Status: ${order.status}'),
                trailing: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
