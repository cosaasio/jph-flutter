// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutterbuyandsell/config/ps_colors.dart';
import 'package:flutterbuyandsell/constant/ps_dimens.dart';
import 'package:flutterbuyandsell/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CustomCameraView extends StatefulWidget {
  @override
  _CustomCameraViewState createState() {
    return _CustomCameraViewState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // ignore: dead_code
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String? message) =>
    print('Error: $code\nError Message: $message');

class _CustomCameraViewState extends State<CustomCameraView>
    with WidgetsBindingObserver {
  CameraController? controller;
  String? imagePath;
  String? videoPath;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  FlashMode flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Utils.cameras.isNotEmpty) {
      onNewCameraSelected(Utils.cameras[0]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized!) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller!.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Center(
                        child: ZoomableWidget(
                            child: _cameraPreviewWidget(),
                            // onTapUp: (scaledPoint) {
                            //   //controller.setPointOfInterest(scaledPoint);
                            // },
                            onZoom: (dynamic zoom) {
                              print('zoom');
                              if (zoom < 11) {
                                controller!.zoom(zoom);
                              }
                            })),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: controller != null &&
                              controller!.value.isRecordingVideo!
                          ? Colors.redAccent
                          : Colors.grey,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
              _captureControlRowWidget(),
            ],
          ),
          Positioned(
              left: PsDimens.space16,
              top: PsDimens.space72,
              child: GestureDetector(
                child: Container(
                    width: 50,
                    height: 50,
                    child: Icon(Icons.clear, color: PsColors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized!) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      final double width = MediaQuery.of(context).size.width;

      return ClipRect(
          child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Container(
                width: width,
                height: width / controller!.value.aspectRatio,
                child: AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: CameraPreview(controller!),
                ))),
      ));
    }
  }

  /// Toggle recording audio
  // Widget _toggleAudioWidget() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 25),
  //     child: Row(
  //       children: <Widget>[
  //         const Text('Enable Audio:'),
  //         Switch(
  //           value: enableAudio,
  //           onChanged: (bool value) {
  //             enableAudio = value;
  //             if (controller != null) {
  //               onNewCameraSelected(controller.description);
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Display the thumbnail of the captured image or video.
  // Widget _thumbnailWidget() {
  //   return Expanded(
  //     child: Align(
  //       alignment: Alignment.centerRight,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           videoController == null && imagePath == null
  //               ? Container()
  //               : SizedBox(
  //                   child: (videoController == null)
  //                       ? Image.file(File(imagePath))
  //                       : Container(
  //                           child: Center(
  //                             child: AspectRatio(
  //                                 aspectRatio:
  //                                     videoController.value.size != null
  //                                         ? videoController.value.aspectRatio
  //                                         : 1.0,
  //                                 child: VideoPlayer(videoController)),
  //                           ),
  //                           decoration: BoxDecoration(
  //                               border: Border.all(color: Colors.pink)),
  //                         ),
  //                   width: 64.0,
  //                   height: 64.0,
  //                 ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
                  controller!.value.isInitialized! &&
                  !controller!.value.isRecordingVideo!
              ? onTakePictureButtonPressed
              : null,
        ),
      ],
    );
  }

  /// Flash Toggle Button
  // Widget _flashButton() {
  //   IconData iconData = Icons.flash_off;
  //   Color color = Colors.black;
  //   if (flashMode == FlashMode.alwaysFlash) {
  //     iconData = Icons.flash_on;
  //     color = Colors.blue;
  //   } else if (flashMode == FlashMode.autoFlash) {
  //     iconData = Icons.flash_auto;
  //     color = Colors.red;
  //   }
  //   return IconButton(
  //     icon: Icon(iconData),
  //     color: color,
  //     onPressed: controller != null && controller.value.isInitialized
  //         ? _onFlashButtonPressed
  //         : null,
  //   );
  // }

  /// Toggle Flash
  // Future<void> _onFlashButtonPressed() async {
  //   bool hasFlash = false;
  //   if (flashMode == FlashMode.off || flashMode == FlashMode.torch) {
  //     // Turn on the flash for capture
  //     flashMode = FlashMode.alwaysFlash;
  //   } else if (flashMode == FlashMode.alwaysFlash) {
  //     // Turn on the flash for capture if needed
  //     flashMode = FlashMode.autoFlash;
  //   } else {
  //     // Turn off the flash
  //     flashMode = FlashMode.off;
  //   }
  //   // Apply the new mode
  //   await controller.setFlashMode(flashMode);

  //   // Change UI State
  //   setState(() {});
  // }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  // Widget _cameraTogglesRowWidget() {
  //   final List<Widget> toggles = <Widget>[];

  //   if (cameras.isEmpty) {
  //     return const Text('No camera found');
  //   } else {
  //     for (CameraDescription cameraDescription in cameras) {
  //       toggles.add(
  //         SizedBox(
  //           width: 90.0,
  //           child: RadioListTile<CameraDescription>(
  //             title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
  //             groupValue: controller?.description,
  //             value: cameraDescription,
  //             onChanged: controller != null && controller.value.isRecordingVideo
  //                 ? null
  //                 : onNewCameraSelected,
  //           ),
  //         ),
  //       );
  //     }
  //   }

  //   return Row(children: toggles);
  // }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  dynamic showInSnackBar(String message) async {
    await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: PsColors.primary500,
        textColor: PsColors.white);
  }

  dynamic onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(
      Utils.cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (controller!.value.hasError) {
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String? filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          Navigator.pop(context, filePath);
        }
      }
    });
  }

  void toogleAutoFocus() {
    controller!.setAutoFocus(!controller!.value.autoFocusEnabled!);
    showInSnackBar('Toogle auto focus');
  }

  Future<String?> startVideoRecording() async {
    if (!controller!.value.isInitialized!) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller!.value.isRecordingVideo!) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller!.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  // Future<void> stopVideoRecording() async {
  //   if (!controller.value.isRecordingVideo) {
  //     return null;
  //   }

  //   try {
  //     await controller.stopVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     return null;
  //   }

  //   await _startVideoPlayer();
  // }

  // Future<void> pauseVideoRecording() async {
  //   if (!controller.value.isRecordingVideo) {
  //     return null;
  //   }

  //   try {
  //     await controller.pauseVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> resumeVideoRecording() async {
  //   if (!controller.value.isRecordingVideo) {
  //     return null;
  //   }

  //   try {
  //     await controller.resumeVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> _startVideoPlayer() async {
  //   final VideoPlayerController vcontroller =
  //       VideoPlayerController.file(File(videoPath));
  //   videoPlayerListener = () {
  //     if (videoController != null && videoController.value.size != null) {
  //       // Refreshing the state to update video player with the correct ratio.
  //       if (mounted) setState(() {});
  //       videoController.removeListener(videoPlayerListener);
  //     }
  //   };
  //   vcontroller.addListener(videoPlayerListener);
  //   await vcontroller.setLooping(true);
  //   await vcontroller.initialize();
  //   await videoController?.dispose();
  //   if (mounted) {
  //     setState(() {
  //       imagePath = null;
  //       videoController = vcontroller;
  //     });
  //   }
  //   await vcontroller.play();
  // }

  Future<String?> takePicture() async {
    if (!controller!.value.isInitialized!) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller!.value.isTakingPicture!) {
      // A capture is already pending, do nothing.
      showInSnackBar('Camera is still processing. Please try again');
      return null;
    }

    try {
      await controller!.takePicture(filePath);
    } on CameraException catch (e) {
      print(e.toString());
      // _showCameraException(e);
      await Fluttertoast.showToast(
          msg: 'Some problem at taking image. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: PsColors.primary500,
          textColor: PsColors.white);
      Navigator.pop(context);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(bodyText1: TextStyle(color: Colors.white)),
      ),
      home: CustomCameraView(),
    );
  }
}

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(CameraApp());
}

