{***************************************************************************}
{  TurboBird: FireBird database administration and management tool          }
{  Started by  : Motaz Abdel Azeem http://code.sd/                          }
{  Start development :  5.Dec.2009                                          }
{  Last updated      : 18.Apr.2015                                          }
{  License           : GPL for GUI, LGPL for Units                          }
{***************************************************************************}

program TurboBird;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  cmem,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Controls, mdolaz, virtualtreeview_package, memdslaz, lazcontrols, dynlibs, ibase60dyn, sysutils, sqldblib, SysTables, Scriptdb,
  topologicalsort, utbConfig, fileimport, UnitFirebirdServices, uTBTypes, uTBFirebird, utbcommon, csvdocument, uTBDBRegistry, dbInfo, main,
  QueryWindow, Reg, UDFInfo, About, BackupRestore, Calen, CallProc, ChangePass, Comparison, CopyTable, CreateDb, CreateUser, EditDataFullRec,
  EditTable, uLoginForm, NewConstraint, NewDomain, NewEditField, NewGen, NewTable, PermissionManage, SQLHistory, TableManage, Update, UserPermissions,
  uTBOptionsform, ViewDomain, ViewGen, ViewSProc, ViewTrigger, ViewView, ufrFontEditor, uEvsDBSchema, uevsGenIntf, ufrDatabaseEdit, uTbDialogs;

const
  Major   = 1;
  Minor   = 2;
  Release = 1;

  VersionDate = '2010 - Jan 2015';
{$IFDEF Unix}
{$DEFINE extdecl:=cdecl}
    fbclib = 'libfbclient.' + sharedsuffix + '.2';
{$ENDIF}
{$IFDEF Windows}
  {$DEFINE extdecl:=stdcall}
   fbclib = 'fbembed.dll'; //allows both embedded and client/server access
   seclib = 'fbclient.dll'; //only client/server access
   thirdlib = 'gds32.dll'; //could be Firebird, could be old Interbase library...
{$ENDIF}

{$R *.res}

var
  SAbout             :TfmAbout;
  ErrorMessage       :widestring;
  IBaseLibraryHandle :TLibHandle;
  {$IFDEF UNIX}
  SLib : TSQLDBLibraryLoader;
  {$ENDIF}
begin
  Application.Initialize;

  // Load library using SQLDBLibraryLoader in Linux, OSX,...
  {$IFDEF UNIX}
  SLib:= TSQLDBLibraryLoader.Create(nil);
  SLib.ConnectionType:= 'Firebird';
  SLib.LibraryName:= 'libfbclient.so.2'; //todo: is this correct for OSX?
  SLib.Enabled:= True;
  {$ENDIF}

  {$IFDEF DEBUG}
  // Requires the build mode to set -dDEBUG in Project Options/Other and
  // defining -gh/heaptrace on
  // This avoids interference when running a production/default build without -gh

  // Set up -gh output for the Leakview package:
  if FileExists('heap.trc') then
    DeleteFile('heap.trc');
  SetHeapTraceOutput('heap.trc');
  {$ENDIF DEBUG}
  IBaseLibraryHandle:= LoadLibrary(fbclib);
// search for all compatible FireBird libraries in Windows
  {$IFDEF Windows}
  if IBaseLibraryHandle = NilHandle then
    IBaseLibraryHandle:= LoadLibrary(seclib);
  if IBaseLibraryHandle = NilHandle then
    IBaseLibraryHandle:= LoadLibrary(thirdlib);
  {$ENDIF}

  // Check Firebird library existence
  if (IBaseLibraryHandle = nilhandle) then
  begin
    ErrorMessage:= Format('Unable to load Firebird library: %s.' + LineEnding +
      'Please follow the Firebird documentation to install the Firebird client on your system.',
      [fbclib]);
    {$IFDEF WINDOWS}
    // More libraries and additional hint
    ErrorMessage:= Format('Unable to load Firebird library: %s.' + LineEnding +
      'Please follow the Firebird documentation to install the Firebird client on your system.' + LineEnding +
      'Hint: you could copy the fbclient/fbembed.dll and associated dlls into the TurboBird directory.',
      [fbclib+'/'+seclib+'/'+thirdlib]);
    {$ENDIF}
    Application.MessageBox(PChar(ErrorMessage), 'Warning', 0);
  end;

  SAbout:= TfmAbout.Create(nil);
  SAbout.BorderStyle:= bsNone;
  SAbout.BitBtn1.Visible:= False;
  SAbout.Show;
  Application.ProcessMessages;
  Application.ExceptionDialog := aedOkMessageBox;
  SAbout.Update;
  Application.CreateForm(TdmSysTables, dmSysTables);
  Application.CreateForm(TfmMain, fmMain);
  //fmMain.Version:= Format('%d.%d.%d', [Major, Minor, Release]);
  fmMain.StatusBar1.Panels[1].Text:= 'Version: ' + Format('%d.%d.%d', [Major, Minor, Release]);//fmMain.Version;
  //fmMain.VersionDate:= VersionDate;
  //fmMain.Major:= Major;
  //fmMain.Minor:= Minor;
  //fmMain.ReleaseVersion:= Release;
  SAbout.Free;
  //Application.CreateForm(TfmCreateDB, fmCreateDB);
  //Application.CreateForm(TfmReg, fmReg);
  //Application.CreateForm(TfmNewGen, fmNewGen);
  //Application.CreateForm(TfmEnterPass, fmEnterPass);
  //Application.CreateForm(TfmCreateTrigger, fmCreateTrigger);
  //Application.CreateForm(TfmEditTable, fmEditTable);
  //Application.CreateForm(TfmCallProc, fmCallProc);
  //Application.CreateForm(TfmEditDataFullRec, fmEditDataFullRec);
  //Application.CreateForm(TfmNewDomain, fmNewDomain);
  //Application.CreateForm(TdmSysTables, dmSysTables);
  //Application.CreateForm(TfmNewConstraint, fmNewConstraint);
  //Application.CreateForm(TfmCalen, fmCalen);
  //Application.CreateForm(TfmBackupRestore, fmBackupRestore);
  //Application.CreateForm(TfmCreateUser, fmCreateUser);
  //Application.CreateForm(TfmChangePass, fmChangePass);
  //Application.CreateForm(TfmSQLHistory, fmSQLHistory);
  //Application.CreateForm(TfmCopyTable, fmCopyTable);
  InitialiseIBase60;
  Application.Run;
  ReleaseIBase60;
end.
