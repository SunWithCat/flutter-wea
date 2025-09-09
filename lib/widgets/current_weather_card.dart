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
  final String humidity;
  final String pressure;
  final String visibility;
  final String precipitation;
  final String aqi;
  final String airCategory;

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
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.precipitation,
    required this.airCategory,
    required this.aqi,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(cityName, style: TextStyle(fontSize: 32)),
          if (airCategory.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade200.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '天气质量：$airCategory($aqi)',
                style: TextStyle(fontSize: 14),
              ),
            ),
          SizedBox(height: 5),
          Text(temperature, style: TextStyle(fontSize: 27)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(weatherText, style: TextStyle(fontSize: 27)),
              SizedBox(width: 24),
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
          const Divider(color: Colors.black54, thickness: 1, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(Icons.water_drop_outlined, "湿度", humidity),
              _buildDetailItem(Icons.speed_outlined, "压强", pressure),
              _buildDetailItem(Icons.visibility_outlined, "能见度", visibility),
              _buildDetailItem(Icons.umbrella_outlined, "降水", precipitation),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            updateTime,
            style: TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          IconButton(onPressed: onRefresh, icon: Icon(Icons.refresh_sharp)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.black54),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black54)),
        SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
