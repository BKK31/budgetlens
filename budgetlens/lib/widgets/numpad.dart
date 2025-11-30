import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../build_provider.dart';
import '../models.dart';

class Numpad extends StatefulWidget{
  const Numpad({super.key});

  @override
  State<Numpad> createState() => _NumpadState();
}

class _NumpadState extends State<Numpad>{
  String currentInput = '';
  String selectedTag = '';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }
}