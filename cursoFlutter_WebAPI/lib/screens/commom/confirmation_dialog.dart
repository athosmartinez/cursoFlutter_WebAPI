import 'package:flutter/material.dart';

showConfirmationDialog(BuildContext context,
    {String title = "Atenção!",
    String content = "Deseja continuar",
    String affirmationOption = "Confirmar"}) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(affirmationOption)),
            TextButton(onPressed: () {}, child: const Text("Cancelar"))
          ],
        );
      });
}
