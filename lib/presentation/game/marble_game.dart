import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/marble.dart';
import 'components/line_layer.dart';
import 'components/marble_card.dart';
import 'components/hint_text.dart';

class MarbleGame extends FlameGame {
  late LineLayer _lineLayer;
  final int marbleCount;
  final int divider;

  List<Set<Marble>> groups = [];
  late double topBoundary;
  late double bottomBoundary;

  // Available colors from cards
  final List<Color> availableColors = [
    const Color(0xFFE5A882),
    const Color(0xFFDEE385),
    const Color(0xFF7BDDE6),
  ];

  // Track which colors are already used
  final Set<Color> usedColors = {};

  // Track which groups are stuck to cards
  final Map<Set<Marble>, NeoCard> stuckGroups = {};

  // Track last hint time for each group to prevent spam
  final Map<Set<Marble>, double> lastHintTime = {};
  double _gameTime = 0.0;
  static const double hintCooldown = 2.0; // 2 seconds between hints

  MarbleGame({this.marbleCount = 10, this.divider = 3});

  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.visibleGameSize = size;

    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    int totalMarbles = marbleCount;

    // Calculate dynamic radius based on marble count
    double dynamicRadius;
    if (totalMarbles <= 18) {
      dynamicRadius = 15.0;
    } else if (totalMarbles <= 24) {
      dynamicRadius = 12.0;
    } else {
      dynamicRadius = 10.0;
    }

    // Adjust minimum spawn distance based on radius
    double minSpawnDistance = dynamicRadius * 2.5;
    Random rng = Random();

    // Left boundary ends at card area (card width + small margin)
    final double leftBoundary = 80.0;
    final double rightMargin = 50.0;
    final double topMargin = 150.0;
    final double bottomMargin = 50.0;

    for (int i = 0; i < totalMarbles; i++) {
      Vector2? candidatePosition;
      bool positionFound = false;
      int attempts = 0;

      while (!positionFound && attempts < 300) {
        attempts++;
        double posX =
            leftBoundary +
            rng.nextDouble() * (size.x - leftBoundary - rightMargin);
        double posY =
            topMargin + rng.nextDouble() * (size.y - topMargin - bottomMargin);
        candidatePosition = Vector2(posX, posY);

        bool isTooClose = false;
        for (var existing in children.whereType<Marble>()) {
          if (existing.position.distanceTo(candidatePosition) <
              minSpawnDistance) {
            isTooClose = true;
            break;
          }
        }
        if (!isTooClose) positionFound = true;
      }

      if (positionFound && candidatePosition != null) {
        Marble m = Marble(
          startX: candidatePosition.x,
          startY: candidatePosition.y,
          radius: dynamicRadius,
        );
        add(m);
        groups.add({m});
      }
    }

    // Special case: If division result is 1 (e.g., 3÷3=1), color marbles directly
    int expectedGroupSize = marbleCount ~/ divider;
    if (expectedGroupSize == 1) {
      int colorIndex = 0;
      for (var marble in children.whereType<Marble>()) {
        if (colorIndex < availableColors.length) {
          marble.groupColor = availableColors[colorIndex];
          usedColors.add(availableColors[colorIndex]);
          colorIndex++;
        }
      }
    }

    // Only add line layer if not already added
    if (!children.whereType<LineLayer>().isNotEmpty) {
      _lineLayer = LineLayer();
      _lineLayer.priority = 200;
      add(_lineLayer);
    }

