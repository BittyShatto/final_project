import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CalllogApp extends StatelessWidget {
  get DateFormat => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Log Access',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21)),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Iterable<CallLogEntry>>(
        future: CallLog.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                CallLogEntry entry = snapshot.data!.elementAt(index);

                //check if entry.timestamp is not null before creating DateTime
                DateTime? timestamp = entry.timestamp != null
                    ? DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)
                    : null;

                //Check if timestamp is not null before formatting
                String formattedDateTime = timestamp != null
                    ? DateFormat.yMd().add_Hms().format(timestamp)
                    : 'N/A';

                return ListTile(
                  leading: Icon(Icons.call),
                  title: Text('${entry.name ?? 'Unknown'}:${entry.number}'),
                  subtitle: Text('$formattedDateTime ${entry.duration}seconds'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
