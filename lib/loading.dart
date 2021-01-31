import 'dart:convert';
import 'package:http/http.dart' as http;


class movie {

  static Map<int, String> genre = {
    28: "Action",
    12: "Adventure",
    16 : "Animation",
    35: "Comedy",
    80: "Crime",
    99: "Documentary",
    18  : "Drama",
    10751 : "Family",
    14  : "Fantasy",
    36 : "History",
    27: "Horror",
    10402: "Music",
    9648 : "Mystery",
    10749  : "Romance",
    878: "Science Fiction",
    10770: "TV Movie",
    53: "Thriller",
    10752 : "War",
    37: "Western"
  };



  static Future<dynamic> fetchMovie(String type) async {

    var url ="https://api.themoviedb.org/3/movie/";
    var key="?api_key=802b2c4b88ea1183e50e6b285a27696e";
    var response = await http.get(url+type+key);

    if (response.statusCode == 200) {
      var data = json.decode(response.body)["results"];

      return data;

    } else {
      throw Exception('Failed to load movies');
    }
  }

  static Future<dynamic> fetchgenre(String type) async {
    var Mygenre = genre.keys.firstWhere(
            (k) => genre[k] == type , orElse: () => null);
    var url ="https://api.themoviedb.org/3/discover/movie";
    var key="?api_key=802b2c4b88ea1183e50e6b285a27696e";
    var response = await http.get(url+key+"&with_genres="+Mygenre.toString());

    if (response.statusCode == 200) {
      var data = json.decode(response.body)["results"];

      return data;

    } else {
      throw Exception('Failed to load movies');
    }
  }

  static String fetchgenrenames(int type)  {
    return  genre[type];
  }

  static Future<dynamic> fetchonlymovie(String id) async {
    var url ="https://api.themoviedb.org/3/movie/";
    var key="?api_key=802b2c4b88ea1183e50e6b285a27696e";
    var response = await http.get(url+id+key);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;

    } else {
      throw Exception('Failed to load movies');
    }
  }

  static Future<dynamic> fetchbysearch(String id) async {
    var url ="https://api.themoviedb.org/3/search/movie";
    var key="?api_key=802b2c4b88ea1183e50e6b285a27696e&query=";
    id = id.replaceAll(" ", "+");
    var response = await http.get(url+key+id);

    if (response.statusCode == 200) {
      var data = json.decode(response.body)["results"];
      return data;

    } else {
      throw Exception('Failed to load movies');
    }
  }

}
