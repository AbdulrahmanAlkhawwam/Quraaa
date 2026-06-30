enum InterestSelection {
  spaceScience('space_science'),
  geography('geography'),
  history('history'),
  encyclopedias('encyclopedias'),
  patrols('patrols'),
  culture('culture'),
  science('science'),
  novels('novels'),
  policy('policy'),
  dictionary('dictionary'),
  education('education'),
  technology('technology'),
  art('art'),
  literature('literature'),
  other('other');

  const InterestSelection(this.key);

  final String key;

  static InterestSelection? fromKey(String? value) {
    for (final InterestSelection selection in InterestSelection.values) {
      if (selection.key == value) {
        return selection;
      }
    }
    return null;
  }
}
