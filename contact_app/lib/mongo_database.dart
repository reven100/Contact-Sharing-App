import 'dart:developer';
import 'package:contact_app/contact.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db;
  static final DbCollection user = db.collection('contact_table');

  static Future<void> connect() async {
    try {
      db = await Db.create(
          'mongodb+srv://newuser:user1234@cluster8.pp5oo1v.mongodb.net/?retryWrites=true&w=majority&appName=Cluster8');
      await db.open();
      inspect(db);
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> close() async {
    try {
      await db.close();
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<void> insert(Contact contact) async {
    final DbCollection user = db.collection('contact_table');
    try {
      await user.insertOne(contact.toMap());
    } catch (e) {
      log("Error in insert function$e");
    }
  }

  static Future<List<Contact>> retrieve() async {
    try {
      final DbCollection user = db.collection('contact_table');
      final result = await user.find().toList();
      return result.map((e) => Contact.fromMap(e)).toList();
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}
