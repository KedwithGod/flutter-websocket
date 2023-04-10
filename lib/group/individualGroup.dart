import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pcash_test/group/requestFunction.dart';

class Group {
  final String name;
  final String coordinator;
  final List<Member> members;
  final int groupId;
  final int coordinatorId;


  Group( {required this.name, required this.coordinator, required this.members,required this.groupId,required this.coordinatorId});


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'coordinator': coordinator,
      'members': members.map((member) => member.toMap()).toList(),
      'groupId': groupId,
      'coordinatorId': coordinatorId,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      name: map['name'],
      coordinator: map['coordinator'],
      members: List<Member>.from(
        map['members'].map((memberMap) => Member.fromMap(memberMap)),
      ),
      groupId: map['groupId'],
      coordinatorId: map['coordinatorId'],
    );
  }
}

class Member {
  final String name;
  final double contribution;

  Member({required this.name, required this.contribution});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contribution': contribution,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      name: map['name'],
      contribution: map['contribution'],
    );
  }
}

final Group mockGroup = Group(
  coordinatorId:0,
  name: 'Group 1',
  coordinator: 'John Smith',
  members: [
    Member(name: 'Alice', contribution: 50.0),
    Member(name: 'Bob', contribution: 25.0),
    Member(name: 'Charlie', contribution: 10.0),
  ], groupId: 0,
);


class GroupDetailsPage extends StatefulWidget {
  final Group group;
  final channel;
  const GroupDetailsPage(this.group, {super.key, this.channel});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  List? members;
  void _setContribution(BuildContext context, Member member) {
    double contribution = 0.0;
    // TODO: Open dialog to set contribution
  }

  fetchMemberList(){
      sendRequest(context, body: {
        'rts_id':widget.group.groupId.toString()
      }, urlString: 'http://127.0.0.1:8000/api/listMembers', successResponse: (){

      }).then((value){
        setState(() {
          members=value;
        });
      });
  }

  @override
  void initState() {
   fetchMemberList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        
        actions: [
          Text(widget.group.coordinator)
        ],
      ),
      body:members==null || members!.isEmpty?const Center(child: Text('No member have joined this group')): ListView.builder(
        itemCount: members!.length,
        itemBuilder: (BuildContext context, int index) {
          Map member = members![index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(member['members_name'][0]),
            ),
            title: Text(member['members_name']),
            // subtitle: Text('\$${member.contribution}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContributionDialog(channel: widget.channel,group: widget.group,);
      },
    );
        },
      ),
    );
  }
}




class ContributionDialog extends StatefulWidget {
  final channel;
  final Group group;

  const ContributionDialog({super.key, required this.channel, required this.group});
  @override
  _ContributionDialogState createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<ContributionDialog> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Contribution'),
      content: TextField(
        controller: _textEditingController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter contribution amount',
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            String contributionAmount = _textEditingController.text;
            Map data={'tag':'group_sent','id':widget.group.groupId,'contibution_amount':contributionAmount,'group':widget.group.toMap()};
          widget.channel.sink.add(jsonEncode(data));
            Navigator.pop(context);
          },
          child: Text('Set Contribution'),
        ),
      ],
    );
  }

    
}
