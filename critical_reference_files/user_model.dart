class NFUserModel {
  final dynamic accessToken;
  final dynamic tokenType;
  final dynamic expiresIn;
  final dynamic id;
  final dynamic username;
  final dynamic email;
  final dynamic licenseNo;
  final dynamic firstName;
  final dynamic lastName;
  final dynamic isMcDUser;
  final dynamic customerId;
  final dynamic customerName;
  final dynamic countryId;
  final dynamic countryIso;
  final dynamic siteId;
  final dynamic timeZoneName;
  final dynamic customerHasTruck;
  final dynamic isthirdpartyuser;

  NFUserModel({
    this.accessToken,
    this.countryId,
    this.countryIso,
    this.customerHasTruck,
    this.customerId,
    this.customerName,
    this.email,
    this.expiresIn,
    this.firstName,
    this.id,
    this.isMcDUser,
    this.lastName,
    this.licenseNo,
    this.siteId,
    this.timeZoneName,
    this.tokenType,
    this.username,
    this.isthirdpartyuser,
  });

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'countryId': countryId,
        'countryIso': countryIso,
        'customerHasTruck': customerHasTruck,
        'customerId': customerId,
        'customerName': customerName,
        'email': email,
        'expiresIn': expiresIn,
        'firstName': firstName,
        'id': id,
        'isMcDUser': isMcDUser,
        'lastName': lastName,
        'licenseNo': licenseNo,
        'siteId': siteId,
        'timeZoneName': timeZoneName,
        'tokenType': tokenType,
        'username': username,
        'isthirdpartyuser': isthirdpartyuser,
      };

  factory NFUserModel.fromJson(Map<String, dynamic> json) {
    return NFUserModel(
      accessToken: json['access_token'].toString(),
      tokenType: json['token_type'].toString(),
      expiresIn: json['expires_in'].toString(),
      id: json['id'].toString(),
      username: json['username'].toString(),
      email: json['email'].toString(),
      licenseNo: json['licenseno'].toString(),
      firstName: json['firstname'].toString(),
      lastName: json['lastname'].toString(),
      isMcDUser: json['ismcduser'],
      customerId: json['customerid'].toString(),
      customerName: json['customername'].toString(),
      countryId: json['countryid'].toString(),
      countryIso: json['countryiso'].toString(),
      siteId: json['siteid'].toString(),
      timeZoneName: json['timezonename'].toString(),
      customerHasTruck: json['customerhastrucks'],
      isthirdpartyuser: json['isthirdpartyuser'],
    );
  }
}
