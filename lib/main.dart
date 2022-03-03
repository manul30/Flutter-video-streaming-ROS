
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:linux_desktop/constant.dart';
import 'dart:math';
import 'package:roslib/roslib.dart';
import 'package:linux_desktop/quanterion.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_html/flutter_html.dart';


void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roslib Example',
      home: JoyStickPage(),
    );
  }
}


class JoyStickPage extends StatefulWidget {
  @override
  _JoyStickPageState createState() => _JoyStickPageState();
}

class _JoyStickPageState extends State<JoyStickPage> {
  late Ros ros;
  late Topic chatter;
  late Topic counter;
  late Topic cmd_vel;
  late Topic imu;
  late Topic camera;

  void _move(double _degrees, double _distance) {
    print(
        'Degree:' + _degrees.toString() + ' Distance:' + _distance.toString());
    double radians = _degrees * ((22 / 7) / 180);
    double linear_speed = cos(radians) * _distance;
    double angular_speed = -sin(radians) * _distance;

    publishCmd(linear_speed, angular_speed);
  }

  @override
  void initState() {
    ros = Ros(url: 'ws://0.0.0.0:9090');
    chatter = Topic(
        ros: ros,
        name: '/chatter',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    cmd_vel = Topic(
        ros: ros,
        name: '/cmd_vel',
        type: "geometry_msgs/Twist",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    counter = Topic(
      ros: ros,
      name: '/counter',
      type: "std_msgs/String",
      reconnectOnClose: true,
      queueSize: 10,
      queueLength: 10,
    );

    imu = Topic(
      ros: ros,
      name: 'imu',
      type: 'sensor_msgs/Imu',
      queueSize: 10,
      queueLength: 10,
    );

    camera = Topic(
      ros: ros,
      name: 'camera/image/compressed',
      type: 'sensor_msgs/CompressedImage',
      queueSize: 10,
      queueLength: 10,
    );

    super.initState();
  }

  void initConnection() async {
    ros.connect();
    await chatter.subscribe();
    await cmd_vel.subscribe();
    await imu.subscribe();
    await camera.subscribe();
    await counter.advertise();
    await cmd_vel.advertise();
    setState(() {});
  }

  void publishCounter() async {
    var msg = {'data': 'hello'};
    await counter.publish(msg);
    print('done published');
  }

  void publishCmd(double _linear_speed, double _angular_speed) async {
    var linear = {'x': _linear_speed, 'y': 0.0, 'z': 0.0};
    var angular = {'x': 0.0, 'y': 0.0, 'z': _angular_speed};
    var twist = {'linear': linear, 'angular': angular};
    await cmd_vel.publish(twist);
    print('cmd published');
    publishCounter();
  }

  void destroyConnection() async {
    await chatter.unsubscribe();
    await cmd_vel.unsubscribe();
    await imu.unsubscribe();
    await camera.unsubscribe();
    await counter.unadvertise();
    await ros.close();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roslib Example'),
      ),
      body: StreamBuilder<Object>(
      stream: ros.statusStream,
      builder: (context, snapshot) {
        return Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ActionChip(
                label: Text(snapshot.data == Status.CONNECTED
                    ? 'DISCONNECT'
                    : 'CONNECT'),
                backgroundColor: snapshot.data == Status.CONNECTED
                    ? Colors.green[300]
                    : Colors.grey[300],
                onPressed: () {
                  print(snapshot.data);
                  if (snapshot.data != Status.CONNECTED) {
                    this.initConnection();
                  } else {
                    this.destroyConnection();
                  }
                },
              ),
              Padding(padding: EdgeInsets.all(10)),
              Container(
              child: JoystickView(
                onDirectionChanged: ( double degrees, double distance) {
                    //vardegrees = degrees;
                    //vardistance = distance;
                    //degreesTF.text = vardegrees.toString();
                    //distance.text = vardistance.toString();
                    //print("degrees: ${vardegrees}");
                    //print("distance: ${vardistance}");
                    _move(degrees, distance);
                },
              ),),
              Padding(padding: EdgeInsets.all(20)),
              
                /*
                StreamBuilder(
                  stream: imu.subscription,
                  builder: (context2, AsyncSnapshot<dynamic> snapshot2) {
                    if (snapshot2.hasData){
                      print('-----------------------------');
                      print(snapshot2.data);
                      print('-----------------------------');
                      return Column(
                        children: [
                         Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                            Container(
                            height: 150,
                            child: Quanterion(),
                            ),
                            Container(
                            height: 150,
                            child: Quanterion(),
                            ),
                            Container(
                            height: 150,
                            child: Quanterion(),
                            ),
                              ],
                            ),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [                          
                            Text('orientation x : ${snapshot2.data['msg']['orientation']['x']}'),
                            Text('orientation y : ${snapshot2.data['msg']['orientation']['y']}'),
                            Text('orientation z : ${snapshot2.data['msg'] ['orientation']['z']}'),
                          ],
                          ),
                        ],
                        ),
                        ]
                      ); 
                       }
                    else{
                      return CircularProgressIndicator();
                    }
                  }
                  ),
                  */
                  StreamBuilder(
                    stream: camera.subscription,
                    builder: (context2,AsyncSnapshot<dynamic> snapshot2){
                      if (snapshot2.hasData){
                        //var x = snapshot2.data['data'];
                        //Uint8List _bytesImage = Base64Decoder().convert(snapshot2.data['msg']['data']);
                        /*
                        return Html(
                          
                          data: """<img src="data:https//image/jpeg;base64,${snapshot2.data['msg']['data']}" >"""
                                           
                        );
                        */
                        /*
                        return Text('${snapshot2.data['msg']['data']}') ; 
                        */

                        return getImagenBase64(snapshot2.data['msg']['data']);

                        /*
                        return ListTile(
                        
                        leading: Image.memory(Base64Decoder().convert(snapshot2.data['msg']['data'])),

                        );
                        */
                      }
                      else{
                        return CircularProgressIndicator();
                      }
                    }
                  ),
                ]
              ),
            
          );

      },
    ),
  
    );
  }
}



Widget getImagenBase64(String imagen) {
    var _imageBase64 = imagen;
    const Base64Codec base64 = Base64Codec();
    if (_imageBase64 == null) return new Container(child: Text('XD'),);
    var bytes = base64.decode(_imageBase64);
    return Image.memory(
          bytes,
          gaplessPlayback: true,
          width: 400,
          fit: BoxFit.fitWidth,
       
    );
  }



// roscore
// roslaunch rosbridge_server rosbridge_websocket.launch
// roslaunch turtlebot3_gazebo turtlebot3_empty_world.launch
// roslaunch turtlebot3_gazebo turtlebot3_world.launch model:=burger_for_autorace

