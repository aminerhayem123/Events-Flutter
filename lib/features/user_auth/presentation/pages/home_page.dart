import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // Import dart:typed_data for Uint8List
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    // Define the URL of your background image
    final backgroundImageUrl = 'web/5.jpg';

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(194, 196, 2, 44), // Set app bar background color
        title: Text(
          "EventZoom",
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white, // Set icon color to white
            ),
            onPressed: () {
              // Add notifications functionality here
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white, // Set icon color to white
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white, // Set icon color to white
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEventPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(194, 196, 2,
                    44), // Set the drawer header background color to purple
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
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            // Set the background image using NetworkImage
            image: DecorationImage(
              image: NetworkImage(backgroundImageUrl),
              fit: BoxFit.cover, // Adjust this as needed
            ),
          ),
        ),
        // Semi-transparent overlay
        Container(
          color: Colors.black.withOpacity(0.6), // Adjust opacity as needed
        ),
        StreamBuilder(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final events = snapshot.data!.docs;

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index].data() as Map<String, dynamic>;
                  final title = event['EventTitle'] ?? '';
                  final date = event['EventDate'] != null
                      ? (event['EventDate'] as Timestamp).toDate()
                      : DateTime.now();
                  final imageUrls = event['EventImages'] ?? [];

                  return Card(
                    margin: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (imageUrls.isNotEmpty)
                          Image.network(
                            imageUrls[0], // Display the first image
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('MMMM d, y HH:mm')
                                    .format(date), // Format the date with time
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ]),
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
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        backgroundColor: Color.fromARGB(194, 196, 2, 44),
      ),
      body: Center(
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
                color: Color.fromARGB(194, 196, 2, 44),
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
                primary: Color.fromARGB(194, 196, 2, 44), // Button color
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
  int _selectedHour = 0;
  int _selectedMinute = 0;
  bool _isAM = true;
  List<String> _imageUrls = [];
  List<Uint8List> _imageBytes = [];
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Event",
          style: TextStyle(
            color: Colors.white, // Set text color to purple
          ),
        ),
        backgroundColor: Color.fromARGB(
            194, 196, 2, 44), // Set the app bar background color to purple
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: const Color.fromARGB(255, 255, 255, 255), // Button color
            ),
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
              decoration: InputDecoration(
                labelText: "Event Title",
                labelStyle: TextStyle(
                  color: Color.fromARGB(194, 196, 2, 44), // Button color,
                ),
              ),
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
              style: TextButton.styleFrom(
                primary: Color.fromARGB(194, 196, 2, 44), // Button color,
              ),
              child: Text("Select Date"),
            ),
            Text(
              "Selected Date: ${DateFormat('yyyy MM dd').format(_selectedDate)}",
              style: TextStyle(
                color: Color.fromARGB(194, 196, 2, 44), // Button color,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                DropdownButton<int>(
                  value: _selectedHour,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedHour = newValue!;
                    });
                  },
                  items: List.generate(12, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text('$index'),
                    );
                  }),
                ),
                DropdownButton<String>(
                  value: _isAM ? 'AM' : 'PM',
                  onChanged: (String? newValue) {
                    setState(() {
                      _isAM = newValue == 'AM';
                    });
                  },
                  items: ['AM', 'PM'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            DropdownButton<int>(
              value: _selectedMinute,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedMinute = newValue!;
                });
              },
              items: List.generate(60, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text('$index'),
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _pickImage();
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(194, 196, 2, 44), // Button color,
              ),
              child: Text(
                "Add Image",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            _buildImagePreview(),
          ],
        ),
      ),
    );
  }

  // Function to pick an image from the device
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        // Add the selected image data as Uint8List
        _imageBytes.add(Uint8List.fromList(bytes));
      });
    }
  }

  // Function to build a preview of selected images
  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _imageBytes.map((bytes) {
        return Image.memory(
          bytes,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        );
      }).toList(),
    );
  }

  void _addEventToFirebase() async {
    final title = _titleController.text;
    final date = _selectedDate
        .add(Duration(hours: _selectedHour, minutes: _selectedMinute));

    final List<String> imageBase64List = _imageBytes
        .map((bytes) => base64Encode(bytes))
        .toList(); // Convert Uint8List images to base64 strings

    final eventData = {
      'EventTitle': title,
      'EventDate': date,
      'EventImages':
          imageBase64List, // Store base64-encoded strings in Firestore
    };

    // Add the event data to the "events" collection in Firestore
    await FirebaseFirestore.instance.collection('events').add(eventData);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
