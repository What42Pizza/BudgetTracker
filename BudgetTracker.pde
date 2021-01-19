// Started 01/06/20
// Last updated 01/19/20

// B 1.3.0





/*

Change log:

B 1.3.0: 01/19/21
More work on page editor (almost done)

B 1.2.0: 01/18/21
More work on page editor

B 1.1.0: 01/16/21
Started work on new page editor

B 1.0.0: 01/15/21
Deleted old page editor
Updated page manager to use new page system

A 1.1.0: 01/14/21
Finished page selector (mostly)
Fixed many bugs
Made many small improvements

A 1.0.0: 01/13/21
Finished page editor (mostly)

*/










// Stuff for Processing GUI System 2

GUI_Functions GUIFunctions = new GUI_Functions();

boolean EscKeyPressed = false;
boolean[] Keys = new boolean [128];
boolean[] PrevKeys = new boolean [128];

void keyPressed() {
  if (key < 128) Keys[key] = true;
  GUIFunctions.keyPressed();
  if (key == 27) {
    EscKeyPressed = true;
    key = 0;
  }
  if (key == 10) OnEnterKeyPressed();
  /*
  if (key == 'a') {
    println();
    println();
    println();
    println ("All Page Names:");
    for (String S : PageManager.AllPageNames) println (S);
  }
  */
}

void keyReleased() {
  GUIFunctions.keyReleased();
  if (key < 128) Keys[key] = false;
}

void mouseWheel (MouseEvent E) {
  GUIFunctions.mouseWheel(E);
}










void setup() {
  
  background (255);
  frameRate (30);
  
}



void settings() {
  
  Settings.Init();
  PageManager.BasicInit();
  InitGUI();
  PageManager.Init();
  History.Init();
  
  if (Settings.GetBool("fullscreen", false)) {
    fullScreen();
  } else {
    String Size = Settings.GetString ("window size", "1200x675");
    String[] ResolutionInStrings = Size.split("x");
    if (ResolutionInStrings.length == 2) {
      int[] Resolution = CastStringsToInts (ResolutionInStrings);
      size (Resolution[0], Resolution[1]);
    } else {
      println ("Error: the setting " + '"' + "window size" + '"' + " has to be formatted as two numbers directly joined with an x (example: " + '"' + "window size: 100x100" + '"' + ").");
      exit();
    }
  }
  
  /*
  println ("CurrentPage.Name: " + PagesManager.CurrentPage.get(0));
  for (int i = 1; i < PagesManager.CurrentPage.size(); i ++) {
    println (PagesManager.CurrentPage.get(i));
  }
  */
  
}










void draw() {
  
  background (255);
  
  GUIFunctions.EscKeyUsed = false;
  RenderGUI();
  
  if (EscKeyPressed && !GUIFunctions.EscKeyUsed) OnEscKeyPressed();
  GUIFunctions.EscKeyUsed = false;
  EscKeyPressed = false;
  
  PrevKeys = Keys.clone();
  
}











void Close() {
  //println ("Closing...");
  //Settings.SetDataString ("latest page", PageManager.CurrentPage.get(0)); // This shouldn't be used because you can exit without saving the current page
  Settings.UpdateDataFile();
  exit();
}





void OnEscKeyPressed() {
  
  // Exit windows
  if (TryClose (GUI_SaveBeforeExitWindow   )) return;
  if (TryClose (GUI_ConfirmExitWindow      )) return;
  
  // Other windows
  if (TryClose (GUI_SaveBeforeNewPageWindow)) return;
  
  // Else: enable ConfirmExitWindow
  GUI_ConfirmExitWindow.Enabled = true;
  return;
  
}



boolean TryClose (GUI_Element WindowToClose) {
  if (WindowToClose.Enabled) {
    WindowToClose.Enabled = false;
    return true;
  }
  return false;
}





void OnEnterKeyPressed() {
  
  if (GUI_SaveBeforeExitWindow.Enabled) {
    GUI_SaveBeforeExitWindow_ExitWSavingButton.OnButtonPressed.Run (null); // Normally you shouldn't pass null here, but I made the Run function and I know it isn't used
    return;
  }
  
  if (GUI_ConfirmExitWindow.Enabled) {
    GUI_ConfirmExitWindow_ExitButton.OnButtonPressed.Run (null);
    return;
  }
  
  if (GUI_SaveBeforeNewPageWindow.Enabled) {
    GUI_SBNPW_CreatePageWSavingButton.OnButtonPressed.Run (null);
    return;
  }
  
}





boolean KeyJustPressed (int Key) {
  return Keys[Key] && !PrevKeys[Key];
}





public void dispose() {
  // https://discourse.processing.org/t/how-do-you-detect-stop-someone-from-closing-the-sketch/26864
  Close();
  super.dispose();
}
