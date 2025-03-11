import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CardMatchingGame(title: 'Card Matching Game'),
    );
  }
}

class CardMatchingGame extends StatefulWidget {
  const CardMatchingGame({super.key, required this.title});
  final String title;

  @override
  State<CardMatchingGame> createState() => _CardMatchingGameState();
}

class CardModel {
  final String frontDesign;
  final String backDesign;
  bool isFaceUp;

  CardModel({
    required this.frontDesign,
    required this.backDesign,
    this.isFaceUp = false,
  });
}

class GameState extends ChangeNotifier {
  List<CardModel> cards = List.generate(
    16,
    (index) => CardModel(
      frontDesign: 'assets/images/card${index % 8 + 1}.jpg',
      backDesign: 'assets/images/backofcard.jpg',
    ),
  )..shuffle();

  List<int> _faceUpCards = [];

  void flipCard(int index) {
    if (_faceUpCards.length < 2) {
      cards[index].isFaceUp = !cards[index].isFaceUp;
      if (cards[index].isFaceUp) {
        _faceUpCards.add(index);
      } else {
        _faceUpCards.remove(index);
      }
      notifyListeners();

      if (_faceUpCards.length == 2) {
        Future.delayed(const Duration(seconds: 1), () {
          _checkMatch();
        });
      }
    }
  }

  void _checkMatch() {
    if (_faceUpCards.length == 2) {
      final firstCard = cards[_faceUpCards[0]];
      final secondCard = cards[_faceUpCards[1]];

      if (firstCard.frontDesign != secondCard.frontDesign) {
        firstCard.isFaceUp = false;
        secondCard.isFaceUp = false;
      }
      _faceUpCards.clear();
      notifyListeners();
    }
  }
}

class _CardMatchingGameState extends State<CardMatchingGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _flippingCardIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: gameState.cards.length,
        itemBuilder: (context, index) {
          final card = gameState.cards[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _flippingCardIndex = index;
              });
              gameState.flipCard(index);
              _controller.forward(from: 0.0);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final isFlipping = _flippingCardIndex == index;
                  final rotationValue = isFlipping ? _animation.value * 3.14 : 0.0;
                  return Transform(
                    transform: Matrix4.rotationY(rotationValue),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.black),
                        image: card.isFaceUp
                            ? DecorationImage(
                                image: AssetImage(card.frontDesign),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: AssetImage(card.backDesign),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: Center(
                        child: card.isFaceUp ? Container() : Container(),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}