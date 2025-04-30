import 'package:flutter/material.dart';

class AppTextfield extends StatelessWidget {
  AppTextfield(
      {super.key,
      required this.controller,
      required this.validator,
      this.icon,
      this.keyboardType = TextInputType.name,
      this.hinttext});

  TextEditingController controller;
  String? Function(String?)? validator;
  IconData? icon;
  TextInputType keyboardType;
  String? hinttext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          hintText: hinttext,
          suffix: Icon(icon),
          //suffix: icon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class Passwordtextfield extends StatelessWidget {
  Passwordtextfield(
      {super.key,
      required this.controller,
      required this.validator,
      required this.ontap,
      required this.obscureText});

  TextEditingController? controller;
  String? Function(String?)? validator;
  final void Function()? ontap;
  bool obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          suffix: InkWell(
            onTap: ontap,
            child: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
