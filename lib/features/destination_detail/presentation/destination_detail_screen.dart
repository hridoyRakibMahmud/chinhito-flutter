import 'package:flutter/material.dart';

/// Placeholder — full destination detail wiring lands in step 3.
class DestinationDetailScreen extends StatelessWidget {
  const DestinationDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(slug)),
      body: Center(child: Text('Destination detail for "$slug" — coming in step 3')),
    );
  }
}
