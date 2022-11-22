import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class Common {
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    final file = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return file!.buffer.asUint8List();
  }
}
