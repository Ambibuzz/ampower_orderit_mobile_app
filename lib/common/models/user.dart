class User {
  String? name;
  String? creation;
  String? modified;
  String? modifiedBy;
  String? owner;
  int? docstatus;
  String? parent;
  String? parentfield;
  String? parenttype;
  int? idx;
  String? interest;
  String? lastName;
  int? enabled;
  String? bio;
  String? newPassword;
  String? fullName;
  String? redirectUrl;
  int? sendWelcomeEmail;
  String? middleName;
  String? timeZone;
  String? language;
  String? lastKnownVersions;
  String? resetPasswordKey;
  String? roleProfileName;
  String? location;
  String? lastPasswordResetDate;
  String? lastActive;
  String? mobileNo;
  String? userImage;
  String? documentFollowFrequency;
  String? birthDate;
  String? username;
  int? loginAfter;
  String? email;
  int? threadNotify;
  String? lastIp;
  int? simultaneousSessions;
  String? apiSecret;
  int? bypassRestrictIpCheckIf2faEnabled;
  String? firstName;
  String? phone;
  int? unsubscribed;
  int? muteSounds;
  int? loginBefore;
  String? userType;
  int? documentFollowNotify;
  String? gender;
  String? restrictIp;
  String? lastLogin;
  int? sendMeACopy;
  int? logoutAllSessions;
  String? homeSettings;
  String? bannerImage;
  String? emailSignature;
  int? allowedInMentions;
  String? apiKey;
  String? nUserTags;
  String? nComments;
  String? nAssign;
  String? nLikedBy;

  User(
      {this.name,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.owner,
      this.docstatus,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.interest,
      this.lastName,
      this.enabled,
      this.bio,
      this.newPassword,
      this.fullName,
      this.redirectUrl,
      this.sendWelcomeEmail,
      this.middleName,
      this.timeZone,
      this.language,
      this.lastKnownVersions,
      this.resetPasswordKey,
      this.roleProfileName,
      this.location,
      this.lastPasswordResetDate,
      this.lastActive,
      this.mobileNo,
      this.userImage,
      this.documentFollowFrequency,
      this.birthDate,
      this.username,
      this.loginAfter,
      this.email,
      this.threadNotify,
      this.lastIp,
      this.simultaneousSessions,
      this.apiSecret,
      this.bypassRestrictIpCheckIf2faEnabled,
      this.firstName,
      this.phone,
      this.unsubscribed,
      this.muteSounds,
      this.loginBefore,
      this.userType,
      this.documentFollowNotify,
      this.gender,
      this.restrictIp,
      this.lastLogin,
      this.sendMeACopy,
      this.logoutAllSessions,
      this.homeSettings,
      this.bannerImage,
      this.emailSignature,
      this.allowedInMentions,
      this.apiKey,
      this.nUserTags,
      this.nComments,
      this.nAssign,
      this.nLikedBy});

  User.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    owner = json['owner'];
    docstatus = json['docstatus'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    interest = json['interest'];
    lastName = json['last_name'];
    enabled = json['enabled'];
    bio = json['bio'];
    newPassword = json['new_password'];
    fullName = json['full_name'];
    redirectUrl = json['redirect_url'];
    sendWelcomeEmail = json['send_welcome_email'];
    middleName = json['middle_name'];
    timeZone = json['time_zone'];
    language = json['language'];
    lastKnownVersions = json['last_known_versions'];
    resetPasswordKey = json['reset_password_key'];
    roleProfileName = json['role_profile_name'];
    location = json['location'];
    lastPasswordResetDate = json['last_password_reset_date'];
    lastActive = json['last_active'];
    mobileNo = json['mobile_no'];
    userImage = json['user_image'];
    documentFollowFrequency = json['document_follow_frequency'];
    birthDate = json['birth_date'];
    username = json['username'];
    loginAfter = json['login_after'];
    email = json['email'];
    threadNotify = json['thread_notify'];
    lastIp = json['last_ip'];
    simultaneousSessions = json['simultaneous_sessions'];
    apiSecret = json['api_secret'];
    bypassRestrictIpCheckIf2faEnabled =
        json['bypass_restrict_ip_check_if_2fa_enabled'];
    firstName = json['first_name'];
    phone = json['phone'];
    unsubscribed = json['unsubscribed'];
    muteSounds = json['mute_sounds'];
    loginBefore = json['login_before'];
    userType = json['user_type'];
    documentFollowNotify = json['document_follow_notify'];
    gender = json['gender'];
    restrictIp = json['restrict_ip'];
    lastLogin = json['last_login'];
    sendMeACopy = json['send_me_a_copy'];
    logoutAllSessions = json['logout_all_sessions'];
    homeSettings = json['home_settings'];
    bannerImage = json['banner_image'];
    emailSignature = json['email_signature'];
    allowedInMentions = json['allowed_in_mentions'];
    apiKey = json['api_key'];
    nUserTags = json['_user_tags'];
    nComments = json['_comments'];
    nAssign = json['_assign'];
    nLikedBy = json['_liked_by'];
  }

  Map<String, dynamic> toJson() {
    final  data = <String, dynamic>{};
    data['name'] = name;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['owner'] = owner;
    data['docstatus'] = docstatus;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['idx'] = idx;
    data['interest'] = interest;
    data['last_name'] = lastName;
    data['enabled'] = enabled;
    data['bio'] = bio;
    data['new_password'] = newPassword;
    data['full_name'] = fullName;
    data['redirect_url'] = redirectUrl;
    data['send_welcome_email'] = sendWelcomeEmail;
    data['middle_name'] = middleName;
    data['time_zone'] = timeZone;
    data['language'] = language;
    data['last_known_versions'] = lastKnownVersions;
    data['reset_password_key'] = resetPasswordKey;
    data['role_profile_name'] = roleProfileName;
    data['location'] = location;
    data['last_password_reset_date'] = lastPasswordResetDate;
    data['last_active'] = lastActive;
    data['mobile_no'] = mobileNo;
    data['user_image'] = userImage;
    data['document_follow_frequency'] = documentFollowFrequency;
    data['birth_date'] = birthDate;
    data['username'] = username;
    data['login_after'] = loginAfter;
    data['email'] = email;
    data['thread_notify'] = threadNotify;
    data['last_ip'] = lastIp;
    data['simultaneous_sessions'] = simultaneousSessions;
    data['api_secret'] = apiSecret;
    data['bypass_restrict_ip_check_if_2fa_enabled'] =
        bypassRestrictIpCheckIf2faEnabled;
    data['first_name'] = firstName;
    data['phone'] = phone;
    data['unsubscribed'] = unsubscribed;
    data['mute_sounds'] = muteSounds;
    data['login_before'] = loginBefore;
    data['user_type'] = userType;
    data['document_follow_notify'] = documentFollowNotify;
    data['gender'] = gender;
    data['restrict_ip'] = restrictIp;
    data['last_login'] = lastLogin;
    data['send_me_a_copy'] = sendMeACopy;
    data['logout_all_sessions'] = logoutAllSessions;
    data['home_settings'] = homeSettings;
    data['banner_image'] = bannerImage;
    data['email_signature'] = emailSignature;
    data['allowed_in_mentions'] = allowedInMentions;
    data['api_key'] = apiKey;
    data['_user_tags'] = nUserTags;
    data['_comments'] = nComments;
    data['_assign'] = nAssign;
    data['_liked_by'] = nLikedBy;
    return data;
  }
}
