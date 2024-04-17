import 'package:chat/app_exports.dart';
import 'package:flutter/material.dart';

class ChangeProfilePage extends StatefulWidget {

  final String name;
  final String phoneNumber;
  final String status;

  const ChangeProfilePage({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.status,
  });

  @override
  State<ChangeProfilePage> createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {

  final nameController = TextEditingController();

  final numberController = TextEditingController();

  final statusController = TextEditingController();

  bool isLoading = true;

  void setChanges() async {
    ProfileService _profile = ProfileService();

    await _profile.setProfile(nameController.text, numberController.text, statusController.text);

    Navigator.pop(context);
  }

  @override
  void initState() {
    nameController.text = widget.name;
    numberController.text = widget.phoneNumber;
    statusController.text = widget.status;
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
    ? const Center(child: CircularProgressIndicator(),)
    : Scaffold(
      appBar: AppBar(
        title: Text(
          "Изменить",
          style: TextStyles.styleOfAppBarText,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextField(
                controller: nameController,
                hintText: "Имя",
                obscureText: false,
                typeOfField: "namely",
                isCounter: true,
                isEdit: false,
                isChatField: false,
              ),

              const SizedBox(height: 10,),

              MyTextField(
                controller: numberController,
                hintText: "Номер телефона",
                obscureText: false,
                typeOfField: "phoneNumber",
                isCounter: true,
                isEdit: false,
                isChatField: false,
              ),

              const SizedBox(height: 10,),

              MyTextField(
                controller: statusController,
                hintText: "Статус",
                obscureText: false,
                typeOfField: "status",
                isCounter: true,
                isEdit: false,
                isChatField: false,
              ),

              const SizedBox(height: 20,),

              MyButton(text: "Сохранить", onTap: setChanges,),
            ],
          ),
        ),
      ),
    );
  }
}