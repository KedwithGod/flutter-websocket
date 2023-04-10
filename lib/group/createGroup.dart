import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pcash_test/group/requestFunction.dart';

import 'listGroup.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createGroup (BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    sendRequest(context, body: {
        'group_name':_groupNameController.text,
        'coordinator_name':'Ezekiel',
        'coordinator_id':"1",
        }, urlString: 'http://127.0.0.1:8000/api/createRTS', successResponse: ()async{
          await Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupListPage()));
        });
    setState(() {
      _isLoading = false;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
              ),
            ),
            SizedBox(height: 16.0),
            CupertinoButton.filled(
              child: Text('Create Group'),
              onPressed: (){_createGroup(context);},
            ),
          ],
        ),
      ),
    );
  }
}
