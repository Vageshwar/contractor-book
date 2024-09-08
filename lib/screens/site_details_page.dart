import 'package:contractor_book/models/site_note.dart';
import 'package:flutter/material.dart';
import 'package:contractor_book/models/sites.dart';
import 'package:contractor_book/services/db_service.dart';
import 'package:intl/intl.dart'; // For formatting dates

class SiteDetailsPage extends StatefulWidget {
  final Sites site;

  const SiteDetailsPage({Key? key, required this.site}) : super(key: key);

  @override
  _SiteDetailsPageState createState() => _SiteDetailsPageState();
}

class _SiteDetailsPageState extends State<SiteDetailsPage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _noteController = TextEditingController();
  late Future<List<Note>> _siteNotes;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _fetchNotes() {
    _siteNotes = _databaseService.getNotesForSite(widget.site.siteId);
  }

  void _addNote() async {
    if (_noteController.text.isNotEmpty) {
      await _databaseService.addNoteForSite(
          widget.site.siteId, _noteController.text);
      _noteController.clear();
      setState(() {
        _fetchNotes(); // Refresh notes list
      });
    }
  }

  void _archiveSite() async {
    await _databaseService.updateSiteStatus(
        widget.site.siteId, 0); // Set is_active to 0
    Navigator.pop(context); // Go back to previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.site.name),
        actions: [
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
              _archiveSite();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSiteDetailsSection(),
            const SizedBox(height: 20),
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteDetailsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Site Name', widget.site.name),
            _buildDetailRow('Location', widget.site.location),
            _buildDetailRow('Owner ID', widget.site.ownerName.toString()),
            _buildDetailRow(
                'Date Created',
                DateFormat('yyyy-MM-dd').format(
                    DateTime.fromMillisecondsSinceEpoch(widget.site.date))),
            _buildDetailRow(
                'Is Active', widget.site.active == 1 ? 'Yes' : 'No'),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildAddNoteField(),
        const SizedBox(height: 10),
        FutureBuilder<List<Note>>(
          future: _siteNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No notes available.'));
            } else {
              List<Note> notes = snapshot.data!;
              notes.sort(
                  (a, b) => b.dateAdded.compareTo(a.dateAdded)); // Sort by date

              return _buildNotesTable(notes);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAddNoteField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'Enter note',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _addNote,
          child: const Text('Add Note'),
        ),
      ],
    );
  }

  Widget _buildNotesTable(List<Note> notes) {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
      },
      children: [
        _buildNotesTableHeader(),
        ...notes.map((note) => _buildNotesTableRow(note)).toList(),
      ],
    );
  }

  TableRow _buildNotesTableHeader() {
    return TableRow(
      children: [
        _buildTableHeader('Date'),
        _buildTableHeader('Note'),
      ],
    );
  }

  TableRow _buildNotesTableRow(Note note) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(DateFormat('yyyy-MM-dd').format(note.dateAdded)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(note.content),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
