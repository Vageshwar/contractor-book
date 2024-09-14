import 'package:contractor_book/screens/add_site.dart';
import 'package:contractor_book/screens/profile_tab.dart';
import 'package:contractor_book/screens/site_details_page.dart';
import 'package:contractor_book/services/db_service.dart';
import 'package:contractor_book/widgets/search_bar.dart';
import 'package:contractor_book/widgets/site_list.dart';
import 'package:flutter/material.dart';
import 'package:contractor_book/models/sites.dart';
import 'package:contractor_book/models/contractor.dart';
import 'package:shimmer/shimmer.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSites();
    currentContractor = _databaseService.getCurrentUser();
  }

  Future<void> fetchSites() async {
    setState(() {
      isLoading = true; // Start loading
    });
    List<Sites> archived = await _databaseService.getSitesWithState(0);
    List<Sites> active = await _databaseService.getSitesWithState(1);

    setState(() {
      _filteredArchivedSites = archived;
      _filteredActiveSites = active;
      isLoading = false;
    });
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Show 5 shimmer items as a placeholder
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
        },
      ),
    );
  }

  // Use `await` to wait for the result from AddSitePage
  Future<void> _navigateToAddSite() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSitePage()),
    );

    if (result == true) {
      // Refresh site list after adding a new site
      await fetchSites();
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _searchSites(String query, bool isActive) {
    setState(() {
      List<Sites> filteredSites =
          isActive ? _filteredActiveSites : _filteredArchivedSites;
      filteredSites = filteredSites.where((site) {
        return site.name.toLowerCase().contains(query.toLowerCase()) ||
            site.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
      if (isActive) {
        _filteredActiveSites = filteredSites;
      } else {
        _filteredArchivedSites = filteredSites;
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
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 1)
          ? FloatingActionButton(
              onPressed: _navigateToAddSite, // Navigate and wait for result
              child: const Icon(Icons.add_circle_outline, size: 30),
              backgroundColor: Colors.white, // Minimalist white background
              foregroundColor: Colors.blueAccent, // Blue icon for intuitiveness
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15), // Rounded, modern shape
              ),
              elevation: 5, // Slight shadow for a floating effect
            )
          : null, // No FAB on the "Profile" tab
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

  Future<void> _navigateToSiteDetails(Sites site) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SiteDetailsPage(site: site)),
    );

    // If result is true, refresh the site list
    if (result == true) {
      await fetchSites();
    }
  }

  Widget _buildArchivedSitesTab() {
    if (isLoading) {
      return _buildLoadingShimmer(); // Show shimmer while loading
    }
    return _filteredArchivedSites.isEmpty
        ? _buildEmptyState('No Archived Sites', Icons.archive_outlined)
        : Column(
            children: [
              MySearchBar(
                  controller: _searchController,
                  isActive: false,
                  onSearch: _searchSites),
              Expanded(
                  child: SiteList(
                sites: _filteredArchivedSites,
                isActive: false,
                onTapSite: _navigateToSiteDetails,
              )),
            ],
          );
  }

  Widget _buildActiveSitesTab() {
    if (isLoading) {
      return _buildLoadingShimmer(); // Show shimmer while loading
    }
    return _filteredActiveSites.isEmpty
        ? _buildEmptyState('No Active Sites', Icons.construction_outlined,
            showAddButton: true)
        : Column(
            children: [
              MySearchBar(
                  controller: _searchController,
                  isActive: true,
                  onSearch: _searchSites),
              Expanded(
                  child: SiteList(
                sites: _filteredActiveSites,
                isActive: true,
                onTapSite: _navigateToSiteDetails,
              )),
            ],
          );
  }

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
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Expanded(
              child: ProfileTab(),
            ),
          );
        }
      },
    );
  }

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

  Widget _buildEmptyState(String message, IconData icon,
      {bool showAddButton = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(fontSize: 18, color: Colors.red)),
          if (showAddButton)
            ElevatedButton(
              onPressed: _navigateToAddSite,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text('+ Add New Site'),
            ),
        ],
      ),
    );
  }
}
