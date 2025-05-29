import 'dart:convert';
import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  String nameTxt = '';
  String emailTxt = '';
  String passTxt = '';
  File? selectedImage;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  void _onSave() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    final isValid = formState.validate();

    if (!isValid || (!isLogin && selectedImage == null)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields correctly.')),
      );
    }

    formState.save();

    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
      });

      if (isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: emailTxt,
          password: passTxt,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: emailTxt,
          password: passTxt,
        );

        final user = userCredentials.user;
        if (user == null) {
          return;
        }
        final userId = user.uid;

        String? base64Image;
        if (selectedImage != null) {
          final bytes = await selectedImage!.readAsBytes();
          base64Image = base64Encode(bytes);
        }

        final userData = {
          'email': emailTxt,
          'username': nameTxt,
          'image_base64': base64Image,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(userData);
      }

      if (!mounted) return;
      formState.reset();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              SizedBox(
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),

              const SizedBox(height: 30),

              // Auth Card
              SizedBox(
                width: 400, // optional: good for wider screens
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // even padding
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                selectedImage = pickedImage;
                              },
                            ),
                          if (!isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              enableSuggestions: false,

                              onSaved: (newValue) {
                                nameTxt = newValue!;
                              },
                              validator: (nameTxt) {
                                if (nameTxt == null ||
                                    nameTxt.isEmpty ||
                                    nameTxt.trim().length < 4) {
                                  return 'Please enter at least 4 characters for your name.';
                                }

                                return null;
                              },
                            ),

                          // Email Field
                          const SizedBox(height: 16),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (newValue) {
                              emailTxt = newValue!;
                            },
                            validator: (emailTxt) {
                              if (emailTxt == null ||
                                  emailTxt.trim() == '' ||
                                  !emailTxt.trim().contains('@')) {
                                return 'Please enter a valid email address.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (newValue) {
                              passTxt = newValue!;
                            },
                            validator: (passTxt) {
                              if (passTxt == null ||
                                  passTxt.trim() == '' ||
                                  passTxt.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16), // this adds bottom space

                          if (isLoading) CircularProgressIndicator(),

                          if (!isLoading) // Submit Button
                            ElevatedButton(
                              onPressed: _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                              child: Text(isLogin ? 'Login' : 'Signup'),
                            ),
                          SizedBox(height: 8),
                          if (!isLoading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(
                                isLogin
                                    ? 'Create an account'
                                    : 'I already have an account',
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
    );
  }
}
