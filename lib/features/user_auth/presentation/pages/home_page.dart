import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userRole = ''; // Store the user's role

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // Fetch the user's role when the page loads
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userRole = userData.data()?['role'] ??
          ''; // Fetch the user's role from Firestore
      setState(() {
        _userRole = userRole;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundImageUrl = 'web/5.jpg';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(194, 196, 2, 44),
        title: Text(
          "EventZoom",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              // Add notifications functionality here
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          if (_userRole == 'Event Owner')
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
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
                color: Color.fromARGB(194, 196, 2, 44),
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
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            if (_userRole == 'Event Owner')
              ListTile(
                leading: Icon(Icons.event),
                title: Text(
                  "Add Event",
                  style: TextStyle(
                    color: Colors.black,
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
                  color: Colors.black,
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(backgroundImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final events = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final eventDoc = events[index];
                    final eventId = eventDoc.id;
                    final event = eventDoc.data() as Map<String, dynamic>;
                    final title = event['EventTitle'] ?? '';
                    final date = event['EventDate'] != null
                        ? (event['EventDate'] as Timestamp).toDate()
                        : DateTime.now();
                    final imageUrl = event['EventImage'];
                    final likes = event['likes'] ?? 0;
                    final ownerId = event['ownerId'];

                    if (_userRole == 'Event Owner') {
                      final currentUserUid =
                          FirebaseAuth.instance.currentUser?.uid;
                      // Check if the event's owner is the current user
                      if (currentUserUid == ownerId) {
                        return EventCard(
                          eventId: eventId,
                          imageUrl: imageUrl,
                          title: title,
                          date: date,
                          userRole: _userRole,
                          likes: likes,
                        );
                      } else {
                        // If the user is an event owner but not the owner of this event, return an empty container
                        return Container();
                      }
                    } else {
                      // For simple users, display all events
                      return EventCard(
                        eventId: eventId,
                        imageUrl: imageUrl,
                        title: title,
                        date: date,
                        userRole: _userRole,
                        likes: likes,
                      );
                    }
                  },
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final String eventId;
  final String imageUrl;
  final String title;
  final DateTime date;
  final String userRole;
  final int likes;

  EventCard({
    required this.eventId,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.userRole,
    required this.likes,
  });

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  int likes = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _fetchEventLikes();
  }

  Future<void> _fetchEventLikes() async {
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
    final eventData = eventDoc.data();
    if (eventData != null) {
      setState(() {
        likes = eventData['likes'] ?? 0;
        // Check if the current user has liked the event
        if (eventData['likedBy'] != null) {
          final likedBy = List<String>.from(eventData['likedBy']);
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && likedBy.contains(user.uid)) {
            isLiked = true;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.imageUrl != null)
            Image.network(
              widget.imageUrl,
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
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMMM d, y HH:mm').format(widget.date),
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                if (widget.userRole != 'Event Owner')
                  LikeButtons(
                    likes: likes,
                    isLiked: isLiked,
                    onLike: _toggleLike,
                  ),
                if (widget.userRole ==
                    'Event Owner') // Display likes for Event Owners
                  Text(
                    '${likes} Likes',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userUid = user.uid;

      if (isLiked) {
        // If the user has already liked the event, remove their like
        setState(() {
          isLiked = false;
          likes--;
        });

        // Update the 'likedBy' array in Firestore to remove the user's ID
        FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          'likes': likes,
          'likedBy': FieldValue.arrayRemove([userUid]),
        });
      } else {
        // If the user hasn't liked the event, add their like
        setState(() {
          isLiked = true;
          likes++;
        });

        // Update the 'likedBy' array in Firestore to add the user's ID
        FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          'likes': likes,
          'likedBy': FieldValue.arrayUnion([userUid]),
        });
      }
    }
  }
}

class LikeButtons extends StatefulWidget {
  final int likes;
  final bool isLiked;
  final VoidCallback onLike;

  LikeButtons({
    required this.likes,
    required this.isLiked,
    required this.onLike,
  });

  @override
  _LikeButtonsState createState() => _LikeButtonsState();
}

class _LikeButtonsState extends State<LikeButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            widget.isLiked ? Icons.favorite : Icons.favorite_border,
            color: widget.isLiked ? Colors.red : Colors.black,
          ),
          onPressed: widget.onLike,
        ),
        Text('${widget.likes} Likes'),
      ],
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
                primary: Color.fromARGB(194, 196, 2, 44),
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
  List<Uint8List> _imageBytes = [];
  final picker = ImagePicker(); // Define the ImagePicker here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Event",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(194, 196, 2, 44),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: const Color.fromARGB(255, 255, 255, 255),
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
                  color: Color.fromARGB(194, 196, 2, 44),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime
                      .now(), // Set the minimum selectable date to the current date
                  lastDate: DateTime(2025),
                );

                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                }
              },
              style: TextButton.styleFrom(
                primary: Color.fromARGB(194, 196, 2, 44),
              ),
              child: Text("Select Date"),
            ),
            Text(
              "Selected Date: ${DateFormat('yyyy MM dd').format(_selectedDate)}",
              style: TextStyle(
                color: Color.fromARGB(194, 196, 2, 44),
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
                primary: Color.fromARGB(194, 196, 2, 44),
              ),
              child: Text(
                "Add Image",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold, // Valid 'FontWeight'
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes.add(Uint8List.fromList(bytes));
      });
    }
  }

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
    final date = _selectedDate.add(Duration(
        hours: _selectedHour + (_isAM ? 0 : 12), minutes: _selectedMinute));

    // Generate a unique ID for the event
    final eventId = FirebaseFirestore.instance.collection('events').doc().id;

    // Reference to the Firebase Storage bucket
    final storageReference =
        FirebaseStorage.instance.ref().child('event_images/$eventId.jpg');

    try {
      // Upload the image to Firebase Storage
      await storageReference.putData(_imageBytes[0]);

      // Get the download URL of the uploaded image
      final imageUrl = await storageReference.getDownloadURL();

      final eventData = {
        'EventTitle': title,
        'EventDate': date, // Store the event date as a Timestamp
        'EventImage': imageUrl, // Store the image URL
        'ownerId':
            FirebaseAuth.instance.currentUser?.uid, // Set the event owner's ID
      };

      // Save event details to Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .set(eventData);

      Navigator.pop(context); // Close the AddEventPage
    } catch (e) {
      // Handle errors here
      print('Error uploading image: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
