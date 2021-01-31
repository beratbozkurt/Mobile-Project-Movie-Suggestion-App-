import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'homescreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}
SharedPreferences preferences;
class _loginState extends State<login> {
  String _connectionStatus = '';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySub;

  bool rm=false;
  @override
  void initState() {

    super.initState();
    ConnectivityCheck();
    _connectivitySub = _connectivity.onConnectivityChanged.listen(ConnectionStatus);
    getPref();

  }
  Future<void> ConnectivityCheck() async {
    ConnectivityResult result = ConnectivityResult.none;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return ConnectionStatus(result);
  }
  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }
  Future<void> ConnectionStatus(ConnectivityResult result) async {
    switch (result) {

      case ConnectivityResult.wifi:
        setState(() => _connectionStatus = 'Success');
        print('wifi');
        break;
      case ConnectivityResult.mobile:
        setState(() => _connectionStatus = 'Success');
        print('mobile');
        break;
      case ConnectivityResult.none:
        setState(() => _connectionStatus = 'Failed');
        print('No Connection');
        break;
      default:
        setState(() => _connectionStatus = 'Failed');
        break;
    }
  }

  getPref() async{
    preferences= await SharedPreferences.getInstance();

    setState(() {    /*Remember me process*/
      rm=preferences.getBool("remember") ?? false;
      _mailController.text= preferences.getString("name") ?? "";
      _passwordController.text=preferences.getString("password")?? "";
    });


  }

  final GlobalKey<ScaffoldState> _scaffoldLogin = new GlobalKey<ScaffoldState>();

  authentication authSer = new authentication();
  // Variables
  TextEditingController _mailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool login = true;
  List<bool> c = [true, false];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Stack(
        children: [
          Image.asset(
            "asset/login.jpg",
            height: size.height,
            width: size.width,
            fit: BoxFit.cover,
          ),
          Scaffold(
            key:_scaffoldLogin ,
            backgroundColor: Colors.transparent,
            body: SizedBox.expand(
              child: ListView(
                children: [
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Container(
                    height: size.height * 0.25,
                    child: Image.asset(
                      "asset/icon.png",
                      height: size.height * 0.024,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: card("Log in", c[0], size),
                        onTap: () {

                          setState(() {
                            c[1] = false;
                            c[0] = true;
                            login = true;
                          });
                        },
                      ),
                      GestureDetector(
                        child: card("Sign up", c[1], size),
                        onTap: () {
                          setState(() {
                            c[0] = false;
                            c[1] = true;
                            login = false;
                          });

                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  login
                      ? Column(
                          children: [
                            info("Log in", size),
                            Row(
                              children: [
                                SizedBox(
                                  width: size.width * 0.07,
                                ),
                                Checkbox(
                                  activeColor: Colors.amber,
                                  value: rm,
                                  onChanged: (newValue) {
                                    setState(() {
                                      rm = newValue;
                                      preferences.setBool("remember", rm);
                                      preferences.setString("name", _mailController.text);
                                      preferences.setString("password", _passwordController.text);


                                    });

                                  },
                                ),
                                Text(
                                  "Remember me",
                                  style: TextStyle(
                                      color: CupertinoColors
                                          .extraLightBackgroundGray,
                                      fontSize: 14),
                                ),
                              ],
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: size.width * 0.83,
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                controller: _nameController,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  labelStyle: TextStyle(
                                    color: CupertinoColors
                                        .extraLightBackgroundGray,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: CupertinoColors.systemYellow,
                                        width: 1.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: CupertinoColors.systemYellow,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.04),
                            info("Sign up", size),
                          ],
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  card(String s, bool c, Size size) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      child: Container(
        height: size.height * 0.1,
        width: size.width * 0.18,
        child: Column(
          children: [
            Text(
              s,
              style: TextStyle(
                fontSize: 15.0,
                color: c ? Colors.amber : Colors.white,
              ),
            ),
            Divider(
              color: c ? Colors.amber : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  info(String s, Size size) {
    return Column(
      children: [
        Container(
          width: size.width * 0.83,
          child: TextField(
            controller: _mailController,
            obscureText: false,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: TextStyle(
                color: CupertinoColors.extraLightBackgroundGray,
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CupertinoColors.systemYellow,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(15.0)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CupertinoColors.systemYellow,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.04),
        Container(
          width: size.width * 0.83,
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: TextStyle(
                color: CupertinoColors.extraLightBackgroundGray,
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CupertinoColors.systemYellow,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(15.0)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CupertinoColors.systemYellow,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.05,
        ),
        Container(
          width: size.width * 0.2,
          height: size.height * 0.06,
          child: Center(
            child: RaisedButton(
              color: Colors.transparent.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: CupertinoColors.black)),
              child: Text(
                s,
                style: TextStyle(
                  color: CupertinoColors.extraLightBackgroundGray,fontSize: size.width*0.035
                ),
              ),
              onPressed: () async{
                if(_connectionStatus == 'Failed'){
                  _scaffoldLogin.currentState
                      .showSnackBar(
                      new SnackBar(content: new Text("No internet Connection")));
                }
                else{

                setState(() {
                  if(s=="Sign up"){
                    authSer.SignUp(_mailController.text, _passwordController.text, _nameController.text).then((value) {

                          _scaffoldLogin.currentState
                              .showSnackBar(
                              new SnackBar(content: new Text(value)));
                    });
                  }else{
                      if(!rm){
                        preferences.setString("name", "");
                        preferences.setString("password", "");
                      }

                      authSer.SignIn(_mailController.text, _passwordController.text).then((value){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(value)));
                    }
                    );


                  }


                });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
