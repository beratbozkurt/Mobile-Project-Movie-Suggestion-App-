import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitleB extends StatelessWidget {
  String s;
  TitleB(this.s);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipOval(
            child: Material(
              color: Colors.transparent, // button color
              child: InkWell(
                splashColor: Colors.grey, // inkwell color
                child: SizedBox(width: 56, height: 56, child: Icon(Icons.arrow_back,color: CupertinoColors.extraLightBackgroundGray,)),
                onTap: () {
                  Navigator.pop(context, '/home');
                },
              ),
            ),
          ),
          Text(s),
        ],
      ),
    );
  }
}