    // Only add cards if not already added
    if (!children.whereType<NeoCard>().isNotEmpty) {
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

      add(
        NeoCard(
          baseColor: c1,
          position: Vector2(leftMargin, topStart),
          size: Vector2(cardWidth, cardHeight),
        ),
      );
      add(
        NeoCard(
          baseColor: c2,
          position: Vector2(leftMargin, topStart + cardHeight + gap),
          size: Vector2(cardWidth, cardHeight),
        ),
      );
      add(
        NeoCard(
          baseColor: c3,
          position: Vector2(leftMargin, topStart + 2 * (cardHeight + gap)),
          size: Vector2(cardWidth, cardHeight),
        ),
      );
    }
  }

  void resetGame() {
    // Remove all marbles
    children.whereType<Marble>().toList().forEach((marble) {
      marble.removeFromParent();
    });

    // Clear groups and tracking
    groups.clear();
    usedColors.clear();
    stuckGroups.clear();
    lastHintTime.clear();
    _gameTime = 0.0;

    // Reset cards
    for (var card in children.whereType<NeoCard>()) {
      card.isCorrect = false;
    }

    // Reinitialize game with new marble count
    _initializeGame();
  }

  @override
  Color backgroundColor() => Colors.transparent;

  Set<Marble> findGroup(Marble m) {
    return groups.firstWhere((g) => g.contains(m), orElse: () => {m});
  }

  // Check if a group has the correct number of marbles
  bool isGroupCountCorrect(Set<Marble> group) {
    int expectedCount = marbleCount ~/ divider;
    return group.length == expectedCount;
  }

  // Get the next available color that hasn't been used (random selection)
  Color? getNextAvailableColor() {
    List<Color> availableUnused = availableColors
        .where((color) => !usedColors.contains(color))
        .toList();

    if (availableUnused.isEmpty) {
      return null; // All colors used
    }

    // Return a random color from available unused colors
    return availableUnused[Random().nextInt(availableUnused.length)];
  }

  // Assign color to a group when count is correct
  void assignColorToGroup(Set<Marble> group) {
    if (isGroupCountCorrect(group) && !group.first.isBeingDragged) {
      // Check if group already has a color assigned
      bool hasDefaultColor = group.first.groupColor == Colors.purple;

      if (hasDefaultColor) {
        Color? newColor = getNextAvailableColor();
        if (newColor != null) {
          usedColors.add(newColor);
          for (var marble in group) {
            marble.groupColor = newColor;
          }
        }
      }
    }
  }

  void _showHint(Set<Marble> group, int expectedCount) {
    // Calculate center of the group
    Vector2 center = Vector2.zero();
    for (var marble in group) {
      center += marble.position;
    }
    center /= group.length.toDouble();

    // Show hint text
    String message = expectedCount == 1 
        ? 'You need 1 marble!' 
        : 'You need $expectedCount marbles!';
    add(HintText(message: message, position: center));
  }

  // Check collision between marble group and cards
  void checkGroupCardCollision(Set<Marble> group) {
    if (stuckGroups.containsKey(group)) return; // Already stuck

    // Special case: For division by same number (e.g., 3÷3), allow single marbles
    int expectedCount = marbleCount ~/ divider;
    bool isSingleMarbleCase = expectedCount == 1;

    if (!isSingleMarbleCase && group.length <= 1) return;
    if (!isSingleMarbleCase && !group.first.isConnected) return;

    final cards = children.whereType<NeoCard>().toList();
    Color groupColor = group.first.groupColor;

    for (final card in cards) {
      // Check if this is the correct matching card
      if (isGroupCountCorrect(group) &&
          groupColor != Colors.purple &&
          card.baseColor == groupColor &&
          !card.isCorrect) {
        // Check if any marble in the group is colliding with the card
        bool isColliding = false;
        for (var marble in group) {
          final double r = marble.radius;
          final double x0 = card.position.x;
          final double y0 = card.position.y;
          final double x1 = x0 + card.size.x;
          final double y1 = y0 + card.size.y;

          // Check distance to card edges
          final double cx = marble.position.x.clamp(x0, x1);
          final double cy = marble.position.y.clamp(y0, y1);
          final Vector2 closest = Vector2(cx, cy);
          final double dist = (marble.position - closest).length;

          if (dist <= r + 2) {
            // Touching or very close
            isColliding = true;
            break;
          }
        }

        if (isColliding) {
          // Stick the group to the card
          stuckGroups[group] = card;
          card.isCorrect = true;
          _positionGroupOnCard(group, card);
          for (var marble in group) {
            marble.isConnected = true;
            marble.isStuckToCard = true; // Freeze physics
          }
          break;
        }
      }
      // Show hint if wrong count and colliding with any card
      else if (!isGroupCountCorrect(group) && groupColor != Colors.purple) {
        // Check collision with this card
        bool isColliding = false;
        for (var marble in group) {
          final double r = marble.radius;
          final double x0 = card.position.x;
          final double y0 = card.position.y;
          final double x1 = x0 + card.size.x;
          final double y1 = y0 + card.size.y;

          final double cx = marble.position.x.clamp(x0, x1);
          final double cy = marble.position.y.clamp(y0, y1);
          final Vector2 closest = Vector2(cx, cy);
          final double dist = (marble.position - closest).length;

          if (dist <= r + 2) {
            isColliding = true;
            break;
          }
        }

        if (isColliding && !group.first.isBeingDragged) {
          double lastTime = lastHintTime[group] ?? 0.0;
          if (_gameTime - lastTime >= hintCooldown) {
            int expectedCount = marbleCount ~/ divider;
            _showHint(group, expectedCount);
            lastHintTime[group] = _gameTime;
          }
        }
      }
    }
  }

  void _positionGroupOnCard(Set<Marble> group, NeoCard card) {
    List<Marble> marbles = group.toList();
    int count = marbles.length;

    // Position marbles touching the right edge of the card (no gap)
    double rightEdgeX = card.position.x + card.size.x;
    double cardCenterY = card.position.y + card.size.y / 2;
    double marbleRadius = marbles.first.radius;
    double spacing = marbleRadius * 2.0; // Tight spacing like marble-to-marble

    if (count <= 4) {
      // Small groups: arrange in 2x2 or less
      int cols = 2;
      int rows = (count + 1) ~/ 2;

      for (int i = 0; i < count; i++) {
        int row = i ~/ cols;
        int col = i % cols;
        // Position marbles touching the card edge (rightEdgeX + radius)
        double offsetX = marbleRadius + col * spacing;
        double offsetY = (row - (rows - 1) / 2) * spacing;

        marbles[i].position = Vector2(
          rightEdgeX + offsetX,
          cardCenterY + offsetY,
        );
        marbles[i].targetPosition = marbles[i].position.clone();
        marbles[i].originalFormPosition = marbles[i].position.clone();
      }
    } else {
      // Larger groups: arrange in grid
      int cols = (sqrt(count).ceil()).clamp(2, 4);
      int rows = (count / cols).ceil();

      for (int i = 0; i < count; i++) {
        int row = i ~/ cols;
        int col = i % cols;
        // Position marbles touching the card edge (rightEdgeX + radius)
        double offsetX = marbleRadius + col * spacing;
        double offsetY = (row - (rows - 1) / 2) * spacing;

        marbles[i].position = Vector2(
          rightEdgeX + offsetX,
          cardCenterY + offsetY,
        );
        marbles[i].targetPosition = marbles[i].position.clone();
        marbles[i].originalFormPosition = marbles[i].position.clone();
      }
    }
  }

  void moveGroup(Marble leader, Vector2 delta) {
    Set<Marble> group = findGroup(leader);

    // Don't move if stuck to a card
    if (stuckGroups.containsKey(group)) {
      return;
    }

    // Calculate group size dampening for large groups
    int groupSize = group.length;
    bool isLargeGroup = groupSize > 6;

    for (var m in group) {
      // LOGIKA DRAG GROUP
      if (m == leader) {
        // Leader bergerak instan (mengikuti jari)
        m.position += delta;
        m.targetPosition += delta;
      } else {
        // Follower HANYA update targetnya.
        // For large groups, also move position slightly to reduce lag
        m.targetPosition += delta;
        if (isLargeGroup) {
          // Move position 50% instantly to reduce spinning
          m.position += delta * 0.5;
        }
      }

      // Penting: Update rumah formasi
      m.originalFormPosition += delta;
    }

    // Apply collision resolution immediately after moving
    _resolveMarbleCardCollisions();

    // Check if group should get a color assignment
    assignColorToGroup(group);
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
      // If group was stuck, unstick it
      if (stuckGroups.containsKey(oldGroup)) {
        NeoCard card = stuckGroups[oldGroup]!;
        card.isCorrect = false;
        stuckGroups.remove(oldGroup);
      }

      // Reset color if it was assigned
      Color oldColor = oldGroup.first.groupColor;
      if (oldColor != Colors.purple) {
        usedColors.remove(oldColor);
      }

      // Clean up hint tracking
      lastHintTime.remove(oldGroup);

      groups.remove(oldGroup);

      Vector2 center = Vector2.zero();
      for (var m in oldGroup) center += m.position;
      center /= oldGroup.length.toDouble();

      for (var m in oldGroup) {
        groups.add({m});
        m.isConnected = false;
        m.isStuckToCard = false; // Unfreeze physics
        m.groupColor = Colors.purple; // Reset to default color

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

    // Track game time for hint cooldown
    _gameTime += dt;

    final allMarbles = children.whereType<Marble>().toList();

    for (int i = 0; i < allMarbles.length; i++) {
      for (int j = i + 1; j < allMarbles.length; j++) {
        Marble mA = allMarbles[i];
        Marble mB = allMarbles[j];
        double dist = mA.position.distanceTo(mB.position);

        // Calculate dynamic distances based on marble radius
        double collisionDistance =
            (mA.radius + mB.radius); // Sum of radii (diameter if same size)
        double connectionDistance =
            collisionDistance + 4.0; // Slightly more for easy connection

        // --- 1. COLLISION (Tolak Menolak - Biar gak numpuk) ---
        if (dist < collisionDistance && dist > 0) {
          Vector2 dir = (mA.position - mB.position)..normalize();
          double overlap = collisionDistance - dist;
          Vector2 pushVector = dir * (overlap / 2);

          // Don't push stuck marbles (they're like rocks)
          bool isAStuck = mA.isStuckToCard;
          bool isBStuck = mB.isStuckToCard;

          if (!mA.isBeingDragged && !isAStuck) {
            // If B is stuck, push A with full force
            if (isBStuck) {
              mA.position += pushVector * 2;
              mA.targetPosition += pushVector * 2;
            } else {
              mA.position += pushVector;
              mA.targetPosition += pushVector;
            }
          }
          if (!mB.isBeingDragged && !isBStuck) {
            // If A is stuck, push B with full force
            if (isAStuck) {
              mB.position -= pushVector * 2;
              mB.targetPosition -= pushVector * 2;
            } else {
              mB.position -= pushVector;
              mB.targetPosition -= pushVector;
            }
          }
        }

        // --- 2. COHESION (Tarik Menarik - Biar Nempel 0 Jarak) ---
        // Syarat: Mereka satu grup & Jaraknya lebih dari collision distance
        if (mA.isConnected && mB.isConnected && dist > collisionDistance) {
          Set<Marble> groupA = findGroup(mA);
          Set<Marble> groupB = findGroup(mB);

          // Jika mereka SATU GRUP dan jaraknya agak renggang (akibat drag inersia)
          // Tarik mereka kembali mendekat (Snap Effect)
          if (groupA == groupB) {
            // Skip cohesion for stuck groups (they're immovable)
            if (stuckGroups.containsKey(groupA)) continue;

            // Hitung vektor tarik
            Vector2 pullDir = (mB.position - mA.position)..normalize();

            // Reduce pull strength for larger groups to prevent spinning
            int groupSize = groupA.length;
            double dampening = 1.0;
            if (groupSize > 6) {
              dampening = 0.3; // Much weaker for large groups
            } else if (groupSize > 4) {
              dampening = 0.5; // Moderate dampening
            } else if (groupSize > 2) {
              dampening = 0.7; // Light dampening
            }

            double pullStrength = 50.0 * dt * dampening;

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
              // Don't allow connections with stuck groups
              if (stuckGroups.containsKey(groupA) ||
                  stuckGroups.containsKey(groupB)) {
                continue;
              }

              if (isDraggingA && groupA.length > 1) continue;
              if (isDraggingB && groupB.length > 1) continue;

              groupA.addAll(groupB);
              groups.remove(groupB);
              for (var m in groupA) {
                m.isConnected = true;
                m.priority = mA.priority;
              }

              // Check if the new merged group should get a color
              assignColorToGroup(groupA);
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

    // Check for group-card collisions (for sticking)
    int expectedCount = marbleCount ~/ divider;
    bool isSingleMarbleCase = expectedCount == 1;

    for (var group in groups) {
      // Allow single marbles for 1:1 division, otherwise require connected groups
      bool shouldCheck = isSingleMarbleCase
          ? group.first.groupColor != Colors.purple
          : (group.length > 1 && group.first.isConnected);

      if (shouldCheck) {
        checkGroupCardCollision(group);
      }
    }
  }

  void _resolveMarbleCardCollisions() {
    final marbles = children.whereType<Marble>().toList();
    final cards = children.whereType<NeoCard>().toList();

    for (final m in marbles) {
      // Skip collision resolution for marbles in stuck groups
      Set<Marble> marbleGroup = findGroup(m);
      if (stuckGroups.containsKey(marbleGroup)) continue;

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
            final double minPen = [
              leftPen,
              rightPen,
              topPen,
              bottomPen,
            ].reduce(min);
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