//Zoomer this will be a seprate widget
class ZoomableWidget extends StatefulWidget {
  const ZoomableWidget({Key? key, this.child, this.onZoom, this.onTapUp})
      : super(key: key);
  final Widget? child;
  final Function? onZoom;
  final Function? onTapUp;

  @override
  _ZoomableWidgetState createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  Matrix4 matrix = Matrix4.identity();
  double zoom = 1;
  double prevZoom = 1;
  bool showZoom = false;
  Timer? t1;

  bool handleZoom(double newZoom) {
    if (newZoom >= 1) {
      if (newZoom > 10) {
        return false;
      }
      setState(() {
        showZoom = true;
        zoom = newZoom;
      });

      if (t1 != null) {
        t1!.cancel();
      }

      t1 = Timer(const Duration(milliseconds: 2000), () {
        setState(() {
          showZoom = false;
        });
      });
    }
    widget.onZoom!(zoom);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onScaleStart: (ScaleStartDetails scaleDetails) {
          print('scalStart');
          setState(() => prevZoom = zoom);
          //print(scaleDetails);
        },
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          final double newZoom = prevZoom * scaleDetails.scale;

          handleZoom(newZoom);
        },
        onScaleEnd: (ScaleEndDetails scaleDetails) {
          print('end');
          //print(scaleDetails);
        },
        onTapUp: (TapUpDetails det) {
          // final RenderBox box = context.findRenderObject() as RenderBox;
          // final Offset localPoint = box.globalToLocal(det.globalPosition);
          // final Offset scaledPoint =
          //     localPoint.scale(1 / box.size.width, 1 / box.size.height);
          //
          // widget.onTapUp(scaledPoint);
        },
        child: Stack(children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: Expanded(
                  child: widget.child!,
                ),
              ),
            ],
          ),
          Visibility(
            visible: showZoom, //Default is true,
            child: Positioned.fill(
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        valueIndicatorTextStyle: const TextStyle(
                            color: Colors.amber,
                            letterSpacing: 2.0,
                            fontSize: 30),
                        valueIndicatorColor: Colors.blue,
                        // This is what you are asking for
                        inactiveTrackColor: const Color(0xFF8D8E98),
                        // Custom Gray Color
                        activeTrackColor: Colors.white,
                        thumbColor: Colors.red,
                        overlayColor: const Color(0x29EB1555),
                        // Custom Thumb overlay Color
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12.0),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 20.0),
                      ),
                      child: Slider(
                        value: zoom,
                        onChanged: (double newValue) {
                          handleZoom(newValue);
                        },
                        label: '$zoom',
                        min: 1,
                        max: 10,
                      ),
                    ),
                  ),
                ],
              )),
            ),
            //maintainSize: bool. When true this is equivalent to invisible;
            //replacement: Widget. Defaults to Sizedbox.shrink, 0x0
          )
        ]));
  }
}
