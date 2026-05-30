/*

// =====================================
// POST CATEGORY MODEL / CONSTANT CLASS
// =====================================

class PostCategory {

  /// =====================================
  /// ALL CATEGORY
  /// =====================================

  // সব ধরনের post দেখানোর category
  static const String all = 'All';

  /// =====================================
  /// LIFESTYLE CATEGORY
  /// =====================================

  // Lifestyle related post
  static const String lifestyle = 'Lifestyle';

  /// =====================================
  /// STUDY CATEGORY
  /// =====================================

  // Study / Education related post
  static const String study = 'Study';

  /// =====================================
  /// FEELING CATEGORY
  /// =====================================

  // Emotional / Feeling related post
  static const String feeling = 'Feeling';

  /// =====================================
  /// RELATIONSHIP CATEGORY
  /// =====================================

  // Relationship related post
  static const String relationship = 'Relationship';

  /// =====================================
  /// OTHER CATEGORY
  /// =====================================

  // Other ধরনের post
  static const String other = 'Other';

  /// =====================================
  /// CATEGORY LIST
  /// =====================================

  // সব category একসাথে list আকারে রাখা হয়েছে
  // Dropdown / Filter / Chips এ use করা যাবে

  static const List<String> values = [

    // All category
    all,

    // Lifestyle category
    lifestyle,

    // Study category
    study,

    // Feeling category
    feeling,

    // Relationship category
    relationship,

    // Other category
    other,
  ];

  static get goal => null;
}

*/

class PostCategory {

  static const String all = "সব";

  static const String lifestyle = "জীবন";
  static const String study = "স্টাডি";
  static const String goal = "লক্ষ্য";
  static const String feeling = "মুড";
  static const String relationship = "সম্পর্ক";
  static const String other = "আরও";

  static const List<String> values = [
    all,
    lifestyle,
    study,
    goal,
    feeling,
    relationship,
    other,
  ];
}