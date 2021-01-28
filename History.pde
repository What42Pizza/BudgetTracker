// This keeps track of all the changes so they can be undone and redone



HistorySystem History = new HistorySystem() {
  
  @Override public Cloneable_AsClass GetCloneable() {
    return PageManager;
  }
  
  @Override public void SetCloneable (Cloneable_AsClass NewCloneable) {
    PageManager = (PageManager_Class) NewCloneable;
    PageManager.ChangesSaved = false;
    ResetValueElements();
    PageManager.CalcTotals();
  }
  
};










abstract class Cloneable_AsClass implements Cloneable {
  public Object clone() {
    try {return super.clone();} catch (CloneNotSupportedException e) {return null;}
  }
}



class HistorySystem {
  
  
  
  // Needs to be overridden
  
  public Cloneable_AsClass GetCloneable() {
    return null;
  }
  
  public void SetCloneable (Cloneable_AsClass NewCloneable) {
    
  }
  
  
  
  
  
  ArrayList <Cloneable_AsClass> SavedCloneables;
  int CurrentIndex = -1;
  int MaxUndoChain = 100;
  
  
  
  void AddSavePoint() {
    //if (SavedPages.size() > 0 && SavedPages.get(SavedPages.size() - 1).equals(PageManager.CurrentPage)) return; // No need to add save point when no change has been made // Actually, this should be handled by whatever is calling this function
    while (CurrentIndex < SavedCloneables.size() - 1) { // If changes were undone, remove all undone changes before adding to history
      SavedCloneables.remove (SavedCloneables.size() - 1);
    }
    SavedCloneables.add ((Cloneable_AsClass) GetCloneable().clone());
    if (SavedCloneables.size() > MaxUndoChain) SavedCloneables.remove (0);
    CurrentIndex ++;
  }
  
  
  
  void Undo() {
    CurrentIndex --;
    SetCloneable ((Cloneable_AsClass) SavedCloneables.get(CurrentIndex).clone());
  }
  
  void Redo() {
    CurrentIndex ++;
    SetCloneable ((Cloneable_AsClass) SavedCloneables.get(CurrentIndex).clone());
  }
  
  
  
  boolean CanUndo() {
    return CurrentIndex > 0;
  }
  
  boolean CanRedo() {
    return CurrentIndex < SavedCloneables.size() - 1;
  }
  
  
  
  void Reset() {
    SavedCloneables = new ArrayList <Cloneable_AsClass> ();
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
