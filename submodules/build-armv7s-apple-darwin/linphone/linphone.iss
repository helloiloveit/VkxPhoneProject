[Setup]
AppName=Linphone
AppVerName=Linphone version 3.6.99
AppPublisher=linphone.org
AppPublisherURL=http://www.linphone.org
AppSupportURL=http://www.linphone.org
AppUpdatesURL=http://www.linphone.org
DefaultDirName={pf}\Linphone
DefaultGroupName=Linphone
LicenseFile=COPYING
;InfoBeforeFile=README
OutputBaseFilename=setup
Compression=lzma
SolidCompression=yes
ShowLanguageDialog=yes
UninstallDisplayIcon={app}\bin\linphone.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl";
Name: "french";  MessagesFile: "compiler:Languages\French.isl"
Name: "czech";   MessagesFile: "compiler:Languages\Czech.isl"
Name: "german";  MessagesFile: "compiler:Languages\German.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
#include "linphone-win32.filelist"

[Icons]
Name: "{group}\Linphone"; Filename: "{app}\bin\linphone.exe" ; WorkingDir: "{app}"
Name: "{userdesktop}\Linphone"; Filename: "{app}\bin\linphone.exe"; WorkingDir: "{app}" ; Tasks: desktopicon

[Registry]
Root: HKCR; Subkey: "sip";
Root: HKCR; Subkey: "sip"; ValueData: "URL: SIP protocol" ; ValueType:string
Root: HKCR; Subkey: "sip"; ValueName: "EditFlags"; ValueData: "02 00 00 00" ; ValueType:binary
Root: HKCR; Subkey: "sip"; ValueName: "URL Protocol" ;  ValueType:string
Root: HKCR; Subkey: "sip\DefaultIcon"; ValueData: "{app}\bin\linphone.exe"; ValueType:string ; Flags:uninsdeletekey
Root: HKCR; Subkey: "sip\shell"
Root: HKCR; Subkey: "sip\shell\open"
Root: HKCR; Subkey: "sip\shell\open\command"; ValueType:string ; ValueData: "{app}\bin\linphone.exe --workdir {app} --call %1"; Flags:uninsdeletekey

[Run]
Filename: "{app}\bin\linphone.exe"; Description: "{cm:LaunchProgram,Linphone}"; WorkingDir: "{app}" ; Flags: nowait postinstall skipifsilent

