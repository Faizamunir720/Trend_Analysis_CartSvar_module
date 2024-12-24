import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch Graph Data from Firestore
  Future<Map<String, dynamic>?> fetchGraphData(String documentId) async {
    try {
      // Access Firestore 'Graphs' collection and document by ID
      DocumentSnapshot snapshot =
      await _firestore.collection('Graphs').doc(documentId).get();

      // Check if document exists
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print("Document with ID $documentId not found");
        return null;
      }
    } catch (e) {
      print("Error fetching graph data: $e");
      return null;
    }
  }

  // Fetch Shipping Costs Impact Data
  Future<Map<String, dynamic>> fetchShippingCostsImpactData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Graphs').doc('shipping_costs_impact_on_abandonment').get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print("Shipping Costs Impact data not found");
        return {
          "data": [25, 40, 15],
          "categories": ["Low", "Medium", "High"]
        }; // Default data if document doesn't exist
      }
    } catch (e) {
      print("Error fetching Shipping Costs Impact data: $e");
      return {
        "data": [25, 40, 15],
        "categories": ["Low", "Medium", "High"]
      }; // Default data
    }
  }
  // Fetch Weekly Cart Abandonment Trends Data
  Future<Map<String, dynamic>> fetchWeeklyCartAbandonmentData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Graphs').doc('weekly_trends').get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print("Weekly Cart Abandonment Trends data not found");
        return {
          "dataValues": [50, 70, 80, 60, 90, 120, 110],
          "categories": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }; // Default data if document doesn't exist
      }
    } catch (e) {
      print("Error fetching Weekly Cart Abandonment Trends data: $e");
      return {
        "dataValues": [50, 70, 80, 60, 90, 120, 110],
        "categories": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
      }; // Default data
    }
  }

}
