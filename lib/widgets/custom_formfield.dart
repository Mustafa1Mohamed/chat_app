import 'package:flutter/material.dart';

class CustomFormfield extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validation;
  final bool obsecureText;
  final void Function(String?) onSaved;
  const CustomFormfield({
    super.key,
    required this.hintText,
    required this.height,
    required this.validation,
    this.obsecureText = false,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        obscureText: obsecureText,
        validator: (value) {
          if (value != null && validation.hasMatch(value)) {
            return null;
          }
          return "Entere a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
