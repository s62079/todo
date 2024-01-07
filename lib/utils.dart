import 'package:flutter/material.dart';

import 'data.dart';

// https://stackoverflow.com/questions/45948168
void snack(ScaffoldMessengerState state, String message) {
  state
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

// https://stackoverflow.com/questions/70830642
void snackWithUndo(
  ScaffoldMessengerState state,
  String message,
  void Function() onUndo,
) {
  state
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            onUndo();
            await Data.save();
          },
        ),
      ),
    );
}

Color tintColor(Color color, Color tint, double elevation) =>
    ElevationOverlay.applySurfaceTint(color, tint, elevation);
