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
    AllPageNames = ConvertStrings (PagesFolder.list());
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
    ResetGUIElements();
  }
  
  
  
  
  
  
  
  
  
  
  void LoadLatestPage() {
    String LatestPage = Settings.GetDataString ("latest page", null);
    if (LatestPage != null) {
      ArrayList <String> LoadedPage = GetPageDataFromFile (LatestPage);
      if (LoadedPage != null) {
        CurrentPage = LoadedPage;
        CalcTotal();
        ChangesSaved = true;
      } else {
        println ("Error: page " + '"' + LatestPage + '"' + " was not found.");
        CreateBasicPage();
      }
    } else {
      println ("Error: data.txt entry " + '"' + "latest page" + '"' + " was not found.");
      CreateBasicPage();
    }
  }
  
  
  
  
  
  ArrayList <String> GetPageDataFromFile (String PageName) {
    String PageFileName = GetPageFileName (PageName);
    for (String S : AllPageNames) {
      if (S.equals(PageFileName)) {
        return ConvertStrings (loadStrings (dataPath("") + "/Pages/" + PageFileName));
      }
    }
    return null;
  }
  
  
  
  
  
  void ResetGUIElements() {
    GUI_PageEditor_AllValues.DeleteChildren();
    for (int i = 1; i < CurrentPage.size(); i ++) {
      AddValueElement (CurrentPage.get(i));
    }
  }
  
  
  
  
  
  void SaveCurrentPage() {
    String PageFileName = GetPageFileName (CurrentPage.get(0));
    PrintWriter PageOutput = createWriter (dataPath("") + "/Pages/" + PageFileName);
    for (String S : CurrentPage) {
      PageOutput.println(S);
    }
    PageOutput.flush();
    PageOutput.close();
    Settings.SetDataString ("latest page", PageManager.CurrentPage.get(0));
    ChangesSaved = true;
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
    CalcTotal();
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
