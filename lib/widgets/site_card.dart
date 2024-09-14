import 'package:flutter/material.dart';
import 'package:contractor_book/models/sites.dart';
import 'package:contractor_book/screens/site_details_page.dart';

class SiteCard extends StatelessWidget {
  final Sites site;

  const SiteCard({Key? key, required this.site}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.place),
        title: Text(site.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(site.location),
            Text('Owner: ${site.ownerName}'),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SiteDetailsPage(site: site)),
          );
        },
      ),
    );
  }
}
