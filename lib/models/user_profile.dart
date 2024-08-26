class UserProfile {
  String? uid, name, pfpURL;
  UserProfile({
    required this.name,
    required this.uid,
    required this.pfpURL,
  });
  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['uid'] = uid;
    data['pfpURL'] = pfpURL;
    return data;
  }
}
