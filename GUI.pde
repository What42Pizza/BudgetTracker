GUI_Element GUI_Main;

GUI_Element GUI_ExitButton;

GUI_Element GUI_PageSelector;
GUI_Element GUI_PageSelector_BackButton;

GUI_Element GUI_PageEditor;

GUI_Element GUI_PageEditor_PageName;
GUI_Element GUI_PageEditor_SaveButton;
GUI_Element GUI_PageEditor_UndoButton;
GUI_Element GUI_PageEditor_RedoButton;
GUI_Element GUI_PageEditor_NewPageButton;
GUI_Element GUI_PageEditor_SelectPageButton;
GUI_Element GUI_PageEditor_Total;
int SaveButton_FramesUntilReset = -1;
String PrevPageName = null;

GUI_Element GUI_PageEditor_AddValueButton;
GUI_Element GUI_PageEditor_RemoveValueButton;
GUI_Element GUI_PageEditor_ValuePreset;
GUI_Element GUI_PageEditor_AllValues;

GUI_Element GUI_ConfirmExitWindow;
GUI_Element GUI_ConfirmExitWindow_ExitButton;

GUI_Element GUI_SaveBeforeExitWindow;
GUI_Element GUI_SaveBeforeExitWindow_ExitWSavingButton;

GUI_Element GUI_SaveBeforeNewPageWindow;
GUI_Element GUI_SBNPW_CreatePageWOSavingButton;
GUI_Element GUI_SBNPW_CreatePageWSavingButton;





void InitGUI() {
  
  
  
  // Load GUI and set vars
  
  GUI_Main = new GUI_Element (new File (dataPath("") + "/GUI"));
  
  GUI_ExitButton = GUI_Main.Child("ExitButton");
  
  GUI_PageSelector = GUI_Main.Child("PageSelector");
  GUI_PageSelector_BackButton = GUI_PageSelector.Child("BackButton");
  
  GUI_PageEditor = GUI_Main.Child("PageEditor");
  
  GUI_PageEditor_PageName = GUI_PageEditor.Child("PageName");
  GUI_PageEditor_SaveButton = GUI_PageEditor.Child("SaveButton");
  GUI_PageEditor_UndoButton = GUI_PageEditor.Child("UndoButton");
  GUI_PageEditor_RedoButton = GUI_PageEditor.Child("RedoButton");
  GUI_PageEditor_NewPageButton = GUI_PageEditor.Child("NewPageButton");
  GUI_PageEditor_SelectPageButton = GUI_PageEditor.Child("SelectPageButton");
  GUI_PageEditor_Total = GUI_PageEditor.Child("TotalText");
  
  GUI_Element ValuesFrame = GUI_PageEditor.Child("ValuesFrame");
  GUI_PageEditor_AllValues = ValuesFrame.Child("AllValues");
  GUI_PageEditor_AddValueButton = ValuesFrame.Child("AddValueButton");
  GUI_PageEditor_RemoveValueButton = ValuesFrame.Child("RemoveValueButton");
  GUI_PageEditor_ValuePreset = ValuesFrame.Child("ValuePreset");
  
  GUI_Element Windows = GUI_Main.Child("Windows");
  
  GUI_ConfirmExitWindow = Windows.Child("ConfirmExitWindow");
  GUI_ConfirmExitWindow_ExitButton = GUI_ConfirmExitWindow.Child("MainWindow").Child("ExitButton");
  
  GUI_SaveBeforeExitWindow = Windows.Child("SaveBeforeExitWindow");
  GUI_SaveBeforeExitWindow_ExitWSavingButton = GUI_SaveBeforeExitWindow.Child("MainWindow").Child("ExitWithSavingButton");
  
  GUI_SaveBeforeNewPageWindow = Windows.Child("SaveBeforeNewPageWindow");
  GUI_SBNPW_CreatePageWOSavingButton = GUI_SaveBeforeNewPageWindow.Child("MainWindow").Child("CreatePageWithoutSavingButton");
  GUI_SBNPW_CreatePageWSavingButton = GUI_SaveBeforeNewPageWindow.Child("MainWindow").Child("CreatePageWithSavingButton");
  
  
  
  // Set button actions
  
  
  // ConfirmExitWindow.ExitButton
  GUI_ConfirmExitWindow_ExitButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    if (PageManager.ChangesSaved) {
      Close(); // Not needed because exit() calls dispose() which calls close()
    } else {
      GUI_SaveBeforeExitWindow.Enabled = true;
    }
  }};
  
  
  // SaveBeforeExitWindow.ExitWSavingButton
  GUI_SaveBeforeExitWindow_ExitWSavingButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.SaveCurrentPage();
    Close();
  }};
  
  
  // SaveBeforeNewPageWindow_CreatePagWSavingButton
  GUI_SBNPW_CreatePageWSavingButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.SaveCurrentPage();
    PageManager.CreateBasicPage();
    History.AddSavePoint();
    PageManager.ChangesSaved = false;
    GUI_SaveBeforeNewPageWindow.Enabled = false;
    GUI_SBNPW_CreatePageWSavingButton.Pressed = false;
  }};
  
  
  // SaveBeforeNewPageWindow_CreatePageWOSavingButton
  GUI_SBNPW_CreatePageWOSavingButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.CreateBasicPage();
    History.AddSavePoint();
    PageManager.ChangesSaved = false;
    GUI_SaveBeforeNewPageWindow.Enabled = false;
    GUI_SBNPW_CreatePageWOSavingButton.Pressed = false;
  }};
  
  
  // NewPageButton
  GUI_PageEditor_NewPageButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    if (PageManager.ChangesSaved) {
      PageManager.CreateBasicPage();
      PageManager.ResetGUIElements();
      History.AddSavePoint();
      PageManager.ChangesSaved = false;
    } else {
      GUI_SaveBeforeNewPageWindow.Enabled = !GUI_SaveBeforeNewPageWindow.Enabled;
    }
  }};
  
  
  // SelectPageButton
  GUI_PageEditor_SelectPageButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    GUI_PageEditor.Enabled = false;
    GUI_PageSelector.Enabled = true;
    CloseAllWindows();
  }};
  
  
  // SaveButton
  GUI_PageEditor_SaveButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.SaveCurrentPage();
    GUI_PageEditor_SaveButton.Text = "Saved!";
    SaveButton_FramesUntilReset = (int) frameRate; // Wait ~1 second
  }};
  
  
  // PageEditor.AddValueButton
  GUI_PageEditor_AddValueButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    String NewValue = GUI_PageEditor_ValuePreset.Child("TextBox").Text;
    AddValueElement (NewValue);
    PageManager.CurrentPage.add (NewValue);
    History.AddSavePoint();
    PageManager.ChangesSaved = false;
  }};
  
  
  // PageEditor.RemoveValueButton
  GUI_PageEditor_RemoveValueButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    if (PageManager.CurrentPage.size() > 1) RemoveLastValue();
  }};
  
  
  // PageEditor.ValuePreset.TextBox
  GUI_PageEditor_ValuePreset.Child("TextBox").OnTextFinished = new Action() {@Override public void Run (GUI_Element This) {
    int Index = int (This.Parent.Name);
    String OldValue = PageManager.CurrentPage.get (Index);
    String NewValue = This.Text;
    if (!OldValue.equals(NewValue)) { // Only update if text has changed
      PageManager.CurrentPage.remove (Index);
      PageManager.CurrentPage.add (Index, NewValue);
      PageManager.CalcTotal();
      PageManager.ChangesSaved = false;
      History.AddSavePoint();
    }
  }};
  
  
  
  // PageSelector.BackButton
  GUI_PageSelector_BackButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    GUI_PageSelector.Enabled = false;
    GUI_PageEditor.Enabled = true;
    CloseAllWindows();
  }};
  
  
  
}





