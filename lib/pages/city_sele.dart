import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../config.dart';

class CitySeletorPage extends StatefulWidget {
  final http.Client? client; // 允许 client 为空，以便在 app 中正常使用
  const CitySeletorPage({super.key, this.client});

  @override
  State<CitySeletorPage> createState() => _CitySeletorPageState();
}

class _CitySeletorPageState extends State<CitySeletorPage> {
  late http.Client _client;
  final TextEditingController _controller = TextEditingController();
  final String apiKey = Config.apiKey;
  List<Map<String, String>> searchResults = [];
  Timer? _debounce; // 防抖计时器
  int _searchVersion = 0; // 请求版本号，用于忽略旧结果

  @override
  void initState() {
    super.initState();
    // 如果 widget 提供了 client，就用它，否则创建一个新的
    _client = widget.client ?? http.Client();
  }

  // 监听输入框文字变化并触发防抖逻辑
  void onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(microseconds: 400), () {
      searchCity(keyword);
    });
  }

  // 执行城市搜索请求
  Future<void> searchCity(String keyword) async {
    // 空输入直接返回，不请求、不提示
    if (keyword.trim().isEmpty || keyword.length < 2) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final currentVersion = ++_searchVersion;
    final url = Uri.parse(
      'https://mt54e3pvdv.re.qweatherapi.com/geo/v2/city/lookup?location=$keyword&key=$apiKey&lang=zh',
    );
    try {
      final response = await _client.get(url); // 使用注入的 client
      if (currentVersion != _searchVersion) return;
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decoded);
        if (data['code'] == '200' && data['location'] != null) {
          setState(() {
            searchResults =
                (data['location'] as List).map((e) {
                  return {
                    'cityName': e['name'].toString(),
                    'id': e['id'].toString(),
                    'adm1': e['adm1'].toString(),
                    'adm2': e['adm2'].toString(),
                  };
                }).toList();
          });
        } else {
          setState(() {
            searchResults = [];
          });
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('未找到匹配的城市')));
          }
        }
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      if (currentVersion != _searchVersion) return;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('参数错误: $e')));
      }
    }
  }

  // 取消定时器
  @override
  void dispose() {
    _debounce?.cancel();
    // 如果 client 是在 widget 内部创建的，则关闭它
    if (widget.client == null) {
      _client.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 不用调整尺寸
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/Fulilian.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Container(color: Colors.blue.shade200),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 370,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade100.withValues(alpha: 0.3),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      onChanged: onSearchChanged,
                      style: TextStyle(height: 1.0),
                      decoration: InputDecoration(
                        hintText: '请输入城市的名称或拼音',
                        hintStyle: TextStyle(
                          color: Colors.blue.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                    // 完全移除间距
                    Expanded(
                      child:
                          _controller.text.isEmpty
                              ? Container()
                              : (searchResults.isEmpty
                                  ? Center(
                                    child: Text(
                                      '未找到与 "${_controller.text}"相关的城市',
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: searchResults.length,
                                    itemBuilder: (context, index) {
                                      final city = searchResults[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          '${city['cityName']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          '${city['adm2']} - ${city['adm1']}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context, {
                                            'cityName': city['cityName']!,
                                            'id': city['id']!,
                                          });
                                        },
                                      );
                                    },
                                  )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade200.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Colors.grey.shade700,
                    ),
                    Text(
                      '返回',
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
