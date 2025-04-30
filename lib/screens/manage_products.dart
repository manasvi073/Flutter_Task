import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/Model/product_model.dart';
import 'package:firebase_log/validation/app_validation.dart';
import 'package:firebase_log/widgets/app_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constant/colorConstant.dart';
import '../widgets/app_button.dart';

class Manageproducts extends StatefulWidget {
  final Productmodel? product;

  const Manageproducts({super.key, this.product});

  @override
  State<Manageproducts> createState() => _ManageproductsState();
}

class _ManageproductsState extends State<Manageproducts> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formkey = GlobalKey();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  bool _isloading = false;

  String uuid = const Uuid().v4();

  @override
  void dispose() {
    namecontroller.dispose();
    pricecontroller.dispose();
    descriptioncontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      namecontroller.text = widget.product!.name;
      pricecontroller.text = widget.product!.price.toString();
      descriptioncontroller.text = widget.product!.description;
    }
  }

  /* Future<void> addbtn() async {
    if (_formkey.currentState!.validate()) {
      if (_selectedImage == null) {
        Fluttertoast.showToast(msg: "Please select image .");
        return;
      }

      setState(() {
        _isloading = true;
      });

      try {
        String userid = FirebaseAuth.instance.currentUser!.uid;

        String imageurl = await uploadImage(_selectedImage!);

        await addProductList(
          userid,
          namecontroller.text.trim(),
          uuid,
          pricecontroller.text.trim(),
          decsriptioncontroller.text.trim(),
          imageurl,
        );

        Fluttertoast.showToast(msg: "Product added successfully!");
      } catch (e) {
        Fluttertoast.showToast(msg: "Product not add..: $e");
      } finally {
        setState(() {
          _isloading = false;
        });
      }
      Navigator.pop(
          context, MaterialPageRoute(builder: (context) => const Dashboard()));
    }
  }

  Future addProductList(String userid, String productName, String productId,
      String price, String description, String? imageurl) async {
    FirebaseFirestore.instance.collection('users').doc(userid).set({
      'products': FieldValue.arrayUnion([
        {
          'name': productName,
          'id': productId,
          'price': price,
          'description': description,
          'imageURL': imageurl,
        }
      ])
    }, SetOptions(merge: true));
  }*/

  Future<void> handleProduct() async {
    if (_formkey.currentState!.validate()) {
      if (_selectedImage == null && widget.product == null) {
        Fluttertoast.showToast(msg: 'Please select an image.');
        return;
      }
      setState(() {
        _isloading = true;
      });

      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        String imageUrl = widget.product?.imageURL ?? '';

        if (_selectedImage != null) {
          imageUrl = await uploadImage(_selectedImage!);
        }

        String productId = widget.product?.id ?? uuid;

        Productmodel product = Productmodel(
          userid: userId,
          id: productId,
          name: namecontroller.text.trim(),
          price: pricecontroller.text.trim(),
          description: descriptioncontroller.text.trim(),
          imageURL: imageUrl,
        );

        if (widget.product != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('products')
              .doc(productId)
              .update(product.toMap());

          Fluttertoast.showToast(msg: 'Product updated successfully.');
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('products')
              .doc(productId)
              .set(product.toMap());

          Fluttertoast.showToast(msg: 'Product added successfully.');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: $e');
      } finally {
        setState(() {
          _isloading = false;
        });

        Navigator.pop(context);
      }
    }
  }

  /*..........................Without using product model......................

  Future<void> addbutton() async {
    if (_formkey.currentState!.validate()) {
      if (_selectedImage == null) {
        Fluttertoast.showToast(msg: 'Please select image..');
        return;
      }
      setState(() {
        _isloading = true;
      });
      try {
        String userid = FirebaseAuth.instance.currentUser!.uid;
        String imageurl = await uploadImage(_selectedImage!);
        addProductList(
          userid,
          uuid,
          namecontroller.text.trim(),
          decsriptioncontroller.text.trim(),
          imageurl,
          pricecontroller.text.trim(),
        );

        Fluttertoast.showToast(msg: 'Products add successfully');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Product not add $e');
      } finally {
        setState(() {
          _isloading = false;
        });
      }
      Navigator.pop(context);
    }
  }


   Future addProductList(
    String userid,
    String id,
    String name,
    String description,
    String? imageurl,
    String price,
  ) async {
    FirebaseFirestore.instance.collection('users').doc(userid).collection('products').doc(id).set({
      'id': id,
      'name': name,
      'description': description,
      'imageURL': imageurl,
      'price': price,
    });
  }
*/

  Future<String> uploadImage(File image) async {
    try {
      var imageName = DateTime.now().millisecondsSinceEpoch.toString();
      var reference =
          FirebaseStorage.instance.ref().child('productimage/$imageName');
      var uploadTask = reference.putFile(image);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colorconstant.appwhite,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
      ),
      body: Form(
        key: _formkey,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 30),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 160),
                  child: GestureDetector(
                    onTap: () async {
                      final pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);

                      if (pickedFile != null) {
                        setState(() {
                          _selectedImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.product?.imageURL != null
                                  ? NetworkImage(widget.product!.imageURL!)
                                  : const AssetImage('assets/icons/image.jpg'))
                              as ImageProvider,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 60, top: 50),
                        child: _selectedImage == null &&
                                (widget.product?.imageURL == null)
                            ? const Icon(
                                Icons.camera_alt_sharp,
                                size: 29,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.product != null ? 'Edit' : 'Add'} Product',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                AppTextfield(
                  hinttext: 'Enter product name',
                  controller: namecontroller,
                  validator: (value) =>
                      emptyValidation(value, 'Please enter product name'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                AppTextfield(
                  hinttext: 'Enter product price',
                  keyboardType: TextInputType.number,
                  controller: pricecontroller,
                  validator: (value) =>
                      emptyValidation(value, 'Please enter price'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                AppTextfield(
                  hinttext: 'Enter product description',
                  controller: descriptioncontroller,
                  validator: (value) =>
                      emptyValidation(value, 'Please enter description'),
                ),
                const SizedBox(height: 20),
                AppBtn(
                    text: widget.product != null ? 'Edit' : 'Add',
                    onpressed: handleProduct),
              ],
            ),
            if (_isloading)
              Container(
                color: Colorconstant.appblack.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
