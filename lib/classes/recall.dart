class Recall {
  final String reportReceivedDate;
  final String component;
  final String summary;
  final String consequence;
  final String remedy;

  Recall(
    this.reportReceivedDate,
    this.component,
    this.summary,
    this.consequence,
    this.remedy,
  );

  Recall.fromJson(Map<String, dynamic> json)
      : reportReceivedDate = json['ReportReceivedDate'],
        component = json['Component'],
        summary = json["Summary"],
        consequence = json["Consequence"],
        remedy = json["Remedy"];
}
