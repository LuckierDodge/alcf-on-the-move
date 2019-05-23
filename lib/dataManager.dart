import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'dataManager.g.dart';

@JsonSerializable()
class Activity {
  final Dimensions dimensions;
  final List<NodeInfo> nodeInfo;
  final List<QueuedJob> queuedJobs;
  final List<RunningJob> runningJobs;
  final List<Reservation> reservations;
  final int updated;

  Activity({this.dimensions, this.nodeInfo, this.queuedJobs, this.runningJobs, this.reservations, this.updated});

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
}

@JsonSerializable()
class Dimensions {
  final int midplanes;
  final int nodecards;
  final int racks;
  final int rows;
  final int subdivisions;

  Dimensions({this.midplanes, this.nodecards, this.racks, this.rows, this.subdivisions});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      midplanes: json['midplanes'],
      nodecards: json['nodecards'],
      racks: json['racks'],
      rows: json['rows'],
      subdivisions: json['subdivisions'],
    );
  }
}

@JsonSerializable
class NodeInfo {
  String id;
  String state;
  String color;
  String jobid;

  NodeInfo({this.id, this.state, this.color, this.jobid});

  factory NodeInfo.fromJson(Map<String, dynamic> json) => _$NodeInfoFromJson(json);
}

@JsonSerializable()
class QueuedJob {
  num jobid;
  String mode;
  num nodes;
  String project;
  String queue;
  String queuedtimef;
  num score;
  String starttime;
  String state;
  num submittime;
  num walltime;
  String walltimef;

  QueuedJob({this.jobid, this.mode, this.nodes, this.project, this.queue,
      this.queuedtimef, this.score, this.starttime, this.state, this.submittime,
      this.walltime, this.walltimef});

  factory QueuedJob.fromJson(Map<String, dynamic> json) => _$QueuedJobFromJson(json);
}

@JsonSerializable()
class RunningJob {
  String color;
  num jobid;
  List<String> location;
  String mode;
  num nodes;
  String project;
  String queue;
  String runtimef;
  String starttime;
  String state;
  num submittime;
  num walltime;
  String walltimef;


  RunningJob(this.color, this.jobid, this.location, this.mode, this.nodes,
      this.project, this.queue, this.runtimef, this.starttime, this.state,
      this.submittime, this.walltime, this.walltimef);

  factory RunningJob.fromJson(Map<String, dynamic> json) => _$RunningJobFromJson(json);
}

@JsonSerializable
class Reservation {
  num duration;
  String durationf;
  String name;
  String queue;
  num start;
  String startf;
  String tminus;

  Reservation({this.duration, this.durationf, this.name, this.queue, this.start,
    this.startf, this.tminus});

  factory Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);
}




class DataManager {
  Future<http.Response> fetchActivity(String machine) {
    return http.get('http://status.alcf.anl.gov/$machine/activity.json');
  }

}