void RenderGUI() {
  
  GUI_Element HoveredWindow = GetHoveredWindow();
  
  // Set only the highest window as draggable
  SetDraggables (HoveredWindow);
  
  UpdateGlobalElements();
  if (GUI_PageEditor.Enabled) UpdatePageEditorElements();
  
  GUI_Main.Render();
  
}





void UpdateGlobalElements() {
  
  
  // SaveButton
  if (SaveButton_FramesUntilReset > 0) {
    SaveButton_FramesUntilReset --;
    if (SaveButton_FramesUntilReset == 0) {
      GUI_PageEditor_SaveButton.Text = "Save";
      //SaveButton_FramesUntilReset = -1;
    }
  } else { // I don't want SaveButton to change until the text has been reset
    GUI_PageEditor_SaveButton.BackgroundColor = PageManager.ChangesSaved ? color (79) : color (127);
    GUI_PageEditor_SaveButton.CanBePressed = !PageManager.ChangesSaved;
  }
  
  
  // UndoButton
  if (History.CurrentIndex > 0) {
    GUI_PageEditor_UndoButton.CanBePressed = true;
    GUI_PageEditor_UndoButton.BackgroundColor = color (127);
    if (GUI_PageEditor_UndoButton.JustClicked()) {
      History.Undo();
    }
  } else {
    GUI_PageEditor_UndoButton.CanBePressed = false;
    GUI_PageEditor_UndoButton.Pressed = false;
    GUI_PageEditor_UndoButton.BackgroundColor = color (79);
  }
  
  
  // RedoButton
  if (History.CurrentIndex < History.SavedPages.size() - 1) {
    GUI_PageEditor_RedoButton.CanBePressed = true;
    GUI_PageEditor_RedoButton.BackgroundColor = color (127);
    if (GUI_PageEditor_RedoButton.JustClicked()) {
      History.Redo();
    }
  } else {
    GUI_PageEditor_RedoButton.CanBePressed = false;
    GUI_PageEditor_RedoButton.Pressed = false;
    GUI_PageEditor_RedoButton.BackgroundColor = color (79);
  }
  
  
}





