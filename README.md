# 🎯 Marbleous

<div align="center">
  <p><strong>An Interactive Educational Game for Learning Division Through Play</strong></p>
  <p>
    <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
    <img alt="Dart" src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
    <img alt="Flame" src="https://img.shields.io/badge/Flame-FF6D00?style=for-the-badge&logo=flame&logoColor=white" />
  </p>
</div>

## 📖 About

**Marbleous** is an interactive educational game that makes learning division fun and intuitive. Players drag and group colorful marbles to solve division problems, reinforcing mathematical concepts through hands-on gameplay.

### ✨ Key Features

- **🎮 Interactive Gameplay**: Drag marbles to form groups and solve division problems
- **🎨 Beautiful Design**: Modern, colorful interface with smooth animations
- **📚 Educational**: Teaches division concepts through visual grouping
- **🎯 Physics-Based**: Realistic marble interactions using Flame game engine
- **📱 Responsive**: Works seamlessly across different screen sizes
- **🔄 Dynamic Questions**: Randomized problems to keep learning fresh

## 🎮 How to Play

1. **View the Question**: See the division problem displayed at the top
2. **Group Marbles**: Drag marbles together to form groups
3. **Place on Cards**: Move groups onto colored cards
4. **Check Answer**: Submit your solution to see if you're correct!
5. **Try Again**: Practice with new problems to master division

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: 3.9.2 or higher
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Device**: Android device/emulator, iOS device/simulator, or web browser

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/marbleous.git
   cd marbleous
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Built With

- **[Flutter](https://flutter.dev/)** - UI framework
- **[Flame](https://flame-engine.org/)** - 2D game engine for physics and rendering
- **[GetX](https://pub.dev/packages/get)** - State management and navigation
- **[Flutter SVG](https://pub.dev/packages/flutter_svg)** - SVG rendering support

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── presentation/
│   ├── game/                    # Game engine components
│   │   ├── marble_game.dart     # Main game logic
│   │   ├── components/          # Game components (marbles, cards, etc.)
│   │   └── controllers/         # Game state management
│   └── screens/                 # UI screens
│       └── game_screen.dart     # Main game screen
└── utils/
    └── responsive_utils.dart    # Responsive design utilities
```

## 🎨 Features in Detail

### Physics Engine
- Realistic marble collision detection
- Smooth drag-and-drop interactions
- Group formation mechanics

### Visual Feedback
- Connection lines between grouped marbles
- Color-coded cards for visual learning
- Animated responses to player actions

### Educational Design
- Progressive difficulty levels
- Immediate feedback on answers
- Visual representation of division concepts

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

Built with ❤️ by a Flutter enthusiast

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Flame engine community for game development tools
- All contributors and testers

## 📧 Contact

For questions or suggestions, please open an issue on GitHub.

---

<div align="center">
  <p>Made with Flutter 💙</p>
</div>
