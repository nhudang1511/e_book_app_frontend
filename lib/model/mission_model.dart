import 'custom_model.dart';

class Mission extends CustomModel{

  final String? name;
  final String? detail;
  final String? type;
  final int? times;
  final int? coins;
  final String? id;
  final bool? status;

  Mission({this.name, this.detail, this.type, this.times, this.coins, this.id, this.status});

  @override
  Mission fromJson(Map<String, dynamic> json) {
    Mission mission = Mission(
      name: json['name'],
      detail: json['detail'],
      type: json['type'],
      times: json['times'],
      coins: json['coins'],
      id: json['id'],
      status: json['status']
    );
    return mission;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'detail': detail,
      'type': type,
      'times': times,
      'coins': coins,
      'status': status
    };
  }
}