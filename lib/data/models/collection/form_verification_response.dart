class FormVerificationResponse {
  String? formId;
  Map<String, dynamic>? formData;
  List<PreviewData>? previewData;
  bool? requireSecondFactor;
  dynamic secondFactor;
  List<Map<String, dynamic>>? authMode;
  dynamic currency;

  FormVerificationResponse({
    this.formId,
    this.formData,
    this.previewData,
    this.requireSecondFactor,
    this.secondFactor,
    this.authMode,
    this.currency,
  });

  FormVerificationResponse.fromMap(Map<String, dynamic> json) {
    if (json["formId"] is String) {
      formId = json["formId"];
    }
    if (json["formData"] is Map) {
      formData = json["formData"] == null ? null : json["formData"] as Map<String, dynamic>;
    }
    if (json["previewData"] is List) {
      previewData = json["previewData"] == null ? null : (json["previewData"] as List).map((e) => PreviewData.fromMap(e)).toList();
    }
    if (json["requireSecondFactor"] is bool) {
      requireSecondFactor = json["requireSecondFactor"];
    }
    secondFactor = json["secondFactor"];
    if (json["authMode"] is List) {
      authMode = json["authMode"] == null ? null : List<Map<String, dynamic>>.from(json["authMode"]);
    }
    currency = json["currency"];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["formId"] = formId;
    if (formData != null) {
      data["formData"] = formData;
    }
    if (previewData != null) {
      data["previewData"] = previewData?.map((e) => e.toMap()).toList();
    }
    data["requireSecondFactor"] = requireSecondFactor;
    data["secondFactor"] = secondFactor;
    if (authMode != null) {
      data["authMode"] = authMode;
    }
    data["currency"] = currency;
    return data;
  }
}

class PreviewData {
  String? key;
  String? value;
  int? dataType;
  bool? payeeTitle;
  bool? payeeValue;

  PreviewData({this.key, this.value, this.dataType, this.payeeTitle, this.payeeValue});

  PreviewData.fromMap(Map<String, dynamic> json) {
    if (json["key"] is String) {
      key = json["key"];
    }
    if (json["value"] is String) {
      value = json["value"];
    }
    if (json["dataType"] is int) {
      dataType = json["dataType"];
    }
    if (json["payeeTitle"] is bool) {
      payeeTitle = json["payeeTitle"];
    }
    if (json["payeeValue"] is bool) {
      payeeValue = json["payeeValue"];
    }
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["key"] = key;
    data["value"] = value;
    data["dataType"] = dataType;
    data["payeeTitle"] = payeeTitle;
    data["payeeValue"] = payeeValue;
    return data;
  }
}