class UserModel {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? idx;
  int? docstatus;
  int? enabled;
  String? email;
  String? firstName;
  String? lastName;
  String? fullName;
  int? sendWelcomeEmail;
  int? unsubscribed;
  String? username;
  String? language;
  int? muteSounds;
  String? newPassword;
  int? logoutAllSessions;
  String? resetPasswordKey;
  int? documentFollowNotify;
  String? documentFollowFrequency;
  int? threadNotify;
  int? sendMeACopy;
  int? allowedInMentions;
  int? simultaneousSessions;
  String? userType;
  String? userImage;
  int? loginAfter;
  int? loginBefore;
  int? bypassRestrictIpCheckIf2faEnabled;
  String? lastLogin;
  String? lastIp;
  String? lastActive;
  String? lastKnownVersions;
  String? apiKey;
  String? apiSecret;
  String? doctype;
  String? phone;
  String? mobile;
  List<Roles>? roles;
  List<BlockModules>? blockModules;
  List<SocialLogins>? socialLogins;

  UserModel(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.idx,
      this.docstatus,
      this.enabled,
      this.email,
      this.firstName,
      this.lastName,
      this.fullName,
      this.sendWelcomeEmail,
      this.unsubscribed,
      this.username,
      this.language,
      this.muteSounds,
      this.newPassword,
      this.logoutAllSessions,
      this.resetPasswordKey,
      this.documentFollowNotify,
      this.documentFollowFrequency,
      this.threadNotify,
      this.sendMeACopy,
      this.allowedInMentions,
      this.simultaneousSessions,
      this.userType,
      this.userImage,
      this.loginAfter,
      this.loginBefore,
      this.bypassRestrictIpCheckIf2faEnabled,
      this.lastLogin,
      this.lastIp,
      this.lastActive,
      this.lastKnownVersions,
      this.apiKey,
      this.apiSecret,
      this.doctype,
      this.roles,
      this.phone,
      this.mobile,
      this.blockModules,
      this.socialLogins});

  UserModel.fromJson(Map<String, dynamic> json) {
    List<Roles>? r = [];
    List<BlockModules>? b = [];

    if (json['roles'] != null) {
      json['roles'].forEach((v) {
        r.add(Roles.fromJson(v));
      });
    }
    if (json['block_modules'] != null) {
      json['block_modules'].forEach((v) {
        b.add( BlockModules.fromJson(v));
      });
    }
    if (json['social_logins'] != null) {
      socialLogins = [];
      json['social_logins'].forEach((v) {
        socialLogins?.add( SocialLogins.fromJson(v));
      });
    }
    roles = r;
    blockModules = b;
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    enabled = json['enabled'];
    phone = json['phone'];
    mobile = json['mobile_no'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    fullName = json['full_name'];
    sendWelcomeEmail = json['send_welcome_email'];
    unsubscribed = json['unsubscribed'];
    username = json['username'];
    userImage = json['user_image'];
    language = json['language'];
    muteSounds = json['mute_sounds'];
    newPassword = json['new_password'];
    logoutAllSessions = json['logout_all_sessions'];
    resetPasswordKey = json['reset_password_key'];
    documentFollowNotify = json['document_follow_notify'];
    documentFollowFrequency = json['document_follow_frequency'];
    threadNotify = json['thread_notify'];
    sendMeACopy = json['send_me_a_copy'];
    allowedInMentions = json['allowed_in_mentions'];
    simultaneousSessions = json['simultaneous_sessions'];
    userType = json['user_type'];
    loginAfter = json['login_after'];
    loginBefore = json['login_before'];
    bypassRestrictIpCheckIf2faEnabled =
        json['bypass_restrict_ip_check_if_2fa_enabled'];
    lastLogin = json['last_login'];
    lastIp = json['last_ip'];
    lastActive = json['last_active'];
    lastKnownVersions = json['last_known_versions'];
    apiKey = json['api_key'];
    apiSecret = json['api_secret'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (roles != null) {
      data['roles'] = roles?.map((v) => v.toJson()).toList();
    }
    if (blockModules != null) {
      data['block_modules'] =
          blockModules?.map((v) => v.toJson()).toList();
    }
    if (socialLogins != null) {
      data['social_logins'] =
          socialLogins?.map((v) => v.toJson()).toList();
    }
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['idx'] = idx;
    data['docstatus'] = docstatus;
    data['enabled'] = enabled;
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['full_name'] = fullName;
    data['send_welcome_email'] = sendWelcomeEmail;
    data['unsubscribed'] = unsubscribed;
    data['username'] = username;
    data['language'] = language;
    data['mute_sounds'] = muteSounds;
    data['new_password'] = newPassword;
    data['logout_all_sessions'] = logoutAllSessions;
    data['reset_password_key'] = resetPasswordKey;
    data['document_follow_notify'] = documentFollowNotify;
    data['document_follow_frequency'] = documentFollowFrequency;
    data['thread_notify'] = threadNotify;
    data['send_me_a_copy'] = sendMeACopy;
    data['allowed_in_mentions'] = allowedInMentions;
    data['simultaneous_sessions'] = simultaneousSessions;
    data['user_type'] = userType;
    data['login_after'] = loginAfter;
    data['login_before'] = loginBefore;
    data['bypass_restrict_ip_check_if_2fa_enabled'] =
        bypassRestrictIpCheckIf2faEnabled;
    data['last_login'] = lastLogin;
    data['last_ip'] = lastIp;
    data['last_active'] = lastActive;
    data['last_known_versions'] = lastKnownVersions;
    data['api_key'] = apiKey;
    data['api_secret'] = apiSecret;
    data['doctype'] = doctype;

    return data;
  }
}

class Roles {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  String? parent;
  String? parentfield;
  String? parenttype;
  int? idx;
  int? docstatus;
  String? role;
  String? doctype;

  Roles(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.role,
      this.doctype});

  Roles.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    role = json['role'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['idx'] = idx;
    data['docstatus'] = docstatus;
    data['role'] = role;
    data['doctype'] = doctype;
    return data;
  }
}

class BlockModules {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  String? parent;
  String? parentfield;
  String? parenttype;
  int? idx;
  int? docstatus;
  String? module;
  String? doctype;

  BlockModules(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.module,
      this.doctype});

  BlockModules.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    module = json['module'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['idx'] = idx;
    data['docstatus'] = docstatus;
    data['module'] = module;
    data['doctype'] = doctype;
    return data;
  }
}

class SocialLogins {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  String? parent;
  String? parentfield;
  String? parenttype;
  int? idx;
  int? docstatus;
  String? provider;
  String? userid;
  String? doctype;

  SocialLogins(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.provider,
      this.userid,
      this.doctype});

  SocialLogins.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    provider = json['provider'];
    userid = json['userid'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['idx'] = idx;
    data['docstatus'] = docstatus;
    data['provider'] = provider;
    data['userid'] = userid;
    data['doctype'] = doctype;
    return data;
  }
}
