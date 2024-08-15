import 'package:flutter/material.dart';
import 'package:frontend/services/data/user/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          height: height,
          child: Form(
              child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to ETAlert!',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        SignInWithGoogle.loginWithGoogle(context);
                        // .then((value) => {
                        //       if (value)
                        //         {
                        //           Navigator.pushReplacementNamed(
                        //               context, '/name')
                        //         }
                        //     });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/google.png',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      )),
                )
              ],
            )),
          )),
        ),
      ),
    );
  }
}
