import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/utils/TokenModel.dart';
import 'package:my_app/utils/routes.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  List<TokenModel> userToken = [];
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool changeButton = false;
  bool isLoggedIn = false;

  initializeLogin() async {
    SharedPreferences pf = await SharedPreferences.getInstance();

    var token = pf.getString('token');

    if (token == null) {
      setState(() {
        isLoggedIn = false;
      });
    } else {
      setState(() {
        isLoggedIn = true;
      });
    }

    isLoggedIn == true
        ? Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => HomePage()), (route) => false)
        : MyRoutes.loginRoute;
  }

  saveToLocalStorage(String tokenValue) async {
    SharedPreferences pf = await SharedPreferences.getInstance();
    pf.setString('tokenNew', tokenValue);
    pf.setString('email', userController.text);
  }

  Future callLoginMethod() async {
    String url = "https://biomujappback.herokuapp.com/api-token-auth/";

    var response = await http.post(Uri.parse(url), body: {
      'username': userController.text,
      'password': passwordController.text
    });

    if (response.statusCode != 200) {
      // show snackbar
      final snackbar = SnackBar(
        content: const Text("Invalid Credentials Please Enter Again"),
        duration: Duration(seconds: 15),
        action: SnackBarAction(
          label: '',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } else if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      setState(() {
        changeButton = true;
        userToken = jsonResponse.map((e) => TokenModel.fromJson(e)).toList();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        saveToLocalStorage(userToken[0].token!);
      });

      print('a');
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => HomePage()), (route) => false);
    }
  }

  moveToHome() async {
    if (formkey.currentState!.validate()) {
      callLoginMethod();
    }
  }

  @override
  void initState() {
    initializeLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 70,
              ),
              Image.asset(
                "assets/images/loginimg.png",
                fit: BoxFit.cover,
                height: 280,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 35.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: userController,
                      decoration: InputDecoration(
                        hintText: "Enter User ID",
                        labelText: "USER ID",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Username Cannot Be Empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        labelText: "PASSWORD",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password Cannot Be Empty";
                        } else if (value.length < 6) {
                          return "Password Length Must Be of Atleast 6 characters";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.pushNamed(context, MyRoutes.homeRoute);
                    //   },
                    //   child: Text("Login"),
                    //   style: TextButton.styleFrom(
                    //     minimumSize: Size(150, 40),
                    //   ),
                    // ),
                    InkWell(
                      splashColor: Colors.red,
                      onTap: () => moveToHome(),
                      child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          width: changeButton ? 40 : 150,
                          height: 40,
                          alignment: Alignment.center,
                          child: changeButton
                              ? Icon(
                                  Icons.done,
                                  color: Colors.white,
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                          decoration: BoxDecoration(
                              color: Colors.pink,
                              // shape: changeButton
                              //     ? BoxShape.circle
                              //     : BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(
                                  changeButton ? 35 : 13))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
