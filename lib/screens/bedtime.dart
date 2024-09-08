import 'package:flutter/material.dart';
import 'package:frontend/services/data/bedtime/create_bedtime.dart';
import 'package:go_router/go_router.dart';

class Bedtime extends StatefulWidget {
  String googleId;

  Bedtime({Key? key, required this.googleId}) : super(key: key);

  @override
  State<Bedtime> createState() => _BedtimeState();
}

class _BedtimeState extends State<Bedtime> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController bedtimeController = TextEditingController();
  final TextEditingController wakeupController = TextEditingController();
  TimeOfDay? selectedBedtime;
  TimeOfDay? selectedWakeup;

  Future<void> selectTime(bool isBedtime) async {
    final initialTime = isBedtime ? selectedBedtime : selectedWakeup;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isBedtime) {
          selectedBedtime = pickedTime;
          bedtimeController.text = pickedTime.format(context);
        } else {
          selectedWakeup = pickedTime;
          wakeupController.text = pickedTime.format(context);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createBedtime() async {
    await createBedtime(
        widget.googleId, bedtimeController.text, wakeupController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'What is your sleep schedule?',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0), // Set padding to 0
                            child: IconButton(
                              icon: Icon(
                                Icons.bed,
                                color: colorScheme.primary,
                                size: 32.0,
                              ),
                              onPressed: () => selectTime(true),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: bedtimeController,
                            onTap: () => selectTime(true),
                            decoration: InputDecoration(
                              labelText: 'Bedtime',
                              labelStyle: TextStyle(color: colorScheme.primary),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'To',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0), // Set padding to 0
                            child: IconButton(
                              icon: Icon(
                                Icons.alarm,
                                color: colorScheme.primary,
                                size: 32.0,
                              ),
                              onPressed: () => selectTime(true),
                            ),
                          ), // Add the Icon here
                        ),
                        Expanded(
                          child: TextField(
                            controller: wakeupController,
                            onTap: () => selectTime(false),
                            decoration: InputDecoration(
                              labelText: 'Wake Up Time',
                              labelStyle: TextStyle(color: colorScheme.primary),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _createBedtime();
                          context.push('/preference/${widget.googleId}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
