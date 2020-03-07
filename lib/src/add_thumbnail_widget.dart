// import 'package:cached_network_image/cached_network_image.dart';
import 'package:add_thumbnail/src/bloc/bloc.dart';
import 'package:add_thumbnail/src/model/media_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/thumbnail_event.dart';
import 'bloc/thumbnail_state.dart';

class AddMediaDialogContent extends StatefulWidget {
  @override
  _AddMediaDialogContentState createState() => _AddMediaDialogContentState();
}

class _AddMediaDialogContentState extends State<AddMediaDialogContent> {
  TextEditingController _txtController = TextEditingController();
  String textFieldText = "";
  TextField _textField;

  @override
  void initState() {
    super.initState();

    // Give TextField focus after a little delay
    Future.delayed(Duration(milliseconds: 500), () {
      FocusScope.of(context).requestFocus(_textField.focusNode);
    });
  }

  initTextField() {
    _textField = TextField(
      focusNode: FocusNode(),
      maxLines: 1,
      onChanged: (text) {
        textFieldText = text;
        BlocProvider.of<ThumbnailBloc>(context).add(UrlChange());
      },
      controller: _txtController,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        hintText: "Add link here..",
        border: InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initTextField();

    return BlocBuilder<ThumbnailBloc, ThumbnailState>(
      // bloc: ThumbnailBloc,
      builder: (context, state) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          children: <Widget>[
            // top padding
            SizedBox(height: 32),

            // title
            Text("Add a media link here",
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.black54)),
            SizedBox(height: 16),

            // sub title
            Text("Paste URL from any website here",
                style: Theme.of(context)
                    .textTheme
                    .subtitle
                    .copyWith(fontSize: 12)),
            SizedBox(height: 16),

            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFFF5F5F5),
                ),
                child: _textField),

            SizedBox(height: 16),

            Container(child: _previewSection(state)),

            _footer(state)
          ],
        );
      },
    );
  }

  Widget _footer(ThumbnailState state) {
    MediaInfo media;
    if (state is LoadedMedia) {
      media = state.mediaInfo;
    }
    if (state is UrlChanged) {
      media = null;
    }
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          child: Opacity(opacity: 0.36, child: Text("CANCEL")),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text(
              media != null && media.thumbnailUrl != null ? "SAVE" : "NEXT",
              style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            if (media == null) {
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              BlocProvider.of<ThumbnailBloc>(context)
                  .add(AddUrl(url: _txtController.text));
            } else {
              Navigator.pop(context, _txtController.text);
            }
          },
        ),
      ],
    );
  }

  Widget _previewSection(ThumbnailState state) {
    MediaInfo media;
    if (state is LoadedMedia) {
      media = state.mediaInfo;
    }
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.linear,
      child: state is DialogOpened
          ? SizedBox(
              key: ValueKey(1),
            )
          : state is LoadingMedia
              ? _loader()
              : state is LoadedMedia &&
                      (media == null || media.thumbnailUrl == null)
                  ? _errorWidget()
                  : state is LoadedMedia && media != null
                      ? _thumbnailWidget(media)
                      : Container(
                          key: ValueKey(5),
                        ),
    );
  }

  Widget _errorWidget() {
    return Container(
      key: ValueKey(3),
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "hmm, this link looks too complicated for me... Can you try another one?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _thumbnailWidget(MediaInfo media) {
    return Container(
      key: ValueKey(4),
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 20),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Opacity(
                opacity: 0.5,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    media.thumbnailUrl != null ? media.thumbnailUrl : "",
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: media.title != null
                    ? Text(
                        media.title,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loader() {
    return Container(
      key: ValueKey(2),
      padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      color: Colors.grey[850],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
        ),
      ),
    );
  }
}
