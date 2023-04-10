import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

Future sendRequest(BuildContext context,{
  required Map<String,dynamic> body,required String urlString, required Function successResponse
})async{
   try {
       final url = Uri.parse(urlString);
      final response = await post(
        url,
        headers: {},
        body:body );

     
      if (response.statusCode == 200) {
         Map<String,dynamic> body =jsonDecode(response.body);
        // Success
        if(body['code']==0){
           successResponse();
          //  print(body['data']);
           return body['data'];
        }
        else{

         showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(body['exception_code']),
          content: Text(body['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return null;
        }
      } else {
        // Error
        throw Exception('Error: ${response.reasonPhrase}');
      }
    } catch (error,stacktrace) {
      print(stacktrace);
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return null;
    }
}