import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'authentication.dart';
import 'databaseHelper.dart';
import 'loading.dart';
import 'homescreen.dart';
import 'authentication.dart';
import 'login.dart';

class DetailsScreen extends StatefulWidget {
  String id;
  DetailsScreen(String id){
    this.id = id;
  }
  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  authentication authSer = new authentication();

  final GlobalKey<ScaffoldState> _scaffoldAddingDeleting = new GlobalKey<ScaffoldState>();


  final dbHelper = DatabaseHelper.instance;

  /*Insert and Delete Operations for Both Firebase and Database*/
   Future<bool> insertOrDelete(var element) async{
    bool tf = await dbHelper.find(element["id"], DatabaseHelper.tableFavorite, DatabaseHelper.columnMovieID);
    Map<String, dynamic> row = {
      DatabaseHelper.columnMovieID: element["id"].toString(),
      DatabaseHelper.columnTitle: element["title"],
      DatabaseHelper.columnOverview: element["overview"],
      DatabaseHelper.columnPoster: element["poster_path"],
    };
    if(tf) {

      _insert(row, DatabaseHelper.tableFavorite);
      return true;

    }else{
      await DeleteMovieFromList(row);
      await dbHelper.delete(element["id"], DatabaseHelper.tableFavorite);


      return false;
    }
  }
  /**/
  void _insert(Map<String, dynamic> row,String tableName) async {
    await AddMovieToList(row);
    final id = await dbHelper.insert(row, tableName);
  }
  Future<Map<String,dynamic>> AddMovieToList(Map<String,dynamic> Movie) async{
     HomeScreen.favoList.add(Movie);
     await authSer.updateUserFavorites(HomeScreen.globalUser.email,HomeScreen.favoList);

  }
  Future<Map<String,dynamic>> DeleteMovieFromList(Map<String, dynamic> index) async{
     HomeScreen.favoList.removeWhere((item) => item["id"] == index["id"]);
     await authSer.updateUserFavorites(HomeScreen.globalUser.email,HomeScreen.favoList);

  }




  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      body: FutureBuilder(
        key: _scaffoldAddingDeleting,
        future: movie.fetchonlymovie(widget.id),
        builder: (context, AsyncSnapshot snapshot){
          if (snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Icon(
              Icons.error,
              size: 110,
            );
          } else{
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Container(
              height: size.height * 0.65,
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: size.height * 0.7 - 50,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(50)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image:snapshot.data["poster_path"]==null ? AssetImage("asset/not.png") : NetworkImage("https://image.tmdb.org/t/p/w500"+snapshot.data["poster_path"]),),
                      ),
                    ),
                    // Rating Box
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: size.width * 0.9,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            topLeft: Radius.circular(50),
                          ),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 12),
                              blurRadius: 30,
                              color: Colors.black.withOpacity(0.9),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 15),
                                  Icon(Icons.star,
                                      color: CupertinoColors.systemYellow),
                                  SizedBox(height: 3),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: Colors.black38),
                                      children: [
                                        TextSpan(
                                          text: "Popularity: "+snapshot.data["popularity"].toString(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                          text: "\n",
                                        ),
                                        TextSpan(
                                          text: "Votes: "+snapshot.data["vote_count"].toString(),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Rate this
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.star_border),
                                    onPressed: () {
                                      //Rating
                                    },
                                  ),
                                  SizedBox(height: 5),
                                  Text("Rate This",
                                      style:
                                      Theme.of(context).textTheme.bodyText2),
                                ],
                              ),
                              //SumoScore
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemYellow,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      "SS",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Sumoscore",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    snapshot.data["vote_average"].toString(),
                                    style: TextStyle(color: Colors.black),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Back Button
                    SafeArea(
                        child: BackButton(
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              snapshot.data["title"],
                              style: TextStyle(
                                  color: CupertinoColors.extraLightBackgroundGray,
                                  fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Text(
                                  snapshot.data["release_date"].toString(),
                                  style: TextStyle(
                                      color: CupertinoColors
                                          .extraLightBackgroundGray,
                                      fontSize: 13),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Duration : ${snapshot.data["runtime"].toString() ?? "Unknown" } min",
                                  style: TextStyle(
                                      color: CupertinoColors
                                          .extraLightBackgroundGray,
                                      fontSize: 13),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 64,
                        width: 64,
                        child: FlatButton(
                          onPressed: () async{
                            bool tf;
                            tf=await insertOrDelete(snapshot.data);
                            if(tf){
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Added to Favorites"),));
                            }else{
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Deleted from Favorites"),));
                            }




                            //Add favourite
                          },
                          color: CupertinoColors.systemYellow,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Icon(
                            Icons.favorite,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: SizedBox(
                  height: size.height*0.14,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data["genres"].length,
                      itemBuilder: (context, index) => CircleAvatar(
                        radius: size.height*size.width*0.00019,
                        child: Text(
                          snapshot.data["genres"][index]["name"],
                          style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: CupertinoColors.systemYellow,
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Text(
                    "Plot Summary",
                  style: TextStyle(
                      color: CupertinoColors.extraLightBackgroundGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: size.width * 0.9,
                  child: Text(
                   snapshot.data["overview"],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                    style: TextStyle(
                        color: CupertinoColors.extraLightBackgroundGray),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.1,
              )
            ],
          ),
        );
        }
        }
      ),
    );
  }
}
