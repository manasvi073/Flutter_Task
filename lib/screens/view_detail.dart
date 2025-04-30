import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/Model/product_model.dart';
import 'package:firebase_log/constant/colorConstant.dart';
import 'package:firebase_log/screens/payment_screen.dart';
import 'package:flutter/material.dart';

class Viewdetail extends StatefulWidget {
  final Productmodel product;

  const Viewdetail({super.key, required this.product});

  @override
  State<Viewdetail> createState() => _ViewdetailState();
}

class _ViewdetailState extends State<Viewdetail> {
  final Map<String, bool> isFavorite = {};
  int _currentIndex = 0;

  final List<String> imageList = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg',
    'https://example.com/image4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    checkCart();
  }

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
    double price = double.tryParse(widget.product.price) ?? 0.0;
    double discount = price * 0.10;
    double discountedPrice = price - discount;

    bool _isfavorite = isFavorite[widget.product.id] ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colorconstant.appwhite,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.only(left: 220),
          child: IconButton(
              icon: Icon(
                _isfavorite ? Icons.favorite : Icons.favorite_border,
                color:
                    _isfavorite ? Colorconstant.appred : Colorconstant.appgrey,
              ),
              onPressed: () {
                addToCart(widget.product);
              }),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 350,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reverse) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: imageList.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return CachedNetworkImage(
                        imageUrl: widget.product.imageURL ?? '',
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.red),
                        fit: BoxFit.cover,
                        width: 300,
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _currentIndex = entry.key;
                    }),
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? Colorconstant.apppurple
                            : Colorconstant.appgrey,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Text(
                ' ${widget.product.name}',
                style:
                    const TextStyle(fontSize: 16, color: Colorconstant.appgrey),
              ),
              const SizedBox(height: 10),
              Text(
                ' ${widget.product.description}',
                style:
                    const TextStyle(fontSize: 16, color: Colorconstant.appgrey),
              ),
              const SizedBox(height: 10),
              Text(
                // 'MRP:-${widget.product.price}',
                'Original price:- $price',

                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text('10% off'),
              const SizedBox(height: 10),
              Text(
                'Discount:$discount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Price: $discountedPrice',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /*Expanded(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colorconstant.apppurple),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Add to cart'),
              ),
            ),*/
            // const SizedBox(width: 16),
            Expanded(
              child: TextButton(
                onPressed: () async {
                  bool? confirmorder = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('confirm order'),
                      content: const Text(
                          'Are you sure you want to add this order?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('confirm')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('cancel')),
                      ],
                    ),
                  );

                  if (confirmorder == true) {
                    String userId = FirebaseAuth.instance.currentUser!.uid;

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('order')
                        .doc(widget.product.id)
                        .set({
                      'id': widget.product.id,
                      'name': widget.product.name,
                      'description': widget.product.description,
                      'price': widget.product.price,
                      'imageURL': widget.product.imageURL,
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PaymentScreen(product: widget.product)),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colorconstant.apppurple),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Buy now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
