import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_keeper_app/new%20product/inventory_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Map product;
  final int index;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late int _quantity;
  File? _imageFile;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _priceController = TextEditingController(text: widget.product['price']);
    _quantity = widget.product['quantity'];
    if (widget.product['imagePath'] != null) {
      _imageFile = File(widget.product['imagePath']);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _updateProduct() async {
    final box = Hive.box('products');
    final updatedProduct = {
      'name': _nameController.text,
      'quantity': _quantity,
      'price': _priceController.text,
      'imagePath': _imageFile?.path,
    };
    await box.putAt(widget.index, updatedProduct);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully!')),
    );
    setState(() => _isEditing = false);
  }

  Future<void> _deleteProduct() async {
    final box = Hive.box('products');
    await box.deleteAt(widget.index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: BackButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InventoryPage()),
          ),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //Product Image
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 250,
                          width: double.infinity,
                          color: Colors.blue.shade100,
                          child: const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

              //  Product Info
              if (!_isEditing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.product['name'],
                          style: GoogleFonts.quicksand(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color:
                          Colors.grey, // Optional: set the color of the divider
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),

                    Row(
                      children: [
                        Text(
                          "Quantity: ${widget.product['quantity']} in stock",
                          style: GoogleFonts.lato(fontSize: 16),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      color:
                          Colors.grey, // Optional: set the color of the divider
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Text(
                      "Price: \$${widget.product['price']} per unit",
                      style: GoogleFonts.lato(fontSize: 16),
                    ),
                  ],
                ),

              //  Edit Mode UI
              if (_isEditing)
                Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: GoogleFonts.quicksand(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Quantity: ", style: GoogleFonts.quicksand()),
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) setState(() => _quantity--);
                          },
                          icon: const Icon(Icons.remove_circle),
                        ),
                        Text('$_quantity', style: GoogleFonts.lato()),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: GoogleFonts.quicksand(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),

              SizedBox(height: screenHeight * 0.30),

              //  Edit / Delete Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isEditing) {
                          _updateProduct();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Save' : 'Edit',
                        style: GoogleFonts.openSans(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _deleteProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.openSans(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
