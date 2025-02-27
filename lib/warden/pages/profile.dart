import 'package:flutter/material.dart';
import 'package:minipro/firebase/firestore_services.dart';

/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
*/
class MyProfile extends StatefulWidget {
  const MyProfile({super.key});
   @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;
    
 
  void initState() {
super.initState();
  fetchUserData ();
  
  }
 
  void fetchUserData() async {
    Map<String, dynamic>? cachedUserData =
        await _firestoreService.getCachedUserData();
    if (cachedUserData != null) {
      setState(() {
        userData = cachedUserData;
      });
    } else {
      await _firestoreService.getUserData();
      Map<String, dynamic>? newUserData =
          await _firestoreService.getCachedUserData();
      setState(() {
        userData = newUserData;
      });
    }
  }
  
  @override

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
         alignment: Alignment.center,
          child: Builder(
            
            builder: (context) {
              return userData == null
                  ? const CircularProgressIndicator()
                  : Column(
                      
                     
                       mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      
                        const CircleAvatar(
                          
                          radius: 50.0,
                          backgroundImage: AssetImage('assets/images/profile/profile.png'),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          userData!["username"]?? "Username",
                          
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          userData!["role"]?? "Username",
                          
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),

        
    );
  }

  
}
          

