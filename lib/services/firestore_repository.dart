import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_app_v1/data/fake_app_data.dart';
import 'package:fake_app_v1/models/cuisine_model.dart';
import 'package:fake_app_v1/models/dish_model.dart';

class FirestoreRepository {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> update() async {
    List<Dish> firestoreDishes = (await _firestore.collection("dishes").get())
        .docs
        .map((doc) => Dish.fromJson(doc.data())..id = doc.id)
        .toList();
    List<Cuisine> firestoreCuisines =
        (await _firestore.collection("cuisines").get()).docs.map((doc) {
      Cuisine cuisine = Cuisine.fromFirestore(doc);
      return cuisine
        ..dishes = firestoreDishes
            .where((dish) => dish.cuisineName == cuisine.name)
            .toList();
    }).toList();

    updateCuisines(firestoreCuisines);
  }

  Future<void> updateCuisines(List<Cuisine> cuisines) async {
    int counter = 0;

    for (Cuisine cuisine in cuisines) {
      DocumentReference docRef =
          _firestore.collection("cuisines").doc(cuisine.id);

      if (cuisine.id == null) cuisine.id = docRef.id;

      await docRef.set(cuisine.toJson(), SetOptions(merge: true));

      counter++;
    }

    print("updated $counter cuisine docs");
  }

  Future<void> deleteCuisines() async {
    int counter = 0;

    await _firestore.collection("cuisines").get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
        counter++;
      }
    });

    print("deleted $counter cuisine docs");
  }

  Future<void> updateDishesFromCuisine(Cuisine cuisine) async {
    int counter = 0;

    for (Dish dish in cuisine.dishes) {
      DocumentReference docRef = _firestore.collection("dishes").doc(dish.id);

      dish.cuisineName = cuisine.name;

      if (dish.id == null) dish.id = docRef.id;

      await docRef.set(dish.toJson(), SetOptions(merge: true));

      counter++;
    }

    print("updated $counter dish docs from ${cuisine.name}");
  }

  Future<void> deleteDishes() async {
    int counter = 0;

    await _firestore.collection("dishes").get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
        counter++;
      }
    });

    print("deleted $counter dish docs");
  }

  Future<List<Cuisine>> downloadData() async {
    QuerySnapshot snapshot = await _firestore.collection("cuisines").get();

    List<Cuisine> cuisines =
        snapshot.docs.map((doc) => Cuisine.fromFirestore(doc)).toList();

    return cuisines;
  }
}
