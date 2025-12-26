import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// PositionComponent adalah benda yang punya posisi (X, Y) di layar
class Marble extends PositionComponent {
  // Kita buat variabel warna dan jari-jari (radius)
  final double radius;
  final Paint _paint;

  // Constructor: Saat Marble dibuat, dia minta posisi X dan Y
  Marble({
    required double positionX, 
    required double positionY,
  }) : 
    radius = 20, // Besar kelereng
    _paint = Paint()..color = Colors.purple, // Warna kelereng
    super(
      position: Vector2(positionX, positionY), // Vector2 adalah cara Flame menyimpan koordinat X,Y
      size: Vector2.all(40), // Ukuran kotak pembungkus kelereng (2 x radius)
      anchor: Anchor.center, // Titik pusatnya ada di tengah (bukan pojok kiri atas)
    );

  // Method render: Di sini kita menggambar bentuknya
  @override
  void render(Canvas canvas) {
    // Gambar lingkaran
    // Offset.zero artinya gambar di titik 0,0 dari komponen ini
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, _paint);
  }
}