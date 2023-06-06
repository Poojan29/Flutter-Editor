import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Image Demo',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? capturedImagePath;
  String? selectedImagePath;

  bool isDeleteIconVisible = false;
  bool isDeleteButtonActive = false;

  late Map<Permission, PermissionStatus> statuses;

  double _scale = 1.0;
  double _previousScale = 1.0;
  double _rotation = 0.0;
  Offset _position = Offset(0, 0);
  Offset _startPosition = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    checkCameraAndStoragePermission();
  }

  Future<String?> captureImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return pickedFile.path;
    }
    return null;
  }

  Future<String?> selectImageFromGallery() async {
    final picker = ImagePicker();
    final selectedFile = await picker.pickImage(source: ImageSource.gallery);
    if (selectedFile != null) {
      return selectedFile.path;
    }
    return null;
  }

  Future<void> captureImage() async {
    final imagePath = await captureImageFromCamera();
    setState(() {
      capturedImagePath = imagePath;
    });
  }

  Future<void> selectImage() async {
    final selectImagePath = await selectImageFromGallery();
    setState(() {
      selectedImagePath = selectImagePath;
    });
  }

  Future<void> checkCameraAndStoragePermission() async {
    statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
  }

  resetPositions() {
    _scale = 1.0;
    _previousScale = 1.0;
    _rotation = 0.0;
    _position = Offset(0, 0);
    _startPosition = Offset(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                if (statuses[Permission.storage]?.isDenied == true) {
                  Permission.storage.request();
                } else if (statuses[Permission.storage]?.isPermanentlyDenied ==
                    true) {
                  openAppSettings();
                } else if (statuses[Permission.storage]?.isGranted == true) {
                  if (capturedImagePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "To add image you need to first capture image."),
                      ),
                    );
                  } else {
                    selectImage();
                  }
                }
              },
              icon: const Icon(Icons.add_a_photo))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Stack(
              children: [
                capturedImagePath != null
                    ? Image.file(
                        File(capturedImagePath!),
                        fit: BoxFit.fill,
                      )
                    : const Text("Please capture image."),
                selectedImagePath != null
                    ? Positioned(
                        left: _position.dx,
                        top: _position.dy,
                        child: GestureDetector(
                          onScaleStart: (details) {
                            _previousScale = _scale;
                            _startPosition = details.focalPoint;
                            if (!isDeleteIconVisible) {
                              setState(() {
                                isDeleteIconVisible = true;
                              });
                            }
                          },
                          onScaleEnd: (details) {
                            if (isDeleteIconVisible) {
                              setState(() {
                                isDeleteIconVisible = false;
                              });
                            }
                            if (isDeleteButtonActive) {
                              setState(() {
                                selectedImagePath = null;
                                resetPositions();
                              });
                            }
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              _scale = _previousScale * details.scale;
                              _rotation = details.rotation;
                              _position = _position +
                                  details.focalPoint -
                                  _startPosition -
                                  Offset(0, 0);
                              _startPosition = details.focalPoint;
                            });
                          },
                          child: Listener(
                            onPointerMove: (event) {
                              if (event.position.dy >
                                  MediaQuery.of(context).size.height - 50) {
                                setState(() {
                                  isDeleteButtonActive = true;
                                });
                              } else {
                                setState(() {
                                  isDeleteButtonActive = false;
                                });
                              }
                            },
                            child: Transform.rotate(
                              angle: _rotation,
                              child: Transform.scale(
                                scale: _scale,
                                child: Image.file(
                                  File(selectedImagePath!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
            if (isDeleteIconVisible)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      Icons.delete,
                      size: isDeleteButtonActive ? 30 : 25,
                      color: isDeleteButtonActive ? Colors.red : Colors.grey,
                    )),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (statuses[Permission.camera]?.isGranted == true) {
            captureImage();
          } else if (statuses[Permission.camera]?.isDenied == true) {
            Permission.camera.request();
          } else if (statuses[Permission.camera]?.isPermanentlyDenied == true) {
            openAppSettings();
          }
        },
        tooltip: 'Capture Image',
        child: const Icon(Icons.camera_alt_outlined),
      ),
    );
  }
}
