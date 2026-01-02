class RcoDeliveryModel {
  final List<dynamic> containers;
  final String userid;
  final String datetimeofdelivery;
  final String truckrego;
  final int staffid;
  final String comments;

  RcoDeliveryModel({
    this.containers,
    this.comments,
    this.datetimeofdelivery,
    this.staffid,
    this.truckrego,
    this.userid,
  });

  Map<String, dynamic> toJson() => {
        'containers': containers,
        'comments': comments,
        'datetimeofdelivery': datetimeofdelivery,
        'staffid': staffid,
        'truckrego': truckrego,
        'userid': userid,
      };
}
