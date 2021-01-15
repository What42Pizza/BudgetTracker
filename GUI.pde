GUI_Element GUI_Main;

GUI_Element GUI_ExitButton;

GUI_Element GUI_PageSelector;

GUI_Element GUI_PageSelector_BackButton;
GUI_Element GUI_PageSelector_CreatePageButton;
GUI_Element GUI_PageSelector_PagePreset;
GUI_Element GUI_PageSelector_AllPages;

GUI_Element GUI_PageEditor;

GUI_Element GUI_PageEditor_PageName;
GUI_Element GUI_PageEditor_SaveButton;
GUI_Element GUI_PageEditor_UndoButton;
GUI_Element GUI_PageEditor_RedoButton;
GUI_Element GUI_PageEditor_NewPageButton;
GUI_Element GUI_PageEditor_SelectPageButton;
int SaveButton_FramesUntilReset = -1;
String PrevPageName = null;

GUI_Element GUI_ConfirmExitWindow;
GUI_Element GUI_ConfirmExitWindow_ExitButton;

GUI_Element GUI_SaveBeforeExitWindow;
GUI_Element GUI_SaveBeforeExitWindow_ExitWSavingButton;

GUI_Element GUI_SaveBeforeNewPageWindow;
GUI_Element GUI_SBNPW_CreatePageWOSavingButton;
GUI_Element GUI_SBNPW_CreatePageWSavingButton;

GUI_Element GUI_SaveBeforePageMoveWindow;
GUI_Element GUI_SBPMW_MoveWSavingButton;
GUI_Element GUI_SBPMW_MoveWOSavingButton;
GUI_Element GUI_SBPMW_SelectedPageName;





void InitGUI() {
  
  
  
  // Load GUI and set vars
  
  GUI_Main = new GUI_Element (new File (dataPath("") + "/GUI"));
  
  GUI_ExitButton = GUI_Main.Child("ExitButton");
  
  GUI_PageSelector = GUI_Main.Child("PageSelector");
  
  GUI_Element PagesFrame = GUI_PageSelector.Child("PagesFrame");
  GUI_PageSelector_BackButton = GUI_PageSelector.Child("BackButton");
  GUI_PageSelector_CreatePageButton = PagesFrame.Child("CreatePageButton");
  GUI_PageSelector_PagePreset = PagesFrame.Child("PagePreset");
  GUI_PageSelector_AllPages = PagesFrame.Child("AllPages");
  
  GUI_PageEditor = GUI_Main.Child("PageEditor");
  
  GUI_PageEditor_PageName = GUI_PageEditor.Child("PageName");
  GUI_PageEditor_SaveButton = GUI_PageEditor.Child("SaveButton");
  GUI_PageEditor_UndoButton = GUI_PageEditor.Child("UndoButton");
  GUI_PageEditor_RedoButton = GUI_PageEditor.Child("RedoButton");
  GUI_PageEditor_NewPageButton = GUI_PageEditor.Child("NewPageButton");
  GUI_PageEditor_SelectPageButton = GUI_PageEditor.Child("SelectPageButton");
  
  GUI_Element Windows = GUI_Main.Child("Windows");
  
  GUI_ConfirmExitWindow = Windows.Child("ConfirmExitWindow");
  GUI_ConfirmExitWindow_ExitButton = GUI_ConfirmExitWindow.Child("MainWindow").Child("ExitButton");
  
  GUI_SaveBeforeExitWindow = Windows.Child("SaveBeforeExitWindow");
  GUI_SaveBeforeExitWindow_ExitWSavingButton = GUI_SaveBeforeExitWindow.Child("MainWindow").Child("ExitWithSavingButton");
  
  GUI_SaveBeforeNewPageWindow = Windows.Child("SaveBeforeNewPageWindow");
  GUI_SBNPW_CreatePageWOSavingButton = GUI_SaveBeforeNewPageWindow.Child("MainWindow").Child("CreatePageWithoutSavingButton");
  GUI_SBNPW_CreatePageWSavingButton = GUI_SaveBeforeNewPageWindow.Child("MainWindow").Child("CreatePageWithSavingButton");
  
  GUI_SaveBeforePageMoveWindow = Windows.Child("SaveBeforePageMoveWindow");
  GUI_SBPMW_MoveWSavingButton = GUI_SaveBeforePageMoveWindow.Child("MainWindow").Child("MovePageWithSavingButton");
  GUI_SBPMW_MoveWOSavingButton = GUI_SaveBeforePageMoveWindow.Child("MainWindow").Child("MovePageWithoutSavingButton");
  GUI_SBPMW_SelectedPageName = GUI_SaveBeforePageMoveWindow.Child("SelectedPageName");
  
  
  
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
    PageManager.Save();
    Close();
  }};
  
  
  // SaveBeforeNewPageWindow_CreatePagWSavingButton
  GUI_SBNPW_CreatePageWSavingButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.Save();
    GUI_SBNPW_CreatePageWOSavingButton.OnButtonPressed.Run (null);
    GUI_SBNPW_CreatePageWSavingButton.Pressed = false; // Wait is this really needed?
  }};
  
  
  // SaveBeforeNewPageWindow_CreatePageWOSavingButton
  GUI_SBNPW_CreatePageWOSavingButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.CreateBasicPage();
    ResetValueElements();
    History.AddSavePoint();
    PageManager.ChangesSaved = false;
    GUI_SaveBeforeNewPageWindow.Enabled = false;
    GUI_SBNPW_CreatePageWOSavingButton.Pressed = false;
    GUI_PageSelector.Enabled = false; // This is needed because of PageSelector.CreatePageButton
    GUI_PageEditor.Enabled = true;
    CloseAllWindows();
  }};
  
  
  // SaveBeforePageMoveWindow.MoveWSavingButton
  GUI_SBPMW_MoveWSavingButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.Save();
    GUI_SBPMW_MoveWOSavingButton.OnButtonPressed.Run (null);
  }};
  
  
  // SaveBeforePageMoveWindow.MoveWOSavingButton
  GUI_SBPMW_MoveWOSavingButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.LoadPage (GUI_SBPMW_SelectedPageName.Text);
      GUI_PageSelector.Enabled = false;
      GUI_PageEditor.Enabled = true;
      CloseAllWindows();
  }};
  
  
  
  
  
  // NewPageButton
  GUI_PageEditor_NewPageButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    if (PageManager.ChangesSaved) {
      GUI_SBNPW_CreatePageWOSavingButton.OnButtonPressed.Run (null);
    } else {
      GUI_SaveBeforeNewPageWindow.Enabled = !GUI_SaveBeforeNewPageWindow.Enabled;
    }
  }};
  
  
  // SelectPageButton
  GUI_PageEditor_SelectPageButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    GUI_PageEditor.Enabled = false;
    GUI_PageSelector.Enabled = true;
    ResetPageElements();
    CloseAllWindows();
  }};
  
  
  // SaveButton
  GUI_PageEditor_SaveButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    PageManager.Save();
    GUI_PageEditor_SaveButton.Text = "Saved!";
    SaveButton_FramesUntilReset = (int) frameRate; // Wait ~1 second
  }};
  
  
  
  
  
  // PageSelector.BackButton
  GUI_PageSelector_BackButton.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    GUI_PageSelector.Enabled = false;
    GUI_PageEditor.Enabled = true;
    CloseAllWindows();
  }};
  
  
  // PageSelector.CreatePageButton
  GUI_PageSelector_CreatePageButton.OnButtonPressed = GUI_PageEditor_NewPageButton.OnButtonPressed;
  
  
  // PageSelector.PagePreset
  GUI_PageSelector_PagePreset.OnButtonPressed = new Action() {@Override public void Run (GUI_Element This) {
    if (PageManager.ChangesSaved) {
      PageManager.LoadPage (This.Text);
      GUI_PageSelector.Enabled = false;
      GUI_PageEditor.Enabled = true;
    } else {
      GUI_SBPMW_SelectedPageName.Text = This.Text;
      GUI_SaveBeforePageMoveWindow.Enabled = true;
    }
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
    PageName.Text = PageManager.PageName;
    PageName.PlaceholderText = PageName.Text;
  }
  
  
}










