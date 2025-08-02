import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:weather_app/additional_cards.dart';
import 'package:weather_app/secrets.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    const String cityName = "Mumbai";
    try {
      final res = await http.get(
        Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$weatherAppAPIkey",
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != "200") {
        throw "An unexpected error occured";
      }

      return data;
    } catch (e) {
      print("Error: $e");
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;

          final currentWeather = data['list'][0];
          final currentTemp = currentWeather['main']['temp'];
          final currentSky = currentWeather['weather'][0]['main'];
          final currentPressure = currentWeather['main']['pressure'];
          final currentHumidity = currentWeather['main']['humidity'];
          final currentWindSpeed = currentWeather['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Color.fromRGBO(44, 41, 50, 1),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: const Color.fromARGB(199, 73, 61, 83),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp K",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                //hourly forecast cards
                Text(
                  "Hourly Forecast",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                //Hourly Forecast Cards
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         hourlyWeatherForecast(
                //           icon:
                //               data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Rain'
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           temperature: data['list'][i+1]['main']['temp'].toString(),
                //           time: data['list'][i + 1]['dt'].toString(),
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky =
                          data['list'][index + 1]['weather'][0]['main'] ==
                              'Clouds' ||
                          data['list'][index + 1]['weather'][0]['main'] ==
                              'Rain';
                      final time = DateTime.parse(hourlyForecast['dt_txt']);

                      return hourlyWeatherForecast(
                        icon: hourlySky ? Icons.cloud : Icons.sunny,
                        temperature: hourlyForecast['main']['temp'].toString(),
                        time: DateFormat.Hm().format(time),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20),
                //Additional info cards
                Text(
                  "Additional information",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //Humidity
                    AdditionalInfoCards(
                      icon: Icons.water_drop,
                      text: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    //Wind speed
                    AdditionalInfoCards(
                      icon: Icons.air,
                      text: "Wind speed",
                      value: currentWindSpeed.toString(),
                    ),
                    //Pressure
                    AdditionalInfoCards(
                      icon: Icons.beach_access,
                      text: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ignore: camel_case_types
class hourlyWeatherForecast extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temperature;
  const hourlyWeatherForecast({
    super.key,
    required this.icon,
    required this.temperature,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 155,
      child: Card(
        color: Color.fromRGBO(44, 41, 50, 1),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: const Color.fromARGB(199, 73, 61, 83),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    time,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Icon(icon, size: 32),
                  SizedBox(height: 8),
                  Text(temperature, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
