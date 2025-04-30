import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/Model/user_model.dart';
import 'package:firebase_log/constant/colorConstant.dart';
import 'package:firebase_log/screens/configscreen.dart';
import 'package:firebase_log/validation/app_validation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/app_button.dart';
import '../widgets/app_textfield.dart';
import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_log/screens/signup_screen.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp();
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyLoginPage> {
  final GlobalKey<FormState> _formkey = GlobalKey();

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  bool _obscureText = true;


  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void btn() async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: emailcontroller.text.trim(),
            password: passwordcontroller.text.trim());

        User? user = userCredential.user;

        if (user != null) {
          debugPrint('Signed in as :${user.email}');
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Dashboard(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user not found') {
          errorMessage = 'user not found';
        } else if (e.code == 'password-incorrect') {
          errorMessage = 'Incorrect Password';
        } else {
          errorMessage = e.message ?? 'An unknown error occurred.';
        }
        Fluttertoast.showToast(msg: errorMessage);
      }
    }
  }

  Future<String?> getUserImage(String uid) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Usermodel user = Usermodel(
          userid: userDoc.id,
          username: userDoc['username'],
          email: userDoc['email'],
          bod: userDoc['bod'],
          imageURL: userDoc['imageURL'],
          time: (userDoc['time'] as Timestamp?)?.toDate(),
        );
        return user.imageURL;
      } else {
        debugPrint('User document does not exist.');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching image URL: $e');
      return null;
    }
  }

  void show() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colorconstant.appwhite,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
      ),
      body: Center(
        child: Form(
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                AppTextfield(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailcontroller,
                    validator: emailvalidation,
                    icon: Icons.mail),
                const SizedBox(height: 10),
                const Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Passwordtextfield(
                    controller: passwordcontroller,
                    validator: passvalidation,
                    ontap: show,
                    obscureText: _obscureText),
                const SizedBox(height: 10),
                AppBtn(text: 'Login', onpressed: btn),


                const SizedBox(height: 10),

               /* ElevatedButton(onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ConfigScreen()));
                }, child: Text('config screen')),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    GestureDetector(
                      onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (
                                context) => const SignUp()),
                          ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