void ResetValueElements() {
  println ("WIP: ResetValueElements");
}










void ResetPageElements() {
  GUI_PageSelector_AllPages.DeleteChildren();
  for (int i = 0; i < PageManager.AllPageNames.size(); i ++) {
    AddPageElement (PageManager.AllPageNames.get(i));
  }
}



void AddPageElement (String PageName) {
  
  // Create element
  GUI_Element NewPageElement = (GUI_Element) GUI_PageSelector_PagePreset.clone();
  
  // Set element data
  int NewValueIndex = GUI_PageSelector_AllPages.Children.size();
  NewPageElement.Text = PageName;
  NewPageElement.Name = Integer.toString (NewValueIndex + 1);
  NewPageElement.YPos = NewValueIndex * 0.11 + 0.02;
  NewPageElement.Enabled = true;
  
  // Add element
  GUI_PageSelector_AllPages.AddChild(NewPageElement);
  
  // Finish
  SetPagesFrameScroll();
  
}



void SetPagesFrameScroll() {
  int NumOfValues = GUI_PageSelector_AllPages.Children.size();
  GUI_PageSelector_AllPages.MaxScrollY = max (NumOfValues * 0.1 - 0.975, 0);
  GUI_PageSelector_AllPages.ConstrainScroll();
}










void SetDraggables (GUI_Element HoveredWindow) {
  
  // Reset all
  if (!GUI_ConfirmExitWindow.IsDragging) GUI_ConfirmExitWindow.Draggable = false;
  if (!GUI_SaveBeforeExitWindow.IsDragging) GUI_SaveBeforeExitWindow.Draggable = false;
  if (!GUI_SaveBeforeNewPageWindow.IsDragging) GUI_SaveBeforeNewPageWindow.Draggable = false;
  if (!GUI_SaveBeforePageMoveWindow.IsDragging) GUI_SaveBeforePageMoveWindow.Draggable = false;
  
  // Set Hovered as draggable
  if (HoveredWindow != null) {
    HoveredWindow.Draggable = true;
  }
  
}





GUI_Element GetHoveredWindow() {
  if (WindowIsHovered (GUI_SaveBeforeExitWindow    )) return GUI_SaveBeforeExitWindow    ;
  if (WindowIsHovered (GUI_ConfirmExitWindow       )) return GUI_ConfirmExitWindow       ;
  if (WindowIsHovered (GUI_SaveBeforeNewPageWindow )) return GUI_SaveBeforeNewPageWindow ;
  if (WindowIsHovered (GUI_SaveBeforePageMoveWindow)) return GUI_SaveBeforePageMoveWindow;
  return null;
}

boolean WindowIsHovered (GUI_Element WindowToCheck) {
  return WindowToCheck.Enabled && WindowToCheck.HasMouseHovering();
}





void CloseAllWindows() {
  GUI_ConfirmExitWindow.Enabled = false;
  GUI_SaveBeforeExitWindow.Enabled = false;
  GUI_SaveBeforeNewPageWindow.Enabled = false;
  GUI_SaveBeforePageMoveWindow.Enabled = false;
}
