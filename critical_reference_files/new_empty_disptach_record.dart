class EmptyDespatchRecordModel {
  List<dynamic> containers;
  String userid;
  String datetimeofdespatch;
  String siteid;
  int staffid;
  String truckrego;
  String comments;

  EmptyDespatchRecordModel({
    this.containers,
    this.comments,
    this.datetimeofdespatch,
    this.siteid,
    this.staffid,
    this.truckrego,
    this.userid,
  });

  Map<String, dynamic> toJson() => {
        'containers': containers,
        'userid': userid,
        'datetimeofdespatch': datetimeofdespatch,
        'siteid': siteid,
        'staffid': staffid,
        'truckrego': truckrego,
        'comments': comments,
      };
}
