import 'package:luna/l10n/app_localizations.dart';

const moodEmojis = ['😔', '😐', '🙂', '😊', '🤩'];
const moodKeys = ['low', 'okay', 'good', 'happy', 'amazing'];

extension MoodL10n on AppLocalizations {
  String moodLabel(int index) => switch (moodKeys[index]) {
        'low' => moodLow,
        'okay' => moodOkay,
        'good' => moodGood,
        'happy' => moodHappy,
        'amazing' => moodAmazing,
        _ => moodKeys[index],
      };
}
