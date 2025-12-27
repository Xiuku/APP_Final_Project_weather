import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF9DACDB),
      ),
      home: const HomePage(),
    );
  }
}

// 資料儲存類別
class DataStore {
  static List<Map<String, String>> users = [];
  static Map<String, List<String>> subscriptions = {};
  static String? currentUserId;

  static String signup(String id, String email) {
    bool exists = users.any((u) => u['id'] == id || u['email'] == email);
    if (exists) {
      return "此ID或email已經註冊過";
    }
    users.add({'id': id, 'email': email});
    subscriptions[id] = [];
    return "註冊成功";
  }

  static bool login(String id, String email) {
    bool valid = users.any((u) => u['id'] == id && u['email'] == email);
    if (valid) {
      currentUserId = id;
      return true;
    }
    return false;
  }

  static String subscribeCity(String city) {
    if (currentUserId == null) return "請先登入";
    if (subscriptions[currentUserId]!.contains(city)) {
      return "此城市已經登記過";
    }
    subscriptions[currentUserId]!.add(city);
    return "訂閱成功";
  }

  static void removeCity(String city) {
    if (currentUserId != null) {
      subscriptions[currentUserId]?.remove(city);
    }
  }
}

// 主頁面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather",
          style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigoAccent.withOpacity(0.3),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/weather-home-background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()));
                        },
                        icon: const Icon(Icons.person),
                        label: Text(DataStore.currentUserId ?? "Login / Sign up"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (DataStore.currentUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請先登入")));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscribedCitiesPage()));
                          }
                        },
                        icon: const Icon(Icons.location_city),
                        label: const Text("My Cities"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextFormField(
                      controller: searchController,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        hintText: 'Search for a city',
                        hintStyle: TextStyle(fontSize: 16),
                        border: InputBorder.none,
                      ),
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherPage(cityName: value)));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(foregroundColor: Colors.blueAccent),
                    onPressed: () {
                      if (searchController.text.isNotEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WeatherPage(cityName: searchController.text)));
                      }
                    },
                    child: const Text("Search"),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 使用者登入頁面
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final idController = TextEditingController();
  final emailController = TextEditingController();
  String message = "";
  bool isError = false;

  void handleLogin() {
    bool success = DataStore.login(idController.text, emailController.text);
    setState(() {
      if (success) {
        message = "登入成功";
        isError = false;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SubscribedCitiesPage()));
      } else {
        message = "沒有帳號，請註冊!";
        isError = true;
      }
    });
  }

  void handleSignup() {
    String result = DataStore.signup(idController.text, emailController.text);
    setState(() {
      message = result;
      isError = result.contains("已經註冊");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Login"), backgroundColor: Colors.transparent),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black54.withOpacity(0.5),
                offset: const Offset(3, 10),
                blurRadius: 20,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              TextFormField(
                controller: idController,
                decoration: const InputDecoration(labelText: "User ID", prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "User Mail",
                  prefixIcon: const Icon(Icons.email),
                  errorText: isError ? message : null,
                ),
              ),
              const SizedBox(height: 10),
              if (!isError && message.isNotEmpty)
                Text(message, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: handleSignup, child: const Text("Sign up")),
                  ElevatedButton(
                    onPressed: handleLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 天氣頁面
class WeatherPage extends StatefulWidget {
  final String cityName;
  const WeatherPage({super.key, required this.cityName});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey = "API_KEY";

  final String authority = "api.openweathermap.org";
  final String weatherPath = "/data/2.5/weather";
  final String forecastPath = "/data/2.5/forecast";

  Map<String, dynamic>? weatherData;
  List<dynamic>? forecastList;
  bool isLoading = true;
  bool hasError = false;

  String? normalizedCityName;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final weatherUri = Uri.https(authority, weatherPath, {
        'q': widget.cityName,
        'appid': apiKey,
        'units': 'metric',
      });

      final weatherResponse = await http.get(weatherUri);

      if (weatherResponse.statusCode == 200) {
        final currentData = jsonDecode(weatherResponse.body);
        final lat = currentData['coord']['lat'].toString();
        final lon = currentData['coord']['lon'].toString();

        final name = currentData['name'];
        final country = currentData['sys']['country'];
        normalizedCityName = "$name,$country";

        final forecastUri = Uri.https(authority, forecastPath, {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
          'units': 'metric',
        });

        final forecastResponse = await http.get(forecastUri);
        final forecastData = jsonDecode(forecastResponse.body);

        setState(() {
          weatherData = currentData;
          forecastList = (forecastData['list'] as List).where((item) {
            return item['dt_txt'].toString().contains("12:00:00");
          }).take(5).toList();

          isLoading = false;
        });
      } else {
        setState(() { hasError = true; isLoading = false; });
      }
    } catch (e) {
      print("Error: $e");
      setState(() { hasError = true; isLoading = false; });
    }
  }

  void subscribeCity() {
    String cityToSave = normalizedCityName ?? widget.cityName;
    String result = DataStore.subscribeCity(cityToSave);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    if (result == "訂閱成功") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscribedCitiesPage()));
    }
  }

  // 取得天氣提醒文字
  String getWeatherAdvice(double temp, String weatherMain) {
    List<String> advices = [];

    // 溫度判斷
    if (temp < 15) advices.add("天氣寒冷，請多穿件外套保暖。");
    else if (temp > 30) advices.add("天氣炎熱，請注意防曬與補充水分。");
    else advices.add("氣溫舒適，適合外出活動。");

    // 天氣狀況判斷
    String main = weatherMain.toLowerCase();
    if (main.contains("rain") || main.contains("drizzle")) {
      advices.add("外面正在下雨，別忘了帶傘！");
    } else if (main.contains("snow")) {
      advices.add("路面可能有積雪，行走請小心。");
    } else if (main.contains("clear")) {
      advices.add("天氣晴朗，享受陽光吧！");
    } else if (main.contains("clouds")) {
      advices.add("多雲天氣，涼爽宜人。");
    }

    return advices.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (hasError || weatherData == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => Navigator.pop(context))),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/404_error_background.jpg'), fit: BoxFit.cover),
          ),
          child: const Center(
            child: Text("找不到此城市。\n請確認輸入名稱。",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    // 解析資料
    final temp = weatherData!['main']['temp'].toDouble();
    final tempRound = temp.round();
    final weatherMain = weatherData!['weather'][0]['main'];
    final minTemp = weatherData!['main']['temp_min'].floor();
    final maxTemp = weatherData!['main']['temp_max'].ceil();
    final windSpeed = weatherData!['wind']['speed'];
    final country = weatherData!['sys']['country'];
    final name = weatherData!['name'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Info", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF6B8AB9),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("$name, $country",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 40, color: Colors.white),
                    onPressed: subscribeCity,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$tempRound°C", style: const TextStyle(fontSize: 80, color: Colors.white)),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [const Icon(Icons.cloud, color: Colors.white), const SizedBox(width: 10), Text(weatherMain, style: const TextStyle(fontSize: 20, color: Colors.white))]),
                      Row(children: [const Icon(Icons.thermostat, color: Colors.white), const SizedBox(width: 10), Text("$minTemp° - $maxTemp°", style: const TextStyle(fontSize: 20, color: Colors.white))]),
                      Row(children: [const Icon(Icons.air, color: Colors.white), const SizedBox(width: 10), Text("$windSpeed m/s", style: const TextStyle(fontSize: 20, color: Colors.white))]),
                    ],
                  )
                ],
              ),
              const Divider(color: Colors.white54),
              const Text("5-DAY FORECAST", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecastList?.length ?? 0,
                  itemBuilder: (context, index) {
                    final item = forecastList![index];
                    final dateTxt = item['dt_txt'].split(" ")[0].substring(5); // 只取 MM-DD
                    final fTemp = item['main']['temp'].round();
                    final fWeather = item['weather'][0]['main'];

                    return Container(
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dateTxt, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 10),
                          Icon(getWeatherIcon(fWeather), size: 35, color: Colors.white),
                          const SizedBox(height: 10),
                          Text("$fTemp°", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.amberAccent),
                        SizedBox(width: 10),
                        Text("Weather Reminder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      getWeatherAdvice(temp, weatherMain),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
  IconData getWeatherIcon(String main) {
    switch (main.toLowerCase()) {
      case 'clouds': return Icons.cloud;
      case 'rain': return Icons.water_drop;
      case 'clear': return Icons.wb_sunny;
      case 'snow': return Icons.ac_unit;
      default: return Icons.cloud;
    }
  }
}

class SubscribedCitiesPage extends StatefulWidget {
  const SubscribedCitiesPage({super.key});

  @override
  State<SubscribedCitiesPage> createState() => _SubscribedCitiesPageState();
}

class _SubscribedCitiesPageState extends State<SubscribedCitiesPage> {
  final String apiKey = "API_KEY";
  final String authority = "api.openweathermap.org";
  final String path = "/data/2.5/weather";

  List<Map<String, dynamic>> citiesData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSubscribedCities();
  }

  Future<void> loadSubscribedCities() async {
    final userId = DataStore.currentUserId;
    if (userId == null) return;
    final cityNames = DataStore.subscriptions[userId] ?? [];
    List<Map<String, dynamic>> tempCities = [];

    for (String city in cityNames) {
      try {
        final uri = Uri.https(authority, path, {
          'q': city,
          'appid': apiKey,
          'units': 'metric'
        });

        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          tempCities.add({
            'displayName': city,
            'name': data['name'],
            'country': data['sys']['country'],
            'temp': data['main']['temp'].round(),
            'weather': data['weather'][0]['main'],
          });
        } else {
          tempCities.add({'displayName': city, 'name': city, 'country':'?', 'temp': 'N/A', 'weather': 'Error'});
        }
      } catch (e) {
        tempCities.add({'displayName': city, 'name': city, 'country':'?', 'temp': 'N/A', 'weather': 'Error'});
      }
    }

    if (mounted) {
      setState(() {
        citiesData = tempCities;
        isLoading = false;
      });
    }
  }

  void removeCity(String city) {
    DataStore.removeCity(city);
    loadSubscribedCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${DataStore.currentUserId ?? 'Guest'}'s City"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: citiesData.length,
          itemBuilder: (context, index) {
            final city = citiesData[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.white.withOpacity(0.6),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WeatherPage(cityName: city['displayName']))
                  );
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud, size: 40, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${city['name']}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${city['country']}",
                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                                Text("${city['temp']}°C", style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () => removeCity(city['displayName']),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}