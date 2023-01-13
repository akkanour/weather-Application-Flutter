import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/controller/global_controller.dart';
import 'package:weather_app/decorations/text_style.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/services/weather_api_client.dart';
import 'package:weather_app/widgets/hourly_widget.dart';
import '../widgets/city_header.dart';
import '../widgets/current_weather.dart';
import '../widgets/daily_forecast_widget.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    double lat = 33.8240909150367;
    double lng = -7.373021793954447 ;
    String cityhint = 'Casablanca';


  String datetime = DateFormat("yMMMMd").format(DateTime.now());
  TextEditingController _textController = TextEditingController();
  Future<Map<String, dynamic>> getCoordinates(String city) async {
    // Replace YOUR_API_KEY with your actual API key
    var endpoint = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$city&key=AIzaSyAp10qRjxj1nY5Ey37f7mBzzWJy0e4-Z1E');

    final response = await http.get(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Extract the latitude and longitude from the response
      final double lat = data['results'][0]['geometry']['location']['lat'];
      final double lng = data['results'][0]['geometry']['location']['lng'];

      return {'lat': lat, 'lng': lng};
    } else {
      // If the call to the API failed, throw an error
      throw Exception('Failed to get coordinates');
    }
  }




  final GlobalController globalController = Get.put(GlobalController(), permanent: true);

  WeatherApiClient client = WeatherApiClient();
  WeatherModel? data;

  String city ="";
  @override
  void initState(){
    getAddress(globalController.getLatitude().value, globalController.getLongitude().value,);
    super.initState();
  }

  getAddress(lat, lon) async {
    List<Placemark> placemark = await placemarkFromCoordinates(lat, lon);
    Placemark place = placemark[0];
    print(placemark);
    setState(() {
      city = place.locality!;
    });
  }
  Future<void> getData() async{
    data = await client.getWeatherModel(
        lat.toString(),
        lng.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot){

          if(snapshot.connectionState == ConnectionState.done){
            return ListView(
              children: [


                const SizedBox(height: 30,),
                Container(

                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [



                            TextField(
                              controller: _textController,

                              style: TextStyle(fontSize:30),
                              decoration: InputDecoration(
                                hintText: "$cityhint",
                                hintStyle: TextStyle(fontSize: 30),
                                border: InputBorder.none,
                                suffixIcon:  IconButton (
                                  icon: Icon(Icons.search),
                                  onPressed: () async {
                                    String textFieldValue = _textController.text;
                                    String city = textFieldValue;
                                    Map<String, dynamic> coordinates = await getCoordinates(city);
                                    double lati = coordinates['lat'];
                                    double lngo = coordinates['lng'];

                                    setState(() {
                                      lat = lati;
                                      lng = lngo;
                                      cityhint = '';

                                    });




                                  },
                                ) ,

                              ),







                            ),






                            Text(datetime)
                          ],
                        ),

                        const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              "assets/weather/${data?.icon_id}.png",
                              height: 60,
                              width: 60,
                            ),
                            Text("${data?.temp} \u2103" , style: const TextStyle(fontSize: 45),),
                          ],
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 20,),
                Container(
                  child: currentWeatherDetails("${data?.wind}", "${data?.clouds}", "${data?.humidity}" ),
                ),
                const SizedBox(height: 30,),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                    child: Text("Today", style: daytimeStyle,)
                ),
                SizedBox(
                  height: 180,
                  width: MediaQuery.of(context).size.width - 125,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (BuildContext context, index){
                        return HourlyWidget(
                            "${data?.hourlytemp?[index]}",
                            "${data?.hourlyicon?[index]}",
                            "${data?.hourlydt?[index]}",
                            index,
                        );
                      }
                  ),
                ),
                const SizedBox(height: 30,),
                Container(
                  margin: const EdgeInsets.all(12),
                  height: 350,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                          "Forecast for 7 days :",
                          style: GoogleFonts.poppins(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            color: Colors.black,
                          ),
                      ),
                      const SizedBox(height: 30,),
                      SizedBox(
                        height: 250,
                        width: 400,
                        child: ListView.builder(
                          itemCount: 7,
                            itemBuilder: (BuildContext context, index){
                            return DailyForcast(
                                "${data?.dailydt![index]}",
                                "${data?.dailyicon?[index]}",
                                "${data?.dailytemp_max?[index]}",
                                "${data?.dailytemp_min?[index]}",
                            );
                            }
                            ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
          else if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container();
        },
      )
    );
  }
}
