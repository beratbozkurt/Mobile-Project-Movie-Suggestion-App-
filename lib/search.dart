import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'homescreen.dart';
import 'loading.dart';
import 'movie_list.dart';

import 'MovieDetails.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SearchBarHome();
  }
}

class SearchBarHome extends StatefulWidget {
  @override
  _SearchBarHomeState createState() => new _SearchBarHomeState();
}

class _SearchBarHomeState extends State<SearchBarHome> {
  SearchBar searchBar;
  var data;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        backgroundColor: CupertinoColors.darkBackgroundGray,
        title: new Text('Search'),
        actions: [searchBar.getSearchAction(context)]);
  }

  Enter(String value) async {
    data = await movie.fetchbysearch(value);
    setState(() => _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text("Found: ${data.length} Movie(s)"))));
  }

  _SearchBarHomeState() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: Enter,
        onCleared: () {
          print("cleared");
        },
        onClosed: () {
          print("closed");
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isp = MediaQuery.of(context).orientation == Orientation.portrait;
    return new Scaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      appBar: searchBar.build(context),
      key: _scaffoldKey,
      body: data == null
          ? Container()
          : CustomScrollView(
          slivers: <Widget>[ SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                    searchmovie(index),
                    childCount: data.length),
              ),
          ],
      ),
    );
  }

  searchmovie(int index){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(data[index]["id"].toString())));
      },
      child: Container(
        height: 100,
        child: Row(
          children: [
            SizedBox(
              width: 25,
            ),
            CircleAvatar(
              backgroundColor:
              CupertinoColors.darkBackgroundGray,
              backgroundImage:data[index]["poster_path"]==null ? AssetImage("asset/not.png") :NetworkImage(
                  "https://image.tmdb.org/t/p/w500" +
                      data[index]["poster_path"]),
              radius: 40,
            ),
            SizedBox(
              width: 25,
            ),
            Container(
              width: 250,
              child: Text(
                data[index]["title"],
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                    color: CupertinoColors
                        .extraLightBackgroundGray,
                    fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