void UpdatePageEditorElements() {
  
  
  // PageName
  GUI_Element PageName = GUI_PageEditor_PageName;
  if (PageName.UserStoppedEditingText() && !PageName.Text.equals(PageManager.CurrentPage.get(0))) {
    PageManager.SetPageName (PageName.Text);
    History.AddSavePoint();
    PageManager.ChangesSaved = false;
  }
  if (!PageName.TextIsBeingEdited) {
    PageName.Text = PageManager.CurrentPage.get(0);
    PageName.PlaceholderText = PageName.Text;
  }
  
  
  // Value.RemoveButtons
  for (int i = 0; i < GUI_PageEditor_AllValues.Children.size(); i ++) {
    GUI_Element E = GUI_PageEditor_AllValues.Children.get(i);
    if (E.Child("RemoveButton").JustClicked()) {
      PageManager.CurrentPage.remove (i + 1);
      RemoveValueElement (i, E);
      History.AddSavePoint();
      PageManager.ChangesSaved = false;
      i --;
    }
  }
  
  
}





void AddValueElement (String Value) {
  
  // Create element
  GUI_Element NewValueElement = (GUI_Element) GUI_PageEditor_ValuePreset.clone();
  
  // Set data
  int NewValueIndex = GUI_PageEditor_AllValues.Children.size();
  NewValueElement.Child("TextBox").Text = Value;
  NewValueElement.Name = Integer.toString (NewValueIndex + 1);
  NewValueElement.YPos = NewValueIndex * 0.1;
  NewValueElement.Enabled = true;
  
  // Add element
  GUI_PageEditor_AllValues.AddChild(NewValueElement);
  
  // Finish
  SetValuesFrameScroll();
  
}



void RemoveValueElement (int Index, GUI_Element ElementToDelete) {
  
  // Remove element
  ElementToDelete.Delete();
  
  // Move continuing elements
  for (int i = Index + 2; i < PageManager.CurrentPage.size() + 1; i ++) {
    GUI_Element ElementToMove = GUI_PageEditor_AllValues.Child(Integer.toString (i));
    ElementToMove.YPos = (i - 2) * 0.1;
    ElementToMove.Name = Integer.toString (i - 1);
  }
  
  // Finsih
  SetValuesFrameScroll();
  
}



void RemoveLastValue() {
  
  // Remove value & element
  int Index = PageManager.CurrentPage.size() - 1;
  PageManager.CurrentPage.remove (Index);
  RemoveValueElement (Index, GUI_PageEditor_AllValues.Child (Integer.toString (Index)));
  
  // Finish
  History.AddSavePoint();
  PageManager.ChangesSaved = false;
  
}



void SetValuesFrameScroll() {
  int NumOfValues = GUI_PageEditor_AllValues.Children.size();
  GUI_PageEditor_AllValues.MaxScrollY = max (NumOfValues * 0.1 - 0.975, 0);
  GUI_PageEditor_AllValues.ConstrainScroll();
}










void SetDraggables (GUI_Element HoveredWindow) {
  
  // Reset all
  if (!GUI_ConfirmExitWindow.IsDragging) GUI_ConfirmExitWindow.Draggable = false;
  if (!GUI_SaveBeforeExitWindow.IsDragging) GUI_SaveBeforeExitWindow.Draggable = false;
  if (!GUI_SaveBeforeNewPageWindow.IsDragging) GUI_SaveBeforeNewPageWindow.Draggable = false;
  
  // Set Hovered as draggable
  if (HoveredWindow != null) {
    HoveredWindow.Draggable = true;
  }
  
}





GUI_Element GetHoveredWindow() {
  if (WindowIsHovered (GUI_SaveBeforeExitWindow   )) return GUI_SaveBeforeExitWindow   ;
  if (WindowIsHovered (GUI_ConfirmExitWindow      )) return GUI_ConfirmExitWindow      ;
  if (WindowIsHovered (GUI_SaveBeforeNewPageWindow)) return GUI_SaveBeforeNewPageWindow;
  return null;
}

boolean WindowIsHovered (GUI_Element WindowToCheck) {
  return WindowToCheck.Enabled && WindowToCheck.HasMouseHovering();
}





void CloseAllWindows() {
  GUI_ConfirmExitWindow.Enabled = false;
  GUI_SaveBeforeExitWindow.Enabled = false;
  GUI_SaveBeforeNewPageWindow.Enabled = false;
}