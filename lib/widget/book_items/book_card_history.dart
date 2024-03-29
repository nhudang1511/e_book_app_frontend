import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../blocs/blocs.dart';
import '../../model/models.dart';

class BookCardHistory extends StatefulWidget {
  final Book book;
  late bool inLibrary;
  final num percent;

  BookCardHistory({
    super.key,
    required this.book,
    required this.inLibrary,
    required this.percent,
  });

  @override
  State<BookCardHistory> createState() => _BookCardHistoryState();
}

class _BookCardHistoryState extends State<BookCardHistory> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/book_detail',
          arguments: {'book': widget.book, 'inLibrary': widget.inLibrary},
        );
      },
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            String uId = state.user.id;
            BlocListener<LibraryBloc, LibraryState>(listener: (context, state) {
              if (state is LibraryLoaded) {
                bool isBookInLibrary = state.libraries
                    .any((b) => b.userId == uId && b.bookId == widget.book.id);
                if (isBookInLibrary) {
                  widget.inLibrary =
                      true; // Nếu sách có trong Library, đặt inLibrary thành true
                }
              }
            });
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width - 10,
          height: 150,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CategoryLoaded) {
                // Tạo danh sách tên danh mục từ categoryId trong book
                if (widget.book.categoryId != null) {
                  List<String> categoryNames = [];
                  for (String categoryId in widget.book.categoryId!) {
                    Category? category = state.categories.firstWhere(
                      (cat) => cat.id == categoryId,
                    );
                    categoryNames.add(category.name ?? '');
                  }
                }
                return Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Image.network(widget.book.imageUrl ?? '')),
                    const SizedBox(width: 5),
                    Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.book.title ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    BlocBuilder<AuthorBloc, AuthorState>(
                                      builder: (context, state) {
                                        if (state is AuthorLoading) {
                                          return const Expanded(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (state is AuthorLoaded) {
                                          Author? author =
                                              state.authors.firstWhere(
                                            (author) =>
                                                author.id ==
                                                widget.book.authodId,
                                          );
                                          return Text(
                                            author.fullName ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall!
                                                .copyWith(
                                                    color:
                                                        const Color(0xFFC7C7C7),
                                                    fontWeight:
                                                        FontWeight.normal),
                                          );
                                        } else {
                                          return const Text(
                                              "Something went wrong");
                                        }
                                      },
                                    ),
                                  ],
                                )),
                            Expanded(
                              flex: 3,
                              child: (widget.percent.isNaN ||
                                      widget.percent.isInfinite)
                                  ? LinearPercentIndicator(
                                      animation: true,
                                      lineHeight: 10.0,
                                      animationDuration: 2500,
                                      percent: 0,
                                      center: const Text(
                                        "",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      progressColor: const Color(0xFF8C2EEE),
                                    )
                                  : LinearPercentIndicator(
                                      animation: true,
                                      lineHeight: 10.0,
                                      animationDuration: 2500,
                                      percent: (widget.percent / 100) < 0
                                          ? 0
                                          : (widget.percent / 100) > 1.0
                                              ? 1
                                              : widget.percent / 100,
                                      center: const Text(
                                        "",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      progressColor: const Color(0xFF8C2EEE),
                                    ),
                            ),
                          ],
                        ))
                  ],
                );
              } else {
                return const Text("Something went wrong");
              }
            },
          ),
        ),
      ),
    );
  }
}
