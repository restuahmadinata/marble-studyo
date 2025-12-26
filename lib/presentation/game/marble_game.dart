import 'dart:async';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/marble.dart'; //

// Kelas ini adalah "Dunia" game kita
class MarbleGame extends FlameGame {
  
  // Method onLoad dipanggil sekali saat game pertama kali dimulai.
  // Di sinilah kita "menaruh barang" ke dalam dunia game.
  @override
  FutureOr<void> onLoad() async {
    // 1. Set warna background dunia game (biar tidak hitam polos)
    // 0xFF berarti tidak transparan, diikuti kode warna Hex.
    // Contoh: Ungu muda
    camera.viewfinder.visibleGameSize = size; // Agar kamera pas dengan layar HP
    
    // 2. Membuat satu Marble (Kelereng)
    final firstMarble = Marble(
      positionX: size.x / 2, // Posisi X di tengah layar
      positionY: size.y / 2, // Posisi Y di tengah layar
    );

    // 3. Menambahkan Marble ke dalam dunia game
    add(firstMarble);
  }
  
  @override
  Color backgroundColor() => const Color(0xFFE1BEE7); // Background Ungu Muda
}