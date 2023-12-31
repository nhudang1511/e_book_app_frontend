part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  @override
  List<Object?> get props => [];
}

class UpdateHistory extends HistoryEvent {
  final List<History> histories;

  const UpdateHistory(this.histories);

  @override
  List<Object?> get props => [histories];
}

class AddToHistoryEvent extends HistoryEvent {
  final String uId;
  final String chapters;
  final num percent;
  final int times;
  final Map<String, dynamic> chapterScrollPositions;
  final Map<String, dynamic> chapterScrollPercentages;

  const AddToHistoryEvent(
      {required this.uId,
      required this.chapters,
      required this.percent,
      required this.times,
      required this.chapterScrollPositions,
      required this.chapterScrollPercentages});

  @override
  List<Object?> get props => [uId, chapters, percent, times];
}
