import 'package:flutter/material.dart';

class WeatherSummaryText extends StatelessWidget {
  final String feelsLikeTemp;
  final String todayTextDay;
  const WeatherSummaryText({
    super.key,
    required this.feelsLikeTemp,
    required this.todayTextDay,
  });

  @override
  Widget build(BuildContext context) {
    if (todayTextDay.isEmpty || feelsLikeTemp.isEmpty) {
      return const SizedBox.shrink();
    }

    final summary = '今天的天气是 $todayTextDay，体感温度为 $feelsLikeTemp。\n追求源于热爱！';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        summary,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, height: 1.5),
      ),
    );
  }
}
