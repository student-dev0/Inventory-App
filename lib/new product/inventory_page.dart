import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'new_product.dart';
import 'product_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box box = Hive.box('products');

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory', style: GoogleFonts.roboto()),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box products, _) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products added yet!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products.getAt(index) as Map;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailPage(product: product, index: index),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product['imagePath'] != null
                          ? Image.file(
                              File(product['imagePath']),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.blue.shade50,
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    title: Text(
                      product['name'] ?? 'Unnamed Product',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${product['quantity']} units${product['quantity'] < 3 ? ' - Low stock' : ''}",
                      style: TextStyle(
                        color: product['quantity'] < 3
                            ? Colors.orange
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Text(
                      "\$${product['price']}",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewProduct()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
