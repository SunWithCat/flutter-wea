import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wea/city_sele.dart';
import 'package:wea/config.dart';

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天气',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.withValues(alpha: 0.6),
        ),
        useMaterial3: true,
      ),
      home: const WeatherShow(),
    );
  }
}

class WeatherShow extends StatefulWidget {
  const WeatherShow({super.key});

  @override
  State<WeatherShow> createState() => _WeatherShowState();
}

class _WeatherShowState extends State<WeatherShow> {
  // 初始化天气信息
  String cityName = '广东';
  String cityId = '101280601';
  String temperature = '';
  String weatherText = '';
  String windDir = '';
  String windScale = '';
  String weatherCode = '';
  String updateTime = '';
  bool isLoading = true;

  List<HourlyForecast> hourlyForecasts = [];
  List<DailyForecast> dailyForcecasts = [];

  // 启动初始时加载已保存的城市
  @override
  void initState() {
    super.initState();
    loadCityFromPrefs();
    // fetchWeather();
  }

  // 保存城市信息到本地
  Future<void> loadCityFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('selectedCity') ?? '广东';
    final savedId = prefs.getString('selectedCityId') ?? '101280601';
    setState(() {
      cityName = savedCity;
      cityId = savedId;
    });
    fetchWeather();
  }

  // 保存城市信息到本地
  Future<void> saveCityToPrefs(String city, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
    await prefs.setString('selectedCityId', id);
  }

  // 从配置文件获取API密钥
  final String apiKey = Config.apiKey;

  Future<void> fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.wait([
        fetchNowWeather(),
        fetchHourlyForecast(),
        fetchDailyForecast(),
      ]);
    } catch (e) {
      setState(() {
        weatherText = '获取天气信息失败: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 获取实时天气信息
  Future<void> fetchNowWeather() async {
    final url = Uri.parse(
      // 构建请求 URL
      '${Config.baseUrl}/v7/weather/now?location=$cityId&key=$apiKey&lang=zh',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      setState(() {
        temperature = data['now']['temp'] + '°C';
        weatherText = data['now']['text'];
        windDir = data['now']['windDir']; // 更新风向
        windScale = '${data['now']['windScale']}级'; // 更新风力
        weatherCode = data['now']['icon']; // 更新天气代码
        updateTime =
            ' 更新时间：${data['now']['obsTime'].substring(11, 16)}'; // 更新时间
        isLoading = false;
      });
    } else {
      throw Exception('获取天气数据失败');
    }
  }

  // 获取逐时预报
  Future<void> fetchHourlyForecast() async {
    final url = Uri.parse(
      '${Config.baseUrl}/v7/weather/24h?location=$cityId&key=$apiKey&lang=zh',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      final List<dynamic> hourlyData = data['hourly'];
      setState(() {
        hourlyForecasts =
            hourlyData.map((item) {
              return HourlyForecast(
                time: item['fxTime'].substring(11, 16),
                temp: '${item['temp']}',
                icon: item['icon'],
                text: item['text'],
              );
            }).toList();
      });
    } else {
      throw Exception('获取天气数据失败');
    }
  }

  // 获取未来的天气预报
  Future<void> fetchDailyForecast() async {
    final url = Uri.parse(
      '${Config.baseUrl}/v7/weather/7d?location=$cityId&key=$apiKey&lang=zh',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      final List<dynamic> dailyData = data['daily'];
      setState(() {
        dailyForcecasts =
            dailyData.map((item) {
              return DailyForecast(
                date: item['fxDate'].substring(5),
                tempMax: '${item['tempMax']}',
                tempMin: '${item['tempMin']}',
                iconDay: item['iconDay'],
                textDay: item['textDay'],
              );
            }).toList();
      });
    } else {
      throw Exception('获取天气数据失败');
    }
  }

  // 构建顶部的实时天气卡片
  Widget _buildCurrentWeatherCard() {
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
                      Colors.lightBlueAccent,
                      BlendMode.srcIn,
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
            IconButton(
              onPressed: fetchWeather,
              icon: Icon(Icons.refresh_sharp),
            ),
          ],
        ),
      ),
    );
  }

  // 构建底部的天气详情卡片
  Widget _buildWeatherDetailCard() {
    return Container(
      width: 370,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 底层图片
          Image.asset(
            'assets/images/Fulilian.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator(color: Colors.lightBlue))
          else
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 200),
                    _buildCurrentWeatherCard(),
                    SizedBox(height: 30),
                    _buildWeatherDetailCard(),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CitySeletorPage(),
                  ),
                );
                if (result != null && result is Map<String, String>) {
                  final newCityName = result['cityName']!;
                  final newCityId = result['id']!;
                  setState(() {
                    cityName = newCityName;
                    cityId = newCityId;
                  });
                  await saveCityToPrefs(newCityName, newCityId);
                  fetchWeather();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade400.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_city, size: 24),
                    Text('城市', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
