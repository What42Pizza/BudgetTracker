PageManager_Class PageManager = new PageManager_Class();

class PageManager_Class {
  
  
  
  
  
  
  // General
  String[] ColumnNames;
  boolean ChangesSaved = false;
  File PagesFolder;
  
  // Page
  ArrayList <String> AllPageNames = null;
  ArrayList <String[]> CurrentPage;
  String PageName;
  
  // Totals
  ArrayList <Float[]> PageNumValues;
  float[] PageColumnTotals;
  ArrayList <Float> PageRowTotals;
  float PageTotal = 0;
  
  
  
  
  
  
  
  
  
  
  void BasicInit() { // ColumnNames is needed in InitGUI, but PageManager.Init() calls GUI functions
    String DefaultColumnNames = "Jan" + char(9) + "Feb" + char (9) + "Mar" + char (9) + "Apr" + char (9) + "May" + char (9) + "June" + char (9) + "July" + char (9) + "Aug" + char (9) + "Sep" + char (9) + "Oct" + char (9) + "Nov" + char (9) + "Dec";
    ColumnNames = split (Settings.GetString ("cloumn names", DefaultColumnNames), char(9));
    PagesFolder = new File (dataPath("") + "/Pages");
  }
  
  
  
  
  
  void Init() {
    AllPageNames = ConvertStrings (loadStrings (dataPath("") + "/AllPageNames.txt"));
    if (PagesFolder.exists()) {
      if (PagesFolder.isDirectory()) {
        if (PagesFolder.list().length != 0) {
          LoadLatestPage();
        } else {
          println ("Error: data.txt entry " + '"' + "latest page" + '"' + " was not found.");
          CreateBasicPage();
        }
      } else {
        println ("Error: " + '"' + "data/Pages" + '"' + " has to be a folder.");
        exit();
      }
    } else {
      CreateBasicPage();
    }
    History.AddSavePoint();
  }
  
  
  
  
  
  
  
  
  
  
  void LoadLatestPage() {
    String LatestPageName = Settings.GetDataString ("latest page", null);
    if (LatestPageName != null) {
      LoadPage (LatestPageName);
      if (CurrentPage == null) {
        println ("Error: could not find page " + LatestPageName);
        CreateBasicPage();
      }
    } else {
      println ("Error: data.txt entry " + '"' + "latest page" + '"' + " was not found.");
      CreateBasicPage();
    }
  }
  
  
  
  
  
  void LoadPage (String PageName) {
    
    String FilePath = dataPath("") + "/Pages/" + GetPageFileName (PageName);
    if (! new File(FilePath).exists()) return;
    
    String[] RawPage = loadStrings (FilePath);
    this.PageName = RawPage[0];
    
    CurrentPage = DeserializeRawPage (RawPage);
    CalcTotals();
    ResetValueElements();
    ChangesSaved = true;
    History.Reset();
    //History.SwitchToPage (CurrentPage.get(0));
    
  }
  
  
  
  
  
  void Save() {
    SaveCurrentPage();
    SaveAllPageNames();
    RemoveUnneededPages();
    Settings.SetDataString ("latest page", PageName);
    ChangesSaved = true;
  }
  
  
  
  void SaveCurrentPage() {
    String PageFileName = GetPageFileName (PageName);
    PrintWriter PageOutput = createWriter (dataPath("") + "/Pages/" + PageFileName);
    String[] SerializedPage = SerializeCurrentPage();
    for (String S : SerializedPage) {
      PageOutput.println(S);
    }
    PageOutput.flush();
    PageOutput.close();
  }
  
  
  
  void SaveAllPageNames() {
    PrintWriter PageNamesOutput = createWriter (dataPath("") + "/AllPageNames.txt");
    for (String S : AllPageNames) PageNamesOutput.println (S);
    PageNamesOutput.flush();
    PageNamesOutput.close();
  }
  
  
  
  void RemoveUnneededPages() {
    
    // Get vars
    String[] AllPageFiles = PagesFolder.list();
    ArrayList <String> AllPageFileNames = (ArrayList <String>) AllPageNames.clone();
    
    // Get list of needed file names
    for (int i = 0; i < AllPageFileNames.size(); i ++) {
      AllPageFileNames.add (i, GetPageFileName (AllPageFileNames.remove (i)));
    }
    
    // Remove files not on list
    for (String PageFileName : AllPageFiles) {
      if (!StringListContains (AllPageFileNames, PageFileName)) { // O(n^2), not good
        File PageToRemove = new File (dataPath("") + "/Pages/" + PageFileName);
        PageToRemove.delete();
      }
    }
    
  }
  
  
  
  
  
  
  
  
  
  
  String[] SerializeCurrentPage() {
    int NumOfColumns = ColumnNames.length + 1;
    int NumOfRows = CurrentPage.size();
    String[] Output = new String [NumOfRows * NumOfColumns + 1];
    
    Output[0] = PageName;
    int OutputIndex = 1;
    for (int i = 0; i < NumOfRows; i ++) {
      String[] CurrRow = CurrentPage.get(i);
      for (int j = 0; j < NumOfColumns; j ++) {
        Output[OutputIndex] = CurrRow[j];
        OutputIndex ++;
      }
    }
    
    return Output;
  }
  
  
  
  
  
