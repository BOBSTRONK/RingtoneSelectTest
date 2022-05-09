import 'package:flutter/material.dart';
import 'package:frivia/providers/game_page_provider.dart';
import 'package:provider/provider.dart';

class GamePage extends StatelessWidget {
  double? _deviceHeight, _deviceWidth;

  String difficult;

  GamePageProvider? _pageProvider;

  GamePage({required this.difficult});

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      //instantiating a new instance of HomePageProvider object
      //anything going to be the child of this change Notier provider
      //will have access to this game page provider and will be able to access
      //not only the child but it is descendants(后裔) as well.
      create: (context) =>
          GamePageProvider(context: context, difficulty: difficult),
      child:
          _buildUI(), //child is whatever i want the ChangeNotifier to wrapper
      //builUI widget will have access to the HomepageProvider
      //Everytime the state of our HomePageProvider is going to change,
      //everything underneath of this changePageProvider, these child are going to
      // be rebuilt and re-rendered as well
    );
  }

  Widget _buildUI() {
    return Builder(builder: (context) {
      _pageProvider = context.watch<GamePageProvider>();
      //start to using provider
      if (_pageProvider!.questions != null) {
        return Scaffold(
          body: SafeArea(
              child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceHeight! * 0.05,
            ),
            child: _gameUI(),
          )),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    });
  }

  Widget _gameUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _questionText(),
        Column(
          children: [
            _trueButton(),
            SizedBox(
              height: _deviceHeight! * 0.01,
            ),
            _falseButton(),
          ],
        ),
      ],
    );
  }

  Widget _questionText() {
    return Text(
      _pageProvider!.getCurrentQuesitonText(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _trueButton() {
    return MaterialButton(
      onPressed: () {
        _pageProvider?.answerQuestion("True");
      },
      color: Colors.green,
      minWidth: _deviceWidth! * 0.80,
      height: _deviceHeight! * 0.10,
      child: const Text(
        "True",
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget _falseButton() {
    return MaterialButton(
      onPressed: () {
        _pageProvider?.answerQuestion("False");
      },
      color: Colors.red,
      minWidth: _deviceWidth! * 0.80,
      height: _deviceHeight! * 0.10,
      child: const Text(
        "False",
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
        ),
      ),
    );
  }
}
