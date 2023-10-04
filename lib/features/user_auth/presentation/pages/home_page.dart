import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.purple,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                    'web/logo.png'), // Use NetworkImage with a relative path
              ),
            ),
            SizedBox(width: 10),
            Text(
              "EventZoom",
              style: TextStyle(
                color: Colors.purple,
              ),
            ),
          ],
        ),
        backgroundColor:
            Colors.white, // Set the app bar background color to white
        iconTheme: IconThemeData(
          color:
              Colors.purple, // Set the color of the hamburger menu icon/button
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors
                    .purple, // Set the drawer header background color to purple
              ),
              child: Text(
                "Welcome TO EventZoom!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "Profile",
                style: TextStyle(
                  color: Colors.black, // Set the text color to black
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.event), // Icon for "Add Event"
              title: Text(
                "Add Event",
                style: TextStyle(
                  color: Colors.black, // Set the text color to black
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEventPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.black, // Set the text color to black
                ),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, "/login");
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Remove the Center widget with the image
          SizedBox(
            height: 30,
          ),
          // Add other content as needed
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _newPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.purple,
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'web/default_profile.jpg',
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome to your profile,",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.purple,
                ),
              ),
              Text(
                "${user?.email ?? 'N/A'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showPasswordChangeDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple, // Button color
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Change Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPasswordChangeDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String newPassword = _newPasswordController.text.trim();

                try {
                  await _auth.currentUser?.updatePassword(newPassword);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Password updated successfully."),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error updating password: $e"),
                    ),
                  );
                }
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }
}

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Event"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _addEventToFirebase();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Event Title"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2025),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                }
              },
              child: Text("Select Date"),
            ),
            Text("Selected Date: ${_selectedDate.toLocal()}"),
          ],
        ),
      ),
    );
  }

  void _addEventToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final title = _titleController.text;
      final date = _selectedDate;

      final eventData = {
        'EventTitle': title, // Map to Firestore field 'EventTitle'
        'EventDate': date, // Map to Firestore field 'EventDate'
      };

      // Add the event data to the "events" collection in Firestore
      await FirebaseFirestore.instance.collection('events').add(eventData);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _imageFile;
  String? _imageURL; // To store the image URL after uploading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Event"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              await _addEventToFirebase();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Event Title"),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2025),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                }
              },
              child: Text("Select Date"),
            ),
            Text("Selected Date: ${_selectedDate.toLocal()}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Select Image"),
            ),
            SizedBox(height: 20),
            _imageFile != null
                ? Image.file(_imageFile!)
                : _imageURL != null
                    ? Image.network(_imageURL!)
                    : Container(), // Display the selected image or uploaded image
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addEventToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final title = _titleController.text;
      final date = _selectedDate;

      // Upload the image to Firebase Storage and get the image URL
      if (_imageFile != null) {
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('event_images/${user.uid}/${DateTime.now()}.png');
        await storageReference.putFile(_imageFile!);
        _imageURL = await storageReference.getDownloadURL();
      }

      final eventData = {
        'EventTitle': title,
        'EventDate': date,
        'EventImageURL': _imageURL, // Map to Firestore field 'EventImageURL'
      };

      // Add the event data to the "events" collection in Firestore
      await FirebaseFirestore.instance.collection('events').add(eventData);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
