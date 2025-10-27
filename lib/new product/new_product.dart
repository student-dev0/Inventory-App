import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:store_keeper_app/new%20product/inventory_page.dart';

class NewProduct extends StatefulWidget {
  const NewProduct({super.key});

  @override
  State<NewProduct> createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  int _quantity = 1;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Request permission
    final status = await Permission.photos.request();

    if (!mounted) return; // Check if the widget is still in the tree.

    if (status.isGranted) {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } else if (status.isPermanentlyDenied) {
      // Guide user to app settings if permission is permanently denied
      openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo library permission was denied.")),
      );
    }
  }

  Future<void> _captureImage() async {
    // Request permission
    final status = await Permission.camera.request();

    if (!mounted) return; // Check if the widget is still in the tree.

    if (status.isGranted) {
      final captured = await _picker.pickImage(source: ImageSource.camera);
      if (captured != null) {
        setState(() => _imageFile = File(captured.path));
      }
    } else if (status.isPermanentlyDenied) {
      // Guide user to app settings if permission is permanently denied
      openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission was denied.")),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_productNameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    final box = Hive.box("products");
    final product = {
      'name': _productNameController.text,
      'quantity': _quantity,
      'price': _priceController.text,
      'imagePath': _imageFile?.path,
    };
    await box.add(product);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product added successfully')));

    // Resetting the field after saving the product
    setState(() {
      _productNameController.clear();
      _priceController.clear();
      _quantity = 1;
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InventoryPage()),
            );
          },
        ),
        title: Text("Add New Product"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                // Image Picker Container Gallery
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: screenHeight * 0.25,
                    width: screenWidth * 0.9,
                    decoration: BoxDecoration(
                      // color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: _imageFile == null
                          ? Border.all(
                              color: Colors.white,
                              style: BorderStyle.solid,
                              width: 2,
                            )
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.cover)
                          : DottedBorder(
                              options: RectDottedBorderOptions(
                                strokeWidth: 5,
                                dashPattern: [8, 3],
                                color: Colors.white,
                              ),
                              child: Container(
                                color: Colors.blueGrey.shade100,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: screenWidth * 0.1,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Tap to select image",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Capture Image from Camera
                GestureDetector(
                  onTap: _captureImage,
                  child: Container(
                    height: 60,
                    width: screenWidth * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: screenWidth * 0.008),
                          Text(
                            "Use Camera",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                // 🏷 Product Name
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(16),

                    strokeWidth: 1,
                    dashPattern: [6, 3],
                    color: Colors.blueGrey.shade300,
                    padding: EdgeInsets.all(16),
                  ),

                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            Text(
                              "Product Name",
                              style: GoogleFonts.quicksand(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextField(
                        controller: _productNameController,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.lato(),
                          labelText: 'Enter product name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Quantity Counter
                DottedBorder(
                  options: RectDottedBorderOptions(
                    strokeWidth: 1,
                    dashPattern: [5, 0],
                    color: Colors.blueGrey,
                    padding: EdgeInsets.all(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            icon: Icon(
                              Icons.remove_circle,
                              color: Colors.blue.shade200,
                            ),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _quantity++),
                            icon: Icon(
                              Icons.add_circle,
                              color: Colors.blue.shade200,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // 💵 Price Input
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(16),
                    strokeWidth: 1,
                    dashPattern: [10, 5],
                    padding: EdgeInsets.all(16),
                    color: Colors.blueGrey.shade300,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            Text(
                              "Product Name",
                              style: GoogleFonts.sourceSans3(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.lato(),
                          labelText: 'Enter price',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.1),

                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.8, 50),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Text(
                    "Add Product",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
