import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'division.g.dart';

@HiveType(typeId: 5, adapterName: 'DivisionAdapter')
@JsonSerializable()
class Division {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int order;

  Division({
    required this.id,
    required this.name,
    required this.order,
  });

  factory Division.fromJson(Map<String, dynamic> json) =>
      _$DivisionFromJson(json);

  Map<String, dynamic> toJson() => _$DivisionToJson(this);
}
