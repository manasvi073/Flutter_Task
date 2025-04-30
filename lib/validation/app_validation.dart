import 'package:intl/intl.dart';

String? emptyValidation(String? value, String errorMessage) {
  if (value == null || value.isEmpty) {
    return errorMessage;
  }
  return null;
}

String? emailvalidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  } else if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]').hasMatch(value)) {
    return 'Enter valid email';
  }
  return null;
}

String? passvalidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  } else if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  return null;
}

String? bodvalidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your birth date';
  }

  DateTime? birthdate;
  try {
    birthdate = DateFormat('dd-mm-yyyy').parse(value);
  } catch (e) {
    return 'Enter valid birth date';
  }
  DateTime today = DateTime.now();
  int yeardiff = today.year - birthdate.year;
  int monthdiff = today.month - birthdate.month;
  int daydiff = today.day - birthdate.day;

  if (yeardiff > 18 ||
      (yeardiff == 18 && monthdiff > 0) ||
      (yeardiff == 18 && monthdiff == 0 && daydiff >= 0)) {
    return null;
  } else {
    return 'You are not 18 years old';
  }
}
