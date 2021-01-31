import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UserClass.dart';

class authentication{
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> SignUp(String email, String password, String name) async{

    if(email.trim().isEmpty || !email.trim().contains("@")){
      return "Please enter a valid email";
    }
    if(password.trim().length< 6){
      return "Password must be at least 6 characters";
    }
    if(name.trim().length< 2){
      return "Name must be at least 2 characters";
    }

    try{
      UserCredential userCredential= await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());

      await FirebaseFirestore.instance.collection("Users").doc(userCredential.user.uid).set({
        "Name": name.trim(),
        "Mail": email.trim(),
        "Password": password.trim(),

      });
      await FirebaseFirestore.instance.collection("Favorites").doc(userCredential.user.email).set({
        "Movies": new List<Map<String,dynamic>>(),

      });

      return "Account Has Been Created Successfully";


    } on FirebaseAuthException catch(error){
        var message= "An error occurred about Firebase Auth!!";

        if(error.message!=null){
          message=error.message;
        }
        throw message;

    }catch(error){
      throw error.message;
    }

  }



  Future<DataUser> SignIn(String email,String password) async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      var user = await FirebaseFirestore.instance.collection("Users").doc(userCredential.user.uid).get();


      DataUser newUser = new DataUser(email: userCredential.user.email,id:userCredential.user.uid,name:user.get("Name") );
        return newUser;
    }on FirebaseAuthException catch(error){
      var message= "given information is not valid";
      if(error.message!=null){
        message=error.message;
      }
      throw message;

    }catch(error){
      throw error.message;
    }

  }


  CollectionReference favorities = FirebaseFirestore.instance.collection('Favorites');

  Future<List<dynamic>> getMoviesFromFirebase(String email) async{
      var list = await favorities.doc(email).get();
      return list.data()["Movies"] ;
  }
  Future<void> updateUserFavorites(String mail, List<Map<String, dynamic>> FavoriteList) {
    return favorities
        .doc(mail)
        .update({'Movies': FavoriteList})
        .then((value) => print("Favorite List Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }



}