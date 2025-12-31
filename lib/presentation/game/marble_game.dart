import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/marble.dart';
import 'components/line_layer.dart';
import 'components/marble_card.dart';

/// The main game engine for the marble grouping puzzle.
///
/// This class handles:
/// - Marble spawning and physics
/// - Group formation and management
/// - Collision detection (marble-to-marble and marble-to-card)
/// - Visual feedback through connection lines
/// - Card placement validation
///
/// The game uses a physics-based approach where marbles can be dragged
/// to form groups, which can then be placed on colored cards.
class MarbleGame extends FlameGame {
  // ==================== Public Properties ====================

  /// The total number of marbles to spawn
  final int marbleCount;

  /// The divider for the division problem
  final int divider;

  /// The device screen size for responsive scaling
  final Size screenSize;

  /// List of marble groups (each set contains connected marbles)
  List<Set<Marble>> groups = [];

  /// Top boundary for marble movement (below cards and UI)
  late double topBoundary;

  /// Bottom boundary for marble movement
  late double bottomBoundary;

  /// Available colors for cards and marble groups
  final List<Color> availableColors = [
    const Color(0xFFE5A882),
    const Color(0xFFDEE385),
    const Color(0xFF7BDDE6),
  ];

  /// Track which groups are stuck to cards
  final Map<Set<Marble>, NeoCard> stuckGroups = {};

  // ==================== Private Properties ====================

  /// The line layer component for drawing connections
  late LineLayer _lineLayer;

  /// Set of colors currently in use by groups
  final Set<Color> usedColors = {};

  // ==================== Design Constants ====================

  /// Reference design width for scaling calculations
  static const double designWidth = 430.0;

  /// Reference design height for scaling calculations
  static const double designHeight = 932.0;

  // ==================== Constructor ====================

  /// Creates a new MarbleGame instance.
  ///
  /// Parameters:
  /// - [marbleCount]: Number of marbles to spawn (default: 10)
  /// - [divider]: The division problem divider (default: 3)
  /// - [screenSize]: Device screen dimensions for scaling
  MarbleGame({
    this.marbleCount = 10,
    this.divider = 3,
    required this.screenSize,
  });

  // ==================== Lifecycle Methods ====================

  /// Loads the game and initializes all components.
  @override
  FutureOr<void> onLoad() async {
    camera.viewfinder.visibleGameSize = size;
    await _initializeGame();
  }

  /// Sets the background color to transparent.
  @override
  Color backgroundColor() => Colors.transparent;

  // ==================== Initialization Methods ====================

  /// Initializes the game by spawning marbles, cards, and line layer.
  ///
  /// This method:
  /// 1. Calculates responsive scaling
  /// 2. Spawns marbles in random positions
  /// 3. Creates the line layer for connections
  /// 4. Positions the three colored cards
  Future<void> _initializeGame() async {
    final double scaleFactor = _calculateScaleFactor();
    final double dynamicRadius = _calculateMarbleRadius(scaleFactor);

    await _spawnMarbles(dynamicRadius, scaleFactor);
    _initializeLineLayer();
    _initializeCards(scaleFactor);
  }

  /// Calculates the responsive scale factor for UI elements.
  ///
  /// Considers screen size and applies special handling for large displays
  /// to prevent elements from becoming too large.
  double _calculateScaleFactor() {
    double widthScale = size.x / designWidth;
    double heightScale = size.y / designHeight;
    double scaleFactor = min(widthScale, heightScale);

    // Special handling for large displays
    if (size.x > 800) {
      scaleFactor *= 0.65;
    }

    return scaleFactor.clamp(0.7, 1.2);
  }

  /// Calculates marble radius based on marble count and scale.
  ///
  /// Smaller marbles are used when there are more marbles to fit them better.
  double _calculateMarbleRadius(double scaleFactor) {
    double baseRadius;

    if (marbleCount <= 18) {
      baseRadius = 15.0;
    } else if (marbleCount <= 24) {
      baseRadius = 12.0;
    } else {
      baseRadius = 10.0;
    }

    final double dynamicRadius = baseRadius * scaleFactor;
    return dynamicRadius.clamp(8.0, 20.0);
  }

