import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart'; // Import GetX package
import 'package:recipe_app/widgets/dimensions.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with email and password
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to login page on successful sign-up
      Get.offAllNamed('/'); // Use GetX to navigate to login page
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle sign-up error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sign-up Error'),
          content: Text('Failed to sign up. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(Dimensions.height16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              size: Dimensions.height150,
              color: Colors.purple,
            ),
            SizedBox(height: Dimensions.height32),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email, color: Colors.purple),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock, color: Colors.purple),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: Dimensions.height32),
            Container(
              decoration: BoxDecoration(
                color: Colors.purple[100]!,
                borderRadius: BorderRadius.circular(Dimensions.radius8),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple[100]!),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.amber[800]!),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
                )
                    : Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.amber[800],
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
