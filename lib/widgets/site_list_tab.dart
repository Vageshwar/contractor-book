// import 'package:flutter/material.dart';
// import 'package:contractor_book/models/sites.dart';
// import 'package:contractor_book/services/db_service.dart';
// import 'package:contractor_book/widgets/search_bar.dart';
// import 'package:contractor_book/widgets/site_card.dart';

// class SiteListTab extends StatefulWidget {
//   final bool isActive;
//   final DatabaseService dbService;

//   const SiteListTab({Key? key, required this.isActive, required this.dbService}) : super(key: key);

//   @override
//   _SiteListTabState createState() => _SiteListTabState();
// }

// class _SiteListTabState extends State<SiteListTab> {
//   late Future<List<Sites>> _siteList;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSites();
//   }

//   void _fetchSites() {
//     _siteList = widget.isActive ? widget.dbService.getSitesWithState(1) : widget.dbService.getSitesWithState(0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Sites>>(
//       future: _siteList,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildEmptyState();
//         } else {
//           return Column(
//             children: [
//               SearchBar(isActive: widget.isActive),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     return SiteCard(site: snapshot.data![index]);
//                   },
//                 ),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(widget.isActive ? Icons.construction_outlined : Icons.archive_outlined, size: 100),
//           const SizedBox(height: 10),
//           Text(widget.isActive ? 'No Active Sites' : 'No Archived Sites', style: const TextStyle(fontSize: 18, color: Colors.red)),
//         ],
//       ),
//     );
//   }
// }
