// This holds functions to convert lists to arrays and vice versa



String[] ConvertStrings (StringList In) {
  String[] Output = new String [In.size()];
  for (int i = 0; i < Output.length; i ++) {
    Output[i] = In.get(i);
  }
  return Output;
}



ArrayList <String> ConvertStrings (String[] In) {
  ArrayList <String> Output = new ArrayList <String> ();
  for (String S : In) {
    Output.add (S);
  }
  return Output;
}



int[] CastStringsToInts (String[] In) {
  int[] Output = new int [In.length];
  for (int i = 0; i < In.length; i ++) {
    try {
      Output[i] = Integer.parseInt(In[i]);
    } catch (NumberFormatException e) {
      return null;
    }
  }
  return Output;
}
