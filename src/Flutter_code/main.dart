import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';




void main()=>runApp(new MaterialApp(
  home: Bluetooth(),

));

class Bluetooth extends StatefulWidget {
  @override
  _BluetoothState createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;
  BluetoothDevice mydevice;
  String op="Press ConnectBT Button";
  Color status;
  String dropdownhour = '1';
  String dropdownminute = '0';
  String ampm="am";

  bool isConnectButtonEnabled=true;
  bool isDisConnectButtonEnabled=false;
 bool isHourSelect=false;
  bool isMinuteSelect=false;
  bool isSetDate=false;
  bool isAlarmSend=false;
 bool isClearAlarm=false;
 bool isAMPMSelect=false;









  void _connect() async  {

    List<BluetoothDevice> devices = [];
    setState(() {
      isConnectButtonEnabled=false;
      isDisConnectButtonEnabled=true;
      isSetDate=true;
     isHourSelect=true;
     isMinuteSelect=true;
     isAlarmSend=true;
     isClearAlarm=true;
     isAMPMSelect=true;
    });
    devices = await _bluetooth.getBondedDevices();
    // ignore: unnecessary_statements
    devices.forEach((device) {

      print(device);
      if(device.name=="HC-05")
      {
        mydevice=device;
      }
    });

    await BluetoothConnection.toAddress(mydevice.address)
        .then((_connection) {
      print('Connected to the device'+ mydevice.toString());
      _showtoastConnect();

      connection = _connection;});




    connection.input.listen(null).onDone(() {

      print('Disconnected remotely!');
    });

  }
  void _setdatetime()
  {


    connection.output.add(ascii.encode("${DateTime.now().year.toString()}:"));
    connection.output.add(ascii.encode("${DateTime.now().month.toString()}:"));
    connection.output.add(ascii.encode("${DateTime.now().day.toString()}:"));
    connection.output.add(ascii.encode("${DateTime.now().hour.toString()}:"));
    connection.output.add(ascii.encode("${DateTime.now().minute.toString()}:"));
    connection.output.add(ascii.encode("${DateTime.now().second.toString()}:"));
    //connection.output.add(ascii.encode("${DateTime.now().weekday.toString()}:"));
    print("${DateTime.now().year.toString()}:");

    setState((){isSetDate =false;});

  }

  void _alarmsend()
  {


        connection.output.add(ascii.encode("$dropdownhour:"));
        connection.output.add(ascii.encode("$dropdownminute:"));
        connection.output.add(ascii.encode("$ampm:"));


     setState((){isAlarmSend=false;});
  }

  void _clearalarm()
  {

      connection.output.add(ascii.encode('c'));



    setState((){isClearAlarm=false;});


  }

  void _disconnect()
  {

    setState(() {
      op="Disconnected";
      isConnectButtonEnabled=true;
      isDisConnectButtonEnabled=false;
      isSetDate=false;
      isHourSelect=false;
      isMinuteSelect=false;
      isAlarmSend=false;
      isClearAlarm=false;
      isAMPMSelect=false;
      ampm="am";
      dropdownhour="1";
      dropdownminute="0";
    });
    connection.close();
    connection.dispose();
    _showtoastDisConnect();
  }

