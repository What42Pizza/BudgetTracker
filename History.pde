// This keeps track of all the changes so they can be undone and redone

History_Class History = new History_Class();



class History_Class {
  
  
  
  //ArrayList <String> SavedUndoChainNames = new ArrayList <String> ();
  //ArrayList <ArrayList <ArrayList <String>>> AllSavedPages = new ArrayList <ArrayList <ArrayList <String>>> ();
  
  ArrayList <ArrayList <String>> SavedPages = new ArrayList <ArrayList <String>> ();
  ArrayList <ArrayList <String>> SavedPageNames = new ArrayList <ArrayList <String>> ();
  int CurrentIndex = -1;
  
  int MaxUndoChain;
  
  
  
  void Init() {
    MaxUndoChain = Settings.GetInt ("max undo chain", 100);
    /*
    for (String S : PageManager.AllPageNames) {
      SavedUndoChainNames.add (S);
      AllSavedPages.add (new ArrayList <ArrayList <String>> ());
    }
    */
  }
  
  
  
  void AddSavePoint() {
    //if (SavedPages.size() > 0 && SavedPages.get(SavedPages.size() - 1).equals(PageManager.CurrentPage)) return; // No need to add save point when no change has been made // Actually, this should be handled by whatever is calling this function
    while (CurrentIndex < SavedPages.size() - 1) { // If changes were undone, remove all undone changes before adding to history
      SavedPages.remove (SavedPages.size() - 1);
      SavedPageNames.remove (SavedPages.size());
    }
    SavedPages.add ((ArrayList <String>) PageManager.CurrentPage.clone());
    SavedPageNames.add ((ArrayList <String>) PageManager.AllPageNames.clone());
    CurrentIndex ++;
  }
  
  
  
  void Undo() {
    CurrentIndex --;
    PageManager.CurrentPage = (ArrayList <String>) SavedPages.get (CurrentIndex).clone();
    PageManager.AllPageNames = (ArrayList <String>) SavedPageNames.get (CurrentIndex).clone();
    UpdateAll();
  }
  
  
  
  void Redo() {
    CurrentIndex ++;
    PageManager.CurrentPage = (ArrayList <String>) SavedPages.get (CurrentIndex).clone();
    PageManager.AllPageNames = (ArrayList <String>) SavedPageNames.get (CurrentIndex).clone();
    UpdateAll();
  }
  
  
  
  void UpdateAll() {
    PageManager.ChangesSaved = false;
    PageManager.CalcTotal();
    ResetValueElements();
  }
  
  
  
  void Reset() {
    SavedPages = new ArrayList <ArrayList <String>> ();
    SavedPageNames = new ArrayList <ArrayList <String>> ();
    CurrentIndex = -1;
  }
  
  
  
  /*
  void SwitchToPage (String NewPageName) {
    
    boolean Found = false;
    for (int i = 0; i < SavedUndoChainNames.size(); i ++) {
      if (SavedUndoChainNames.get(i).equals(NewPageName)) {
        SavedPages = AllSavedPages.get(i);
        Found = true;
        break;
      }
    }
    
    if (!Found) println ("Error: " + NewPageName + " was not found");
    
  }
  */
  
  
  
}