  /// Spawns all marbles in random positions without overlapping.
  ///
  /// Uses a rejection sampling approach to ensure marbles don't spawn
  /// too close to each other.
  Future<void> _spawnMarbles(double radius, double scaleFactor) async {
    final double minSpawnDistance = radius * 2.5;
    final Random rng = Random();

    // Calculate spawn boundaries
    final double leftBoundary = 105.0 * scaleFactor;
    final double rightMargin = 50.0 * scaleFactor;
    final double topMargin = 150.0 * scaleFactor;
    final double bottomMargin = 50.0 * scaleFactor;

    for (int i = 0; i < marbleCount; i++) {
      final Vector2? position = _findValidSpawnPosition(
        leftBoundary,
        rightMargin,
        topMargin,
        bottomMargin,
        minSpawnDistance,
        rng,
      );

      if (position != null) {
        final Marble marble = Marble(
          startX: position.x,
          startY: position.y,
          radius: radius,
        );
        add(marble);
        groups.add({marble});
      }
    }
  }

  /// Finds a valid spawn position that doesn't overlap with existing marbles.
  ///
  /// Tries up to 300 times to find a position, returns null if unsuccessful.
  Vector2? _findValidSpawnPosition(
    double leftBoundary,
    double rightMargin,
    double topMargin,
    double bottomMargin,
    double minDistance,
    Random rng,
  ) {
    int attempts = 0;
    const int maxAttempts = 300;

    while (attempts < maxAttempts) {
      attempts++;

      final double posX =
          leftBoundary +
          rng.nextDouble() * (size.x - leftBoundary - rightMargin);
      final double posY =
          topMargin + rng.nextDouble() * (size.y - topMargin - bottomMargin);
      final Vector2 candidatePosition = Vector2(posX, posY);

      if (_isPositionValid(candidatePosition, minDistance)) {
        return candidatePosition;
      }
    }

    return null;
  }

  /// Checks if a position is valid (not too close to existing marbles).
  bool _isPositionValid(Vector2 position, double minDistance) {
    for (var existing in children.whereType<Marble>()) {
      if (existing.position.distanceTo(position) < minDistance) {
        return false;
      }
    }
    return true;
  }

  /// Initializes the line layer component if not already added.
  void _initializeLineLayer() {
    if (children.whereType<LineLayer>().isEmpty) {
      _lineLayer = LineLayer();
      _lineLayer.priority = 200;
      add(_lineLayer);
    }
  }

  /// Initializes the three colored cards if not already added.
  ///
  /// Cards are positioned on the left side with even spacing.
  void _initializeCards(double scaleFactor) {
    if (children.whereType<NeoCard>().isNotEmpty) return;

    // Card dimensions
    final double cardWidth = 85 * scaleFactor;
    final double cardHeight = 160 * scaleFactor;
    final double leftMargin = 8 * scaleFactor;
    final double topStart = 280 * scaleFactor;
    final double gap = 28 * scaleFactor;

    // Set boundaries based on card positions
    topBoundary = topStart;
    bottomBoundary = topStart + 2 * (cardHeight + gap) + cardHeight;

    // Add three cards with different colors
    final List<Color> cardColors = availableColors;
    for (int i = 0; i < 3; i++) {
      add(
        NeoCard(
          baseColor: cardColors[i],
          position: Vector2(leftMargin, topStart + i * (cardHeight + gap)),
          size: Vector2(cardWidth, cardHeight),
        ),
      );
    }
  }

  // ==================== Game Control Methods ====================

  /// Resets the game to a fresh state with new marbles.
  ///
  /// Removes all existing marbles, clears groups, and reinitializes.
  void resetGame() {
    // Remove all marbles
    children.whereType<Marble>().toList().forEach((marble) {
      marble.removeFromParent();
    });

    // Clear all tracking data
    groups.clear();
    usedColors.clear();
    stuckGroups.clear();

    // Reset all cards
    for (var card in children.whereType<NeoCard>()) {
      card.isCorrect = false;
    }

    // Reinitialize game
    _initializeGame();
  }

  // ==================== Group Management Methods ====================

  /// Finds the group containing a specific marble.
  ///
  /// Returns the set containing the marble, or a single-marble set
  /// if the marble isn't in any group.
  Set<Marble> findGroup(Marble marble) {
    return groups.firstWhere((g) => g.contains(marble), orElse: () => {marble});
  }

  /// Assigns a color to all marbles in a group based on the card color.
  void assignColorToGroupByCard(Set<Marble> group, NeoCard card) {
    final Color cardColor = card.baseColor;

    for (var marble in group) {
      marble.groupColor = cardColor;
    }
  }

