import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/Model/product_model.dart';
import 'package:firebase_log/Model/user_model.dart';
import 'package:firebase_log/constant/colorConstant.dart';
import 'package:firebase_log/screens/my_cart.dart';
import 'package:firebase_log/screens/my_order.dart';
import 'package:firebase_log/screens/photoview_screen.dart';
import 'package:firebase_log/screens/view_detail.dart';
import 'manage_products.dart';
import 'package:firebase_log/screens/login_screen.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Map<String, bool> isFavorite = {};

  // Map<String, dynamic>? userData;
  Usermodel? usermodel;

  //List<Map<String, dynamic>> products = [];
  List<Productmodel> products = [];

  bool isloading = false;

  @override
  void initState() {
    super.initState();
    fetchuserdata();
    checkCart();
  }

  /* Future<void> fetchuserdata() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userdoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    setState(() {
      userData = userdoc.data() as Map<String, dynamic>;
    });
  }*/

//USING USERMODEL..

  Future<void> fetchuserdata() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userdoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userdoc.exists) {
      setState(() {
        usermodel = Usermodel(
          userid: userdoc['userid'],
          username: userdoc['username'],
          email: userdoc['email'],
          bod: userdoc['bod'],
          imageURL: userdoc['imageURL'],
          time: (userdoc['time'] as Timestamp?)?.toDate(),
        );
      });
    }
  }

  /*USING SINGLE COLLECTION....as products field..

   Future<void> fetchProducts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await  FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      List<dynamic> productData = userDoc['products'] ?? [];
      setState(() {
        products = productData.cast<Map<String, dynamic>>();
      });
    }
  }*/

