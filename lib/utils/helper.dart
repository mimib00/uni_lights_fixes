/// This function takes user ID and the date's ID and weight them to find the order of the ID.
///
/// This can be used to create new [chat],[match] or for fetching matches.
String getId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return b + "_" + a;
  } else {
    return a + "_" + b;
  }
}
