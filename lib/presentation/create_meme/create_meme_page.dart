import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memogenerator/presentation/create_meme/models/meeme_text.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';

class CreateMemePage extends StatefulWidget {
  final String? id;
  final String? selectedMemePath;

  const CreateMemePage({Key? key, this.id, this.selectedMemePath})
      : super(key: key);

  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc(
      id: widget.id,
      selectedMemePath: widget.selectedMemePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title: const Text("Создаем мем"),
          bottom: const EditTextBar(),
          actions: [
            GestureDetector(
              onTap: () => bloc.saveMeme(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.save,
                  color: AppColors.darkGrey,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: const SafeArea(
          child: CreateMemePageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  State<EditTextBar> createState() => _EditTextBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText =
                snapshot.hasData ? snapshot.data! : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? "";
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            final haveSelected = selectedMemeText != null;
            return TextField(
              enabled: haveSelected,
              controller: controller,
              onChanged: (text) {
                if (haveSelected) {
                  bloc.changeMemeText(selectedMemeText.id, text);
                }
              },
              onEditingComplete: () => bloc.deselectMemeText(),
              cursorColor: AppColors.fuchsia,
              decoration: InputDecoration(
                filled: true,
                hintText: haveSelected ? "Ввести текст" : null,
                hintStyle: TextStyle(fontSize: 16, color: AppColors.darkGrey38),
                fillColor:
                    haveSelected ? AppColors.fuchsia16 : AppColors.darkGrey6,
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.darkGrey38, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fuchsia38, width: 1),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fuchsia, width: 2),
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  const CreateMemePageContent({Key? key}) : super(key: key);

  @override
  State<CreateMemePageContent> createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  final FocusNode searchFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 2,
          child: MemeCanvasWidget(),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: AppColors.darkGrey,
        ),
        Expanded(
          flex: 1,
          child: BottomList(),
        ),
      ],
    );
  }
}

class BottomList extends StatelessWidget {
  const BottomList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Container(
      color: Colors.white,
      child: StreamBuilder<List<MemeTextWithSelection>>(
          stream: bloc.observeMemeTextsWithSelection(),
          initialData: const <MemeTextWithSelection>[],
          builder: (context, snapshot) {
            final items =
                snapshot.hasData ? snapshot.data! : <MemeTextWithSelection>[];
            return ListView.separated(
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return const AddNewMemeTextButton();
                }
                final item = items[index - 1];
                return BottomMemeText(item: item);
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return const SizedBox.shrink();
                }
                return const BottomSeparator();
              },
            );
          }),
    );
  }
}

class BottomSeparator extends StatelessWidget {
  const BottomSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.darkGrey,
      margin: const EdgeInsets.only(left: 16),
    );
  }
}

class BottomMemeText extends StatelessWidget {
  const BottomMemeText({
    Key? key,
    required this.item,
  }) : super(key: key);

  final MemeTextWithSelection item;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bloc.selectedMemeText(item.memeText.id),
      child: Container(
        height: 48,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        color: item.selected ? AppColors.darkGrey16 : null,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          item.memeText.text,
          style: const TextStyle(fontSize: 16, color: AppColors.darkGrey),
        ),
      ),
    );
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: AppColors.darkGrey38,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () => bloc.deselectMemeText(),
          child: Stack(
            children: [
              StreamBuilder<String?>(
                  stream: bloc.observeMemePath(),
                  builder: (context, snapshot) {
                    final path = snapshot.hasData ? snapshot.data! : null;
                    if (path == null) {
                      return Container(color: Colors.white);
                    }
                    return Image.file(File(path));
                  }),
              StreamBuilder<List<MemeTextWithOffset>>(
                initialData: const <MemeTextWithOffset>[],
                stream: bloc.observeMemeTextWithOffsets(),
                builder: (context, snapshot) {
                  final memeTextWithOffsets = snapshot.hasData
                      ? snapshot.data!
                      : const <MemeTextWithOffset>[];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: memeTextWithOffsets.map((memeTextWithOffset) {
                          return DraggableMemeText(
                            memeTextWithOffset: memeTextWithOffset,
                            parentConstraints: constraints,
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeTextWithOffset memeTextWithOffset;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    Key? key,
    required this.memeTextWithOffset,
    required this.parentConstraints,
  }) : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  late double top;
  late double left;
  final double padding = 8;

  @override
  void initState() {
    super.initState();
    top = widget.memeTextWithOffset.offset?.dy ??
        widget.parentConstraints.maxHeight / 2;
    left = widget.memeTextWithOffset.offset?.dx ??
        widget.parentConstraints.maxWidth / 3;

    if (widget.memeTextWithOffset.offset == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
        bloc.changeMemeTextOffset(
            widget.memeTextWithOffset.id, Offset(left, top));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => bloc.selectedMemeText(widget.memeTextWithOffset.id),
        onPanUpdate: (details) {
          bloc.selectedMemeText(widget.memeTextWithOffset.id);
          setState(() {
            left = calculateLeft(details);
            top = calculateTop(details);
            bloc.changeMemeTextOffset(
                widget.memeTextWithOffset.id, Offset(left, top));
          });
        },
        child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final selectedItem = snapshot.hasData ? snapshot.data : null;
            final selected = widget.memeTextWithOffset.id == selectedItem?.id;
            return MemeTextOnCanvas(
              padding: padding,
              selected: selected,
              parentConstraints: widget.parentConstraints,
              text: widget.memeTextWithOffset.text,
            );
          },
        ),
      ),
    );
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - padding * 2 - 30) {
      return widget.parentConstraints.maxHeight - padding * 2 - 30;
    }
    return rawTop;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }
    return rawLeft;
  }
}

class MemeTextOnCanvas extends StatelessWidget {
  const MemeTextOnCanvas({
    Key? key,
    required this.padding,
    required this.selected,
    required this.parentConstraints,
    required this.text,
  }) : super(key: key);

  final double padding;
  final bool selected;
  final BoxConstraints parentConstraints;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: parentConstraints.maxWidth,
        maxHeight: parentConstraints.maxHeight,
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: selected ? AppColors.darkGrey16 : null,
        border: Border.all(
          color: selected ? AppColors.fuchsia : Colors.transparent,
          width: 1,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }
}

class AddNewMemeTextButton extends StatelessWidget {
  const AddNewMemeTextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bloc.addNewText(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: AppColors.fuchsia),
              const SizedBox(width: 8),
              Text(
                "Добавить текст".toUpperCase(),
                style: const TextStyle(
                  color: AppColors.fuchsia,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
