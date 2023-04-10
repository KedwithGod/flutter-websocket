import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pcash_test/group/requestFunction.dart';
import 'package:web_socket_channel/io.dart';

import 'createGroup.dart';
import 'individualGroup.dart';

class GroupListPage extends StatefulWidget {
  GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final channel = IOWebSocketChannel.connect('ws://localhost:8080/ws');
  List? groups;
  List? otherGroups;

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  fetchGroupList() {
    sendRequest(context,
            body: {'user_id': '1'},
            urlString: 'http://127.0.0.1:8000/api/listRTS',
            successResponse: () {})
        .then((value) {
      setState(() {
        groups = value;
      });
    });
  }

  joinGroup(String rtsId) {
    sendRequest(context,
            body: {
              'members_name': 'Ezekiel',
              'member_user_id': '1',
              'rts_id': rtsId,
            },
            urlString: 'http://127.0.0.1:8000/api/joinRTS',
            successResponse: () {})
        .then((value) {
      setState(() {
        groups = value;
      });
    });
  }

  fetchOtherGroupList() {
    sendRequest(context,
            body: {'user_id': '1'},
            urlString: 'http://127.0.0.1:8000/api/listOtherGroup',
            successResponse: () {})
        .then((value) {
      setState(() {
        otherGroups = value;
      });
    });
  }

  @override
  void initState() {
    fetchGroupList();
    fetchOtherGroupList();
    channel.stream.listen((event) {
      print(event);
      Map eventData = jsonDecode(event);
  
      if (groups!
          .any((group) => group['id'] == eventData['group']['groupId'])) {
        if (eventData['tag'] == 'group_sent' ||
            eventData['tag'] == 'group_general') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String contributionAmount=eventData['contibution_amount'];
              return AlertDialog(
                title: Text(
                   'Group ${eventData['group']['name']}\n' 'The Coordinator has suggested ${eventData['contibution_amount']}'),
                content: TextField(
                  onChanged: (value) {
                    contributionAmount = value;
                  },
                  decoration: InputDecoration(hintText: 'Enter amount'),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Reject'),
                    onPressed: () {
                      Map data={ 'tag':'group_recieved','accept':'No','sender_name':'Ezekiel',
                      'id':eventData['id'],'contibution_amount':contributionAmount,'group':eventData['group']};
                    channel.sink.add(jsonEncode(data));
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Accept'),
                    onPressed: () {
                       Map data={ 'tag':'group_recieved','accept':'Yes','sender_name':'Ezekiel',
                      'id':eventData['id'],'contibution_amount':contributionAmount,'group':eventData['group']};
                    channel.sink.add(jsonEncode(data));
                      // Do something with the contribution amount
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
        else if (eventData['tag'] == 'group_recieved' && eventData['group']['coordinatorId']==1) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String contributionAmount;
            return AlertDialog(
              title: Text(
                  'The ${eventData['sender_name']} said ${eventData['accept']} to ${eventData['contibution_amount']}'),
              actions: <Widget>[
                TextButton(
                  child: Text('Alright'),
                  onPressed: () {
                    // Do something with the contribution amount
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      } 
    });
    super.initState();
  }

  fetchGroup() {}

  void _createGroup(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateGroupPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text(
            'My groups',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          groups == null
              ? const Center(child: Text('You not joined or created any group'))
              : Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: groups!.length,
                    itemBuilder: (BuildContext context, int index) {
                      String groupName = groups![index]['group_name']!;
                      return ListTile(
                        title: Text(groupName),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupDetailsPage(
                                      Group(
                                          name: groupName,
                                          coordinator: groups![index]
                                              ['coordinator_name']!,
                                          members: [],
                                          groupId: groups![index]['id']!,
                                          coordinatorId: groups![index]
                                              ['coordinator_id']!),
                                      channel: channel)));
                        },
                      );
                    },
                  ),
                ),
          SizedBox(
            height: 10,
          ),
          const Text(
            'Other groups',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          otherGroups == null
              ? const Center(child: Text('No groups available to join'))
              : Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: otherGroups!.length,
                    itemBuilder: (BuildContext context, int index) {
                      String groupName = otherGroups![index]['group_name']!;
                      return ListTile(
                        title: Text(groupName),
                        onTap: () {
                          joinGroup(otherGroups![index]['id']!.toString());
                          // join group
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GroupListPage(),
                                  allowSnapshotting: false));
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _createGroup(context),
      ),
    );
  }
}
