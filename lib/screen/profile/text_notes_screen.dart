import 'package:e_book_app/config/shared_preferences.dart';
import 'package:e_book_app/repository/note/note_repository.dart';
import 'package:e_book_app/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/blocs.dart';
import '../../model/models.dart';

class TextNotesScreen extends StatefulWidget {
  const TextNotesScreen({super.key});

  static const String routeName = '/text_notes';

  @override
  State<TextNotesScreen> createState() => _TextNotesScreenState();
}

class _TextNotesScreenState extends State<TextNotesScreen> {
  String uId = SharedService.getUserId() ?? '';
  List<Note> listNotes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const CustomAppBar(
        title: "Text notes",
      ),
      body: Column(
        children: [
          BlocBuilder<NoteBloc, NoteState>(
            builder: (context, state) {
              if (state is NoteLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is NoteLoaded) {
                listNotes = state.notes;
              }
              return Expanded(
                child: ListView.builder(
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: listNotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    // double noteHeight = 200 ;
                    return TextNoteCard(note: listNotes[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
