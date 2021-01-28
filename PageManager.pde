PageManager_Class PageManager = new PageManager_Class();

class PageManager_Class extends Cloneable_AsClass {
  
  
  
  
  
  
  // General
  String[] ColumnNames;
  boolean ChangesSaved = false;
  File PagesFolder;
  
  // Page
  ArrayList <String> AllPageNames;
  ArrayList <String[]> CurrentPage;
  String PageName;
  
  // Totals
  ArrayList <Float[]> NumValues;
  float[] ColumnTotals;
  ArrayList <Float> RowTotals;
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
    ResetValueElements();
    CalcTotals();
    ChangesSaved = true;
    History.Reset();
    //History.AddSavePoint();
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
  
  
  
  
  
  
  
  
  
  
  void SetRowName (int RowIndex, String NewName) {
    String[] RowToEdit = CurrentPage.remove (RowIndex);
    if (!RowToEdit[0].equals(NewName)) {
      RowToEdit[0] = NewName;
      ChangesSaved = false;
      CurrentPage.add (RowIndex, RowToEdit);
      History.AddSavePoint();
    } else {
      CurrentPage.add (RowIndex, RowToEdit); // This has to be in both branches because AddSavePoint need to happen after that row is added back
    }
  }
  
  
  
  void SetValue (int RowIndex, int ColumnIndex, String NewValue) {
    String[] RowToEdit = CurrentPage.remove (RowIndex);
    if (!RowToEdit[ColumnIndex+1].equals(NewValue)) {
      RowToEdit[ColumnIndex+1] = NewValue;
      CurrentPage.add (RowIndex, RowToEdit);
      CalcRowTotal (RowIndex);
      CalcColumnTotal (ColumnIndex);
      CalcPageTotal();
      UpdateTotalElementsForValue (RowIndex, ColumnIndex);
      History.AddSavePoint();
      ChangesSaved = false;
    } else {
      CurrentPage.add (RowIndex, RowToEdit);
    }
  }
  
  
  
  void AddRow() {
    String[] NewRow = new String [ColumnNames.length + 1];
    NewRow[0] = "New Line:";
    for (int i = 1; i < NewRow.length; i ++) NewRow[i] = "";
    CurrentPage.add (NewRow);
    RowTotals.add (0.0);
  }
  
  void RemoveRowLast() {
    CurrentPage.remove (CurrentPage.size() - 1);
    RowTotals.remove (RowTotals.size() - 1);
  }
  
  void RemoveRow (int Index) {
    CurrentPage.remove (Index);
    RowTotals.remove (Index);
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
    int Index = 1;
    
    for (int i = 0; i < NumOfRows; i ++) {
      String[] NewLine = new String [NumOfColumns];
      for (int j = 0; j < NumOfColumns; j ++) {
        NewLine[j] = In [Index];
        Index ++;
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
    ResetValueElements();
    CalcTotals();
    ChangesSaved = true;
  }
  
  
  
  ArrayList <String[]> CreateNewPage() {
    ArrayList <String[]> Output = new ArrayList <String[]> ();
    String PageNamePreset = Settings.GetString("page name preset", "[year]");
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
    
    int NumOfColumns = ColumnNames.length;
    NumValues = new ArrayList <Float[]> ();
    RowTotals = new ArrayList <Float> ();
    ColumnTotals = new float [ColumnNames.length];
    PageTotal = 0;
    
    for (int i = 0; i < CurrentPage.size(); i ++) {
      Float[] CurrRowValues = new Float [NumOfColumns];
      float CurrRowTotal = 0.0;
      for (int j = 0; j < NumOfColumns; j ++) { // i = row, j = column
        try {
          
          float CastedFloat = Float.parseFloat (CurrentPage.get(i)[j+1]);
          CurrRowValues[j] = CastedFloat;
          CurrRowTotal += CastedFloat;
          //RowTotals.add (j, RowTotals.remove (j) + CastedFloat);
          ColumnTotals[j] += CastedFloat;
          PageTotal += CastedFloat;
          
        } catch (NumberFormatException e) {
          CurrRowValues[j] = null;
        }
      }
      RowTotals.add (CurrRowTotal);
      NumValues.add (CurrRowValues);
    }
    
    UpdateTotalElements();
    
  }
  
  
  
  
  
  void CalcRowTotal (int RowIndex) {
    Float RowTotal = 0.0;
    String[] CurrRow = CurrentPage.get (RowIndex);
    
    // Cast & add
    for (int i = 1; i < CurrRow.length; i ++) {
      try {
        String S = CurrRow[i];
        Float CastedFloat = Float.parseFloat (S);
        RowTotal += CastedFloat;
      } catch (NumberFormatException e) {
        //RowTotal += 0;
      }
    }
    
    // Set new value
    RowTotals.remove (RowIndex);
    RowTotals.add (RowIndex, RowTotal);
    
  }
  
  
  
  
  
  void CalcColumnTotal (int ColumnIndex) {
    float ColumnTotal = 0.0;
    
    // Cast & add
    for (String[] Row : CurrentPage) {
      try {
        float CastedFloat = Float.parseFloat (Row[ColumnIndex+1]);
        ColumnTotal += CastedFloat;
      } catch (NumberFormatException e) {
        //RowTotal += 0;
      }
    }
    
    // Set new value
    ColumnTotals[ColumnIndex] = ColumnTotal;
    
  }
  
  
  
  
  
  void CalcPageTotal() {
    float Total = 0.0;
    
    // Cast & add
    for (String[] Row : CurrentPage) {
      for (String S : Row) {
        try {
          Float CastedFloat = Float.parseFloat (S);
          Total += CastedFloat;
        } catch (NumberFormatException e) {
          //Total += 0;
        }
      }
    }
    
    // Set new value
    PageTotal = Total;
    
  }
  
  
  
  
  
  String[] GetRowNames() {
    String[] Output = new String [CurrentPage.size()];
    for (int i = 0; i < Output.length; i ++) {
      Output[i] = CurrentPage.get(i)[0];
    }
    return Output;
  }
  
  
  
  
  
  
  
  
  
  
  @Override
  public PageManager_Class clone() {
    
    // Shallow copy
    PageManager_Class Output = (PageManager_Class) super.clone();
    
    // Deep copy
    Output.AllPageNames = (ArrayList <String>) AllPageNames.clone();
    ArrayList <String[]> NewCurrentPage = new ArrayList <String[]> ();
    for (String[] S : CurrentPage) NewCurrentPage.add ((String[]) S.clone());
    Output.CurrentPage = NewCurrentPage;
    
    return Output;
    
  }
  
  
  
  
  
  
  
  
  
  
}