  /// Moves all marbles in a group together when the leader is dragged.
  ///
  /// The leader moves instantly to follow the finger, while followers
  /// smoothly interpolate. Large groups get extra dampening to prevent
  /// spinning issues.
  void moveGroup(Marble leader, Vector2 delta) {
    final Set<Marble> group = findGroup(leader);

    // Don't move if stuck to a card
    if (stuckGroups.containsKey(group)) return;

    final bool isLargeGroup = group.length > 6;

    for (var marble in group) {
      if (marble == leader) {
        // Leader follows finger instantly
        marble.position += delta;
        marble.targetPosition += delta;
      } else {
        // Followers update target position
        marble.targetPosition += delta;

        // Large groups need partial instant movement to reduce lag
        if (isLargeGroup) {
          marble.position += delta * 0.5;
        }
      }

      // Update formation home position
      marble.originalFormPosition += delta;
    }

    // Apply collision resolution immediately
    _resolveMarbleCardCollisions();
  }

  /// Sets the rendering priority for all marbles in a group.
  ///
  /// Used to bring dragged groups to the front.
  void setGroupPriority(Marble leader, int priority) {
    final Set<Marble> group = findGroup(leader);
    for (var marble in group) {
      marble.priority = priority;
    }
  }

  /// Disbands a group, separating all marbles.
  ///
  /// If the group was stuck to a card, marbles scatter to the right.
  /// Otherwise, they scatter from the group's center.
  void disbandGroup(Marble target) {
    final Set<Marble> oldGroup = findGroup(target);
    if (oldGroup.isEmpty) return;

    final bool wasStuckToCard = stuckGroups.containsKey(oldGroup);

    // Unstick from card if applicable
    if (wasStuckToCard) {
      final NeoCard card = stuckGroups[oldGroup]!;
      card.isCorrect = false;
      stuckGroups.remove(oldGroup);
    }

    // Reset color if it was assigned
    _resetGroupColor(oldGroup);

    // Handle single marble case
    if (oldGroup.length == 1) {
      _disbandSingleMarble(oldGroup.first, wasStuckToCard);
      return;
    }

    // Handle multi-marble group
    _disbandMultipleMarbles(oldGroup, wasStuckToCard);
  }

  /// Resets the color of a group to the default purple.
  void _resetGroupColor(Set<Marble> group) {
    final Color oldColor = group.first.groupColor;
    if (oldColor != Colors.purple) {
      usedColors.remove(oldColor);
    }
  }

  /// Disbands a single marble.
  void _disbandSingleMarble(Marble marble, bool wasStuckToCard) {
    marble.isConnected = false;
    marble.isStuckToCard = false;
    marble.groupColor = Colors.purple;

    if (wasStuckToCard) {
      marble.scatter(Vector2(1, 0));
    }
  }

  /// Disbands multiple marbles from a group.
  void _disbandMultipleMarbles(Set<Marble> group, bool wasStuckToCard) {
    groups.remove(group);

    if (wasStuckToCard) {
      _scatterGroupToRight(group);
    } else {
      _scatterGroupFromCenter(group);
    }
  }

  /// Scatters marbles to the right (used when unsticking from card).
  void _scatterGroupToRight(Set<Marble> group) {
    for (var marble in group) {
      groups.add({marble});
      marble.isConnected = false;
      marble.isStuckToCard = false;
      marble.groupColor = Colors.purple;
      marble.scatter(Vector2(1, 0));
    }
  }

  /// Scatters marbles from their group center (normal disband).
  void _scatterGroupFromCenter(Set<Marble> group) {
    final Vector2 center = _calculateGroupCenter(group);

    for (var marble in group) {
      groups.add({marble});
      marble.isConnected = false;
      marble.isStuckToCard = false;
      marble.groupColor = Colors.purple;

      Vector2 direction = marble.position - center;
      if (direction.length == 0) {
        direction = Vector2(1, 0);
      }
      direction.normalize();

      marble.scatterReduced(direction);
    }
  }

  /// Calculates the center position of a group of marbles.
  Vector2 _calculateGroupCenter(Set<Marble> group) {
    Vector2 center = Vector2.zero();
    for (var marble in group) {
      center += marble.position;
    }
    center /= group.length.toDouble();
    return center;
  }

  // ==================== Card Collision Methods ====================

