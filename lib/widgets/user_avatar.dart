import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  UserAvatar({super.key, this.imageURL, this.radius});

  String? imageURL;
  int? radius;

  @override
  Widget build(BuildContext context) {
    imageURL ??= FirebaseAuth.instance.currentUser!.photoURL!;
    radius ??= 20;
    return CircleAvatar(
      radius: radius!.toDouble(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius!.toDouble()),
        child: Image.network(
          imageURL!,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: frame != null
                  ? child
                  : SizedBox(
                      height: radius! * 2,
                      width: radius! * 2,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
            );
          },
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}