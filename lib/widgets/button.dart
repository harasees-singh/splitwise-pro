import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button(
      {super.key,
      required this.isLoading,
      required this.onSubmit,
      required this.buttonTitle});

  final bool isLoading;
  final void Function() onSubmit;
  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: onSubmit,
              child: Text(
                buttonTitle,
                style: const TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}
