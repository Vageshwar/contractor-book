import 'dart:typed_data';
import 'package:contractor_book/screens/add_site.dart';
import 'package:contractor_book/screens/site_details_page.dart';
import 'package:contractor_book/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:contractor_book/models/sites.dart';
import 'package:contractor_book/models/contractor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Default to the "Active" tab
  late Future<List<Sites>> archivedSites;
  late Future<List<Sites>> activeSites;
  late Future<Contractor> currentContractor;
  final DatabaseService _databaseService = DatabaseService();
  List<Sites> _filteredActiveSites = [];
  List<Sites> _filteredArchivedSites = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSites();
    currentContractor = _databaseService.getCurrentUser();
  }

  void fetchSites() {
    // Fetch archived and active sites from the database
    archivedSites = _databaseService.getSitesWithState(0);
    activeSites = _databaseService.getSitesWithState(1);

    print("Active site $activeSites");
    print("Archived site $archivedSites");
    archivedSites.then((sites) {
      setState(() {
        _filteredArchivedSites = sites;
      });
    });

    activeSites.then((sites) {
      print("Site $sites");
      setState(() {
        _filteredActiveSites = sites;
      });
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _searchSites(String query, bool isActive) {
    setState(() {
      if (isActive) {
        _filteredActiveSites = _filteredActiveSites.where((site) {
          return site.name.toLowerCase().contains(query.toLowerCase()) ||
              site.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        _filteredArchivedSites = _filteredArchivedSites.where((site) {
          return site.name.toLowerCase().contains(query.toLowerCase()) ||
              site.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40), // Top padding for content
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildArchivedSitesTab(),
            _buildActiveSitesTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archived',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Archived Sites Tab
  Widget _buildArchivedSitesTab() {
    return FutureBuilder<List<Sites>>(
      future: archivedSites,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No Archived Sites', Icons.archive_outlined);
        } else {
          return Column(
            children: [
              _buildSearchBar(false),
              Expanded(child: _buildSitesList(_filteredArchivedSites, false)),
            ],
          );
        }
      },
    );
  }

  // Active Sites Tab
  Widget _buildActiveSitesTab() {
    return FutureBuilder<List<Sites>>(
      future: activeSites,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
              'No Active Sites', Icons.construction_outlined,
              showAddButton: true);
        } else {
          return Column(
            children: [
              // Search Bar and Add New Site Button
              _buildSearchBar(true),
              Expanded(child: _buildSitesList(_filteredActiveSites, true)),
            ],
          );
        }
      },
    );
  }

  // Profile Tab
  Widget _buildProfileTab() {
    return FutureBuilder<Contractor>(
      future: currentContractor,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Error loading profile data'));
        } else {
          final contractor = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileField('Name', contractor.name),
                _buildProfileField('Address', contractor.address),
                _buildProfileField('City', contractor.city),
                _buildProfileField('Phone', contractor.phone),
                _buildProfileField('Title', contractor.title),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildSitesList(List<Sites> sites, bool isActive) {
    return ListView.builder(
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        return FutureBuilder<List<Uint8List>>(
          future: _databaseService.getSiteImages(site.siteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.image_not_supported),
                  title: Text(site.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(site.location),
                      Text('Owner: ${site.ownerName}'),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Site Details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SiteDetailsPage(site: site),
                      ),
                    );
                  },
                ),
              );
            } else {
              final images = snapshot.data!;
              return Card(
                child: ListTile(
                  leading:
                      Image.memory(images.first), // Display the first image
                  title: Text(site.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(site.location),
                      Text('Owner: ${site.ownerName}'),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Site Details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SiteDetailsPage(site: site),
                      ),
                    );
                  },
                ),
              );
            }
          },
        );
      },
    );
  }

  // Profile Field with Edit option
  Widget _buildProfileField(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(label),
            subtitle: Text(value),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Implement edit logic
          },
        ),
      ],
    );
  }

  // Empty state widget for Archived and Active tabs
  Widget _buildEmptyState(String message, IconData icon,
      {bool showAddButton = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
          if (showAddButton)
            ElevatedButton(
              onPressed: () {
                // Navigate to Add Site page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSitePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Black background
                foregroundColor: Colors.white, // White text
              ),
              child: const Text('+ Add New Site'),
            ),
        ],
      ),
    );
  }

  // Search bar widget
  Widget _buildSearchBar(bool isActive) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search Sites',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          _searchSites(value, isActive);
        },
      ),
    );
  }
}
