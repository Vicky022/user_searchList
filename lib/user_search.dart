import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:listuser/user_model.dart';
import 'package:rxdart/rxdart.dart';

class UserSearch extends StatefulWidget {
  @override
  State createState() => new _UserSearch();
}

class _UserSearch extends State<UserSearch> {
  List<UsersModel> user_list = new List();
  List<UsersModel> search_user = new List();

  final subject = new PublishSubject<String>();
  final url = "https://jsonplaceholder.typicode.com/users";

  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController(text: '');

  Future<Null> fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      user_list.clear();
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          for (Map i in data) {
            user_list.add(UsersModel.fromJson(i));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void textChanged(String text) async {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _clearList();
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _clearList();
    user_list.forEach((f) {
      if (f.name.contains(text) || f.username.contains(text))
        search_user.add(f);
    });
    setState(() {
      _isLoading = false;
    });
  }

  void _clearList() {
    setState(() {
      search_user.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    subject.stream
        .debounce(new Duration(milliseconds: 100))
        .listen(textChanged);
  }

  Widget _createSearchBar(BuildContext context) {
    return new Card(
        child: Row(
      children: <Widget>[
        new Icon(Icons.search),
        new Expanded(
          child: TextField(
            autofocus: true,
            controller: textEditingController,
            decoration: new InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.0),
              hintText: 'Search here',
            ),
            onChanged: (string) => (subject.add(string)),
          ),
        ),
        IconButton(
          onPressed: () => clearData(),
          icon: Icon(Icons.cancel),
        ),
      ],
    ));
  }

  clearData() {
    subject.add("");
    textEditingController.text = "";
  }

  Widget _createUser(BuildContext context, UsersModel usersModel) {
    return new GestureDetector(
      onTap: () {},
      child: Column(
        children: <Widget>[
          Padding(
              padding: new EdgeInsets.all(10),
              child: new Row(
                children: <Widget>[
                  Container(
                    child: Text(
                      'ID: ' + usersModel.id.toString(),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    color: Colors.grey[100],
                    height: 80.0,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: _createUserDescriptionSection(context, usersModel),
                  )),
                ],
              )),
          new Divider(
            height: 15.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _createUserDescriptionSection(
      BuildContext context, UsersModel usersModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
//      crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              usersModel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5.0),
            Text(
              usersModel.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(usersModel.email,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                )),
            Text(usersModel.phone,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                )),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(600.0),
        child: const Text(''),
      ),
      body: new Container(
        padding:
            new EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
        child: new Column(
          children: <Widget>[
            _createSearchBar(context),
            new Expanded(
              child: Card(
                  child: _isLoading
                      ? Container(
                          child: Center(child: CircularProgressIndicator()),
                          padding: EdgeInsets.all(16.0),
                        )
                      : Card(
                          child: search_user.length != 0 ||
                                  textEditingController.text.isNotEmpty
                              ? ListView.builder(
                                  padding: new EdgeInsets.all(10),
                                  itemCount: search_user.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _createUser(
                                        context, search_user[index]);
                                  },
                                )
                              : ListView.builder(
                                  padding: new EdgeInsets.all(8.0),
                                  itemCount: user_list.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _createUser(
                                        context, user_list[index]);
                                  },
                                ),
                        )),
            )
          ],
        ),
      ),
    );
  }
}
