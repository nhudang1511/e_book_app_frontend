part of 'review_bloc.dart';
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}
class ReviewInitial extends ReviewState {
  @override
  List<Object?> get props => [];
}
class ReviewLoading extends ReviewState{
  @override
  List<Object?> get props => [];
}
class ReviewLoaded extends ReviewState{
  final List<Review> reviews;
  const ReviewLoaded({this.reviews = const <Review>[]});
  @override
  List<Object?> get props => [reviews];
}
class ReviewError extends ReviewState {
  final String error;

  const ReviewError(this.error);

  @override
  List<Object?> get props => [error];
}