import 'package:json_annotation/json_annotation.dart';

part 'leadership_skills.g.dart';

@JsonSerializable(explicitToJson: true)
class LeadershipSkills {
  LeadershipSkills({
    required this.brawl,
    required this.commander,
    required this.oathbreaker,
  });

  bool brawl;
  bool commander;
  bool oathbreaker;

  factory LeadershipSkills.fromJson(Map<String, dynamic> json) => _$LeadershipSkillsFromJson(json);

  Map<String, dynamic> toJson() => _$LeadershipSkillsToJson(this);
}