  /// Checks if a group collides with any card and sticks it if so.
  ///
  /// Only allows placement of:
  /// - Single marbles that have been dragged
  /// - Connected groups
  void checkGroupCardCollision(Set<Marble> group) {
    if (stuckGroups.containsKey(group)) return;

    // Validate group can be placed
    if (group.length == 1) {
      if (!group.first.hasBeenDragged) return;
    } else if (group.length > 1 && !group.first.isConnected) {
      return;
    }

    final cards = children.whereType<NeoCard>().toList();

    for (final card in cards) {
      if (card.isCorrect) continue;

      if (_isGroupCollidingWithCard(group, card)) {
        _stickGroupToCard(group, card);
        break;
      }
    }
  }

  /// Checks if any marble in a group is colliding with a card.
  bool _isGroupCollidingWithCard(Set<Marble> group, NeoCard card) {
    for (var marble in group) {
      if (_isMarbleCollidingWithCard(marble, card)) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a single marble is colliding with a card.
  bool _isMarbleCollidingWithCard(Marble marble, NeoCard card) {
    final double r = marble.radius;
    final double x0 = card.position.x;
    final double y0 = card.position.y;
    final double x1 = x0 + card.size.x;
    final double y1 = y0 + card.size.y;

    // Find closest point on card to marble center
    final double cx = marble.position.x.clamp(x0, x1);
    final double cy = marble.position.y.clamp(y0, y1);
    final Vector2 closest = Vector2(cx, cy);
    final double dist = (marble.position - closest).length;

    return dist <= r + 2;
  }

  /// Sticks a group of marbles to a card.
  void _stickGroupToCard(Set<Marble> group, NeoCard card) {
    assignColorToGroupByCard(group, card);
    stuckGroups[group] = card;
    card.isCorrect = true;
    _positionGroupOnCard(group, card);

    for (var marble in group) {
      marble.isConnected = true;
      marble.isStuckToCard = true;
    }
  }

  /// Positions marbles in a neat grid formation on the card.
  ///
  /// Uses 2x2 grid for small groups, larger grid for bigger groups.
  void _positionGroupOnCard(Set<Marble> group, NeoCard card) {
    final List<Marble> marbles = group.toList();
    final int count = marbles.length;

    final double rightEdgeX = card.position.x + card.size.x;
    final double cardCenterY = card.position.y + card.size.y / 2;
    final double marbleRadius = marbles.first.radius;
    final double spacing = marbleRadius * 2.0;

    if (count <= 4) {
      _positionSmallGroup(marbles, rightEdgeX, cardCenterY, spacing);
    } else {
      _positionLargeGroup(marbles, rightEdgeX, cardCenterY, spacing);
    }
  }

  /// Positions small groups (<=4 marbles) in 2x2 or smaller arrangement.
  void _positionSmallGroup(
    List<Marble> marbles,
    double rightEdgeX,
    double cardCenterY,
    double spacing,
  ) {
    const int cols = 2;
    final int rows = (marbles.length + 1) ~/ 2;
    final double marbleRadius = marbles.first.radius;

    for (int i = 0; i < marbles.length; i++) {
      final int row = i ~/ cols;
      final int col = i % cols;
      final double offsetX = marbleRadius + col * spacing;
      final double offsetY = (row - (rows - 1) / 2) * spacing;

      _setMarblePosition(
        marbles[i],
        Vector2(rightEdgeX + offsetX, cardCenterY + offsetY),
      );
    }
  }

  /// Positions large groups in a grid pattern.
  void _positionLargeGroup(
    List<Marble> marbles,
    double rightEdgeX,
    double cardCenterY,
    double spacing,
  ) {
    final int cols = (sqrt(marbles.length).ceil()).clamp(2, 4);
    final int rows = (marbles.length / cols).ceil();
    final double marbleRadius = marbles.first.radius;

    for (int i = 0; i < marbles.length; i++) {
      final int row = i ~/ cols;
      final int col = i % cols;
      final double offsetX = marbleRadius + col * spacing;
      final double offsetY = (row - (rows - 1) / 2) * spacing;

      _setMarblePosition(
        marbles[i],
        Vector2(rightEdgeX + offsetX, cardCenterY + offsetY),
      );
    }
  }

  /// Sets a marble's position and updates its targets.
  void _setMarblePosition(Marble marble, Vector2 position) {
    marble.position = position;
    marble.targetPosition = position.clone();
    marble.originalFormPosition = position.clone();
  }

  // ==================== Physics Update Methods ====================

  /// Main update loop handling all physics and interactions.
  @override
  void update(double dt) {
    super.update(dt);

    final allMarbles = children.whereType<Marble>().toList();

    // Process marble-to-marble interactions
    _updateMarbleInteractions(allMarbles, dt);

    // Update connection lines
    _updateConnectionLines();

    // Handle marble-card collisions
    _resolveMarbleCardCollisions();

    // Check for new group-card collisions
    _checkGroupCardCollisions();
  }

  /// Processes all marble-to-marble physics interactions.
  void _updateMarbleInteractions(List<Marble> marbles, double dt) {
    for (int i = 0; i < marbles.length; i++) {
      for (int j = i + 1; j < marbles.length; j++) {
        _processMarblePair(marbles[i], marbles[j], dt);
      }
    }
  }

  /// Processes physics between two marbles.
  ///
  /// Handles three types of interactions:
  /// 1. Collision (push apart)
  /// 2. Cohesion (pull together if in same group)
  /// 3. Connection (form groups when dragged close)
  void _processMarblePair(Marble mA, Marble mB, double dt) {
    final double dist = mA.position.distanceTo(mB.position);
    final double collisionDistance = mA.radius + mB.radius;
    final double connectionDistance = collisionDistance + 4.0;

    // 1. Collision detection and resolution
    if (dist < collisionDistance && dist > 0) {
      _handleCollision(mA, mB, dist, collisionDistance);
    }

    // 2. Cohesion for same-group marbles
    if (mA.isConnected && mB.isConnected && dist > collisionDistance) {
      _handleCohesion(mA, mB, dt);
    }

    // 3. Connection formation
    if (dist < connectionDistance) {
      _handleConnection(mA, mB);
    }
  }

  /// Handles collision between two marbles (push apart).
  void _handleCollision(
    Marble mA,
    Marble mB,
    double dist,
    double collisionDistance,
  ) {
    final Vector2 dir = (mA.position - mB.position)..normalize();
    final double overlap = collisionDistance - dist;
    final Vector2 pushVector = dir * (overlap / 2);

    final bool isAStuck = mA.isStuckToCard;
    final bool isBStuck = mB.isStuckToCard;

    // Push marbles apart (stuck marbles act as immovable)
    if (!mA.isBeingDragged && !isAStuck) {
      final Vector2 push = isBStuck ? pushVector * 2 : pushVector;
      mA.position += push;
      mA.targetPosition += push;
    }

    if (!mB.isBeingDragged && !isBStuck) {
      final Vector2 push = isAStuck ? pushVector * 2 : pushVector;
      mB.position -= push;
      mB.targetPosition -= push;
    }
  }

  /// Handles cohesion (pulling together) for same-group marbles.
  void _handleCohesion(Marble mA, Marble mB, double dt) {
    final Set<Marble> groupA = findGroup(mA);
    final Set<Marble> groupB = findGroup(mB);

    // Only apply if same group and not stuck
    if (groupA != groupB || stuckGroups.containsKey(groupA)) return;

    final Vector2 pullDir = (mB.position - mA.position)..normalize();

    // Dampen pull strength for large groups to prevent spinning
    final double dampening = _calculateCohesionDampening(groupA.length);
    final double pullStrength = 50.0 * dt * dampening;

    // Apply pull (unless being dragged)
    if (!mA.isBeingDragged) {
      mA.targetPosition += pullDir * pullStrength;
    }
    if (!mB.isBeingDragged) {
      mB.targetPosition -= pullDir * pullStrength;
    }
  }

  /// Calculates cohesion dampening based on group size.
  double _calculateCohesionDampening(int groupSize) {
    if (groupSize > 6) return 0.3;
    if (groupSize > 4) return 0.5;
    if (groupSize > 2) return 0.7;
    return 1.0;
  }

  /// Handles connection formation between two marbles.
  void _handleConnection(Marble mA, Marble mB) {
    final bool isDraggingA = mA.isBeingDragged;
    final bool isDraggingB = mB.isBeingDragged;

    if (!isDraggingA && !isDraggingB) return;

    final Set<Marble> groupA = findGroup(mA);
    final Set<Marble> groupB = findGroup(mB);

    if (groupA == groupB) return;

    // Don't connect with stuck groups
    if (stuckGroups.containsKey(groupA) || stuckGroups.containsKey(groupB)) {
      return;
    }

    // Only allow connecting single marbles or small groups
    if (isDraggingA && groupA.length > 1) return;
    if (isDraggingB && groupB.length > 1) return;

    // Merge groups
    _mergeGroups(groupA, groupB, mA.priority);
  }

  /// Merges two groups into one.
  void _mergeGroups(Set<Marble> groupA, Set<Marble> groupB, int priority) {
    groupA.addAll(groupB);
    groups.remove(groupB);

    for (var marble in groupA) {
      marble.isConnected = true;
      marble.priority = priority;
      marble.hasBeenDragged = true;
    }
  }

  /// Updates the connection lines between grouped marbles.
  void _updateConnectionLines() {
    final List<List<Vector2>> connections = [];

    for (var group in groups) {
      final List<Marble> members = group.toList();
      for (int i = 0; i < members.length; i++) {
        for (int j = i + 1; j < members.length; j++) {
          connections.add([members[i].position, members[j].position]);
        }
      }
    }

    _lineLayer.connectionsToDraw = connections;
  }

  /// Checks all groups for collisions with cards.
  void _checkGroupCardCollisions() {
    for (var group in groups) {
      final bool isSingleMarble = group.length == 1;
      final bool shouldCheck = isSingleMarble
          ? group.first.hasBeenDragged
          : group.first.isConnected;

      if (shouldCheck) {
        checkGroupCardCollision(group);
      }
    }
  }

  /// Resolves collisions between marbles and cards (prevents overlap).
  void _resolveMarbleCardCollisions() {
    final marbles = children.whereType<Marble>().toList();
    final cards = children.whereType<NeoCard>().toList();

    for (final marble in marbles) {
      // Skip stuck marbles
      final Set<Marble> marbleGroup = findGroup(marble);
      if (stuckGroups.containsKey(marbleGroup)) continue;

      for (final card in cards) {
        _resolveMarbleCardCollision(marble, card);
      }
    }
  }

  /// Resolves collision between a single marble and a card.
  void _resolveMarbleCardCollision(Marble marble, NeoCard card) {
    final double r = marble.radius;
    final double x0 = card.position.x;
    final double y0 = card.position.y;
    final double x1 = x0 + card.size.x;
    final double y1 = y0 + card.size.y;

    // Find closest point on card to marble
    final double cx = marble.position.x.clamp(x0, x1);
    final double cy = marble.position.y.clamp(y0, y1);
    final Vector2 closest = Vector2(cx, cy);
    final Vector2 diff = marble.position - closest;
    final double dist = diff.length;

    if (dist < r) {
      _pushMarbleOutOfCard(marble, diff, dist, r, x0, x1, y0, y1);
    }
  }

  /// Pushes a marble out of a card when penetrating.
  void _pushMarbleOutOfCard(
    Marble marble,
    Vector2 diff,
    double dist,
    double radius,
    double x0,
    double x1,
    double y0,
    double y1,
  ) {
    if (dist > 0) {
      // Normal penetration case
      final double penetration = radius - dist;
      final Vector2 push = diff.normalized() * penetration;
      marble.position += push;
      marble.targetPosition += push;
    } else {
      // Marble center inside card - push out along minimal axis
      final Vector2 push = _calculateMinimalPush(
        marble.position,
        radius,
        x0,
        x1,
        y0,
        y1,
      );
      marble.position += push;
      marble.targetPosition += push;
    }
  }

  /// Calculates the minimal push vector to get marble out of card.
  Vector2 _calculateMinimalPush(
    Vector2 position,
    double radius,
    double x0,
    double x1,
    double y0,
    double y1,
  ) {
    final double leftPen = (position.x - x0).abs();
    final double rightPen = (x1 - position.x).abs();
    final double topPen = (position.y - y0).abs();
    final double bottomPen = (y1 - position.y).abs();

    final double minPen = [leftPen, rightPen, topPen, bottomPen].reduce(min);

    if (minPen == leftPen) {
      return Vector2(-(radius - leftPen), 0);
    } else if (minPen == rightPen) {
      return Vector2((radius - rightPen), 0);
    } else if (minPen == topPen) {
      return Vector2(0, -(radius - topPen));
    } else {
      return Vector2(0, (radius - bottomPen));
    }
  }
}
