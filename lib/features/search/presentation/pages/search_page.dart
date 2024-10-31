import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/profile/presentation/components/user_tile.dart';
import 'package:socialmedia/features/search/presentation/cubits/search_cubit.dart';
import 'package:socialmedia/features/search/presentation/cubits/search_states.dart';
import 'package:socialmedia/responsive/constrained_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // search text controller
  final searchController = TextEditingController();

  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = searchController.text;

    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();

    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // build UI
  @override
  Widget build(BuildContext context) {
    // scaffold
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
              hintText: "Search People",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              )),
        ),
      ),

      // search results
      body: BlocBuilder<SearchCubit, SearchStates>(
        builder: (context, state) {
          // loading
          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // loaded
          if (state is SearchLoaded) {
            // if no users found
            if (state.users.isEmpty) {
              return const Center(
                child: Text("No users found"),
              );
            }

            // if users found
            else if (state.users.isNotEmpty) {
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return UserTile(user: user!);
                },
              );
            }
          }

          //error
          else if (state is SearchError) {
            return Center(
              child: Text(state.message),
            );
          }

          // default
          return const Center(
            child: Text("Start searching for users"),
          );
        },
      ),
    );
  }
}