  void _showtoastConnect()
  {

    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text("CONNECTED"),duration: Duration(seconds: 5),action: SnackBarAction(onPressed:(){ _scaffoldKey.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.hide);},label: "Close",),));

  }

  void _showtoastDisConnect(){
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: Text("DISCONNECTED"),duration: Duration(seconds: 5),action: SnackBarAction(onPressed:(){ _scaffoldKey.currentState.hideCurrentSnackBar(reason: SnackBarClosedReason.hide);},label: "Close",),));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Arduino Clock With LED Matrix ",style: TextStyle(color: Colors.white,),overflow: TextOverflow.visible,softWrap: false,),

        backgroundColor:Colors.grey[850],
      ),
     key:_scaffoldKey,backgroundColor: Colors.blueGrey,

      body:
      Column(
        children: [

          Center(
              child: Column(

                children: [

                  Card(color: Colors.white,elevation: 50,shadowColor: Colors.grey,
                    child:Text("Please make sure you paired your HC-05, its default password is 1234",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),),
                  )
                ],
              )
          ),


          Container(
            child: Row(

              children: [
                  SizedBox(width: 5,),

                Container(padding: EdgeInsets.all(5),child:FlatButton(onPressed:isConnectButtonEnabled?_connect:null ,child: Text("Connect BT",style: TextStyle(fontSize: 16,color: Colors.green[900]),),disabledColor: Colors.grey,color: Colors.amberAccent,)
                  ,),
                SizedBox(width: 16,),


                Container(padding: EdgeInsets.all(5),child:FlatButton(onPressed:isDisConnectButtonEnabled?_disconnect:null,child: Text("Disconnect BT",style:TextStyle(fontSize: 16,color:Colors.red[900])),disabledColor: Colors.grey,color: Colors.amberAccent,)
                  ,),

              ],
            ),
          ),
          SizedBox(height: 50),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(child: FlatButton(onPressed:isSetDate?_setdatetime:null, child: Text("Set Date/Time",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,wordSpacing: 5),),textColor: Colors.white,color: Colors.deepOrangeAccent,disabledColor: Colors.grey,),padding: EdgeInsets.all(10),),
                  Container(child: Center(child: Text("SET ALARM",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,letterSpacing: 18))),padding: EdgeInsets.all(16),color: Colors.grey,),
                  SizedBox(height: 20,),
                  Row(crossAxisAlignment: CrossAxisAlignment.center,children: [SizedBox(width: 10,),Text("Set Hour",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),textAlign: TextAlign.center,),SizedBox(width: 5,), selectHour(context),SizedBox(width: 5,),Text("Set Minute ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),SizedBox(width: 5,),selectMinute(context),SizedBox(width: 5,),Text("AM/PM ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),SizedBox(width: 5,),selectAMPM(context)], ),
                  SizedBox(height: 20,),
                  Container(child: FlatButton(onPressed:isAlarmSend?_alarmsend:null, child: Text("Send Selected Alarm",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),color: Colors.amberAccent,disabledColor: Colors.grey,),padding: EdgeInsets.all(16),),
                  SizedBox(height: 40,),
                  Container(child: FlatButton(onPressed:isClearAlarm?_clearalarm:null, child: Text("Clear Alarm",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),color: Colors.amberAccent,disabledColor: Colors.grey),padding: EdgeInsets.all(16),),
                ],
              ),

            ],
          )





        ],

      ),



    );

  }

  Widget selectHour(BuildContext context){
    return DropdownButton<String>(
      value: dropdownhour,
      icon: const Icon(Icons.arrow_drop_down_circle),
      iconSize: 16,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple,fontSize: 12),
      underline: Container(
        height: 2,
        width:2,


        color: Colors.deepPurpleAccent,
      ),
      onChanged:isHourSelect? (String newValue) {
        setState(() {
          dropdownhour = newValue;

        });
      }:null,
      items: <String>['1', '2', '3', '4','5','6','7','8','9','10','11','12']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget selectMinute(BuildContext context){
    return DropdownButton<String>(
      value: dropdownminute,
      icon: const Icon(Icons.arrow_drop_down_circle),
      iconSize: 16,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple,fontSize: 12),
      underline: Container(
        height: 2,
        width: 2,

        color: Colors.deepPurpleAccent,
      ),
      onChanged: isMinuteSelect? (String newValue) {
        setState(() {
          dropdownminute = newValue;

        });
      }:null,
      items: <String>['0','1', '2', '3', '4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value)
        );
      }).toList()
    );
  }


  Widget selectAMPM(BuildContext context){
    return DropdownButton<String>(
        value: ampm,
        icon: const Icon(Icons.arrow_drop_down_circle),
        iconSize: 16,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple,fontSize: 12),
        underline: Container(
          height: 2,
          width: 2,

          color: Colors.deepPurpleAccent,
        ),
        onChanged: isAMPMSelect? (String newValue) {
          setState(() {
            ampm = newValue;

          });
        }:null,
        items: <String>['am','pm']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
              value: value,
              child: Text(value)
          );
        }).toList()
    );
  }
}