
import 'package:e_book_app/repository/note/note_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/note_model.dart';

part 'note_event.dart';

part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository _noteRepository;

  NoteBloc(this._noteRepository)
      : super(NoteInitial()) {
    on<LoadedNote>(_onLoadNote);
    on<AddNewNoteEvent>(_onAddNewNote);
    on<RemoveNoteEvent>(_onRemoveNote);
    on<EditNoteEvent>(_onEditNote);
  }

  void _onLoadNote(event, Emitter<NoteState> emit) async {
    try {
      List<Note> note = await _noteRepository.getAllNoteById(event.uId);
      emit(NoteLoaded(notes: note));
    } catch (e) {
      emit(NoteError(e.toString()));
    }
  }

  void _onAddNewNote(event, Emitter<NoteState> emit) async {
    final note = Note(
        bookId: event.bookId,
        content: event.content,
        title: event.title,
        uId: event.userId, noteId: ''
    );
    emit(NoteLoading());
    try {
      await _noteRepository.addNote(note);
      List<Note> notes = await _noteRepository.getAllNoteById(event.userId);
      emit(NoteLoaded(notes: notes));
    } catch (e) {
      print(e.toString());
      emit(const NoteError('error'));
    }
  }
  void _onRemoveNote(event, Emitter<NoteState> emit) async {
    final note = Note(
        bookId: event.bookId,
        content: event.content,
        title: event.title,
        uId: event.userId, noteId: event.noteId);
    emit(NoteLoading());
    try {
      await _noteRepository.removeNote(note);
      emit(AddNote(note: note));
    } catch (e) {
      emit(const NoteError('error'));
    }
  }
  void _onEditNote(event, Emitter<NoteState> emit) async {
    final note = Note(
        bookId: event.bookId,
        content: event.content,
        title: event.title,
        uId: event.userId, noteId: event.noteId);
    emit(NoteLoading());
    try {
      await _noteRepository.editNote(note);
      emit(AddNote(note: note));
    } catch (e) {
      emit(NoteError('error: $e'));
    }
  }
}
