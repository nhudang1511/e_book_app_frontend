import 'package:e_book_app/config/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/blocs.dart';
import '../../model/models.dart';
import '../../widget/widget.dart';
import '../screen.dart';
import 'components/favourites_tab.dart';
import 'components/histories_audio_tab.dart';
import 'components/histories_tab.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  static const String routeName = '/library';

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthInitial || state is UnAuthenticateState) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: const CustomAppBar(title: 'My Library'),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Please log in to use the library feature',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.routeName);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              4), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    child: Text(
                      "Log in now",
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (state is AuthenticateState) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: const CustomAppBar(title: 'My Library'),
          body: CustomTab(uId: SharedService.getUserId() ?? ''),
        );
      } else {
        return const Text("Something went wrong");
      }
    });
  }
}

// Tab bar
class CustomTab extends StatefulWidget {
  const CustomTab({super.key, required this.uId});

  final String uId;

  @override
  State<StatefulWidget> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  List<Book> book = [];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: null,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(
                      text: 'Reading',
                    ),
                    Tab(text: 'Listening'),
                    Tab(
                      text: 'Favourites',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<BookBloc, BookState>(
                  builder: (context, state) {
                    if(state is BookLoaded){
                      book = state.books;
                    }
                    return TabBarView(
                      children: [
                        HistoriesTab(
                          uId: widget.uId, book: book,
                        ),
                        HistoriesAudioTab(uId: widget.uId, book: book,),
                        FavouritesTab(book: book,),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
