import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:recipe_app/pages/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/pages/recipe_detail.dart'; // Import the RecipeDetail page

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Recipe", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('List', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Icon(Icons.search),
                ],
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SliverToBoxAdapter(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final itemCount = snapshot.data!.docs.length;
                      final List<Widget> containers = [];

                      for (int i = 0; i < itemCount; i += 2) {
                        if (i + 1 < itemCount) {
                          containers.add(
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  buildRecipeContainer(snapshot.data!.docs[i]),
                                  SizedBox(width: 20),
                                  buildRecipeContainer(snapshot.data!.docs[i + 1]),
                                ],
                              ),
                            ),
                          );
                        } else {
                          containers.add(
                            Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: buildRecipeContainer(snapshot.data!.docs[i]),
                            ),
                          );
                        }
                      }

                      return SliverList(
                        delegate: SliverChildListDelegate(containers),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navbar(),
    );
  }

  Future<String> getImageUrl(String imageName) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance.ref().child('recipe_images/$imageName');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error retrieving image URL: $e');
      return ''; // Return an empty string if there is an error
    }
  }

  Widget buildRecipeContainer(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey('time')) {
      final time = (data['time'] as num).toInt(); // Convert time to an integer
      final timetype = data['timetype'] as String? ?? '';
      final String name = doc['name'];
      final cal = data['cal'] as int;
      final difficulty = data['difficulty'] as String? ?? '';
      final serving = data['serving'] as int;

      final imageName = name.toLowerCase().replaceAll(' ', '') + '.jpg'; // Convert name to lowercase and remove spaces

      return FutureBuilder<String>(
        future: getImageUrl(imageName), // Use the updated image name
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the image URL, display a placeholder container
            return Container(
              margin: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 185,
                    height: 300,
                    color: Colors.grey[200],
                  ),
                  Text(name),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('Error loading image: ${snapshot.error}');
          }

          final imageUrl = snapshot.data ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetail(
                    recipeId: doc.id,
                    name: name,
                    time: time,
                    timetype: timetype,
                    cal: cal,
                    difficulty: difficulty,
                    serving: serving,
                    imageURL: imageUrl.isNotEmpty ? imageUrl : "assets/images/food-product.jpg",
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 185,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : AssetImage("assets/images/food-product.jpg") as ImageProvider<Object>,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(name),
                ],
              ),
            ),
          );
        },
      );
    }

    return SizedBox(); // Return an empty container if the 'time' field is missing or not an integer
  }
}
