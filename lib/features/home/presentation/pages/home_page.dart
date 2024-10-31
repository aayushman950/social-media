import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/home/presentation/components/my_drawer.dart';
import 'package:socialmedia/features/post/presentation/components/post_tile.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_states.dart';
import 'package:socialmedia/features/post/presentation/pages/upload_post_page.dart';
import 'package:socialmedia/responsive/constrained_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post cubit
  late final postCubit = context.read<PostCubit>();

  // on startup, lets fetch all posts
  @override
  void initState() {
    super.initState();

    // fetch all posts
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postID) {
    postCubit.deletePost(postID);
    fetchAllPosts();
  }

  // build UI
  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          // new post button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadPostPage(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MyDrawer(),

      // body
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // loading
          if (state is PostsLoading || state is PostsUploading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // loaded
          else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(
                child: Text("No Posts :("),
              );
            } else {
              return ListView.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  // get individual post
                  final post = allPosts[index];

                  // image
                  return PostTile(
                    post: post,
                    onDeletePressed: () => deletePost(post.id),
                  );
                },
              );
            }
          }

          // error
          else if (state is PostsError) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return const SizedBox(
              height: 430,
            );
          }
        },
      ),
    );
  }
}
