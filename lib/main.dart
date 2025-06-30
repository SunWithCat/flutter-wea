import 'dart:ui';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wea/city_sele.dart';
import 'package:wea/config.dart';

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

  // 启动初始时加载已保存的城市
  @override
  void initState() {
    super.initState();
    isLoading = true;
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
    try {
      setState(() {
        isLoading = true;
      });
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
        setState(() {
          weatherText = '获取天气信息失败:${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        weatherText = '获取天气信息失败: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseSize = MediaQuery.of(context).size;
    final iconSize = baseSize.width * 0.15;
    final containerHeight = baseSize.height * 0.3;
    final containerWidth = baseSize.width * 0.8;
    final tempFontSize = baseSize.width * 0.1;
    final weatherFontSize = baseSize.width * 0.12;
    final cityFontSize = baseSize.width * 0.05;
    final updateFontSize = baseSize.width * 0.04;
    final windFontSize = baseSize.width * 0.04;

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
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cityName,
                            style: TextStyle(fontSize: cityFontSize),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: baseSize.height * 0.02),
                          Text(
                            temperature,
                            style: TextStyle(fontSize: tempFontSize),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weatherText,
                                style: TextStyle(fontSize: weatherFontSize),
                              ),
                              SizedBox(width: iconSize),
                              if (weatherCode.isNotEmpty)
                                SvgPicture.asset(
                                  'assets/icons/$weatherCode.svg',
                                  width: iconSize,
                                  height: iconSize,
                                  fit: BoxFit.contain,
                                ),
                            ],
                          ),
                          Text(
                            '$windDir $windScale',
                            style: TextStyle(
                              fontSize: windFontSize,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            updateTime,
                            style: TextStyle(fontSize: updateFontSize),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          Positioned(
            top: containerHeight * 1.22,
            left: containerWidth * 0.8,
            child: IconButton(
              onPressed: fetchWeather,
              icon: Icon(Icons.refresh_sharp),
            ),
          ),
          Positioned(
            bottom: iconSize * 0.8,
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
                padding: EdgeInsets.symmetric(
                  horizontal: iconSize * 0.3,
                  vertical: windFontSize * 0.2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_city, size: iconSize * 0.4),
                    SizedBox(height: iconSize * 0.1),
                    Text('城市', style: TextStyle(fontSize: iconSize * 0.25)),
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
