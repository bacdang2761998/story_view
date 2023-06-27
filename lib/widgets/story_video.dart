import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';
import '../controller/story_controller.dart';

class VideoLoader {
  String url;

  File? videoFile;

  Map<String, dynamic>? requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    if(url.isNotEmpty) {
      onComplete();
    }
    // if (this.videoFile != null) {
    //   this.state = LoadState.success;
    //   onComplete();
    // }
    //
    // final fileStream = DefaultCacheManager()
    //     .getFileStream(this.url, headers: this.requestHeaders as Map<String, String>?);
    //
    // fileStream.listen((fileResponse) {
    //   if (fileResponse is FileInfo) {
    //     if (this.videoFile == null) {
    //       this.state = LoadState.success;
    //       this.videoFile = fileResponse.file;
    //       onComplete();
    //     }
    //   }
    // });
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController? storyController;
  final VideoLoader videoLoader;
  final VideoPlayerController? playerController;

  StoryVideo(this.videoLoader, {this.storyController, Key? key, this.playerController})
      : super(key: key ?? UniqueKey());

  static StoryVideo url(String url,
      {StoryController? controller,
      Map<String, dynamic>? requestHeaders,
        VideoPlayerController? playerController,
      Key? key}) {
    return StoryVideo(
      VideoLoader(url, requestHeaders: requestHeaders),
      storyController: controller,
      playerController: playerController,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void>? playerLoader;

  StreamSubscription? _streamSubscription;

  VideoPlayerController? playerController;

  @override
  void initState() {
    super.initState();
    widget.videoLoader.state = LoadState.loading;
    widget.storyController!.pause();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
    widget.videoLoader.loadVideo(() {
      // if (widget.videoLoader.state == LoadState.success) {
        playerController = widget.playerController;
            // VideoPlayerController.network(widget.videoLoader.url);

        // playerController!.initialize().then((v) {
          setState(() {});
          widget.videoLoader.state = LoadState.success;
          widget.storyController!.play();
        // });

        if (widget.storyController != null) {
          _streamSubscription =
              widget.storyController!.playbackNotifier.listen((playbackState) {
            if (playbackState == PlaybackState.pause) {
              playerController!.pause();
            } else {
              playerController!.play();
            }
          });
        }
      // } else {
      //   setState(() {});
      // }
    });
    });
  }

  Widget getContentView() {
    if (widget.videoLoader.state == LoadState.success &&
        playerController!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: playerController!.value.aspectRatio,
          child: VideoPlayer(playerController!),
        ),
      );
    }

    return widget.videoLoader.state == LoadState.loading
        ? Center(
            child: Container(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          )
        : Center(
            child: Text(
            "Media failed to load.",
            style: TextStyle(
              color: Colors.white,
            ),
          ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
