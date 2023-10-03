import 'dart:convert';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'scanner.dart';
//import 'package:permission_handler/permission_handler.dart';

//import 'Listofmyscan.dart';
import 'detail.dart';
import 'user.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String email, password;
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    Uri _uri = Uri.parse("https://billet.pylcrm.com/api/loginapi?email=" +
        email +
        "&password=" +
        password);
    print(_uri);

    final response = await http.get(_uri);
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message, emailAPI, nameAPI, mobileAPI;
    if (data['message'] == null)
      message = '';
    else
      message = data['message'];
    if (data['message'] != null)
      emailAPI = data['email'];
    else
      emailAPI = '';
    if (data['message'] != null)
      nameAPI = data['name'];
    else
      nameAPI = '';
    String id = data['id'];
    if (data['message'] != null)
      mobileAPI = data['Mobile'];
    else
      mobileAPI = '';
    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, emailAPI, nameAPI, id, mobileAPI);
      });
      print(message);
      loginToast("utilisateur connecté avec succès");
    } else {
      print("fail");
      print(message);
      loginToast('utilisateur non connecté');
    }
  }

  loginToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white);
  }

  logoutToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  savePref(
      int value, String email, String name, String id, String mobile) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("name", name);
      preferences.setString("email", email);
      preferences.setString("id", id);
      preferences.setString("mobile", mobile);
      preferences.commit();
    });
  }

  var value;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(preferences);

    setState(() {
      value = preferences.getInt("value");
      print(value);
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    print('ranahna');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      preferences.setString("name", '');
      preferences.setString("email", '');
      preferences.setString("id", '');
      preferences.setString("mobile", '');

      preferences.commit();
      loginToast('Vous avez été déconnecté');

      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 51, 51, 51),
          body: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 200, 25, 29),
                    ),
