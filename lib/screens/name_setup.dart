import 'package:flutter/material.dart';
import 'package:frontend/components/rounded_image.dart';
import 'package:frontend/models/user/user_info.dart';
import 'package:frontend/services/data/user/edit_user_info.dart';
import 'package:frontend/services/data/user/get_user_info.dart';
import 'package:go_router/go_router.dart';

class NameSetup extends StatefulWidget {
  final String googleId;

  NameSetup({super.key, required String this.googleId});

  @override
  State<NameSetup> createState() => _NameSetupState();
}

class _NameSetupState extends State<NameSetup> {
  UserData? data;
  bool isLoading = true;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  Future<void> _getData() async {
    data = (await getUserInfo(widget.googleId))!;
    if (mounted) {
      setState(() {
        data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: data?.name);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    @override
    void dispose() {
      nameController.dispose();
      super.dispose();
    }

    void _updateName() async {
      if (_formKey.currentState!.validate()) {
        await editUser(widget.googleId, nameController.text, data!.image);
        // Perform any other actions, like navigating to a different page or saving the name
      }
    }

    return isLoading
        ? Scaffold(
            body: Center(
                child: Text(
              'Loading...',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 20),
            )),
          )
        : Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Form(
                        key: _formKey,
                        child: Container(
                          margin: const EdgeInsets.only(
                            top: 110,
                            bottom: 50,
                            left: 30,
                            right: 30,
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Welcome to ETAlert!',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 36,
                                ),
                              ),
                              const SizedBox(
                                height: 26,
                              ),
                              RoundedImage(url: data!.image),
                              const SizedBox(
                                height: 50,
                              ),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                    label: const Text('Name'),
                                    helperText:
                                        'This will be your display name',
                                    helperStyle: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  }
                                  return null;
                                },
                                // initialValue: data?.name ?? "",
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 50, horizontal: 30),
                    child: Form(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                            onPressed: () {
                              _updateName();
                              context.go('/bedtime/${widget.googleId}');
                            },
                            style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 70)),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                      ],
                    ))),
              ],
            ),
          );
  }
}
