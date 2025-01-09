import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class SpinWheelWidget extends StatelessWidget {
  final List<Map<String, dynamic>> rewards;
  final Stream<int>? selected;
  final Function(int) onSpinEnd;

  const SpinWheelWidget({
    Key? key,
    required this.rewards,
    required this.selected,
    required this.onSpinEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 5,
              )
            ],
          ),
          child: FortuneWheel(
            selected: selected!,
            animateFirst: false,
            items: rewards
                .map((reward) => FortuneItem(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(reward['https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/73cd599f-99f9-4d9d-8536-6455717abba1/d6dx9l4-ced52dd4-46e3-4686-a71f-55bdfd09d997.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcLzczY2Q1OTlmLTk5ZjktNGQ5ZC04NTM2LTY0NTU3MTdhYmJhMVwvZDZkeDlsNC1jZWQ1MmRkNC00NmUzLTQ2ODYtYTcxZi01NWJkZmQwOWQ5OTcucG5nIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.uIhDsy5mxTLERSDzOc8ECFHJcKBxbJshZ9EtBI0DlMs'], height: 50),
                          SizedBox(height: 5),
                          Text(
                            reward['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onAnimationEnd: () {
              final index = Fortune.randomInt(0, rewards.length);
              onSpinEnd(index);
            },
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final randomIndex = Fortune.randomInt(0, rewards.length);
            onSpinEnd(randomIndex);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'SPIN NOW',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
