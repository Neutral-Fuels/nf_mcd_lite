class RocCollectionModel {
  List<dynamic> containers;
  List<dynamic> emptyROCsSupplied;
  double latitude;
  double longitude;
  String truckrego;
  String storeid;
  String supervisorname;
  String verifycode;
  int supervisorid;
  int ucoreceiptnumber = 0;
  String datetimeofcollection;

  RocCollectionModel(
      {this.containers,
      this.datetimeofcollection,
      this.emptyROCsSupplied,
      this.storeid,
      this.supervisorid,
      this.supervisorname,
      this.truckrego,
      this.latitude,
      this.longitude,
      this.verifycode});

  Map<String, dynamic> toJson() => {
        'containers': containers,
        'emptyROCsSupplied': emptyROCsSupplied,
        'storeid': storeid,
        'ucoreceiptnumber': ucoreceiptnumber,
        'datetimeofcollection': datetimeofcollection,
        'supervisorid': supervisorid,
        'supervisorname': supervisorname,
        'truckrego': truckrego,
        'latitude': latitude,
        'longitude': longitude,
        'verifycode': verifycode,
      };
}
