/// Very small i18n helper for Arabic ('ar') and French ('fr').
class I18n {
  final String locale;
  I18n(this.locale);

  String get chairsTitle => locale == 'ar' ? 'لعبة الكراسي' : 'Chaises Musicales';
  String get tapChairs => locale == 'ar' ? 'اضغط على الكراسي' : 'Tap the chairs';
  String get correct => locale == 'ar' ? 'صحيح!' : 'Bravo!';
  String get wrong => locale == 'ar' ? 'حاول مرة أخرى' : 'Essaie encore';
  String get playAgain => locale == 'ar' ? 'إعادة' : 'Rejouer';
}
