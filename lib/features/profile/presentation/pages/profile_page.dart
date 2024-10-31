import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/auth/domain/entities/app_user.dart';
import 'package:socialmedia/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmedia/features/post/presentation/components/post_tile.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_states.dart';
import 'package:socialmedia/features/profile/presentation/components/bio_box.dart';
import 'package:socialmedia/features/profile/presentation/components/follow_button.dart';
import 'package:socialmedia/features/profile/presentation/components/profile_stats.dart';
import 'package:socialmedia/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:socialmedia/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialmedia/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:socialmedia/features/profile/presentation/pages/followers_page.dart';
import 'package:socialmedia/responsive/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  // posts count
  int postCount = 0;

  // on startup
  @override
  void initState() {
    super.initState();

    // load user profile data
    profileCubit.fetchUserProfile(widget.uid);
  }

  /*
  
  Follow/Unfollow
  
  */
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.userID);

    // optimistically update the ui
    setState(() {
      // unfollow
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.userID);
      }

      // follow
      else {
        profileUser.followers.add(currentUser!.userID);
      }
    });

    // perform actual toggle in the cubit
    profileCubit
        .toggleFollow(currentUser!.userID, widget.uid)
        .catchError((error) {
      // revert changes if error
      // unfollow
      if (isFollowing) {
        profileUser.followers.add(currentUser!.userID);
      }

      // follow
      else {
        profileUser.followers.remove(currentUser!.userID);
      }
    });
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    // check if own profile(for follow button)
    bool isOwnProfile = widget.uid == currentUser!.userID;

    // Scaffold
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // loaded
        if (state is ProfileLoaded) {
          //get loaded user
          final user = state.profileUser;

          // scaffold
          return ConstrainedScaffold(
            // appbar
            appBar: AppBar(
              centerTitle: true,
              title: Text(user.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                //edit profile button
                if (isOwnProfile)
                  IconButton(
                    onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              user: user,
                            ),
                          ))
                    },
                    icon: const Icon(Icons.settings),
                  )
              ],
            ),

            //body
            body: ListView(
              children: [
                // email
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // pfp
                CachedNetworkImage(
                  imageUrl: user.profileImageURL,

                  // loading
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),

                  // error
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  // loaded
                  imageBuilder: (context, imageProvider) => Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // profile stats
                ProfileStats(
                  postCount: postCount,
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowersPage(
                                followers: user.followers,
                                following: user.following,
                              ))),
                ),

                if (!isOwnProfile)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.userID),
                  ),

                const SizedBox(
                  height: 25,
                ),

                // bio box
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                BioBox(
                  text: user.bio,
                ),

                // posts
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25.0,
                    top: 25.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Posts",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // list of posts from this user
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    // loaded state
                    if (state is PostsLoaded) {
                      // filter posts by user id
                      final userPosts = state.posts
                          .where((post) => (post.userID == widget.uid))
                          .toList();

                      postCount = userPosts.length;

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: postCount,
                        itemBuilder: (context, index) {
                          // get individual post
                          final post = userPosts[index];

                          // return list of post tiles
                          return PostTile(
                            post: post,
                            onDeletePressed: () =>
                                context.read<PostCubit>().deletePost(post.id),
                          );
                        },
                      );
                    }

                    // loading state
                    else if (state is PostsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // error / no posts
                    else {
                      return const Center(
                        child: Text("No Posts :("),
                      );
                    }
                  },
                )
              ],
            ),
          );
        }

        // loading
        else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text("No profile found"),
          );
        }
      },
    );
  }
}
