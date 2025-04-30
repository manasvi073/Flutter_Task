import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_log/Model/user_model.dart';
import 'package:firebase_log/validation/app_validation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_log/constant/colorConstant.dart';
import 'package:flutter/material.dart';
import 'package:firebase_log/screens/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_log/widgets/app_button.dart';
import 'package:firebase_log/widgets/app_textfield.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formkey = GlobalKey();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  TextEditingController birthdatedcontroller = TextEditingController();

  bool _isloading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    namecontroller.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
    confirmpasswordcontroller.dispose();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void show() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? confirmpasswordvalidation(String? value) {
    if (passwordcontroller.text.isEmpty) {
      return 'Enter your password';
    } else if (value == null || value.isEmpty) {
      return 'Please enter your confirm password';
    } else if (value != passwordcontroller.text) {
      return 'Confirm password does not match';
    }
    return null;
  }

  Future<void> signupbtn() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailcontroller.text.trim(),
          password: passwordcontroller.text.trim(),
        );

        await userCredential.user!
            .updateDisplayName(namecontroller.text.trim());

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyLoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'password') {
          errorMessage = 'password provided is  weak.';
        } else if (e.code == 'email-already-use') {
          errorMessage = 'account already exists.';
        } else if (e.code == 'email') {
          errorMessage = 'email address is not valid.';
        } else {
          errorMessage = e.message ?? 'unknown error occurred';
        }
        Fluttertoast.showToast(msg: errorMessage);
      }
    }

    DateTime? currenttime = DateTime.now();

    String? imageUrl;

    if (_selectedImage != null) {
      imageUrl = await uploadImage(_selectedImage!);
    }

    String userid = FirebaseAuth.instance.currentUser!.uid;

    addUserDetail(
        userid,
        namecontroller.text.trim(),
        emailcontroller.text.trim(),
        birthdatedcontroller.text.trim(),
        currenttime,
        imageUrl);
  }

  /* Future addUserDetail(String userid, String username, String email, String bod,
      DateTime? currenttime, String? imageUrl) async {
    FirebaseFirestore.instance.collection('users').doc(userid).set({
      'userid': userid,
      'username': username,
      'email': email,
      'time': currenttime,
      'imageURL': imageUrl,
      'bod': bod,
    });
  }*/

  Future addUserDetail(
    String userid,
    String username,
    String email,
    String bod,
    DateTime? currenttime,
    String? imageUrl,
  ) async {
    Usermodel user = Usermodel(
      userid: userid,
      username: username,
      email: email,
      time: currenttime,
      imageURL: imageUrl,
      bod: bod,
    );
    FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .set(user.toMap());
  }

  Future<String> uploadImage(File image) async {
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef =
          FirebaseStorage.instance.ref().child('profileimages/$imageName');
      var uploadTask = storageRef.putFile(image);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Image upload failed $e');
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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 37),
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery);
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
                                : const AssetImage('assets/icons/user.jpeg'),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 60, top: 50),
                              child: _selectedImage == null
                                  ? const Icon(
                                      Icons.camera_alt_sharp,
                                      size: 29,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const Text(
                          'Create an account',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        AppTextfield(
                            controller: namecontroller,
                            validator: (value) => emptyValidation(
                                value, 'Please enter your name'),
                            icon: Icons.account_box_rounded),
                        const SizedBox(height: 10),
                        const Text(
                          'Email Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        AppTextfield(
                            controller: emailcontroller,
                            validator: emailvalidation,
                            icon: Icons.mail),
                        const SizedBox(height: 10),
                        const Text(
                          'Birth Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: birthdatedcontroller,
                          decoration: InputDecoration(
                            // suffix: const Icon(Icons.date_range),
                            suffix: const Icon(Icons.date_range),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: bodvalidation,
                          readOnly: true,
                          onTap: () async {
                            DateTime? datepicked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2024),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now());
                            if (datepicked != null) {
                              birthdatedcontroller.text =
                                  DateFormat('dd-MM-yyyy').format(datepicked);
                            }
                          },
                        ),
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
                        const Text(
                          'Confirm password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          //keyboardType: TextInputType.text,
                          controller: confirmpasswordcontroller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: confirmpasswordvalidation,
                        ),
                        const SizedBox(height: 10),
                        AppBtn(text: 'Sign Up', onpressed: signupbtn),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isloading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
