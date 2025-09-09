import 'package:flutter/material.dart';

// 天气灾害预警数据类型
class WeatherWarning {
  final String title;
  final String text;
  final String level;
  final String type;

  WeatherWarning({
    required this.title,
    required this.text,
    required this.level,
    required this.type,
  });
}

class WeatherWarningCard extends StatelessWidget {
  final List<WeatherWarning> warnings;
  const WeatherWarningCard({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink(); // 没有预警不显示内容
    
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.orange.shade100.withAlpha(200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('天气灾害预警', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          ...warnings.map((warning) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warning.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(warning.text),
                  const Divider(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
