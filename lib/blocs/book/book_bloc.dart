import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:e_book_app/repository/book/book_repository.dart';
import 'package:equatable/equatable.dart';
import '../../model/models.dart';
part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository _bookRepository;

  BookBloc(this._bookRepository)
      :super(BookLoading()){
          on<LoadBooks>(_onLoadBook);
  }
  void _onLoadBook(event, Emitter<BookState> emit) async{
    try {
      List<Book> books = await _bookRepository.getAllBooks();
      emit(BookLoaded(books: books));
    } catch (e) {
      emit(BookFailure());
    }
  }
}
