import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/marble.dart';
import 'components/line_layer.dart';
import 'components/neo_card.dart';

class MarbleGame extends FlameGame {
  late LineLayer _lineLayer;
  
  final double collisionDistance = 40.0; 
  // Connection distance dilebihkan sedikit (45) biar gampang nyambung
  // Tapi nanti Kohesi akan memaksa mereka nempel jadi 40.
  final double connectionDistance = 45.0; 

  List<Set<Marble>> groups = [];
  late double topBoundary;
  late double bottomBoundary;

  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.visibleGameSize = size;
    
    int totalMarbles = 10; 
    double minSpawnDistance = 80.0; 
    Random rng = Random();
    
    for (int i = 0; i < totalMarbles; i++) {
      Vector2? candidatePosition;
      bool positionFound = false;
      int attempts = 0;

      while (!positionFound && attempts < 200) { 
        attempts++;
        double posX = 50 + rng.nextDouble() * (size.x - 100);
        double posY = 150 + rng.nextDouble() * (size.y - 200);
        candidatePosition = Vector2(posX, posY);

        bool isTooClose = false;
        for (var existing in children.whereType<Marble>()) {
          if (existing.position.distanceTo(candidatePosition) < minSpawnDistance) {
            isTooClose = true;
            break;
          }
        }
        if (!isTooClose) positionFound = true;
      }

      if (positionFound && candidatePosition != null) {
        Marble m = Marble(startX: candidatePosition.x, startY: candidatePosition.y);
        add(m);
        groups.add({m});
      }
    }

    _lineLayer = LineLayer();
    _lineLayer.priority = 200; 
    add(_lineLayer);

    const Color c1 = Color(0xFFE5A882);
    const Color c2 = Color(0xFFDEE385);
    const Color c3 = Color(0xFF7BDDE6);

    final double cardWidth = 70;
    final double cardHeight = 140;
    final double leftMargin = 0;
    final double topStart = 240;
    final double gap = 22;

    // Set boundaries to match the card area
    topBoundary = topStart;
    bottomBoundary = topStart + 2 * (cardHeight + gap) + cardHeight;

