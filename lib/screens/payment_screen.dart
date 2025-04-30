import 'package:firebase_log/Model/product_model.dart';
import 'package:firebase_log/constant/colorConstant.dart';
import 'package:firebase_log/screens/payment_success.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final Productmodel product;

  const PaymentScreen({super.key, required this.product});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    double price = double.tryParse(widget.product.price) ?? 0.0;
    double discount = price * 0.10;
    double discountedPrice = price - discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colorconstant.appwhite,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Payment detail',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Original price: $price',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const Text(
              '10% off',
              style: TextStyle(fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 10),
            Text(
              'Discount: $discount',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const Divider(
              indent: 50,
              endIndent: 50,
            ),
            Text(
              'Total price: $discountedPrice',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentSuccess()),
                  );
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colorconstant.apppurple),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Proceed payment')),
          ],
        ),
      ),
    );
  }
}
