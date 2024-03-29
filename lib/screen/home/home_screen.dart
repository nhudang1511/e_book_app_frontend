import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_book_app/widget/book_items/list_book.dart';
import 'package:e_book_app/widget/book_items/list_book_history.dart';
import 'package:e_book_app/widget/book_items/list_book_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import '../../blocs/blocs.dart';
import '../../model/models.dart';
import '../../widget/widget.dart';
import '../library/components/histories_tab.dart';
import 'components/custom_appbar_home.dart';
import 'components/list_quote.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const HomeScreen());
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final List<Widget> imageSliders = listQuote
      .map((item) => Container(
            margin: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                color: item.color, borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      child: Image.asset(item.imageUrl, fit: BoxFit.fill)),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ReadMoreText(
                        item.quote,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        trimLength: 100,
                        colorClickableText: Colors.white.withAlpha(80),
                      ),
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal))
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    String period = getDayPeriod(now);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBarHome(title: period),
      body: SingleChildScrollView(
        child: BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            if (state is BookLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BookLoaded) {
              //print(state.books.length);
              List<Book> book = state.books.where((element) => element.status == true).toList();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CarouselSlider(
                      items: imageSliders,
                      carouselController: _controller,
                      options: CarouselOptions(
                          viewportFraction: 1,
                          autoPlay: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: listQuote.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(
                                      _current == entry.key ? 0.9 : 0.4)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SectionTitle(title: 'New reals'),
                  ListBook(
                    books: book,
                    inLibrary: false,
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthenticateState) {
                        final uId = state.authUser?.uid;
                        return DisplayHistories(
                          uId: uId,
                          scrollDirection: Axis.horizontal,
                          height: 180,
                          inHistory: true,
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  const SectionTitle(title: 'Recommendation'),
                  ListBookMain(
                    books: book.take(4).toList(),
                    scrollDirection: Axis.vertical,
                    height: MediaQuery.of(context).size.height,
                    inLibrary: false,
                  ),
                ],
              );
            } else {
              return const Text('Something went wrong');
            }
          },
        ),
      ),
    );
  }

  String getDayPeriod(TimeOfDay time) {
    if (time.hour < 12) {
      return 'Good morning!';
    } else if (time.hour < 18) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }
}
