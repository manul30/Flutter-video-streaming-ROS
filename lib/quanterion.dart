import 'package:linux_desktop/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_math/vector_math.dart';

class Quanterion extends StatefulWidget{
  const Quanterion({
    Key? key,
  }):super(key: key);

  @override
  _QuanterionState createState() => _QuanterionState();
}

class _QuanterionState extends State<Quanterion>{

  double angle = 0;

  
  void mySetState(double angle) {
    setState(() {
      angle = angle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
                  height: 135,
                  width: 135,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: darkColor,
                  ),
                  child: Expanded(
                    child: Transform.rotate(
                      angle: radians(angle),
                      child: SvgPicture.asset('assets/piy.svg'),
                      ),
                  ),
                  );
  }


}