  ArrayList <String[]> DeserializeRawPage (String[] In) {
    int NumOfRawRows = In.length - 1;
    int NumOfColumns = ColumnNames.length + 1;
    
    // Error checking
    if (NumOfRawRows % NumOfColumns != 0) {
      println ("Error: page length cannot be " + In.length + ".");
      exit(); return null;
    }
    
    // Deserialize
    ArrayList <String[]> Output = new ArrayList <String[]> ();
    int NumOfRows = NumOfRawRows / NumOfColumns;
    
    for (int i = 0; i < NumOfRows; i ++) {
      String[] NewLine = new String [NumOfColumns];
      for (int j = 0; j < NumOfColumns; j ++) {
        NewLine[j] = In [j + i + 1];
      }
      Output.add (NewLine);
    }
    
    return Output;
    
  }
  
  
  
  
  
  
  
  
  
  
  void SetPageName (String NewPageName) {
    
    // Replace name in AllPageNames
    String CurrPageName = PageName;
    for (int i = 0; i < AllPageNames.size(); i ++) {
      if (AllPageNames.get(i).equals(CurrPageName)) {
        AllPageNames.remove(i);
        break;
      }
    }
    AllPageNames.add (NewPageName);
    
    // Update CurrentPage
    CurrentPage.remove (0);
    PageName = NewPageName;
    
  }
  
  
  
  
  
  
  
  
  
  
  void CreateBasicPage() {
    CurrentPage = CreateNewPage();
    AllPageNames.add(PageName);
    //History.SwitchToPage (CurrentPage.get(0));
    CalcTotals();
    ResetValueElements();
    ChangesSaved = true;
  }
  
  
  
  ArrayList <String[]> CreateNewPage() {
    ArrayList <String[]> Output = new ArrayList <String[]> ();
    String PageNamePreset = Settings.GetString("page name preset", "[month]/--/[year]");
    String PageNameWONum = FillNamePreset (PageNamePreset);
    String NewPageName = PageNameWONum;
    int PageNum = 0;
    while (PageAlreadyExists (NewPageName)) {
      PageNum ++;
      NewPageName = PageNameWONum + " (" + PageNum + ")";
    }
    PageName = NewPageName;
    return Output;
  }
  
  
  
  boolean PageAlreadyExists (String PageName) {
    for (String S : AllPageNames) {
      if (S.equals(PageName)) return true;
    }
    return false;
  }
  
  
  
  String FillNamePreset (String PageNamePreset) {
    PageNamePreset = ReplaceSequenceInString (PageNamePreset, "[second]", second() + "");
    PageNamePreset = ReplaceSequenceInString (PageNamePreset, "[minute]", minute() + "");
    PageNamePreset = ReplaceSequenceInString (PageNamePreset, "[hour]", hour() + "");
    PageNamePreset = ReplaceSequenceInString (PageNamePreset, "[day]", day() + "");
    PageNamePreset = ReplaceSequenceInString (PageNamePreset, "[month]", month() + "");
    PageNamePreset = ReplaceSequenceInString (PageNamePreset, "[year]", year() + "");
    //println (PageNamePreset);
    return PageNamePreset;
  }
  
  
  
  String GetPageFileName (String PageName) {
    PageName = PageName.replaceAll("/", "_");
    return PageName + ".txt";
  }
  
  
  
  
  
  
  
  
  
  
  void CalcTotals() {
    
    int NumOfColumns = ColumnNames.length + 1;
    PageNumValues = new ArrayList <Float[]> ();
    PageRowTotals = new ArrayList <Float> ();
    PageColumnTotals = new float [NumOfColumns];
    PageTotal = 0;
    
    for (int i = 0; i < NumOfColumns; i ++) PageRowTotals.add(0.0);
    
    for (int i = 0; i < CurrentPage.size(); i ++) {
      Float[] RowValues = new Float [NumOfColumns];
      for (int j = 0; j < NumOfColumns; j ++) { // i = row, j = column
        try {
          
          float CastedFloat = Float.parseFloat (CurrentPage.get(i)[j]);
          RowValues[j] = CastedFloat;
          PageRowTotals.add (j, PageRowTotals.remove (j) + CastedFloat);
          PageColumnTotals[i] += CastedFloat;
          PageTotal += CastedFloat;
          
        } catch (NumberFormatException e) {
          RowValues[j] = null;
        }
      }
      PageNumValues.add (RowValues);
    }
    
  }
  
  
  
  
  
  
  
  
  
  
}
