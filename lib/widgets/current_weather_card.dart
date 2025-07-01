import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrentWeatherCard extends StatelessWidget {
  final String cityName;
  final String temperature;
  final String weatherText;
  final String weatherCode;
  final String windDir;
  final String windScale;
  final String updateTime;
  final VoidCallback onRefresh;
  const CurrentWeatherCard({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.weatherText,
    required this.weatherCode,
    required this.windDir,
    required this.windScale,
    required this.updateTime,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      height: 370,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(cityName, style: TextStyle(fontSize: 32)),
            SizedBox(height: 5),
            Text(temperature, style: TextStyle(fontSize: 27)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weatherText, style: TextStyle(fontSize: 27)),
                SizedBox(width: 8),
                if (weatherCode.isNotEmpty)
                  SvgPicture.asset(
                    'assets/icons/$weatherCode.svg',
                    width: 27,
                    height: 27,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      // 设置颜色滤镜
                      Colors.lightBlueAccent,
                      BlendMode.srcIn, // 使用指定的颜色
                    ),
                  ),
              ],
            ),
            Text(
              '$windDir $windScale',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            Text(
              updateTime,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            IconButton(onPressed: onRefresh, icon: Icon(Icons.refresh_sharp)),
          ],
        ),
      ),
    );
  }
}
