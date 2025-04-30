import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/constant/colorConstant.dart';
import 'package:firebase_log/screens/photoview_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model/product_model.dart';

class Mycart extends StatefulWidget {
  const Mycart({super.key});

  @override
  State<Mycart> createState() => _MycartState();
}

class _MycartState extends State<Mycart> {
  final Map<String, bool> _favorite = {};

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
          title: const Text('My cart'),
          backgroundColor: Colorconstant.appwhite,
          elevation: 0.0,
          scrolledUnderElevation: 0.0),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items in the cart.'));
          }

          List<QueryDocumentSnapshot> cartdocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartdocs.length,
            itemBuilder: (context, index) {
              Productmodel product = Productmodel(
                userid: userId,
                id: cartdocs[index].id,
                name: cartdocs[index]['name'],
                description: cartdocs[index]['description'],
                price: cartdocs[index]['price'],
                imageURL: cartdocs[index]['imageURL'],
              );

              bool isFavorite = _favorite[product.id] ?? false;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Photoviewscreen(
                                  imageURL: product.imageURL ?? ''),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            height: 65,
                            width: 65,
                            fit: BoxFit.cover,
                            imageUrl: product.imageURL ?? '',
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colorconstant.appred,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text('Price: ${product.price}'),
                            const SizedBox(height: 5),
                            Text('Description: ${product.description}'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('cart')
                              .doc(product.id)
                              .delete();

                          Fluttertoast.showToast(
                              msg: '${product.name} removed from cart');

                          await FirebaseFirestore.instance
                              .collection('products')
                              .doc(product.id)
                              .update({'isFavorite': false});
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite_border : Icons.favorite,
                          color: isFavorite
                              ? Colorconstant.appgrey
                              : Colorconstant.appred,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
