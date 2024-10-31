import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmedia/features/auth/domain/entities/app_user.dart';
import 'package:socialmedia/features/auth/presentation/components/my_text_field.dart';
import 'package:socialmedia/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialmedia/features/post/domain/entities/post.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_cubit.dart';
import 'package:socialmedia/features/post/presentation/cubits/post_states.dart';
import 'package:socialmedia/responsive/constrained_scaffold.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // mobile image pick
  PlatformFile? imagePickedFile;

  // web image pick
  Uint8List? webImage;

  // text controller for caption
  final textController = TextEditingController();

  // every time someone uploads an image, its gonna be from the current user. so keep track of the current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // select image (similar to edit_profile_page.dart)
  // pick image (tei bata copy gareko ho)
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // create and upload post
  void uploadPost() {
    // check if both image and caption are provided
    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Both Image and Caption are required!"),
        ),
      );
      return;
    }

    // create a new post object
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageURL: '',
      text: textController.text,
      timeStamp: DateTime.now(),
      userID: currentUser!.userID,
      userName: currentUser!.name,
      likes: [],
      comments: [],
    );

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    }

    // mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // build UI
  @override
  Widget build(BuildContext context) {
    // bloc consumer = builder + listener
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        print(state);
        
        // loading or uploading
        if (state is PostsLoading || state is PostsUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // build upload page
        return buildUploadPage();
      },

      // go to previous page when upload is done
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    // scaffold
    return ConstrainedScaffold(
      // appbar
      appBar: AppBar(
        title: const Text('Create Post'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // upload button
          IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload))
        ],
      ),

      // body
      body: Center(
        child: Column(
          children: [
            // image preview for web
            if (kIsWeb && webImage != null) Image.memory(webImage!),

            // image preview for mobile
            if (!kIsWeb && imagePickedFile != null)
              Image.file(
                File(imagePickedFile!.path!),
              ),

            // pick image button
            MaterialButton(
              color: Colors.blue,
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            // caption text box
            MyTextField(controller: textController, hintText: "Add Caption", obscureText: false),
          ],
        ),
      ),
    );
  }
}
