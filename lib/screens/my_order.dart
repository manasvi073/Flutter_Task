import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/Model/product_model.dart';
import 'package:firebase_log/constant/colorConstant.dart';
import 'package:firebase_log/screens/photoview_screen.dart';
import 'package:flutter/material.dart';

class Myorder extends StatefulWidget {
  const Myorder({super.key});

  @override
  State<Myorder> createState() => _MyorderState();
}

class _MyorderState extends State<Myorder> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  void removeorder(String id) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('order')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My orders'),
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        backgroundColor: Colorconstant.appwhite,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('An error occur'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          List<QueryDocumentSnapshot> orderdocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orderdocs.length,
            itemBuilder: (context, index) {
              Productmodel product = Productmodel(
                userid: userId,
                id: orderdocs[index].id,
                name: orderdocs[index]['name'],
                description: orderdocs[index]['description'],
                price: orderdocs[index]['price'],
                imageURL: orderdocs[index]['imageURL'],
              );

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
                            const Divider(
                              endIndent: 10,
                              indent: 10,
                              color: Colorconstant.appgrey,
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left:200),
                              child: IconButton(
                                icon: const Icon(Icons.delete),
                                iconSize: 25,
                                onPressed: () async => await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: const Text(
                                        'Are you sure you want to cancel this order?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          removeorder(
                                              orderdocs[index].id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text('No'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
