import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoCompressWidget(),
    );
  }
}

class VideoCompressWidget extends StatefulWidget {
  @override
  _VideoCompressWidgetState createState() => _VideoCompressWidgetState();
}

class _VideoCompressWidgetState extends State<VideoCompressWidget> {
  XFile? videoPath;
  double originalSize = 0.0;
  double compressedSize = 0.0;
  bool compressing = false;

  Future<void> pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        videoPath = pickedFile;
        originalSize = double.parse((File(pickedFile.path).lengthSync() / (1024 * 1024)).toStringAsFixed(2));
      });
    }
  }

  Future<void> compressVideo() async {
    setState(() {
      compressing = true;
    });

    final info = await VideoCompress.compressVideo(
      videoPath!.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
    );

    setState(() {
      compressedSize = double.parse((info!.filesize! / (1024 * 1024)).toStringAsFixed(2));
      compressing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Compressor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: pickVideo,
              child: Text('Pick Video'),
            ),
            SizedBox(height: 16),
            if (videoPath != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.file(
                    File(videoPath!.path),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                  Text('Original Size: $originalSize MB'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: compressing ? null : compressVideo,
                    child: compressing
                        ? CircularProgressIndicator()
                        : Text('Compress Video'),
                  ),
                  if (compressedSize > 0)
                    SizedBox(height: 16),
                    Text('Compressed Size: $compressedSize MB'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}