class Word {
  final String value;
  final String phonetic;
  final String audio;
  final String origin;
  final List<String> definitions;

  Word({
    required this.value,
    required this.phonetic,
    required this.audio,
    required this.origin,
    required this.definitions,
  });

  String printIt() {
    return 'Word(value: $value, phonetic: $phonetic, audio: $audio, origin: $origin, definitions: $definitions)';
  }
}
