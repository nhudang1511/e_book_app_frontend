import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/models.dart';
import '../../repository/chapters/chapters_repository.dart';
part 'chapters_event.dart';
part 'chapters_state.dart';

class ChaptersBloc extends Bloc<ChaptersEvent, ChaptersState> {
  final ChaptersRepository _chaptersRepository;

  ChaptersBloc(this._chaptersRepository)
      : super(ChaptersLoading()){
        on<LoadChapters> (_onLoadChapters);
  }
  void _onLoadChapters (event, emit) async{
    if (event.bookId.isEmpty) {
      // Throw an error if the bookId parameter is empty.
      throw Exception("The bookId parameter cannot be empty.");
    }
    try {
      Chapters? chapter = await _chaptersRepository.getChapters(event.bookId);
      if(chapter != null){
        emit(ChaptersLoaded(chapters: chapter));
      }
      else{
        emit(ChaptersFailure());
      }
    } catch (e) {
      emit(ChaptersFailure());
    }
  }
}
