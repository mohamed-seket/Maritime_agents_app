import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mission_details.dart';
import 'SettingsPage.dart';
import 'profile.dart';

class MissionDashboard extends StatefulWidget {
  final String token;

  const MissionDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _MissionDashboardState createState() => _MissionDashboardState();
}

class _MissionDashboardState extends State<MissionDashboard> {
  List<Map<String, dynamic>> missions = [];
  List<Map<String, dynamic>> filteredMissions = [];
  bool isLoading = true;
  String searchQuery = "";
  String selectedUrgency = 'All';

  final List<String> urgencyLevels = ['All', 'Low (1-2)', 'Medium (3)', 'High (4)', 'Critical (5)'];

  @override
  void initState() {
    super.initState();
    fetchAssignedMissions();
  }

  Future<void> fetchAssignedMissions() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3030/api/patrols/supervisor/patrols'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        missions = data.expand<Map<String, dynamic>>((patrol) =>
            patrol['assignedMissions'].map<Map<String, dynamic>>((mission) => {
              'title': mission['type'] ?? 'No Title',
              'description': "Urgency: ${mission['niveau']} - ${mission['type']}",
              'detailedDescription': getDetailedDescription(mission),
              'location': '${mission['latitude']}, ${mission['longitude']}',
              'time': mission['createdAt'] ?? 'Unknown Time',
              'priority': mission['niveau'].toString() ?? 'Low',
              'type': mission['type'] ?? 'Unknown',
              'patrolId': patrol['_id'],
            })
        ).toList();
        filterMissions();
      } else {
        print('Failed to load patrols: ${response.body}');
      }
    } catch (e) {
      print('Error fetching patrols: $e');
    }
    setState(() => isLoading = false);
  }

  void filterMissions() {
    List<Map<String, dynamic>> tempMissions = missions.where((mission) {
      return mission['title'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          mission['description'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (selectedUrgency != 'All') {
      int minLevel, maxLevel;
      switch (selectedUrgency) {
        case 'Low (1-2)':
          minLevel = 1;
          maxLevel = 2;
          break;
        case 'Medium (3)':
          minLevel = 3;
          maxLevel = 3;
          break;
        case 'High (4)':
          minLevel = 4;
          maxLevel = 4;
          break;
        case 'Critical (5)':
          minLevel = 5;
          maxLevel = 5;
          break;
        default:
          minLevel = 1;
          maxLevel = 5;
      }
      tempMissions = tempMissions.where((mission) {
        int level = int.tryParse(mission['priority']) ?? 0;
        return level >= minLevel && level <= maxLevel;
      }).toList();
    }

    setState(() {
      filteredMissions = tempMissions;
    });
  }

  String getDetailedDescription(Map<String, dynamic> mission) {
    return "Mission Type: ${mission['type']}\n"
        "Number of People: ${mission['nbrpersonne']}\n"
        "Location: ${mission['latitude']}, ${mission['longitude']}\n"
        "Departure: ${mission['depart']}\n"
        "Size of the boat: ${mission['taille']}\n"
        "Current Status: ${mission['status']}\n"
        "Urgency Level: ${mission['niveau']}\n"
        "Reported On: ${DateTime.parse(mission['createdAt']).toLocal()}\n"
        "This mission requires immediate attention. Please review all details and prepare accordingly.";
  }

  Icon getMissionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'ship collision':
        return Icon(Icons.directions_boat, color: Colors.blue);
      case 'grounding':
        return Icon(Icons.landscape, color: Colors.brown);
      case 'flooding':
        return Icon(Icons.invert_colors, color: Colors.blue);
      case 'fire':
        return Icon(Icons.local_fire_department, color: Colors.red);
      case 'man overboard':
        return Icon(Icons.man, color: Colors.orange);
      case 'machinery failure':
        return Icon(Icons.build, color: Colors.grey);
      case 'piracy and armed attacks':
        return Icon(Icons.security, color: Colors.black);
      case 'medical emergency':
        return Icon(Icons.local_hospital, color: Colors.red);
      case 'search and rescue':
        return Icon(Icons.search, color: Colors.green);
      case 'adverse weather conditions':
        return Icon(Icons.cloud, color: Colors.grey);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Map<String, String> emergencyTypeToImage = {
    'ship collision': 'ship_collision.jpg',
    'grounding': 'grounding.jpg',
    'flooding': 'flooding.jpg',
    'fire': 'fire.jpg',
    'man overboard': 'man_overboard.jpg',
    'Machinery Failure': 'machinery_failure.jpg',
    'piracy and armed attacks': 'piracy.jpg',
    'medical emergency': 'medical_emergency.jpg',
    'search and rescue': 'search_and_rescue.jpg',
    'adverse weather conditions': 'adverse_weather_conditions.jpg',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  filterMissions();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Missions',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: selectedUrgency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUrgency = newValue!;
                  filterMissions();
                });
              },
              items: urgencyLevels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMissions.isEmpty
                    ? const Center(child: Text('No missions found'))
                    : ListView.builder(
                        itemCount: filteredMissions.length,
                        itemBuilder: (context, index) {
                          final mission = filteredMissions[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            color: Colors.lightBlue[50],
                            child: ListTile(
                              leading: getMissionIcon(mission['type']),
                              title: Text(mission['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(mission['description']),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MissionDetails(
                                        title: mission['title'],
                                        description: mission['detailedDescription'],
                                        location: mission['location'],
                                        time: mission['time'],
                                        priority: mission['priority'],
                                        imagePath: emergencyTypeToImage[mission['type']] ?? 'flooding.jpg',
                                        patrolId: mission['patrolId'],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Details'
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(token: widget.token)));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(token: widget.token)));
            break;
        }
      },
      backgroundColor: Colors.lightBlue,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Missions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}