//            color: Colors.grey.withAlpha(20),
                    // color: Color.fromARGB(255, 200, 25, 29),
                    child: Form(
                      key: _key,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          /*Image.network(
                              "https://www.logogenie.net/download/preview/medium/3589659"),*/
                          SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                            height: 50,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 30.0),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),

                          //card for Email TextFormField
                          Card(
                            elevation: 6.0,
                            child: TextFormField(
                              validator: (e) {
                                if (e.isEmpty) {
                                  return "Veuillez insérer un e-mail";
                                }
                              },
                              onSaved: (e) => email = e,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 15),
                                    child:
                                        Icon(Icons.person, color: Colors.black),
                                  ),
                                  contentPadding: EdgeInsets.all(18),
                                  labelText: "Email"),
                            ),
                          ),

                          // Card for password TextFormField
                          Card(
                            elevation: 6.0,
                            child: TextFormField(
                              validator: (e) {
                                if (e.isEmpty) {
                                  return "Le mot de passe ne peut pas être vide";
                                }
                              },
                              obscureText: _secureText,
                              onSaved: (e) => password = e,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                labelText: "Mot de passe",
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 15),
                                  child: Icon(Icons.phonelink_lock,
                                      color: Colors.black),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: showHide,
                                  icon: Icon(_secureText
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                                contentPadding: EdgeInsets.all(18),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 12,
                          ),

                          /* FlatButton(
                            onPressed: null,
                            child: Text(
                              "Mot de passe oublié?",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),*/

                          Padding(
                            padding: EdgeInsets.all(14.0),
                          ),

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SizedBox(
                                height: 44.0,
                                child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    child: Text(
                                      "Connexion",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    textColor: Color.fromARGB(255, 200, 25, 29),
                                    color: Color.fromARGB(255, 51, 51, 51),
                                    onPressed: () {
                                      check();
                                    }),
                              ),
                              /* SizedBox(
                                height: 44.0,
                                child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    child: Text(
                                      "S'inscrire",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    textColor: Colors.black,
                                    color: Color(0xFFf7d426),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Register()),
                                      );
                                    }),
                              ),*/
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;

      case LoginStatus.signIn:
        return MainMenu(signOut);
//        return ProfilePage(signOut);
        break;
    }
  }
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String name, email, mobile, password;
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    Uri _uri = Uri.parse("http://qrcode.cabi-dz.net/api_verification.php");

    final response = await http.post(_uri, body: {
      "flag": 2.toString(),
      "name": name,
      "email": email,
      "mobile": mobile,
      "password": password,
      "fcm_token": "test_fcm_token"
    });

    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
      });
      print(message);
      registerToast(message);
    } else if (value == 2) {
      print(message);
      registerToast(message);
    } else {
      print(message);
      registerToast(message);
    }
  }

  registerToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: Form(
                  key: _key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /*Image.network(
                          "https://www.logogenie.net/download/preview/medium/3589659"),*/
                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        height: 50,
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(color: Colors.black, fontSize: 30.0),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),

                      //card for Fullname TextFormField
                      Card(
                        elevation: 6.0,
                        child: TextFormField(
                          validator: (e) {
                            if (e.isEmpty) {
                              return "Veuillez insérer le nom complet";
                            }
                          },
                          onSaved: (e) => name = e,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(Icons.person, color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.all(18),
                              labelText: "Nom et prénom"),
                        ),
                      ),

                      //card for Email TextFormField
                      Card(
                        elevation: 6.0,
                        child: TextFormField(
                          validator: (e) {
                            if (e.isEmpty) {
                              return "Veuillez insérer un e-mail";
                            }
                          },
                          onSaved: (e) => email = e,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(Icons.email, color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.all(18),
                              labelText: "Email"),
                        ),
                      ),

                      //card for Mobile TextFormField
                      Card(
                        elevation: 6.0,
                        child: TextFormField(
                          validator: (e) {
                            if (e.isEmpty) {
                              return "Veuillez insérer le numéro de mobile";
                            }
                          },
                          onSaved: (e) => mobile = e,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 20, right: 15),
                              child: Icon(Icons.phone, color: Colors.black),
                            ),
                            contentPadding: EdgeInsets.all(18),
                            labelText: "Mobile",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      //card for Password TextFormField
                      Card(
                        elevation: 6.0,
                        child: TextFormField(
                          obscureText: _secureText,
                          onSaved: (e) => password = e,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: showHide,
                                icon: Icon(_secureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(Icons.phonelink_lock,
                                    color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.all(18),
                              labelText: "Mot de passe"),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(12.0),
                      ),

                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            height: 44.0,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Text(
                                  "S'inscrire",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                textColor: Colors.black,
                                color: Color(0xFFf7d426),
                                onPressed: () {
                                  check();
                                }),
                          ),
                          SizedBox(
                            height: 44.0,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Text(
                                  "Connexion",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                textColor: Colors.black,
                                color: Color(0xFFf7d426),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;

  MainMenu(this.signOut);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  int currentIndex = 0;
  String selectedIndex = 'TAB: 1';
  String email = "", name = "", id = "", mobile = "";
  String emailguest = "", nameguest = "", idguest = "", mobileguest = "";

  TabController tabController;
  profileguest(String emaill) async {
    print(emaill + 'jdid');
    Uri _uri = Uri.parse("http://qrcode.cabi-dz.net/api_verification.php");

    final response = await http.post(_uri, body: {
      "flag": 5.toString(),
      "email": emaill,
    });

    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    String emailAPI = data['email'];
    String nameAPI = data['name'];

    String id = data['id'];
    String mobileAPI = data['Mobile'];
    setState(() {
      this.emailguest = emailAPI;
      this.nameguest = nameAPI;
      this.idguest = id;
      this.mobileguest = mobileAPI;
      Scan scan = Scan(
          id: this.idguest,
          name: this.nameguest,
          email: this.emailguest,
          mobile: this.mobileguest);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileWidget(user: scan)),
      );
    });
  }

  /*Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      final response = await http
          .post("http://qrcode.cabi-dz.net/api_verification.php", body: {
        "flag": 3.toString(),
        "myemail": email,
        "otheremail": barcode,
      });

      final data = jsonDecode(response.body);
      int value = data['value'];
      String message = data['message'];
      profileguest(barcode);
      if ((value == 1) || (value == 2)) {
        profileguest(barcode);
      }
      /* setState(() {
          Navigator.pop(context);
        });
        print(message);
        registerToast(message);
      } else if (value == 2) {
        print(message);
        registerToast(message);
      } else {
        print(message);
        registerToast(message);
      }*/
      print(barcode + email);
    }
  }*/

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      email = preferences.getString("email");
      name = preferences.getString("name");
      mobile = preferences.getString("mobile");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: Icon(Icons.lock_open),
          )
        ],
      ),
      body: Center(
          child: FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Scanner()),
          );
        },
        child: Card(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Image.asset('images/scanner.png'),
              ),
              /* Divider(height: 20),
              Expanded(flex: 1, child: Text("Scan")),*/
            ],
          ),
        ),
      )),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.black,
        iconSize: 30.0,
//        iconSize: MediaQuery.of(context).size.height * .60,
        onItemSelected: (index) {
          setState(() {
            currentIndex = index;
          });
          selectedIndex = 'TAB: $currentIndex';
//            print(selectedIndex);
          reds(selectedIndex);
        },

        items: [
          BottomNavyBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
              activeColor: Color(0xFFf7d426)),
          /*BottomNavyBarItem(
              icon: Icon(Icons.view_list),
              title: Text('List'),
              activeColor: Color(0xFFf7d426)),
          BottomNavyBarItem(
              icon: Icon(Icons.qr_code),
              title: Text('Qr code'),
              activeColor: Color(0xFFf7d426)),*/
          BottomNavyBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile'),
              activeColor: Color(0xFFf7d426)),
        ],
      ),
    );
  }

  //  Action on Bottom Bar Press
  void reds(selectedIndex) {
//    print(selectedIndex);

    switch (selectedIndex) {
      case "TAB: 0":
      /*{
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListOfMyScanWidget(email: email)),
          );
        }
        break;*/

      case "TAB: 1":
        {
          Scan scan = Scan(id: id, name: name, email: email, mobile: mobile);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileWidget(user: scan)),
          );
        }
        break;
    }
  }

  callToast(String msg) {
    Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
