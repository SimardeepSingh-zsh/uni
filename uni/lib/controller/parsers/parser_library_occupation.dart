import 'dart:convert';

import 'package:http/http.dart';
import 'package:uni/model/entities/library_occupation.dart';

Future<LibraryOccupation> parseLibraryOccupationFromSheets(
  Response response,
) async {
  final json = response.body.split('\n')[1]; // ignore first line
  const toSkip = 'google.visualization.Query.setResponse('; // should be ignored
  const numFloors = 6;
  final occupation = LibraryOccupation(0, 0);

  final jsonDecoded =
      jsonDecode(json.substring(toSkip.length, json.length - 2));

  for (var i = 0; i < numFloors; i++) {
    int floor;
    int max;
    try {
      floor = jsonDecoded['table']['rows'][i]['c'][0]['v'].toInt();
    } catch (e) {
      floor = 0;
    }
    try {
      max = jsonDecoded['table']['rows'][i]['c'][1]['v'].toInt();
    } catch (e) {
      max = 0;
    }
    occupation.addFloor(FloorOccupation(i + 1, floor, max));
  }

  return occupation;
}
