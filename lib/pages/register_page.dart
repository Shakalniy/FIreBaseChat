import 'package:flutter/material.dart';

import '../app_exports.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({
    super.key,
    this.onTap
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void signUp(BuildContext context) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    // получаем службу аутентификации
    final authService = AuthService();

    try {
      await authService.signUpWithEmailAndPassword(nameController.text.trim(), emailController.text.trim(), passwordController.text.trim());
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
    nameController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: scheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                    "Создайте новый аккаунт!",
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

                  MyTextField(
                    controller: nameController,
                    hintText: 'Имя',
                    obscureText: false,
                    typeOfField: "namely",
                    isCounter: false,
                    isEdit: false,
                    isChatField: false,
                  ),
                  const SizedBox(height: 10,),

                  //password textfield
                  TextForm(
                    controller: passwordController,
                    anotherController: confirmPasswordController,
                    hintText: 'Пароль',
                    errorText: 'Минимум 6 символов',
                    isPassword: true,
                  ),
                  const SizedBox(height: 10,),

                  //confirm password textfield
                  TextForm(
                    controller: confirmPasswordController,
                    anotherController: passwordController,
                    hintText: 'Подтвердить пароль',
                    errorText: 'Минимум 6 символов',
                    isPassword: true,
                  ),

                  const SizedBox(height: 25,),

                  // sign up button
                  MyButton(text: "Зарегистрироваться", onTap: () => signUp(context),),
                  const SizedBox(height: 50,),

                  //register button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Есть аккаунт?",
                        style: TextStyle(
                            fontFamily: "RobotoSlab"
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Войти",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontFamily: "RobotoSlabMedium",
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}