    add(NeoCard(
      baseColor: c1,
      position: Vector2(leftMargin, topStart),
      size: Vector2(cardWidth, cardHeight),
    ));
    add(NeoCard(
      baseColor: c2,
      position: Vector2(leftMargin, topStart + cardHeight + gap),
      size: Vector2(cardWidth, cardHeight),
    ));
    add(NeoCard(
      baseColor: c3,
      position: Vector2(leftMargin, topStart + 2 * (cardHeight + gap)),
      size: Vector2(cardWidth, cardHeight),
    ));
  }

  @override
  Color backgroundColor() => Colors.transparent;

  Set<Marble> findGroup(Marble m) {
    return groups.firstWhere((g) => g.contains(m), orElse: () => {m});
  }

  void moveGroup(Marble leader, Vector2 delta) {
    Set<Marble> group = findGroup(leader);
    for (var m in group) {
      // LOGIKA DRAG GROUP
      if (m == leader) {
        // Leader bergerak instan (mengikuti jari)
        m.position += delta;
        m.targetPosition += delta;
      } else {
        // Follower HANYA update targetnya.
        // Posisi aslinya akan mengejar target ini pelan-pelan (Inersia dari marble.dart)
        m.targetPosition += delta;
      }
      
      // Penting: Update rumah formasi
      m.originalFormPosition += delta; 
    }
    
    // Apply collision resolution immediately after moving
    _resolveMarbleCardCollisions();
  }

  void setGroupPriority(Marble leader, int priority) {
    Set<Marble> group = findGroup(leader);
    for (var m in group) {
      m.priority = priority;
    }
  }

  void disbandGroup(Marble target) {
    Set<Marble> oldGroup = findGroup(target);
    
    if (oldGroup.length > 1) {
      groups.remove(oldGroup);
      
      Vector2 center = Vector2.zero();
      for (var m in oldGroup) center += m.position;
      center /= oldGroup.length.toDouble();

      for (var m in oldGroup) {
        groups.add({m}); 
        m.isConnected = false;
        
        Vector2 direction = m.position - center;
        if (direction.length == 0) direction = Vector2(1, 0); 
        direction.normalize();
        
        m.scatter(direction);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final allMarbles = children.whereType<Marble>().toList();

    for (int i = 0; i < allMarbles.length; i++) {
      for (int j = i + 1; j < allMarbles.length; j++) {
        Marble mA = allMarbles[i];
        Marble mB = allMarbles[j];
        double dist = mA.position.distanceTo(mB.position);

        // --- 1. COLLISION (Tolak Menolak - Biar gak numpuk) ---
        if (dist < collisionDistance && dist > 0) {
           Vector2 dir = (mA.position - mB.position)..normalize();
           double overlap = collisionDistance - dist;
           Vector2 pushVector = dir * (overlap / 2);

           if (!mA.isBeingDragged) {
             mA.position += pushVector;
             mA.targetPosition += pushVector;
           }
           if (!mB.isBeingDragged) {
             mB.position -= pushVector;
             mB.targetPosition -= pushVector;
           }
        }
        
        // --- 2. COHESION (Tarik Menarik - Biar Nempel 0 Jarak) ---
        // Syarat: Mereka satu grup & Jaraknya lebih dari 40
        if (mA.isConnected && mB.isConnected && dist > collisionDistance) {
            Set<Marble> groupA = findGroup(mA);
            Set<Marble> groupB = findGroup(mB);
            
            // Jika mereka SATU GRUP dan jaraknya agak renggang (akibat drag inersia)
            // Tarik mereka kembali mendekat (Snap Effect)
            if (groupA == groupB) {
               // Hitung vektor tarik
               Vector2 pullDir = (mB.position - mA.position)..normalize();
               // Kekuatan tarik (Adjustable) - Cukup kuat untuk snap back
               double pullStrength = 50.0 * dt; 
               
               // Jangan tarik kalau sedang didrag user (biar user bisa bikin gap)
               if (!mA.isBeingDragged) {
                 mA.targetPosition += pullDir * pullStrength;
               }
               if (!mB.isBeingDragged) {
                 mB.targetPosition -= pullDir * pullStrength;
               }
            }
        }

        // --- 3. CONNECTION LOGIC ---
        if (dist < connectionDistance) {
          bool isDraggingA = mA.isBeingDragged;
          bool isDraggingB = mB.isBeingDragged;
          
          if (isDraggingA || isDraggingB) {
            Set<Marble> groupA = findGroup(mA);
            Set<Marble> groupB = findGroup(mB);

            if (groupA != groupB) {
              if (isDraggingA && groupA.length > 1) continue;
              if (isDraggingB && groupB.length > 1) continue;

              groupA.addAll(groupB);
              groups.remove(groupB);
              for (var m in groupA) {
                m.isConnected = true;
                m.priority = mA.priority; 
              }
            }
          }
        }
      }
    }

    // Drawing Lines
    List<List<Vector2>> permanentConnections = [];
    for (var group in groups) {
      List<Marble> members = group.toList();
      for (int i = 0; i < members.length; i++) {
        for (int j = i + 1; j < members.length; j++) {
            permanentConnections.add([members[i].position, members[j].position]);
        }
      }
    }
    _lineLayer.connectionsToDraw = permanentConnections;

    // Handle collisions of marbles with neo cards (rectangles)
    _resolveMarbleCardCollisions();
  }

  void _resolveMarbleCardCollisions() {
    final marbles = children.whereType<Marble>().toList();
    final cards = children.whereType<NeoCard>().toList();

    for (final m in marbles) {
      for (final card in cards) {
        final double r = m.radius;
        // Rect bounds in game space (card anchored at top-left)
        final double x0 = card.position.x;
        final double y0 = card.position.y;
        final double x1 = x0 + card.size.x;
        final double y1 = y0 + card.size.y;

        // Closest point from circle center to rect
        final double cx = m.position.x.clamp(x0, x1);
        final double cy = m.position.y.clamp(y0, y1);
        final Vector2 closest = Vector2(cx, cy);
        final Vector2 diff = m.position - closest;
        final double dist = diff.length;

        if (dist < r) {
          // Penetration resolution
          if (dist > 0) {
            final double penetration = r - dist;
            final Vector2 push = diff.normalized() * penetration;
            m.position += push;
            m.targetPosition += push;
          } else {
            // Center exactly on/inside rect; push out along the minimal axis
            final double leftPen = (m.position.x - x0).abs();
            final double rightPen = (x1 - m.position.x).abs();
            final double topPen = (m.position.y - y0).abs();
            final double bottomPen = (y1 - m.position.y).abs();

            Vector2 push = Vector2.zero();
            final double minPen = [leftPen, rightPen, topPen, bottomPen].reduce(min);
            if (minPen == leftPen) {
              push = Vector2(-(r - leftPen), 0);
            } else if (minPen == rightPen) {
              push = Vector2((r - rightPen), 0);
            } else if (minPen == topPen) {
              push = Vector2(0, -(r - topPen));
            } else {
              push = Vector2(0, (r - bottomPen));
            }
            m.position += push;
            m.targetPosition += push;
          }
        }
      }
    }
  }
}