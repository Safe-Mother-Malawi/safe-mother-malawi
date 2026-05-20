import 'package:flutter/material.dart';
import '../../../state/facilities_store.dart';

class FacilityCard extends StatelessWidget {
  final HealthFacility facility;
  final VoidCallback? onTap;

  const FacilityCard({
    Key? key,
    required this.facility,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          facility.facilityName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('District: ${facility.district}'),
            Text('Zone: ${facility.zone}'),
            Text('Region: ${facility.region}'),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(facility.facilityType),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                facility.facilityType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: facility.urbanRural == 'Urban' ? Colors.blue[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                facility.urbanRural,
                style: TextStyle(
                  color: facility.urbanRural == 'Urban' ? Colors.blue[900] : Colors.green[900],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Colors.red;
      case 'health centre':
        return Colors.orange;
      case 'clinic':
        return Colors.blue;
      case 'dispensary':
        return Colors.purple;
      case 'health post':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

