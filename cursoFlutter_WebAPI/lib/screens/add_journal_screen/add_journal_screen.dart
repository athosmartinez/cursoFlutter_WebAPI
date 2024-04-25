import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webapi_first_course/helpers/logout.dart';
import 'package:flutter_webapi_first_course/helpers/weekday.dart';
import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/screens/commom/exception_dialog.dart';
import 'package:flutter_webapi_first_course/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddJournalScreen extends StatelessWidget {
  final Journal journal;
  final bool isEditing;
  final TextEditingController _contentController = TextEditingController();
  AddJournalScreen({super.key, required this.journal, required this.isEditing});
  @override
  Widget build(BuildContext context) {
    _contentController.text = journal.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${WeekDay(journal.createdAt.weekday).long}, ${journal.createdAt.day} | ${journal.createdAt.month} | ${journal.createdAt.year}"),
        actions: [
          IconButton(
              onPressed: () {
                registerJournal(context);
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          maxLines: null,
          minLines: null,
        ),
      ),
    );
  }

  registerJournal(BuildContext context) {
    SharedPreferences.getInstance().then((value) {
      String? token = value.getString("accessToken");
      if (token != null) {
        String content = _contentController.text;
        journal.content = content;
        JournalService service = JournalService();
        if (isEditing) {
          service
              .edit(journal.id, journal, token)
              .then((value) => Navigator.pop(context, value))
              .catchError((error) {
            logout(context);
          }, test: ((error) => error is tokenNotValidException)).catchError(
                  (error) {
            var innerError = error as HttpException;
            showExceptionDialog(context, content: innerError.message);
          }, test: (error) => error is HttpException);
        } else {
          service
              .register(journal, token)
              .then((value) => Navigator.pop(context, value))
              .catchError((error) {
            logout(context);
          }, test: ((error) => error is tokenNotValidException)).catchError(
                  (error) {
            var innerError = error as HttpException;
            showExceptionDialog(context, content: innerError.message);
          }, test: (error) => error is HttpException);
        }
      }
    });
  }
}
