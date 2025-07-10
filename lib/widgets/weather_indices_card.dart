import 'package:flutter/material.dart';

// 单个生活指数
class DailyIndex {
  final String name;
  final String category;
  final String text;

  DailyIndex({required this.category, required this.name, required this.text});
}

class WeatherIndicesCard extends StatelessWidget {
  final List<DailyIndex> indices;
  const WeatherIndicesCard({super.key, required this.indices});

  IconData _getIconForIndex(String name) {
    switch (name) {
      case '穿衣指数':
        return Icons.checkroom;
      case '紫外线指数':
        return Icons.wb_sunny_outlined;
      case '感冒指数':
        return Icons.ac_unit;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (indices.isEmpty) {
      return const SizedBox.shrink(); // 如果没有任何数据，则不显示
    }
    return Container(
      width: 370,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '生活指数',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true, // 高度根据其内容来决定
            physics: const NeverScrollableScrollPhysics(), // 禁用滚动
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3,
              mainAxisExtent: 120, // 设置一个固定的高度
            ),
            itemCount: indices.length,
            itemBuilder: (context, index) {
              final item = indices[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForIndex(item.name),
                    size: 35,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
