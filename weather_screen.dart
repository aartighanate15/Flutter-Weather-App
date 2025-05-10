import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  //late Future<Map<String,dynamic>> weather;
  Future<Map<String,dynamic>> getCurrentWeather() async{
    try{
 final String cityName = 'London';
     final result = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
    );
    final data = jsonDecode(result.body) ;

    if(data['cod'] != '200'){
      throw 'An Unexpected occur';
    }
  return data;
   // data['list'][0]['main']['temp'];
   

  }catch(e){
    throw e.toString();
  }  
    }
  

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    appBar: AppBar(
      title: const Text('Weather App',
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      ),
      centerTitle: true,
      actions: [
        // GestureDetector(
        //   onTap: (){
        //     print('Refresh');
        //   },
        //   child: const Icon(Icons.refresh),
        // )
        IconButton(onPressed: (){
          setState(() {
           
          });
        }
        , icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder(
      future: getCurrentWeather(),
      builder: (context,snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: const CircularProgressIndicator.adaptive());
        }

        if(snapshot.hasError){
          return  Center(child: Text(snapshot.error.toString()));
        }
        
      //API stuff related data
        final data = snapshot.data;
        final currentWeatherData = data?['list'][0];
        final currentTemp = currentWeatherData['main']['temp'];
        final currentSky = currentWeatherData['weather'][0]['main'];
        final currentPressure = currentWeatherData['main']['pressure'];
        final currentWindSpeed = currentWeatherData['wind']['speed'];
        final currentHumidity = currentWeatherData['main']['humidity'];

        return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //main card
           SizedBox(
            width: double.infinity,
             child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                      //  const SizedBox(height: 16),
                        Text('$currentTemp K',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                        ),
                        ),
                        const SizedBox(height: 16),
                        Icon(currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud:Icons.sunny,
                        size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(currentSky,
                        style: const TextStyle(
                          fontSize: 25
                        ),
                        ),
                       // const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
             ),
           ),
            const SizedBox(height: 20),
            
           const Text('Hourly Forecast',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
      
            ),
            ),
            const SizedBox(height: 14),
            
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //         for(int i = 0; i<12;i++)
            //         HourlyForecastItem(
            //           time: data!['list'][i+1]['dt'].toString(),
            //           icon: data!['list'][i+1]['weather'][0]['main'] == 'Clouds' || data['list'][i+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
            //           temperature: data!['list'][i+1]['main']['temp'].toString()),
            //         // HourlyForecastItem(time: '09:00', icon: Icons.cloud, temperature: '300.20'),
            //         // HourlyForecastItem(time: '12:00', icon: Icons.cloudy_snowing, temperature: '302.20'), 
            //         // HourlyForecastItem(time: '03:00', icon: Icons.cloudy_snowing, temperature: '320.20'),
            //         // HourlyForecastItem(time: '06:00', icon: Icons.cloud, temperature: '3250.20'),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                itemBuilder: (
                 context, index) { 
                  final hourlyForecast = data?['list'][index+1];
                  final hourlySky = data!['list'][index+1]['weather'][0]['main'];
                  final hourlyTemp = hourlyForecast['main']['temp'].toString();
                  final time = DateTime.parse(hourlyForecast['dt_txt']);
                 
                  return HourlyForecastItem(
                    time: DateFormat.j().format(time), 
                      icon:  hourlySky == 'Clouds' || hourlySky == 'Rain' ? Icons.cloud : Icons.sunny,
                    temperature: hourlyTemp.toString(),
                    );
                   },
              
              ),
            ),
             const SizedBox(height: 20),
        
            //additional information card
             const Text('Additional Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               AdditionalInfoItem(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: currentHumidity.toString(),
               ),
               AdditionalInfoItem(
                 icon: Icons.air,
                label: 'Wind Speed',
                value: currentWindSpeed.toString(),
               ),
               AdditionalInfoItem(
                 icon: Icons.beach_access,
                label: 'Pressure',
                value: currentPressure.toString(),
               ),
              ],
            )
          ],
        ),
      );
      },
    ),
    ); 
  }
}

