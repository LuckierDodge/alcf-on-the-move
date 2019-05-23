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

  factory Activity.fromJson(Map<String, dynamic> json) {
    Set<NodeInfo> nodeInfo;
    Set<QueuedJob> queuedJobs;
    Set<RunningJob> runningJobs;
    Set<Reservation> reservations;

    Map<String, dynamic> nodeInfoMap = jsonDecode(json['nodeinfo']);
    nodeInfoMap.forEach((id, node) => nodeInfo.add(NodeInfo(id, node)));

    Map<String, dynamic> queuedJobsMap = jsonDecode(json['queued']);
    queuedJobsMap.forEach((id, job) => queuedJobs.add(QueuedJob.fromJson(job)));

    Map<String, dynamic> runningJobsMap = jsonDecode(json['running']);
    runningJobsMap.forEach((id, job) => runningJobs.add(RunningJob.fromJson(node)));

    Map<String, dynamic> reservationMap = jsonDecode(json['running']);
    reservationMap.forEach((id, reservation) => reservations.add(Reservation.fromJson(reservation)));

    return Activity(
      dimensions: Dimensions.fromJson(json['dimensions']),
      nodeInfo: nodeInfo,
      queuedJobs: queuedJobs,
      runningJobs: runningJobs,
      reservations: reservations,
      updated: json['updated'],
    );
  }
}

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

class NodeInfo {
  String id;
  String state;
  String color;
  String jobid;

  //NodeInfo({this.id, this.state, this.color, this.jobid});

  NodeInfo(String id, Map<String, dynamic> node) {
    this.id = id;
    var state = jsonDecode(node['state']);
    state.runtimeType() == String ? this.state = state : this.state = "";
    var color = jsonDecode(node['color']);
    color.runtimeType() == String ? this.color = state : this.color = "";
    var jobid = jsonDecode(node['jobid']);
    jobid.runtimeType() == String ? this.jobid = state : this.jobid = "";
  }
}

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

  factory QueuedJob.fromJson(Map<String, dynamic> json) {
    return QueuedJob(
      jobid: json['jobid'],
      mode: json['mode'],
      nodes: json['nodes'],
      project: json['project'],
      queue: json['queue'],
      queuedtimef: json['queuedtimef'],
      score: json['score'],
      starttime: json['starttime'],
      state: json['state'],
      submittime: json['submittime'],
      walltime: json['walltime'],
      walltimef: json['walltimef'],
    );
  }
}

class RunningJob {
  String color;
  num jobid;


  RunningJob({});

  factory RunningJob.fromJson(Map<String, dynamic> json) {
    return RunningJob(

    );
  }
}

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

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      duration: json['duration'],
      durationf: json['durationf'],
      name: json['name'],
      queue: json['queue'],
      start: json['start'],
      startf: json['startf'],
      tminus: json['tminus'],
    );
  }
}




class DataManager {
  Future<http.Response> fetchActivity(String machine) {
    return http.get('http://status.alcf.anl.gov/$machine/activity.json');
  }

}