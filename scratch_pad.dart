import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final imagePath = 'assets/images/yny-logo.png';
  final file = File(imagePath);
  if (!file.existsSync()) {
    print('File not found');
    return;
  }
  
  final image = img.decodeImage(file.readAsBytesSync());
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  
  print('Original dimensions: ${image.width} x ${image.height}');
  
  // Create a square image with the max dimension + some padding
  final maxDim = image.width > image.height ? image.width : image.height;
  final padding = (maxDim * 0.2).toInt(); // 20% padding
  final newSize = maxDim + padding * 2;
  
  print('New size will be: $newSize x $newSize');
  
  // Create a new image with white or transparent background
  // Using transparent
  final squareImage = img.Image(width: newSize, height: newSize);
  // Fill with white
  img.fill(squareImage, color: img.ColorRgba8(255, 255, 255, 255));
  
  // Draw the original image centered
  final dstX = (newSize - image.width) ~/ 2;
  final dstY = (newSize - image.height) ~/ 2;
  
  img.compositeImage(squareImage, image, dstX: dstX, dstY: dstY);
  
  final outPath = 'assets/images/yny-logo-square.png';
  File(outPath).writeAsBytesSync(img.encodePng(squareImage));
  print('Saved squared image to $outPath');
}
