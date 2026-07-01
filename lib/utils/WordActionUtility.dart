/// The following is a beautiful piece of code that works to get the next or the previous
/// word boundaries for shortcuts like Option + ArrowRight/ArrowLeft.
/// Look at it and take in the glory.
/// I love it so much.
/// 
/// However, this piece of code is not perfect. One of the main cases where it will break behaviour
/// is when you have a bunch of spaces followed by a return. Here, forward match will move to the 
/// next line. Similarly, backward match will move to the previous line. This is not the ideal
/// behaviour. I will address this once I finish the multi-tab functionality/terminal functionality.
class WordActionUtility {
  final String wordChars;
  static final String _whitespaceChars = r' \t';
  static final String _lineBreakChars = r'\r\n';
  late RegExp _wordOrPunctuationClassRegex;
  late RegExp _prevWordOrPunctuationClassRegex;
  late RegExp _firstWordOrPunctuationClassRegex;
  late RegExp _firstWhitespaceClassRegex;

  WordActionUtility({ required this.wordChars }) {
    _wordOrPunctuationClassRegex = RegExp('([$_lineBreakChars]|[$_whitespaceChars]*([$wordChars]+|[^$wordChars$_whitespaceChars$_lineBreakChars]+))');
    _prevWordOrPunctuationClassRegex = RegExp('([$_lineBreakChars]|[$wordChars]+|[^$wordChars$_whitespaceChars]+)[$_whitespaceChars]*');
    _firstWordOrPunctuationClassRegex = RegExp('([$wordChars]|[^$wordChars$_whitespaceChars])+');
    _firstWhitespaceClassRegex = RegExp('[$_whitespaceChars]+');
  }

  int getNextWordOrPunctuationBoundaryEnd (String input) {
    return _wordOrPunctuationClassRegex.firstMatch(input)?.end ?? 0;
  }

  int getPrevWordOrPunctuationBoundaryStart (String input) {
    return _prevWordOrPunctuationClassRegex.allMatches(input).lastOrNull?.start ?? 0;
  }

  int getFirstWordOrPunctuationBoundaryStart (String input) {
    final priorityMatch = _firstWordOrPunctuationClassRegex.firstMatch(input);

    if (priorityMatch == null) {
      return _firstWhitespaceClassRegex.allMatches(input).lastOrNull?.start ?? 0;
    }
    return priorityMatch.start;
  }

}

WordActionUtility defaultWordCharsWordActionUtility = WordActionUtility(wordChars: 'a-zA-Z0-9');
