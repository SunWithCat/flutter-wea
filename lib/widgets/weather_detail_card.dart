import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 代表逐小时预报的数据模型
class HourlyForecast {
  final String time;
  final String temp;
  final String icon;
  final String text;
  HourlyForecast({
    required this.time,
    required this.temp,
    required this.icon,
    required this.text,
  });
}

// 代表未来几天预报的数据模型
class DailyForecast {
  final String date;
  final String tempMax;
  final String tempMin;
  final String iconDay;
  final String textDay;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.iconDay,
    required this.textDay,
  });
}

class WeatherDetailCard extends StatelessWidget {
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForcecasts;
  final String sunrise;
  final String sunset;
  const WeatherDetailCard({
    super.key,
    required this.hourlyForecasts,
    required this.dailyForcecasts,
    required this.sunrise,
    required this.sunset,
  });

  Widget _buildSunriseSunset(context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(CupertinoIcons.sunrise, color: Colors.orange),
              SizedBox(height: 4),
              Text('日出', style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(height: 5),
              Text(sunrise, style: TextStyle(fontSize: 18)),
            ],
          ),
          Column(
            children: [
              Icon(CupertinoIcons.sunset, color: Colors.deepOrange),
              SizedBox(height: 4),
              Text('日落', style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(height: 5),
              Text(sunset, style: TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '逐时预报',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecasts.length,
              itemBuilder: (context, index) {
                final forecast = hourlyForecasts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(forecast.time, style: TextStyle(fontSize: 16)),
                      SvgPicture.asset(
                        'assets/icons/${forecast.icon}.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.black87,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        "${forecast.temp}°C",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(color: Colors.black38, thickness: 1, height: 20),
          // 日出日落显示
          _buildSunriseSunset(context),
          // 未来几天预报
          Text(
            "未来预报",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true, // 让ListView根据内容自适应高度
            physics: NeverScrollableScrollPhysics(), // 外层已有滚动
            itemCount: dailyForcecasts.length,
            itemBuilder: (context, index) {
              final forecast = dailyForcecasts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      forecast.date,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/${forecast.iconDay}.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            forecast.textDay,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        Text(
                          "${forecast.tempMin}°C/${forecast.tempMax}°C",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