//USING PRODUCT MODEL..
  Stream<List<Productmodel>> fetchProducts() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference productsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products');

    return productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        return Productmodel(
          userid: userId,
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: data['price'] ?? '',
          imageURL: data['imageURL'] ?? '',
        );
      }).toList();
    });
  }

  /*USING SUB_COLLECTION..

  Future<void> fetchProducts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference productsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products');

    QuerySnapshot snapshot = await productsRef.get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;

    setState(() {
      products = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }*/

  void updateProduct(Productmodel product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Manageproducts(product: product),
      ),
    );

    if (result == true) {
      fetchProducts();
    }
  }

  /*
  void updateProduct(Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProduct(product: product),
      ),
    );
    if (result == true) {
      fetchProducts();
    }
  }*/

  void deleteProduct(String id) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('products')
        .doc(id)
        .delete();
    fetchProducts();
  }

  /* void deleteProduct() async {
    String userid = FirebaseAuth.instance.currentUser!.uid;
    await  FirebaseFirestore.instance.collection('users').doc(userid).update({
      'products': FieldValue.arrayRemove(['id'])
    });
  }
*/

  void checkCart() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .listen((QuerySnapshot cartSnapshot) {
      setState(() {
        isFavorite.clear();
        for (var doc in cartSnapshot.docs) {
          isFavorite[doc.id] = true;
        }
      });
    });
  }

  void addToCart(Productmodel product) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot cartDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(product.id)
        .get();

    if (cartDoc.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(product.id)
          .delete();

      setState(() {
        isFavorite[product.id] = false;
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(product.id)
          .set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageURL': product.imageURL,
      });

      setState(() {
        isFavorite[product.id] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colorconstant.appwhite,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
      ),

      /*body: StreamBuilder(
        stream:  FirebaseFirestore.instance.collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var userDoc = snapshot.data?.data();
          List<dynamic> productData = userDoc?['products'] ?? [];

          if (productData.isEmpty) {
            return const Center(child: Text('No products added.'));
          }

          products = productData.cast<Map<String, dynamic>>();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];

              return Card(
                elevation: 5,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: product['imageURL'] ?? '',
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: Colorconstant.Appred),
                        imageBuilder: (context, ImageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: ImageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    radius: 30,
                  ),
                  title: Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: ${product['price']}'),
                      Text('Description: ${product['description']}'),
                      const Divider(thickness: 1, color: Colorconstant.Appgrey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            iconSize: 25,
                            onPressed: () => updateProduct(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            iconSize: 25,
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: const Text(
                                      'Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                deleteProduct(product);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),*/

      body: StreamBuilder<List<Productmodel>>(
        stream: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              isloading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('An Error occur:'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.none) {
            return const Center(
                child:
                    Text('You are not connected to internet,please try again'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data added'));
          } else {
            List<Productmodel> productDocs = snapshot.data!;
            return ListView.builder(
              itemCount: productDocs.length,
              itemBuilder: (context, index) {
                //var product = productDocs[index].data() as Map<String, dynamic>;

                //Does not update direct into firestore

                // var product = products[index];

                //Direct update to firestore

                //Productmodel product = productDocs[index];

                Productmodel product = Productmodel(
                  userid: userId,
                  id: productDocs[index].id,
                  name: productDocs[index].name,
                  description: productDocs[index].description,
                  price: productDocs[index].price,
                  imageURL: productDocs[index].imageURL,
                );

                bool _isfavorite = isFavorite[product.id] ?? false;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Viewdetail(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Photoviewscreen(
                                    imageURL: product.imageURL ?? ''),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            height: 65,
                            width: 65,
                            fit: BoxFit.cover,
                            //imageUrl: product['imageURL'] ?? '',
                            imageUrl: product.imageURL ?? '',
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colorconstant.appred),
                          ),
                        ),
                      ),
                      title: Text(
                        //product['name'],
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text('Price: ${const product['price']}'),
                          Text('Price: ${product.price}'),

                          // Text('Description: ${product['description']}'),
                          Text('Description: ${product.description}'),

                          const Divider(
                              thickness: 1, color: Colorconstant.appgrey),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    _isfavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isfavorite
                                        ? Colorconstant.appred
                                        : Colorconstant.appgrey,
                                  ),
                                  onPressed: () {
                                    addToCart(product);
                                  }),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                iconSize: 25,
                                onPressed: () => updateProduct(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                iconSize: 25,
                                onPressed: () async => await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: const Text(
                                        'Are you sure you want to delete this product?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deleteProduct(productDocs[index].id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
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
              },
              padding: const EdgeInsets.only(bottom: 70),
            );
          }
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  color: Colorconstant.apppurple.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: (usermodel != null)
                  //(userData != null)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Photoviewscreen(
                                      imageURL: usermodel!.imageURL ?? ''),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              //imageUrl: product['imageURL'] ?? '',
                              imageUrl: usermodel!.imageURL ?? '',
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Icon(
                                  Icons.error,
                                  color: Colorconstant.appred),
                            ),
                          ),
                        ),

                        /* backgroundImage: userData!['imageURL'] != null
                              ? NetworkImage(userData!['imageURL'])
                              : const AssetImage('assets/icons/user.jpeg')
                                  as ImageProvider,

                        ),*/

                        const SizedBox(height: 5),
                        Text(
                          // 'Name: ${userData!['username']}',
                          'Name: ${usermodel!.username}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          //'Email: ${userData!['email']}',
                          'Email: ${usermodel!.email}',

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const ListTile(
                title: Text('Home'),
              ),
            ),
            const Divider(
              thickness: 1,
              endIndent: 8,
              indent: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Mycart(),
                  ),
                );
              },
              child: const ListTile(
                title: Text('My cart'),
              ),
            ),
            const Divider(
              thickness: 1,
              endIndent: 8,
              indent: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Myorder(),
                  ),
                );
              },
              child: const ListTile(
                title: Text('My order'),
              ),
            ),
            const Divider(
              thickness: 1,
              endIndent: 8,
              indent: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyLoginPage(),
                  ),
                );
              },
              child: const ListTile(
                title: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Manageproducts(),
              ),
            );
          },
          child: const Text(
            '+',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
