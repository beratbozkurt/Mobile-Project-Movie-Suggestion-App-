import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'FavoriteList.dart';
import 'authentication.dart';
import 'databaseHelper.dart';
import 'MovieDetails.dart';
import 'UserClass.dart';
import 'loading.dart';
import 'login.dart';
import 'movie_list.dart';
import 'search.dart';
import 'rating.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

 class HomeScreen extends StatefulWidget {
  DataUser user;
  static List<Map<String,dynamic>> favoList= new List<Map<String,dynamic>>();
  static DataUser globalUser;
  HomeScreen(DataUser user){
     this.user=user;
  }


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {



  authentication auth=new authentication();
  final dbHelper = DatabaseHelper.instance;

  /*Adding  API Movie Information to the Database */
  void addMovieToDB(dynamic list) async {
    HomeScreen.globalUser=widget.user;
    for (int i = 0; i < 20; i++) {
      bool tf = await dbHelper.find(list[i]["id"].toString(),
          DatabaseHelper.table, DatabaseHelper.columnMovieID);
      if (tf) {
        await _insert(list[i]["title"], list[i]["id"].toString(), list[i]["overview"],
            list[i]["poster_path"], DatabaseHelper.table);
      }
    }
  }

  Future<void> UpdateUpcoming() async {
    for (int index = 0; index < 6; index++) {
      bool tf = await dbHelper.find(
          index + 1, DatabaseHelper.tableUpcoming, DatabaseHelper.columnId);
      if (tf) {
       await _insert(
            upcoming[index]["title"],
            upcoming[index]["id"].toString(),
            upcoming[index]["overview"],
            upcoming[index]["poster_path"],
            DatabaseHelper.tableUpcoming);
      } else {
        bool tf2 = await dbHelper.find(upcoming[index]["id"].toString(),
            DatabaseHelper.tableUpcoming, DatabaseHelper.columnMovieID);
        if (tf2) {
          await _update(
              upcoming[index]["title"],
              upcoming[index]["id"].toString(),
              upcoming[index]["overview"],
              upcoming[index]["poster_path"],
              index + 1);
        }
      }
    }
  }

   var popular, comedy, horror, sf, anime, romance, ec, upcoming;
  bool flag = false;
  getdata() async {
    popular = await movie.fetchMovie("popular");
    comedy = await movie.fetchgenre("Comedy");
    horror = await movie.fetchgenre("Horror");
    sf = await movie.fetchgenre("Science Fiction");
    anime = await movie.fetchgenre("Animation");
    romance = await movie.fetchgenre("Romance");
    ec = await movie.fetchMovie("top_rated");
    upcoming = await movie.fetchMovie("upcoming");

    setState(() {
      flag = true;
    });
      await addMovieToDB(popular);
      await addMovieToDB(comedy);
      await addMovieToDB(horror);
      await addMovieToDB(sf);
      await addMovieToDB(anime);
      await addMovieToDB(romance);
      await addMovieToDB(ec);

      await UpdateUpcoming();
  }

  @override
  void initState() {
    super.initState();
    getdata();
    UpdateFavoriteList();
  }

  /*After Log_in operation, the previous data is being deleted and new user's favorite movies are being added to the database*/
  UpdateFavoriteList() async{
    dbHelper.deleteAll("Favorite_table");
    var list=await auth.getMoviesFromFirebase(widget.user.email);
    dbHelper.addAllToDB("Favorite_table", list);

  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isp = MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      color: CupertinoColors.darkBackgroundGray,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'SUMO',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: CupertinoColors.destructiveRed,
                ),
                onPressed: () {

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavList("Favorites")));
                },
              ),
            ],
          ),
          drawer: Drawer(
              child: Container(
            color: CupertinoColors.darkBackgroundGray,
            child: ListView(
              children: [
                Container(
                  height: size.height * 0.25,
                  alignment: Alignment.center,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("asset/icon.png"),
                            fit: BoxFit.scaleDown)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                  child: Text(
                    widget.user.name,
                    style: TextStyle(
                        color: CupertinoColors.extraLightBackgroundGray,
                        fontSize: 18),
                  ),
                ),
                listtileSearch(
                    "Search", context, Icon(Icons.search, color: Colors.black)),
                listtile("Editor Choice", context,
                    Icon(Icons.people, color: Colors.black), ec),
                listtile(
                    "Top-250",
                    context,
                    Icon(
                      Icons.timeline,
                      color: Colors.black,
                    ),
                    null),
                listtile(
                    "Favorites",
                    context,
                    Icon(
                      Icons.favorite,
                      color: Colors.black,
                    ),
                    null),
                Container(
                  margin: EdgeInsets.fromLTRB(80, 25, 80, 0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red),
                    ),
                    onPressed: () {

                      Navigator.pushReplacementNamed(context, '/');
                      //Navigator.pushNamed(context, '/');
                    },
                    child: Text(
                      'Quit',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(80, 3, 80, 0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red),
                    ),
                    onPressed: () {
                      Firestore.instance.collection('Users').doc(widget.user.id).delete();
                      Firestore.instance.collection('Favorites').doc(widget.user.email).delete();
                      FirebaseAuth.instance.currentUser.delete();



                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          )),
          body: Container(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),
                Container(
                  height: isp ? size.height * 0.22 : size.height * 0.34,
                  color: Colors.transparent,
                  child: FutureBuilder(
                      future: movie.fetchMovie("upcoming"),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Icon(
                            Icons.error,
                            size: 110,
                          );
                        } else {
                          return ListView.separated(
                              itemCount: 6,
                              separatorBuilder: (BuildContext context,
                                      int index) =>
                                  Divider(height: 2, color: Colors.transparent),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Avatarcard(
                                    context,
                                    size,
                                    snapshot.data[index]["poster_path"],
                                    snapshot.data[index]["title"],
                                    snapshot.data[index]["id"].toString());
                              });
                        }
                      }),
                ),
                flag == false
                    ? Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView(
                          children: [
                            Topic(size, context, isp, "Popular", popular),
                            Topic(size, context, isp, "Horror", horror),
                            Topic(size, context, isp, "Science Fiction", sf),
                            Topic(size, context, isp, "Romance", romance),
                            Topic(size, context, isp, "Comedy", comedy),
                            Topic(size, context, isp, "Animation", anime),
                            Topic(size, context, isp, "Editor Choice", ec),
                          ],
                        ),
                      ),
              ],
            ),
          )),
    );
  }

  listtile(String title, BuildContext context, Icon ic, dynamic data) {
    return InkWell(
      splashColor: Colors.grey,
      onTap: () {

        if(title=="Favorites"){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FavList(title)));
        }else{
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MovieList(title, data)));
        }
      },
      child: Card(
        color: Colors.yellowAccent[700],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(35, 60),
              bottomRight: Radius.elliptical(35, 60),
            ),
            side: BorderSide(color: CupertinoColors.black)),
        child: ListTile(
          leading: ic,
          title: Text(
            title,
            style: TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  listtileSearch(String title, BuildContext context, Icon ic) {
    return InkWell(
      splashColor: Colors.grey,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SearchPage()));
      },
      child: Card(
        color: Colors.yellowAccent[700],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(35, 60),
              bottomRight: Radius.elliptical(35, 60),
            ),
            side: BorderSide(color: CupertinoColors.black)),
        child: ListTile(
          leading: ic,
          title: Text(
            title,
            style: TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Avatarcard(
      BuildContext context, Size size, String photo, String title, String id) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 1),
      child: Container(
        child: Column(
          children: [
            InkWell(
              child: CircleAvatar(
                radius: size.width * size.height * 0.000189,
                backgroundColor: Color(0xffFDCF09),
                child: CircleAvatar(
                  backgroundColor: CupertinoColors.darkBackgroundGray,
                  backgroundImage:
                      NetworkImage("https://image.tmdb.org/t/p/w500" + photo),
                  radius: size.width * size.height * 0.00018,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailsScreen(id)));
              },
            ),
            SizedBox(
              height: size.height * 0.015,
            ),
            Container(
              width: size.width * 0.30,
              child: Center(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: CupertinoColors.extraLightBackgroundGray),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  MovieItem(int index, BuildContext context, Size size, isp, String photo,
      String title, String id, double vote) {
    return Padding(
      padding: EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.8),
              spreadRadius: -1,
              blurRadius: 6,
              offset: Offset(6, 6), // changes position of shadow
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DetailsScreen(id)));
          },
          splashColor: Colors.grey,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    CupertinoColors.darkBackgroundGray,
                    CupertinoColors.extraLightBackgroundGray
                  ],
                  stops: [0.5, 0.5],
                  startAngle: 0,
                  endAngle: 8,
                ),
              ),
              width: size.width * 0.80,
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  Container(
                    height: isp ? size.height * 0.26 : size.height * 0.52,
                    width: isp ? size.width * 0.31 : size.width * 0.28,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              "https://image.tmdb.org/t/p/w500" + photo),
                          fit: BoxFit.cover),
                      border: Border.all(
                          width: size.width * 0.003,
                          color: CupertinoColors.activeOrange),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.elliptical(35, 3),
                        bottomRight: Radius.elliptical(35, 25),
                        topLeft: Radius.elliptical(35, 25),
                        topRight: Radius.elliptical(35, 3),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 0, 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: size.width * 0.04,
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 25),
                                child: Text(
                                  'Rank : ',
                                  style: TextStyle(color: Colors.amber),
                                ),
                              ),
                              StarRating(5, vote / 2.0, null, Colors.amber),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Topic(Size size, BuildContext context, bool isp, String title, dynamic data) {
    return Container(
      child: Column(
        children: [
          Container(
            height: size.height * 0.082,
            padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
            child: Container(
              decoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(90, 20),
                    bottomRight: Radius.elliptical(90, 20),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      )),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MovieList(title, data)));
                    },
                    child: Text('see all'),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: isp ? size.height * 0.3 : size.height * 0.5,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) => MovieItem(
                  index,
                  context,
                  size,
                  isp,
                  data[index]["poster_path"],
                  data[index]["title"],
                  data[index]["id"].toString(),
                  double.parse(data[index]["vote_average"].toString())),
              itemCount: 5,
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
        ],
      ),
    );
  }

  /*DATABASE INSERTION*/
  void _insert(String title, String Movie_id, String overview,
      String poster_path, String tableName) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnMovieID: Movie_id,
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnOverview: overview,
      DatabaseHelper.columnPoster: poster_path,
    };
    final id = await dbHelper.insert(row, tableName);
  }

  void _update(String title, String Movie_id, String overview,
      String poster_path, int index) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: index,
      DatabaseHelper.columnMovieID: Movie_id,
      DatabaseHelper.columnTitle: title,
      DatabaseHelper.columnOverview: overview,
      DatabaseHelper.columnPoster: poster_path,
    };
    final updatedRow = await dbHelper.update(row, DatabaseHelper.tableUpcoming);
  }


}
