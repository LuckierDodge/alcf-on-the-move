// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  return Activity(
      dimensions: json['dimensions'] == null
          ? null
          : Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
      nodeInfo: (json['nodeinfo'] as Map<String, dynamic>)?.map(
        (k, e) => MapEntry(
            k, e == null ? null : NodeInfo.fromJson(e as Map<String, dynamic>)),
      ),
      queuedJobs: (json['queued'] as List)
          ?.map((e) =>
              e == null ? null : QueuedJob.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      runningJobs: (json['running'] as List)
          ?.map((e) =>
              e == null ? null : RunningJob.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      reservations: (json['reservation'] as List)
          ?.map((e) => e == null
              ? null
              : Reservation.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      updated: json['updated'] as int,
      maint: json['maint'] as bool);
}

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'dimensions': instance.dimensions,
      'nodeinfo': instance.nodeInfo,
      'queued': instance.queuedJobs,
      'running': instance.runningJobs,
      'reservation': instance.reservations,
      'updated': instance.updated,
      'maint': instance.maint
    };

Dimensions _$DimensionsFromJson(Map<String, dynamic> json) {
  return Dimensions(
      midplanes: json['midplanes'] as int,
      nodecards: json['nodecards'] as int,
      racks: json['racks'] as int,
      rows: json['rows'] as int,
      subdivisions: json['subdivisions'] as int);
}

Map<String, dynamic> _$DimensionsToJson(Dimensions instance) =>
    <String, dynamic>{
      'midplanes': instance.midplanes,
      'nodecards': instance.nodecards,
      'racks': instance.racks,
      'rows': instance.rows,
      'subdivisions': instance.subdivisions
    };

NodeInfo _$NodeInfoFromJson(Map<String, dynamic> json) {
  return NodeInfo(
      id: json['id'] as String,
      state: json['state'] as String,
      color: json['color'] as String,
      jobid: json['jobid'] as int);
}

Map<String, dynamic> _$NodeInfoToJson(NodeInfo instance) => <String, dynamic>{
      'id': instance.id,
      'state': instance.state,
      'color': instance.color,
      'jobid': instance.jobid
    };

QueuedJob _$QueuedJobFromJson(Map<String, dynamic> json) {
  return QueuedJob(
      jobid: json['jobid'] as int,
      mode: json['mode'] as String,
      nodes: json['nodes'] as int,
      project: json['project'] as String,
      queue: json['queue'] as String,
      queuedtimef: json['queuedtimef'] as String,
      score: (json['score'] as num)?.toDouble(),
      starttime: json['starttime'] as String,
      state: json['state'] as String,
      submittime: (json['submittime'] as num)?.toDouble(),
      walltime: json['walltime'] as int,
      walltimef: json['walltimef'] as String);
}

Map<String, dynamic> _$QueuedJobToJson(QueuedJob instance) => <String, dynamic>{
      'jobid': instance.jobid,
      'mode': instance.mode,
      'nodes': instance.nodes,
      'project': instance.project,
      'queue': instance.queue,
      'queuedtimef': instance.queuedtimef,
      'score': instance.score,
      'starttime': instance.starttime,
      'state': instance.state,
      'submittime': instance.submittime,
      'walltime': instance.walltime,
      'walltimef': instance.walltimef
    };

RunningJob _$RunningJobFromJson(Map<String, dynamic> json) {
  return RunningJob(
      json['color'] as String,
      json['jobid'] as int,
      json['mode'] as String,
      json['nodes'] as int,
      json['project'] as String,
      json['queue'] as String,
      json['runtimef'] as String,
      json['starttime'] as String,
      json['state'] as String,
      (json['submittime'] as num)?.toDouble(),
      json['walltime'] as int,
      json['walltimef'] as String);
}

Map<String, dynamic> _$RunningJobToJson(RunningJob instance) =>
    <String, dynamic>{
      'color': instance.color,
      'jobid': instance.jobid,
      'mode': instance.mode,
      'nodes': instance.nodes,
      'project': instance.project,
      'queue': instance.queue,
      'runtimef': instance.runtimef,
      'starttime': instance.starttime,
      'state': instance.state,
      'submittime': instance.submittime,
      'walltime': instance.walltime,
      'walltimef': instance.walltimef
    };

Reservation _$ReservationFromJson(Map<String, dynamic> json) {
  return Reservation(
      duration: json['duration'] as int,
      durationf: json['durationf'] as String,
      name: json['name'] as String,
      queue: json['queue'] as String,
      start: (json['start'] as num)?.toDouble(),
      startf: json['startf'] as String,
      tminus: json['tminus'] as String);
}

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'durationf': instance.durationf,
      'name': instance.name,
      'queue': instance.queue,
      'start': instance.start,
      'startf': instance.startf,
      'tminus': instance.tminus
    };
