import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TestShower extends StatelessWidget {
  final bool isOk;
  final String errMessage;
  const TestShower({
    Key? key,
    required this.isOk,
    required this.errMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      width: 150,
      height: 70,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isOk ? Colors.green : Colors.red),
      child: (errMessage.isNotEmpty)
          ? Center(
              child: AutoSizeText(
              errMessage,
              style: const TextStyle(color: Colors.white),
            ))
          : Container(),
    );
  }
}
