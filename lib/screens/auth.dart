import 'dart:typed_data';

import 'package:splitwise_pro/widgets/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Uint8List? _imageBytes;
  String? _username;
  bool _isLogin = true;
  String _emailAddress = '';
  String _password = '';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _onPickImage(Uint8List imageBytes) {
    _imageBytes = imageBytes;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_imageBytes == null && !_isLogin) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please pick an image'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _emailAddress,
          password: _password,
        );
        // login user
      } else {
        final userCredentails = await _firebase.createUserWithEmailAndPassword(
          email: _emailAddress.trim(),
          password: _password,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentails.user!.uid}.jpg');

        await storageRef.putData(_imageBytes!);
        final imageURl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentails.user!.uid)
            .set({
          'username': _username,
          'email': _emailAddress,
          'image_url': imageURl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'An error occurred'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
    if (context.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  width: 150,
                  child: Image.asset(
                    'assets/images/money_bag.png',
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLogin
                                ? const SizedBox.shrink()
                                : ImagePicker(
                                    onPickImage: _onPickImage,
                                  ),
                            _isLogin
                                ? const SizedBox.shrink()
                                : TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          value.length < 3) {
                                        return 'Please enter a username with atleast 3 characters';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) => _username = value!,
                                  ),
                            TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _emailAddress = value!),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onSaved: (value) => _password = value!,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                    onPressed: _submit,
                                    child: Text(_isLogin
                                        ? 'Login'
                                        : 'Create new account'),
                                  ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(
                                  () {
                                    _isLogin = !_isLogin;
                                  },
                                );
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create a new account'
                                    : 'Login with existing account',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
