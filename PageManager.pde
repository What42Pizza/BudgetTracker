PageManager_Class PageManager = new PageManager_Class();

class PageManager_Class {
  
  
  
  
  
  ArrayList <String> AllPageNames = null;
  ArrayList <Float> PageNumValues;
  float PageNumTotal = 0;
  ArrayList <String> CurrentPage;
  // The first string of a page is the name of that page
  
  boolean ChangesSaved = false;
  
  File PagesFolder;
  
  
  
  
  
  
  
  
  
  
  void Init() {
    PagesFolder = new File (dataPath("") + "/Pages");
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
      if (CurrentPage == null) CreateBasicPage();
    } else {
      println ("Error: data.txt entry " + '"' + "latest page" + '"' + " was not found.");
      CreateBasicPage();
    }
  }
  
  
  
  
  
  void LoadPage (String PageName) {
    ArrayList <String> LoadedPage = GetPageDataFromFile (PageName);
    if (LoadedPage != null) {
      CurrentPage = LoadedPage;
      CalcTotal();
      ResetValueElements();
      ChangesSaved = true;
    } else {
      println ("Error: page " + '"' + PageName + '"' + " was not found.");
    }
    History.Reset();
    //History.SwitchToPage (CurrentPage.get(0));
  }
  
  
  
  
  
  ArrayList <String> GetPageDataFromFile (String PageName) {
    String PageFileName = GetPageFileName (PageName);
    for (String S : AllPageNames) {
      if (S.equals(PageName)) {
        return ConvertStrings (loadStrings (dataPath("") + "/Pages/" + PageFileName));
      }
    }
    return null;
  }
  
  
  
  
  
  void Save() {
    SaveCurrentPage();
    SaveAllPageNames();
    RemoveUnneededPages();
    Settings.SetDataString ("latest page", PageManager.CurrentPage.get(0));
    ChangesSaved = true;
  }
  
  
  
  void SaveCurrentPage() {
    String PageFileName = GetPageFileName (CurrentPage.get(0));
    PrintWriter PageOutput = createWriter (dataPath("") + "/Pages/" + PageFileName);
    for (String S : CurrentPage) {
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
  
  
  
  
  
  void SetPageName (String NewPageName) {
    
    // Replace name in AllPageNames
    String CurrPageName = CurrentPage.get(0);
    for (int i = 0; i < AllPageNames.size(); i ++) {
      if (AllPageNames.get(i).equals(CurrPageName)) {
        AllPageNames.remove(i);
        break;
      }
    }
    AllPageNames.add (NewPageName);
    
    // Update CurrentPage
    CurrentPage.remove (0);
    CurrentPage.add (0, NewPageName);
    
  }
  
  
  
  
  
  
  
  
  
  
  void CreateBasicPage() {
    CurrentPage = CreateNewPage();
    AllPageNames.add(CurrentPage.get(0));
    //History.SwitchToPage (CurrentPage.get(0));
    CalcTotal();
    ResetValueElements();
    ChangesSaved = true;
  }
  
  
  
  ArrayList <String> CreateNewPage() {
    ArrayList <String> Output = new ArrayList <String> ();
    String PageNamePreset = Settings.GetString("page name preset", "[month]/--/[year]");
    String PageNameWONum = FillNamePreset (PageNamePreset);
    String PageName = PageNameWONum;
    int PageNum = 0;
    while (PageAlreadyExists (PageName)) {
      PageNum ++;
      PageName = PageNameWONum + " (" + PageNum + ")";
    }
    Output.add(PageName);
    return Output;
  }
  
  
  
  boolean PageAlreadyExists (String PageName) {
    for (String S : AllPageNames) {
      if (S.equals(PageName)) return true;
    }
    return false;
  }
  
  
  
  void CalcTotal() {
    PageNumValues = new ArrayList <Float> ();
    PageNumTotal = 0;
    for (int i = 1; i < CurrentPage.size(); i ++) {
      try {
        Float CastedFloat = Float.parseFloat(CurrentPage.get(i));
        PageNumValues.add(CastedFloat);
        PageNumTotal += CastedFloat;
      } catch (NumberFormatException e) {
        PageNumValues.add(null);
      }
    }
    GUI_PageEditor_Total.Text = Float.toString (PageNumTotal);
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
  
  
  
  
  
  
  
  
  
  
}
