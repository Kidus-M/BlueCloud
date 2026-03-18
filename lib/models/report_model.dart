import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? id;
  final String createdBy;
  final String createdByName;
  final String incidentType;
  final DateTime date;
  final String time;
  final String district;
  final String location;
  final String arrestMade;
  final String suspectName;
  final String suspectRaceSex;
  final String suspectDOB;
  final String suspectVehicle;
  final String weapons;
  final String victimName;
  final String victimRaceSex;
  final String victimDOB;
  final String victimInjuriesStatus;
  final String propertyLossDamage;
  final String gangRelated;
  final String csnPreparedBy;
  final String caseNumber;
  final String synopsis;
  final Timestamp? timestamp;

  ReportModel({
    this.id,
    required this.createdBy,
    required this.createdByName,
    required this.incidentType,
    required this.date,
    required this.time,
    required this.district,
    required this.location,
    required this.arrestMade,
    required this.suspectName,
    required this.suspectRaceSex,
    required this.suspectDOB,
    required this.suspectVehicle,
    required this.weapons,
    required this.victimName,
    required this.victimRaceSex,
    required this.victimDOB,
    required this.victimInjuriesStatus,
    required this.propertyLossDamage,
    required this.gangRelated,
    required this.csnPreparedBy,
    required this.caseNumber,
    required this.synopsis,
    this.timestamp,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      incidentType: map['incidentType'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      district: map['district'] ?? '',
      location: map['location'] ?? '',
      arrestMade: map['arrestMade'] ?? '',
      suspectName: map['suspectName'] ?? '',
      suspectRaceSex: map['suspectRaceSex'] ?? '',
      suspectDOB: map['suspectDOB'] ?? '',
      suspectVehicle: map['suspectVehicle'] ?? '',
      weapons: map['weapons'] ?? '',
      victimName: map['victimName'] ?? '',
      victimRaceSex: map['victimRaceSex'] ?? '',
      victimDOB: map['victimDOB'] ?? '',
      victimInjuriesStatus: map['victimInjuriesStatus'] ?? '',
      propertyLossDamage: map['propertyLossDamage'] ?? '',
      gangRelated: map['gangRelated'] ?? '',
      csnPreparedBy: map['csnPreparedBy'] ?? '',
      caseNumber: map['caseNumber'] ?? '',
      synopsis: map['synopsis'] ?? '',
      timestamp: map['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdByName': createdByName,
      'incidentType': incidentType,
      'date': Timestamp.fromDate(date),
      'time': time,
      'district': district,
      'location': location,
      'arrestMade': arrestMade,
      'suspectName': suspectName,
      'suspectRaceSex': suspectRaceSex,
      'suspectDOB': suspectDOB,
      'suspectVehicle': suspectVehicle,
      'weapons': weapons,
      'victimName': victimName,
      'victimRaceSex': victimRaceSex,
      'victimDOB': victimDOB,
      'victimInjuriesStatus': victimInjuriesStatus,
      'propertyLossDamage': propertyLossDamage,
      'gangRelated': gangRelated,
      'csnPreparedBy': csnPreparedBy,
      'caseNumber': caseNumber,
      'synopsis': synopsis,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }

  String get formattedDate {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
