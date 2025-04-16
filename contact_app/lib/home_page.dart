import 'package:contact_app/contact.dart';
import 'package:flutter/material.dart';
import 'package:contact_app/mongo_database.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  List<Contact> contacts = [];

  int selectedIndex = -1;

  late Future<List<Contact>>? _future;

  void getData() {
    _future = MongoDatabase.retrieve();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Establish database connection when the widget is initialized
    MongoDatabase.connect();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacts List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {
            getData();
          },
          child: ListView(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Contact Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contactController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: 'Contact Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      String name = nameController.text.trim();
                      String phone = contactController.text.trim();
                      if (name.isNotEmpty && phone.isNotEmpty) {
                        setState(() {
                          nameController.text = '';
                          contactController.text = '';
                          Contact contact = Contact(
                              name: name,
                              contact: phone,
                              qrUrl: _generateQRCode(name, phone));

                          // Insert data into the database
                          MongoDatabase.insert(
                              contact); // Pass name and contact
                        });
                      }
                      getData();
                    },
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String name = nameController.text.trim();
                      String contact = contactController.text.trim();
                      if (name.isNotEmpty && contact.isNotEmpty) {
                        setState(() {
                          nameController.text = '';
                          contactController.text = '';
                          if (selectedIndex != -1) {
                            contacts[selectedIndex].name = name;
                            contacts[selectedIndex].contact = contact;
                            selectedIndex = -1;
                          }
                        });
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data[index].name),
                            subtitle: Text(data[index].contact),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    nameController.text = contacts[index].name;
                                    contactController.text =
                                        contacts[index].contact;
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: const Icon(Icons.edit),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      contacts.removeAt(index);
                                    });
                                  },
                                  child: const Icon(Icons.delete),
                                ),
                                InkWell(
                                  onTap: () {
                                    launchUrlString(data[index].qrUrl);
                                  },
                                  child: const Icon(Icons.qr_code),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              index % 2 == 0 ? Colors.deepPurpleAccent : Colors.purple,
          foregroundColor: Colors.white,
          child: Text(
            contacts[index].name[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contacts[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(contacts[index].contact),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                nameController.text = contacts[index].name;
                contactController.text = contacts[index].contact;
                setState(() {
                  selectedIndex = index;
                });
              },
              child: const Icon(Icons.edit),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  contacts.removeAt(index);
                });
              },
              child: const Icon(Icons.delete),
            ),
            InkWell(
              onTap: () {
              },
              child: const Icon(Icons.qr_code),
            ),
          ],
        ),
      ),
    );
  }

  String _generateQRCode(String name, String phone) {
    String vCardText = _generateVCardText(name, phone);
    String url =
        'https://quickchart.io/qr?text=' + Uri.encodeComponent(vCardText);
    return url;
  }

  String _generateVCardText(String name, String phone) {
    return 'BEGIN:VCARD\n'
        'VERSION:3.0\n'
        'N:$name\n'
        'FN:$name\n'
        'TEL;CELL:$phone\n'
        'END:VCARD';
  }
}
