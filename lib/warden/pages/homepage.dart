import 'package:flutter/material.dart';
import 'package:minipro/warden/components/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('H o m e'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification click
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No new notifications")),
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 20.0, left: 10, right: 10.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns items to the left
          children: [
            Text(
              "Welcome Nicolas Jackson",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Divider(color: const Color.fromARGB(148, 255, 255, 255)),
            SizedBox(height: 20.0),
            Text(
              "Categories",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                "Maintenance Requests",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            // SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: Row(
                children: [
                  Material(
                    elevation: 5.0,
                    child: Container(
                      width: 300,
                      height: 190.0,
                      padding:
                          EdgeInsets.all(20.0), // Correct padding placement
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),

                      child: Column(
                        children: [
                          Image.asset(
                            'assets/warden/maintenance.jpg',
                            width: 170.0,
                            height: 150.0,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                "Complaints",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            Material(
              elevation: 5.0,
              child: Container(
                width: 300,
                height: 190.0,

                padding: EdgeInsets.all(20.0), // Correct padding placement
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 36, 204, 216),
                  borderRadius: BorderRadius.circular(20.0),
                ),

                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/warden/complain1.jpg',
                        width: 170.0,
                        height: 150.0,
                        //fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
    );
  }
}
