import 'dart:io';

import 'package:firebase/consts.dart';
import 'package:firebase/models/user_profile.dart';
import 'package:firebase/services/alert_service.dart';
import 'package:firebase/services/auth_service.dart';
import 'package:firebase/services/database_service.dart';
import 'package:firebase/services/media_service.dart';
import 'package:firebase/services/navigation_service.dart';
import 'package:firebase/services/storage_service.dart';
import 'package:firebase/widgets/custom_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AlertService _alertService;
  String? email, password, name;
  File? selectedImage;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 20,
        ),
        child: Column(
          children: [
            _headerText(),
            if (!isLoading) _registerForm(),
            if (!isLoading) _loginAnAccountLink(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's, get going!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Register an account useing the form below',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelctionField(),
            CustomFormfield(
              hintText: "Name",
              height: MediaQuery.sizeOf(context).height * .10,
              validation: Name_Validation,
              onSaved: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            CustomFormfield(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * .10,
              validation: Email_Validation,
              onSaved: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            CustomFormfield(
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * .10,
              validation: Password_Validation,
              onSaved: (value) {
                setState(() {
                  password = value;
                });
              },
              obsecureText: true,
            ),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelctionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(Place_Holder),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_formKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _formKey.currentState?.save();
              bool result = await _authService.signUp(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                  file: selectedImage!,
                  uid: _authService.user!.uid,
                );
                if (pfpURL != null) {
                  await _databaseService.creatUserProfile(
                    userProfile: UserProfile(
                      name: name,
                      uid: _authService.user!.uid,
                      pfpURL: pfpURL,
                    ),
                  );
                  _alertService.showToast(
                    text: 'User registered successfully',
                    icon: Icons.check,
                  );
                  _navigationService.goBack();
                  _navigationService.pushReplacementNamed("/home");
                } else {
                  throw Exception("Unaple to upload user profile picture");
                }
              } else {
                throw Exception("Unaple to register user");
              }
            }
          } catch (e) {
            _alertService.showToast(
              text: 'Failed to register, please try again!',
              icon: Icons.error,
            );
            print(e);
          }
          setState(() {
            isLoading = false;
          });
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAnAccountLink() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () => _navigationService.goBack(),
          child: const Text(
            "SignIn",
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        )
      ],
    ));
  }
}
