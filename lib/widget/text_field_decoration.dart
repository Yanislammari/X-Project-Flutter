import 'package:flutter/material.dart';

InputDecoration textFieldMainDeco(String placeHolder){
  return InputDecoration(
    border: OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(10), // Set corner radius here
    ),
    labelText: placeHolder,
  );
}