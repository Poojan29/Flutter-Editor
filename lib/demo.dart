import 'dart:io';

import 'package:flutter/material.dart';

class Demo extends StatefulWidget {
  final String imagePath;

  const Demo({super.key, required this.imagePath});

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _position = Offset(0, 0);
  Offset _startPosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Editor'),
      ),
      body: Stack(
        children: [
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onScaleStart: (details) {
                _startPosition = details.focalPoint;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = details.scale;
                  _rotation = details.rotation;
                  _position = _position +
                      details.focalPoint -
                      _startPosition -
                      Offset(0, 0);
                  _startPosition = details.focalPoint;
                });
              },
              child: Transform.rotate(
                angle: _rotation,
                child: Transform.scale(
                  scale: _scale,
                  child: Image.file(
                    File(widget.imagePath),
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
