import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


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

Widget cityHeader(String location, String temp, String iconId){
  return Column(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [



          TextField(
            controller: _textController,

            style: TextStyle(fontSize:30),
            decoration: InputDecoration(
              hintText: "$location",
              hintStyle: TextStyle(fontSize: 30),
              border: InputBorder.none,
              suffixIcon:  IconButton (
                icon: Icon(Icons.search),
                onPressed: () async {
                  String textFieldValue = _textController.text;
                  String city = textFieldValue;
                  Map<String, dynamic> coordinates = await getCoordinates(city);
                  double lat = coordinates['lat'];
                  double lng = coordinates['lng'];

                  print('Latitude: $lat');
                  print('Longitude: $lng');


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
              "assets/weather/$iconId.png",
            height: 60,
            width: 60,
          ),
          Text("$temp \u2103" , style: const TextStyle(fontSize: 45),),
        ],
      ),
    ],
  );
}