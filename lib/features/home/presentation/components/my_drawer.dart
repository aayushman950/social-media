import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmedia/features/home/presentation/components/my_drawer_tile.dart';
import 'package:socialmedia/features/profile/presentation/pages/profile_page.dart';
import 'package:socialmedia/features/search/presentation/pages/search_page.dart';
import 'package:socialmedia/features/settings/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.lock,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              // divider line
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),

              // home
              MyDrawerTile(
                tileName: "HOME",
                tileIcon: Icons.home,
                onTap: () => {Navigator.of(context).pop()},
              ),

              // profile
              MyDrawerTile(
                tileName: "PROFILE",
                tileIcon: Icons.person,
                onTap: () {
                  // pop drawer
                  Navigator.of(context).pop();

                  //get current user's id
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.userID;

                  // goto profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        uid: uid,
                      ),
                    ),
                  );
                },
              ),

              // search
              MyDrawerTile(
                tileName: "Search",
                tileIcon: Icons.search,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                ),
              ),

              // settings
              MyDrawerTile(
                tileName: "Settings",
                tileIcon: Icons.settings,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                ),
              ),

              const Spacer(),

              // logout
              MyDrawerTile(
                tileName: "Logout",
                tileIcon: Icons.logout,
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
