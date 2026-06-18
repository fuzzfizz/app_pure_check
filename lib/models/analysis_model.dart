class FlaggedAllergen {
  final String ingredient;
  final String reason;

  FlaggedAllergen({required this.ingredient, required this.reason});

  factory FlaggedAllergen.fromJson(Map<String, dynamic> json) {
    return FlaggedAllergen(
      ingredient: json['ingredient'] as String,
      reason: json['reason'] as String,
    );
  }
}

class AnalysisModel {
  final bool isSafe;
  final int suitabilityScore;
  final List<FlaggedAllergen> flaggedAllergens;
  final List<String> pros;
  final List<String> cons;
  final String reasoning;

  AnalysisModel({
    required this.isSafe,
    required this.suitabilityScore,
    required this.flaggedAllergens,
    required this.pros,
    required this.cons,
    required this.reasoning,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      isSafe: json['is_safe'] as bool? ?? false,
      suitabilityScore: json['suitability_score'] as int? ?? 0,
      flaggedAllergens: (json['flagged_allergens'] as List<dynamic>?)
              ?.map((e) => FlaggedAllergen.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pros: (json['pros'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      cons: (json['cons'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      reasoning: json['reasoning'] as String? ?? 'No reasoning provided.',
    );
  }
}
