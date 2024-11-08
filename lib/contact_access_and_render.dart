import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestContactPermission();
    searchController.addListener(() {
      filterContacts();
    });
  }

  Future<void> requestContactPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }
    if (status.isGranted) {
      fetchContacts();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchContacts() async {
    final allContacts = await ContactsService.getContacts();
    setState(() {
      contacts = allContacts.toList();
      filteredContacts = contacts;
      isLoading = false;
    });
  }

  void filterContacts() {
    List<Contact> results = contacts.where((contact) {
      final name = contact.displayName?.toLowerCase() ?? '';
      final query = searchController.text.toLowerCase();
      return name.contains(query);
    }).toList();
    setState(() {
      filteredContacts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts with Search'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Contacts',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return ContactListItem(contact: contact);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class ContactListItem extends StatelessWidget {
  final Contact contact;

  ContactListItem({required this.contact});

  @override
  Widget build(BuildContext context) {
    final phone = contact.phones?.isNotEmpty == true
        ? contact.phones!.first.value
        : 'No phone number';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        leading: CircleAvatar(
          child:
              Text(contact.initials(), style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
        title: Text(contact.displayName ?? 'No Name',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(phone!),
      ),
    );
  }
}
