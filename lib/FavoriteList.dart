import 'dart:ui';
import 'MovieDetails.dart';
import 'databaseHelper.dart';
import 'title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'rating.dart';
import 'loading.dart';

class FavList extends StatefulWidget {
  String title;
  FavList(String title,){
    this.title=title;
  }



  @override
  _FavListState createState() => _FavListState();
}

class _FavListState extends State<FavList> {
  final dbHelper = DatabaseHelper.instance;
  var data;
  void initState() {
    super.initState();
      getFav();
  }
   getFav()async{
     final abc= await dbHelper.queryAllRows(DatabaseHelper.tableFavorite);
      setState(() {
        data=abc;
      });

  }


  @override
  Widget build(BuildContext context) {
    bool isp = MediaQuery.of(context).orientation == Orientation.portrait;
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        color: CupertinoColors.darkBackgroundGray,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: data==null ? Container(child: Center(child: Text("Coming Soon",style: TextStyle(color: CupertinoColors.extraLightBackgroundGray),)),) :CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent.withOpacity(0.7),
                expandedHeight: size.height * 0.35,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: TitleB(widget.title),
                  titlePadding: EdgeInsets.only(left: 0),
                  background: Image.asset(
                    'asset/Favorites.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                        MovieItem(data[index]["title"], index, size, context,isp),
                    childCount: data.length),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MovieItem(String s, int index, Size size, BuildContext context,bool isp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Divider(
            color: CupertinoColors.systemYellow,
            thickness: 3,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(data[index]["id"].toString())));
            },
            child: Container(
              height: isp? size.height * 0.26:size.height * 0.40,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: size.width * 0.003,
                            color: CupertinoColors.extraLightBackgroundGray),
                      ),
                      child: Image.network("https://image.tmdb.org/t/p/w500"+data[index]["poster_path"],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height * 0.015,
                        ),
                        Container(
                          width: size.width*0.5,
                          child: Text(
                            data[index]["title"],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                CupertinoColors.extraLightBackgroundGray),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.015,
                        ),
                        //Text('Description: This is a description for this movie',style: TextStyle(fontSize: 15, color: Colors.amber)),
                        SizedBox(
                          height: size.height * 0.015,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
