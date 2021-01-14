// This holds general functions that can be used anywhere



String ReplaceSequenceInString (String StringIn, String Sequence, String ReplaceValue) {
  for (int i = 0; i < StringIn.length() - Sequence.length() + 1; i ++) {
    if (SequenceIsInStringAtPos (StringIn, Sequence, i)) {
      StringIn = ReplaceStringArea (StringIn, i, Sequence.length(), ReplaceValue);
    }
  }
  return StringIn;
}



boolean SequenceIsInStringAtPos (String StringIn, String Sequence, int Pos) {
  int EndPoint = Sequence.length();
  for (int i = 0; i < EndPoint; i ++) {
    if (StringIn.charAt(Pos + i) != Sequence.charAt(i)) return false;
  }
  return true;
}



String ReplaceStringArea (String StringIn, int AreaStart, int AreaLength, String ReplaceValue) {
  String Before = StringIn.substring(0, AreaStart);
  String After = StringIn.substring(AreaStart + AreaLength, StringIn.length());
  return Before + ReplaceValue + After;
}





/*
ArrayList <String> CloneStrings (ArrayList <String> In) { // I use this because .clone() returns ArrayList <Object> // Actually I don't use this because you can cast with (ArrayList <String>)
  ArrayList <String> Output = new ArrayList <String> ();
  for (String S : In) {
    Output.add(S);
  }
  return Output;
}
*/





boolean StringListContains (ArrayList <String> In, String Element) {
  for (String S : In) {
    if (S.equals(Element)) return true;
  }
  return false;
}
