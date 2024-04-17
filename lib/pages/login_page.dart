import 'package:flutter/material.dart';

import '../app_exports.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({
    super.key,
    this.onTap
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void signIn(BuildContext context) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    // получаем службу аутентификации
    final authService = AuthService();

    try {
      await authService.signInWithEmailAndPassword(emailController.text.trim(), passwordController.text.trim());
    }
    catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            e.toString(),
            style: const TextStyle(
              fontFamily: "RobotoSlab"
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  const SizedBox(height: 50,),
                  //logo
                  Icon(
                    Icons.message,
                    color: scheme.primary,
                    size: 100,
                  ),
                  const SizedBox(height: 30,),
                  //welcome back message
                  Text(
                    "Добро пожаловать обратно!",
                    style: TextStyles.styleOfMainText,
                  ),
                  const SizedBox(height: 25,),

                  //email textfield
                  TextForm(
                    controller: emailController,
                    hintText: 'Почта',
                    errorText: 'Введите корректную почту',
                    isPassword: false,
                  ),
                  const SizedBox(height: 10,),

                  //password textfield
                  TextForm(
                    controller: passwordController,
                    hintText: 'Пароль',
                    errorText: 'Минимум 6 символов',
                    isPassword: true,
                  ),
                  const SizedBox(height: 25,),

                  // sign in button
                  MyButton(text: "Войти", onTap: () => signIn(context),),
                  const SizedBox(height: 50,),

                  //register button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Нет аккаунта?",
                        style: TextStyle(
                            fontFamily: "RobotoSlab"
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Зарегистироваться",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontFamily: "RobotoSlabMedium",
                          ),
                        ),
                      )
                    ],
                  )
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}