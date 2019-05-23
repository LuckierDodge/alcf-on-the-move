import 'package:http/http.dart' as http;
import 'dart:convert';


class Activity {
  final Dimensions dimensions;
  final Set<NodeInfo> nodeInfo;
  final Set<QueuedJob> queuedJobs;
  final Set<RunningJob> runningJobs;
  final Set<Reservation> reservations;
  final int updated;

  Activity({this.dimensions, this.nodeInfo, this.queuedJobs, this.runningJobs, this.reservations, this.updated});

  factory Activity.fromJson(Map<String, dynamic> json) {
    Set<NodeInfo> nodeInfo;
    Set<QueuedJob> queuedJobs;
    Set<RunningJob> runningJobs;
    Set<Reservation> reservations;

    Map<String, dynamic> nodeInfoMap = jsonDecode(json['nodeinfo']);
    nodeInfoMap.forEach((id, node) => {
      nodeInfo.add(NodeInfo(id, node));
    });

    Map<String, dynamic> queuedJobsMap = jsonDecode(json['queued']);
    queuedJobsMap.forEach((id, job) => {
      queuedJobs.add(QueuedJob(id, node));
    });

    Map<String, dynamic> runningJobsMap = jsonDecode(json['running']);
    runningJobsMap.forEach((id, job) => {
      runningJobs.add(RunningJob(id, node));
    });

    Map<String, dynamic> reservationMap = jsonDecode(json['running']);
    reservationMap.forEach((id, reservation) => {
      reservations.add(Reservation(id, reservation));
    });

    return Activity(
      dimensions: Dimensions(json['dimensions']),
      nodeInfo: nodeInfo,
      queuedJobs: queuedJobs,
      runningJobs: runningJobs,
      reservations: reservations,
      updated: json['updated'],
    );
  }
}

class Dimensions {

}

class NodeInfo {

}

class QueuedJob {

}

class RunningJob {

}

class Reservation {

}


class DataManager {
  Future<http.Response> fetchActivity(String machine) {
    return http.get('http://status.alcf.anl.gov/$machine/activity.json');
  }

}