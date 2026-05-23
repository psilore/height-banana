import 'package:freezed_annotation/freezed_annotation.dart';
import 'arrow.dart';

part 'end.freezed.dart';
part 'end.g.dart';

/// Represents an "end" in archery - a group of arrows shot in sequence.
///
/// Typically 3 or 6 arrows per end, depending on competition rules.
/// An end is the fundamental unit for scoring in archery training.
@freezed
class End with _$End {
  const factory End({
    /// Unique identifier for this end
    required String id,

    /// ID of the parent training session
    required String sessionId,

    /// End number within the session (1, 2, 3, ...)
    required int endNumber,

    /// List of arrows shot in this end
    @Default([]) List<Arrow> arrows,

    /// When this end was completed
    required DateTime timestamp,
  }) = _End;

  const End._();

  factory End.fromJson(Map<String, dynamic> json) => _$EndFromJson(json);

  /// Calculate total score for this end
  int get totalScore =>
      arrows.fold(0, (sum, arrow) => sum + arrow.numericScore);

  /// Calculate average score per arrow in this end
  double get averageScore => arrows.isEmpty ? 0.0 : totalScore / arrows.length;

  /// Check if this end is complete (has expected number of arrows)
  bool isComplete([int expectedArrows = 6]) => arrows.length >= expectedArrows;
}
