import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wea/pages/city_sele.dart';
import 'package:wea/config.dart';
import './utils/custom_route.dart';

import 'package:wea/widgets/current_weather_card.dart';
import 'package:wea/widgets/weather_detail_card.dart';
import 'package:wea/widgets/weather_summary_text.dart';
import 'package:wea/widgets/weather_warning_card.dart';

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
  String humidity = '';
  String pressure = '';
  String visibility = '';
  String precipitation = '';

  List<HourlyForecast> hourlyForecasts = [];
  List<DailyForecast> dailyForcecasts = [];

  String feelsLikeTemp = '';
  String todayTextDay = '';

  List<WeatherWarning> weatherWarnings = [];

  // 启动初始时加载已保存的城市
  @override
  void initState() {
    super.initState();
    loadCityFromPrefs();
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
        // 并行执行三个天气请求
        fetchNowWeather(),
        fetchHourlyForecast(),
        fetchDailyForecast(),
        fetchWeatherWarnings(),
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
        feelsLikeTemp = data['now']['feelsLike'] + '°C'; // 体感温度
        humidity = '${data['now']['humidity']}%'; // 湿度
        pressure = '${data['now']['pressure']}hPa'; // 气压
        visibility = '${data['now']['vis']}km'; // 能见度
        precipitation = '${data['now']['precip']}mm'; // 降水量
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
                // 对于每个item，创建一个HourlyForecast对象
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
        todayTextDay = dailyData.isNotEmpty ? dailyData[0]['textDay'] : '';
      });
    } else {
      throw Exception('获取天气数据失败');
    }
  }

  // 获取天气预警信息
  Future<void> fetchWeatherWarnings() async {
    final url = Uri.parse(
      '${Config.baseUrl}/v7/warning/now?location=$cityId&key=$apiKey&lang=zh',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);
      if (data['code'] == '200' && data['warning'] != null) {
        final List<dynamic> warningData = data['warning'];
        setState(() {
          weatherWarnings =
              warningData.map((item) {
                return WeatherWarning(
                  title: item['title'],
                  text: item['text'],
                  level: item['level'],
                  type: item['type'],
                );
              }).toList();
        });
      } else {
        setState(() {
          weatherWarnings = [];
        });
      }
    }
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
                    WeatherSummaryText(
                      feelsLikeTemp: feelsLikeTemp,
                      todayTextDay: todayTextDay,
                    ),
                    SizedBox(height: 20),
                    WeatherWarningCard(warnings: weatherWarnings),
                    SizedBox(height: 20),
                    CurrentWeatherCard(
                      cityName: cityName,
                      temperature: temperature,
                      weatherText: weatherText,
                      weatherCode: weatherCode,
                      windDir: windDir,
                      windScale: windScale,
                      updateTime: updateTime,
                      humidity: humidity,
                      pressure: pressure,
                      visibility: visibility,
                      precipitation: precipitation,
                      onRefresh: fetchWeather,
                    ),
                    SizedBox(height: 30),
                    WeatherDetailCard(
                      hourlyForecasts: hourlyForecasts,
                      dailyForcecasts: dailyForcecasts,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        '数据来源：和风天气',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
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
                  SlideRightRoute(page: const CitySeletorPage()),
                  // MaterialPageRoute(
                  //   builder: (context) => const CitySeletorPage(),
                  // ),
                );
                if (result != null && result is Map<String, String>) {
                  final newCityName = result['cityName']!;
                  final newCityId = result['id']!;
                  setState(() {
                    cityName = newCityName;
                    cityId = newCityId;
                  });
                  await saveCityToPrefs(newCityName, newCityId); // 等待执行完成
                  fetchWeather();
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade200.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 只占据足够的空间
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 24,
                      color: Colors.grey.shade700,
                    ),
                    Text(
                      '城市',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
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
