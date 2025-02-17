import 'package:flutter/material.dart';
import 'package:tollcalculator/calculator/age_calculator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3),(){
    if(context.mounted)  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(_)=> AgeCalculatorScreen()), (v)=>false);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Material(color: Color(0xFFA9BDC9),
      child: Center(child: Image.asset('assets/logo.png'),),);
  }
}