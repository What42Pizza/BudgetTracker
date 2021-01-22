Settings_Class Settings = new Settings_Class();

class Settings_Class {
  
  
  
  
  
  // Vars
  
  String[] Settings;
  ArrayList <String> Data;
  
  
  
  
  
  void Init() {
    Settings = loadStrings("/settings.txt");
    Data = ConvertStrings (loadStrings("/data.txt"));
    CleanSettings();
    CleanData();
  }
  
  
  
  void CleanSettings() {
    StringList NewSettings = new StringList();
    for (String S : Settings) {
      if (S.length() > 0) NewSettings.append(S);
    }
    Settings = ConvertStrings (NewSettings);
  }
  
  void CleanData() {
    ArrayList <String> NewData = new ArrayList <String> ();
    for (String S : Data) {
      if (S.length() > 0) NewData.add(S);
    }
    Data = NewData;
  }
  
  
  
  
  
  void UpdateDataFile() {
    PrintWriter DataFile = createWriter(dataPath("") + "/data.txt");
    for (String S : Data) {
      DataFile.println(S);
    }
    DataFile.flush();
    DataFile.close();
  }
  
  
  
  
  
  String GetString (String SettingName) {
    SettingName += ": ";
    for (String S : Settings) {
      if (S.startsWith(SettingName)) {
        return S.substring(SettingName.length());
      }
    }
    println ("Error: could not find setting " + '"' + SettingName + '"' + ".");
    exit();
    return null;
  }
  
  String GetString (String SettingName, String DefaultValue) {
    SettingName += ": ";
    for (String S : Settings) {
      if (S.startsWith(SettingName)) {
        return S.substring(SettingName.length());
      }
    }
    return DefaultValue;
  }
  
  
  
  boolean GetBool (String SettingName) {
    String FoundValue = GetString (SettingName);
    FoundValue = FoundValue.toLowerCase();
    switch (FoundValue) {
      case ("true"):
        return true;
      case ("false"):
        return false;
      default:
        println ("Error: could not convert " + '"' + FoundValue + '"' + " to a boolean. Please enter either " + '"' + "true" + '"' + " or " + '"' + "false" + '"' + ".");
        exit();
        return false;
    }
  }
  
  boolean GetBool (String SettingName, boolean DefaultValue) {
    String FoundValue = GetString (SettingName);
    if (FoundValue == null) return false;
    FoundValue = FoundValue.toLowerCase();
    switch (FoundValue) {
      case ("true"):
        return true;
      case ("false"):
        return false;
      default:
        return DefaultValue;
    }
  }
  
  
  
  int GetInt (String SettingName) {
    String FoundValue = GetString (SettingName);
    if (FoundValue == null) return 0;
    try {
      int CastedInt = Integer.parseInt(FoundValue);
      return CastedInt;
    } catch (NumberFormatException e) {
      println ("Error: could not convert " + FoundValue + " to an integer.");
      exit();
      return 0;
    }
  }
  
  int GetInt (String SettingName, int DefaultValue) {
    String FoundValue = GetString (SettingName);
    if (FoundValue == null) return 0;
    try {
      int CastedInt = Integer.parseInt(FoundValue);
      return CastedInt;
    } catch (NumberFormatException e) {
      return DefaultValue;
    }
  }
  
  
  
  
  
  String GetDataString (String DataName) {
    DataName += ": ";
    for (String S : Data) {
      if (S.startsWith(DataName)) {
        return S.substring(DataName.length() + 1);
      }
    }
    println ("Error: could not find data " + '"' + DataName + '"' + ".");
    exit();
    return null;
  }
  
  String GetDataString (String DataName, String DefaultValue) {
    for (String S : Data) {
      if (S.startsWith(DataName + ':')) {
        return S.substring(DataName.length() + 2);
      }
    }
    return DefaultValue;
  }
  
  
  
  void SetDataString (String DataName, String NewValue) {
    DataName += ": ";
    for (int i = 0; i < Data.size(); i ++) {
      String S = Data.get(i);
      if (S.startsWith(DataName)) {
        Data.remove (i);
        Data.add (i, DataName + NewValue);
        return;
      }
    }
    Data.add (DataName + NewValue);
  }
  
  
  
  
  
}
