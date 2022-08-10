import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_page.dart';
import 'package:memogenerator/presentation/easter_egg/easter_edd_page.dart';
import 'package:memogenerator/presentation/main/main_bloc.dart';
import 'package:memogenerator/presentation/main/memes_with_docs_path.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final goBack = await showConfirmationExitDialog(context);
          return goBack ?? false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.lemon,
            foregroundColor: AppColors.darkGrey,
            title: GestureDetector(
              onLongPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EasterEggPage(),
                  ),
                );
              },
              child: Text(
                "Мемогенератор",
                style: GoogleFonts.seymourOne(fontSize: 24),
              ),
            ),
          ),
          body: const SafeArea(
            child: MainPageContent(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final selectedMemePath = await bloc.selectMeme();
              if (selectedMemePath == null) {
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateMemePage(
                    selectedMemePath: selectedMemePath,
                  ),
                ),
              );
            },
            backgroundColor: AppColors.fuchsia,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Создать"),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Future<bool?> showConfirmationExitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Точно хотите выйти?"),
            content: Text("Мемы сами себя не сделают"),
            actions: [
              AppButton(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                text: "Остаться",
                color: AppColors.darkGrey,
              ),
              AppButton(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                text: "Выйти",
              ),
            ],
          );
        });
  }
}

class MainPageContent extends StatefulWidget {
  const MainPageContent({Key? key}) : super(key: key);

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  final FocusNode searchFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context);
    return StreamBuilder<MemesWithDocsPath>(
      stream: bloc.observeMemesWithDocsPath(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final items = snapshot.requireData.memes;
        final docsPath = snapshot.requireData.docsPath;
        return GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          children: items.map((item) {
            return GridItem(meme: item, docsPath: docsPath);
          }).toList(),
        );
      },
    );
  }
}

class GridItem extends StatelessWidget {
  const GridItem({
    Key? key,
    required this.meme,
    required this.docsPath,
  }) : super(key: key);

  final String docsPath;
  final Meme meme;

  @override
  Widget build(BuildContext context) {
    final imageFile = File("$docsPath${Platform.pathSeparator}${meme.id}.png");
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateMemePage(id: meme.id);
            },
          ),
        );
      },
      child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.darkGrey, width: 1),
          ),
          child: imageFile.existsSync()
              ? Image.file(
                  File("$docsPath${Platform.pathSeparator}${meme.id}.png"))
              : Text(meme.id)),
    );
  }
}
