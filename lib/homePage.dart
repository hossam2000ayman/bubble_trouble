import 'dart:async';

import 'package:bubble_trouble/ball.dart';
import 'package:bubble_trouble/button.dart';
import 'package:bubble_trouble/missile.dart';
import 'package:bubble_trouble/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum directions { RIGHT, LEFT }

class _HomePageState extends State<HomePage> {
  //player variables
  static double playerX = 0;

  //missles variables
  double missleX = playerX;
  double missleYHeight = 10;
  bool midShot = false;

  //ball variables
  double ballX = 0.5;
  double ballY = 1;
  var ballDirection = directions.LEFT;

  void startGame() {
    double time = 0;
    double height = 0;
    double velocity = 60; //how strong the jump is

    //if the ball hits the left wall , then change direction to right
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      //quadratic equaion that models a bounce (upside down parabola)
      height = -5 * time * time + velocity * time;

      //if the ball reaches the ground  , reset the jump
      if (height < 0) {
        time = 0;
      }
      //update the new ball position
      setState(() {
        ballY = heightToPosition(height);
      });

      if (ballX - 0.005 < -1) {
        ballDirection = directions.RIGHT;
      }
      //if the ball hits the right wall , then change direction to left
      else if (ballX + 0.005 > 1) {
        ballDirection = directions.LEFT;
      }

//move the ball in the correct direction
      if (ballDirection == directions.LEFT) {
        setState(() {
          ballX -= 0.005;
        });
      } else if (ballDirection == directions.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }
//checks if the ball hit the player
      if (playerDies()) {
        timer.cancel();
        print('dead');
        _showDialog();
      }

      //keep the time going
      time += 0.1;
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'You Died Pro',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[700],
      ),
    );
  }

  void moveLeft() {
    setState(() {
      if (playerX - 0.1 < -1) {
//do nothing no movement in this direction
      } else {
        playerX -= 0.1;
      }
      // only make the x coordinate the same when it isn't in the middle of a shot
      if (!midShot) {
        missleX = playerX;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (playerX + 0.1 > 1) {
//do nothing no movement in this direction
      } else {
        playerX += 0.1;
      }
      // only make the x coordinate the same when it isn't in the middle of a shot
      if (!midShot) {
        missleX = playerX;
      }
    });
  }

  void fireMissile() {
    if (midShot == false) {
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        //shots fired
        midShot = true;
//missiles grows til hits the top of the screen
        setState(() {
          missleYHeight += 10;
        });

//stop th e missiles when it reach the top of the screen
        if (missleYHeight > MediaQuery.of(context).size.height * 0.75) {
          resetMissiles();
          timer.cancel();
        }

        //check if the missiles hits the ball
        if (ballY > heightToPosition(missleYHeight) &&
            (ballX - missleX).abs() < 0.03) {
          resetMissiles();
          ballX = 5;
          timer.cancel();
        }
      });
    }
  }
//converts height to coordinates

  double heightToPosition(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 0.75;
    double position = 1 - 2 * height / totalHeight;
    return position;
  }

  void resetMissiles() {
    missleX = playerX;
    missleYHeight = 10;
    midShot = false;
  }

  bool playerDies() {
    //if the ball position and the player position are the same , then the player dies

    if ((ballX - playerX).abs() < 0.05 && ballY > 0.95) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        //fpr using keyboard in using other platforms
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent value) {
          if (value.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            setState(() {
              moveLeft();
            });
          } else if (value.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            setState(() {
              moveRight();
            });
          }

          if (value.isKeyPressed(LogicalKeyboardKey.space)) {
            setState(() {
              fireMissile();
            });
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.pink[100],
                child: Center(
                  child: Stack(
                    children: [
                      MyBall(ballX: ballX, ballY: ballY),
                      MyMissile(
                        missileX: missleX,
                        height: missleYHeight,
                      ),
                      MyPlayer(
                        playerX: playerX,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyButton(
                      icon: Icons.play_arrow,
                      function: startGame,
                    ),
                    MyButton(
                      icon: Icons.arrow_back,
                      function: moveLeft,
                    ),
                    MyButton(
                      icon: Icons.arrow_upward,
                      function: fireMissile,
                    ),
                    MyButton(
                      icon: Icons.arrow_forward,
                      function: moveRight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
