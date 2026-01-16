DetectHiddenText, Off
#SingleInstance force
if (A_ScriptName = "Combo1.exe")
{
	FileMove, Combo1.exe, Combo.exe
	Run, Combo.exe
	ExitApp
}
CoordMode, Tooltip
CoordMode, Mouse, Client
CoordMode, Pixel, Client
FormatTime, Day,, WDay
Tooltip



; Determine Windows version (10 or 11)
RegRead, BuildNumber, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentBuildNumber
WindowsVersion := "Windows 10"  ; Default to Windows 10
if (BuildNumber >= 22000)       ; Windows 11 starts at build 22000
    WindowsVersion := "Windows 11"

;OFFICE INFO

; Create the filename using the computer name
;logFileName := A_ScriptDir . "\TreatmentPlanningLogs\" . A_ComputerName . ".ini"

;Assigns each computer name to a value to check for messages on network
CompArray := {"MTM-DEN-0423-W": "1", "MTM-DEN-1477-W": "2", "MTM-DEN-1480-W": "3", "MTM-DEN-1483-W": "4", "MTM-DEN-1478-W": "5", "MTM-DEN-1485-W": "6", "MTM-DEN-1484-W": "7", "MTM-DEN-1482-W": "8", "DOCTOR1-PC": "9", "MTM-DEN-0455-D": "10"}

;Providers initials, name, days of week working, and index
providers := {"BW":["Ben Wolfe","23",1]
	,"CW":["Curtis Wahlen","2345",2]
	,"GP":["Gabe Proulx","3456",3]
	,"JL":["Jay Lee","45",4]}
providerInitials := "GP" ;Current provider


;Get all Edit control variable names from TreatmentPlanning GUI
controlList := ["ExistingMissing"
    , "ExistingRestorationsAndSealants"
    , "ExistingCrownsAndBridges"
    , "ExistingVeneersAndOnlays"
    , "ExistingImplants"
    , "ExistingEndos"
    , "ExistingPartials"
    , "TreatmentPlannedExtractions"
    , "TreatmentPlannedRestorationsAndSealants"
    , "TreatmentPlannedCrownsAndBridges"
    , "TreatmentPlannedVeneersAndOnlays"
    , "TreatmentPlannedImplants"
    , "TreatmentPlannedEndos"
    , "TreatmentPlannedPulpCaps"
    , "TreatmentPlannedPartials"]

;OPEN DENTAL INFO

;Open Dental - General
ODTopButtonsY := 64
ODTopButtons := {"SelectPatient": new Pixel({ x: 106, y: ODTopButtonsY })
	,"CommLog": new Pixel({ x: 213, y: ODTopButtonsY })
	,"Email": new Pixel({ x: 288, y: ODTopButtonsY })
	,"WebMail": new Pixel({ x: 368, y: ODTopButtonsY })
	,"Tasks": new Pixel({ x: 609, y: ODTopButtonsY })}

;Open Dental - Task Window
taskReminderDropdown := new Pixel({ x: 589, y: 49 }) ;Reminder type dropdown in Task window
taskDescriptionField := new Pixel({ x: 158, y: 157 }) ;Description field in Task window

scrollBarBackgroundColor := "0xF0F0F0"

ODmodes := {"Appts": new Pixel({ x: 1, y: 82 }) ;Pixels to check to see what mode is selected in Open Dental
    ,"Family": new Pixel({ x: 1, y: 140 })
    ,"Account": new Pixel({ x: 1, y: 198 })
    ,"TxPlan": new Pixel({ x: 1, y: 256 })
    ,"Chart": new Pixel({ x: 1, y: 314 })
    ,"Imaging": new Pixel({ x: 1, y: 372 })
    ,"Manage": new Pixel({ x: 1, y: 430 })}
imagingCheckPixel := new Pixel({ x: 1 ;When Imaging mode is selected, the client window is the view of the imaging document, these are SCREEN coords
	,y: 373})
ODModeCheckColor := 0xFFFFFF ;Pixel is this color when tab is selected

;Open Dental - OK/Save Buttons
previewSaveButtonPixel := new Pixel({ x: 330 ;Save button for Preview box in Auto Note
	,y: 241
	,color: "0xF4F6F7" })
composeAutoNoteSaveButtonPixel := new Pixel({ x: 786 ;Save button for Compose Auto Note
	,y: 614
	,color: "0x9FE1F5" })

;Open Dental - Prescriptions
newRxButton := new Pixel({ x: 166 ;Button for New Rx
	,y: 95 })
RXFirstChoice := new Pixel({ x: 135 ;First choice in Rx search
	,y: 79 })
RXHalcion := new Pixel({ x: 135 ;Location of Halcion in search results
	,y: 205 })

prescriptions := {"r": ["sodium fluoride tooth", RXFirstChoice.x, RXFirstChoice.y]  ;Preset prescriptions
    ,"e": ["penicillin 500", RXFirstChoice.x, RXFirstChoice.y]
    ,"a": ["amoxicillin 500", RXFirstChoice.x, RXFirstChoice.y]
    ,"c": ["clindamycin 300", RXFirstChoice.x, RXFirstChoice.y]
    ,"z": ["azithromycin 250", RXFirstChoice.x, RXFirstChoice.y]
    ,"n": ["norco 5", RXFirstChoice.x, RXFirstChoice.y]
    ,"h": ["halcion", RXHalcion.x, RXHalcion.y]
    ,"p": ["amoxicillin 500mg", RXFirstChoice.x, RXFirstChoice.y]}

editRXProviderDropdown := new Pixel({ x: 386 ;Dropdown to edit Provider on Edit Rx
	,y: 282 })
editRXProviderButtons := new ButtonList({ x: 61  ;Button info for Providers dropdown on Edit Rx
    ,yStart: 27
    ,buttonHeight: 13
    ,buttonsDisplayed: 100})
editRXPrintButton := new Pixel({ x: 365 ;Print button on Edit Rx
	,y: 622 })

;Open Dental - Popups
popupButton := new Pixel({ x: 763 ;Button for Popups on top bar
	,y: 67 })
popupCheckPixel := new Pixel({ x: 149 ;Pixel to check if there is already a popup there
	,y: 78, color: "0xFCFDFE" })
popupAddButton := new Pixel({ x: 60 ;Add button for Popups for Family
	,y: 392 })
editPopupOKButton := new Pixel({ x: 420 ;OK Buton for Edit Popup
	,y: 352 })
editPopupDeleteButton := new Pixel({ x: 60 ;Delete Button for Edit Popups box
	,y: 352 })
countPopupsFindColor := [118, 85, "y", 1, 277, "0xDCDCDC", "0x787878", false] ;Info to count popups (xStart, yStart, xORy, increment, maxPixelsToCheck, colorToFind, altColorToFind, reverse)
firstPopupPixel := new Pixel({ x: 110 ; Pixel for first popup in Popups for Family
	,y: 81 })

;Open Dental - Reports
reportsMoreOptions := new Pixel({ x: 71 ;First choice on Standard Reports Favorites
	,y: 47 })
reportsMonthly := new Pixel({ x: 62 ; Monthly option of More Options report
	,y: 86 })
reportsProviderButtons := new ButtonList({ x: 61  ;Button info for Providers list on Production and Income Report
    ,yStart: 203
    ,buttonHeight: 14
    ,buttonsDisplayed: 12})
reportsPreviousMonth := new Pixel({ x: 459 ;Previous Month Button on Production and Income Report
	, y: 123, color: "0x0000FF" })
reportsNextMonth := new Pixel({ x: 621 ;Next Month Button on Production and Income Report
	,y: 123
	,color: "0x0000FF" })

;Open Dental - Tasks
taskPatientNamePixel := new Pixel({ x: 343 ;Location of patient name box in a Task
	,y: 645
	,color: "0xFFFFFF" })

;Open Dental - Appts tab
unscheduledApptColor1 := "0xDBDBDB" ;One color possibility showing an unscheduled appt
unscheduledApptColor2 := "0xD3D3D3" ;Another color possibility showing an unscheduled appt
todayButton := new Pixel({ x: 2401 ;Today Button on Appts View
	,y: 281 })
if (A_ScreenWidth = 1280 && A_ScreenHeight = 720) 
{
	statusScrollDown := new Pixel({ x: 1209 ;Pixel on scroll bar of Confirmation status, not the down arrow, but right above so that it is scrolled all the way to end
		,y: 589 })
	statusNotesRev := new Pixel({ x: 1167 ;Button to click to mark states as Notes Revised
		,y: 574 })
} 
else 
{
	statusScrollDown := new Pixel({ x: 2490 ;Pixel on scroll bar of Confirmation status, not the down arrow, but right above so that it is scrolled all the way to end
		,y: 589 })
	statusNotesRev := new Pixel({ x: 2455 ;Button to click to mark states as Notes Revised
		,y: 574 })
}

;Open Dental - Chart/Progress Notes
ODY := 108 ; Y pos for Open Dental Chart CALIBRATE
ULX := 51 ;CALIBRATE
URX := ULX + 410
ULULPixel := new Pixel({ x: ULX
	,y: ODY })
ULLRPixel := new Pixel({ x: URX
	,y: A_ScreenHeight-45 })
URULPixel := new Pixel({ x: URX
	,y: ODY })
URLRPixel := new Pixel({ x: A_ScreenWidth+7
	,y: A_ScreenHeight-45 })
xPosMidpoint := A_ScreenWidth/2  ; Calculate half of the screen width
yAboveTaskbar := 1348 ;yPos of last pixel before windows taskbar CALIBRATE

chartTabs := {"Treatment": new Pixel({ x: URX+49, y: ODY+17 }) ;Tabs for Open Dental Chart
    ,"MissingPrimary": new Pixel({ x: URX+145, y: ODY+17 })
    ,"Movements": new Pixel({ x: URX+226, y: ODY+17 })
    ,"PlannedAppts": new Pixel({ x: URX+306, y: ODY+17 })
    ,"Show": new Pixel({ x: URX+366, y: ODY+17 })
    ,"Draw": new Pixel({ x: URX+406, y: ODY+17 })
    ,"Ortho": new Pixel({ x: URX+446, y: ODY+17 })}
chartTabSelectedColor := "0xAABEE6" ;Pixel above is this color when Charting Tab selected
chartTabExpandedCheckPixel := new Pixel({ x: 1038 ;Pixel is this color if Charting Tab is expanded
	,y: 141
	,color: "0xFFFFFF" })
progressNoteCoords := [URX+2, ODY+294, URX+675, 2000] ;Coords denoting bounds for progress notes box: UL X, UL Y, LR X, LR Y
surfacesArray := {"B": new Pixel({ x: URX+40, y: ODY+54 }) ;Buttons to select surfaces of tooth
    ,"F": new Pixel({ x: URX+40, y: ODY+54 })
    ,"V": new Pixel({ x: URX+63, y: ODY+54 })
    ,"M": new Pixel({ x: URX+18, y: ODY+73 })
    ,"O": new Pixel({ x: URX+49, y: ODY+73 })
    ,"D": new Pixel({ x: URX+75, y: ODY+73 })
    ,"L": new Pixel({ x: URX+48, y: ODY+96 })
    ,"I": new Pixel({ x: URX+49, y: ODY+73 })}

if (WindowsVersion = "Windows 11") ;Windows 11 has a different color for the radio buttons
{
	txModes := {"TP": new Pixel({ x: URX+13, y: ODY+130-2 }) ;Treatment modes for entering treatment
	,"Co": new Pixel({ x: URX+13, y: ODY+145-2 })
	,"EC": new Pixel({ x: URX+13, y: ODY+160-2 })
	,"EO": new Pixel({ x: URX+13, y: ODY+175-2 })
	,"Re": new Pixel({ x: URX+13, y: ODY+190-2 })
	,"Con": new Pixel({ x: URX+13, y: ODY+205-2 })}

	drawTabModes := {"Pointer": new Pixel({ x: URX+211, y: ODY+42-2 }) ;Draw tab modes for drawing
	,"Move": new Pixel({ x: URX+211, y: ODY+60-2 })
	,"Pen": new Pixel({ x: URX+211, y: ODY+78-2 })
	,"Eraser": new Pixel({ x: URX+211, y: ODY+96-2 })
	,"ChangeColor": new Pixel({ x: URX+211, y: ODY+114-2 })}

	radioButtonUnSelectedColor := ["0xF3F3F3", "0xEAEAEA"] ;Above pixel is one of these color if tx mode is unselected (latter is hover color)
}
else
{
	txModes := {"TP": new Pixel({ x: URX+13, y: ODY+130 }) ;Treatment modes for entering treatment
	,"Co": new Pixel({ x: URX+13, y: ODY+145 })
	,"EC": new Pixel({ x: URX+13, y: ODY+160 })
	,"EO": new Pixel({ x: URX+13, y: ODY+175 })
	,"Re": new Pixel({ x: URX+13, y: ODY+190 })
	,"Con": new Pixel({ x: URX+13, y: ODY+205 })}
	

	drawTabModes := {"Pointer": new Pixel({ x: URX+211, y: ODY+42 }) ;Draw tab modes for drawing
	,"Move": new Pixel({ x: URX+211, y: ODY+60 })
	,"Pen": new Pixel({ x: URX+211, y: ODY+78 })
	,"Eraser": new Pixel({ x: URX+211, y: ODY+96 })
	,"ChangeColor": new Pixel({ x: URX+211, y: ODY+114 })}

	radioButtonUnSelectedColor := ["0xFFFFFF", "0xFFFFFF"] ;Above pixel is one of these color if tx mode is unselected (latter is hover color)
}

diagnosis := ["NO","CA","RE","AL","CH","WE","LA","MA","FL","FR","CR","MI","PE","IP","NE","ES","ET"] ;Diagnosis options
procButtons := ["Quick","General","Hygiene","Endo","OralSurgery","CrownBridge","Products","Implants","Ortho","Removable","Limited","NightGuard"] ;Procedure Buttons

;Teeth setup

;Array of tooth, check pixel x, check pixel y, and color if tooth is present
teethArray := [[1,ULX+16,ODY+142,"0xFFFFFF"],[2,ULX+44,ODY+141,"0xFFFFFF"],[3,ULX+73,ODY+141,"0xFFFFFF"]
    ,[4,ULX+99,ODY+146,"0xFFFFFF"],[5,ULX+122,ODY+144,"0xFFFFFF"],[6,ULX+146,ODY+144,"0xFFFFFF"]
    ,[7,ULX+167,ODY+141,"0xFFFFFF"],[8,ULX+191,ODY+141,"0xFFFFFF"],[9,ULX+218,ODY+141,"0xFFFFFF"]
    ,[10,ULX+238,ODY+142,"0xFFFFFF"],[11,ULX+260,ODY+142,"0xFFFFFF"],[12,ULX+283,ODY+142,"0xFFFFFF"]
    ,[13,ULX+311,ODY+141,"0xFFFFFF"],[14,ULX+332,ODY+142,"0xFFFFFF"],[15,ULX+362,ODY+142,"0xFFFFFF"]
    ,[16,ULX+390,ODY+142,"0xFFFFFF"],[17,ULX+390,ODY+159,"0xFFFFFF"],[18,ULX+356,ODY+159,"0xFFFFFF"]
    ,[19,ULX+323,ODY+159,"0xFFFFFF"],[20,ULX+294,ODY+159,"0xFFFFFF"],[21,ULX+266,ODY+159,"0xFFFFFF"]
    ,[22,ULX+250,ODY+159,"0xFFFFFF"],[23,ULX+231,ODY+159,"0xFFFFFF"],[24,ULX+209,ODY+159,"0xFFFFFF"]
    ,[25,ULX+193,ODY+159,"0xFFFFFF"],[26,ULX+178,ODY+159,"0xFFFFFF"],[27,ULX+159,ODY+159,"0xFFFFFF"]
    ,[28,ULX+137,ODY+159,"0xFFFFFF"],[29,ULX+115,ODY+159,"0xFFFFFF"],[30,ULX+86,ODY+159,"0xFFFFFF"]
    ,[31,ULX+52,ODY+159,"0xFFFFFF"],[32,ULX+20,ODY+159,"0xFFFFFF"]]

;Array of praimary teeth, check pixel x, check pixel y, and color if tooth is present, with coords of molars being the x and y pos if the primary 2nd molar in front of it is present, since this is wider than the permanent counterpart
if (WindowsVersion = "Windows 11")
{
	teethArrayPrimary := [[1,ULX+13,ODY+142,"0xFFFFFF"],[2,ULX+40,ODY+141,"0xFFFFFF"],[3,ULX+70,ODY+141,"0xFFFFFF"]
	,["A",ULX+99,ODY+131,"0xFFFFFF"],["B",ULX+122,ODY+133,"0xFFFFFF"],["C",ULX+145,ODY+133,"0xFFFFFF"]
	,["D",ULX+166,ODY+133,"0xFFFFFF"],["E",ULX+190,ODY+133,"0xFFFFFF"],["F",ULX+218,ODY+129,"0xFFFFFF"]
	,["G",ULX+242,ODY+133,"0xFFFFFF"],["H",ULX+263,ODY+129,"0xFFFFFF"],["I",ULX+287,ODY+132,"0xFAFFF8","0xFF004B"]
	,["J",ULX+309,ODY+133,"0xFFFFFF"],[14,ULX+340,ODY+146,"0xFFFFFF"],[15,ULX+372,ODY+144,"0xFFFFFF"]
	,[16,ULX+399,ODY+144,"0xFFFFFF"],[17,ULX+397,ODY+159,"0xFFFFFF"],[18,ULX+363,ODY+159,"0xFFFFFF"]
	,[19,ULX+329,ODY+159,"0xFFFFFF"],["K",ULX+293,ODY+173,"0xF8FFF8","0xFF0048"],["L",ULX+270,ODY+179,"0xFFFFFF"]
	,["M",ULX+244,ODY+172,"0xFFFFFF"],["N",ULX+226,ODY+173,"0xFFFFFF"],["O",ULX+213,ODY+172,"0xFFFFFF"]
	,["P",ULX+198,ODY+172,"0xFFFFFF"],["Q",ULX+182,ODY+172,"0xFFFFFF"],["R",ULX+162,ODY+172,"0xFFFFFF"]
	,["S",ULX+142,ODY+172,"0xFFFFFF"],["T",ULX+114,ODY+172,"0xFFFFFF"],[30,ULX+85,ODY+159,"0xFFFFFF"]
	,[31,ULX+45,ODY+159,"0xFFFFFF"],[32,ULX+19,ODY+159,"0xFFFFFF"]]
}
else
{
	teethArrayPrimary := [[1,ULX+13,ODY+142,"0xFFFFFF"],[2,ULX+40,ODY+141,"0xFFFFFF"],[3,ULX+70,ODY+141,"0xFFFFFF"]
	,["A",ULX+99,ODY+131,"0xFFFFFF"],["B",ULX+122,ODY+133,"0xFFFFFF"],["C",ULX+145,ODY+133,"0xFFFFFF"]
	,["D",ULX+166,ODY+133,"0xFFFFFF"],["E",ULX+190,ODY+133,"0xFFFFFF"],["F",ULX+218,ODY+129,"0xFFFFFF"]
	,["G",ULX+242,ODY+133,"0xFFFFFF"],["H",ULX+263,ODY+129,"0xFFFFFF"],["I",ULX+287,ODY+132,"0xF8FFF6","0xFF003B"]
	,["J",ULX+309,ODY+133,"0xFFFFFF"],[14,ULX+340,ODY+146,"0xFFFFFF"],[15,ULX+372,ODY+144,"0xFFFFFF"]
	,[16,ULX+399,ODY+144,"0xFFFFFF"],[17,ULX+397,ODY+159,"0xFFFFFF"],[18,ULX+363,ODY+159,"0xFFFFFF"]
	,[19,ULX+329,ODY+159,"0xFFFFFF"],["K",ULX+293,ODY+173,"0xF7FFF6","0xFF003B"],["L",ULX+270,ODY+179,"0xFFFFFF"]
	,["M",ULX+244,ODY+172,"0xFFFFFF"],["N",ULX+226,ODY+173,"0xFFFFFF"],["O",ULX+213,ODY+172,"0xFFFFFF"]
	,["P",ULX+198,ODY+172,"0xFFFFFF"],["Q",ULX+182,ODY+172,"0xFFFFFF"],["R",ULX+162,ODY+172,"0xFFFFFF"]
	,["S",ULX+142,ODY+172,"0xFFFFFF"],["T",ULX+114,ODY+172,"0xFFFFFF"],[30,ULX+85,ODY+159,"0xFFFFFF"]
	,[31,ULX+45,ODY+159,"0xFFFFFF"],[32,ULX+19,ODY+159,"0xFFFFFF"]]
}

;Colors if tooth is selected, unselected, or missing
selectedToothColor := "0xFF0000"
unselectedToothColor := "0xFFFFFF"
missingToothColor := "0x959098"

; Define tooth categories
molars := [1, 2, 3, 14, 15, 16, 17, 18, 19, 30, 31, 32]
premolars := [4, 5, 12, 13, 20, 21, 28, 29]
anteriors := [6, 7, 8, 9, 10, 11, 22, 23, 24, 25, 26, 27]

;Empty tooth array to fill with Tooth objects
tooth := {}

; Loop to create tooth objects and populate the tooth array
Loop 32
    tooth[A_Index] := Tooth(A_Index)

; Loop from ASCII code 65 ('A') to 84 ('T') to fill primary tooth array
Loop, 20
{
    ; Convert current loop index to the corresponding ASCII character
    primaryTooth := Chr(64 + A_Index)
    ; Create a new Tooth object for each letter and store it in the 'teeth' array
    tooth[primaryTooth] := Tooth(primaryTooth)
}

;Open Dental - Chart/Enter Treatment/Procedure info screen
procedureInfoUpperButton := new Pixel({ x: 126 ;Button for treatment area Upper
	,y: 184 })
procedureInfoLowerButton := new Pixel({ x: 127 ;Button for treatment area Upper
	,y: 202 })
procedureInfoURButton := new Pixel({ x: 121 ;Button for treatment area Upper
	,y: 184 })
procedureInfoULButton := new Pixel({ x: 174 ;Button for treatment area Upper
	,y: 184 })
procedureInfoLRButton := new Pixel({ x: 121 ;Button for treatment area Upper
	,y: 202 })
procedureInfoLLButton := new Pixel({ x: 174 ;Button for treatment area Upper
	,y: 202 })
procedureInfoToothField := new Pixel({ x: 118 ;Input field for tooth number
	,y: 141 })
procedureInfoDiagnosisDropdown := new Pixel({ x: 277 ;Button to click diagnosis
	,y: 274 })
procedureInfoDiagnosisButtons := new ButtonList({ x: 7 ;Buttonlist info for Diagnoses
    ,yStart: 29
    ,buttonHeight: 13
    ,buttonsDisplayed: 100 })
procedureInfoChangeButton := new Pixel({ x: 226 ;Button "Change" to change codes on Procedure Info
	,y: 97 })
procedureInfoCodeField := new Pixel({ x: 178 ;Input field for CDT code
	,y: 95 })
procedureCodesFirstCode := new Pixel({ x: 307 ;Top CDT code result in list on Procedure Codes
	,y: 76 })
procedureInfoInitialPixel := new Pixel({ x: 174 ;Button to indicate Initial crown
	,y: 344 })
procedureInfoReplacementPixel := new Pixel({ x: 174 ;Button to indicate replacement crown
	,y: 358 })
procedureInfoEstimatedDatePixel := new Pixel({ x: 190 ;Estimated Date box
	,y: 378 })
procedureInfoSurfacesField := new Pixel({ x: 168 ;Input field for tooth surfaces
	,y: 168 })
changeCodeYesButtonPixel := new Pixel({ x: 438 ;Change Code Dialog Yes Button
	,y: 167 })
changeCodeNoButtonPixel := new Pixel({ x: 438 ;Change Code Dialog No Button
	,y: 207 })

;Open Dental - Chart/Enter Treatment tab
chartSurfacesField := new Pixel({ x: URX+74 ;Input field for tooth surfaces on Chart
	,y: ODY+32 })
chartSurfacesPixel := new Pixel({ x: URX+16 ;Pixel to see if anything entered
	,y: ODY+31 })
chartSurfacesBlankColor := "0xFFFFFF"
chartCodeField := new Pixel({ x: URX+431 ;Input field for CDT code on Chart
	,y: ODY+32 })
chartDiagnosisButtons := new ButtonList({ x: URX+98  ;Buttonlist info for chart diagnosis buttons
    ,yStart: ODY+47
    ,buttonHeight: 14
    ,buttonsDisplayed: 9
    ,scrollDownButtonX: URX+176
    ,scrollDownButtonY: ODY+162
    ,resetScrollY: ODY+56
    ,scrollBarBackgroundColor: scrollBarBackgroundColor
    ,colorIfAlreadyClicked: "0xBAC7DB" })
procedureButtons := new ButtonList({ x: URX+305 ;Buttonlist info for procedure buttons on Chart
    ,yStart: ODY+68
    ,buttonHeight: 14
    ,buttonsDisplayed: 12
    ,scrollBarBackgroundColor: scrollBarBackgroundColor
    ,colorIfAlreadyClicked: "0xBAC7DB" })
singleClickButtons := new ButtonList({ x: URX+330 ;Buttonlist info for single click buttons on Chart
    ,yStart: ODY+68
    ,buttonHeight: 21
    ,buttonsDisplayed: 9
    ,scrollDownButtonX: URX+504
    ,scrollDownButtonY: ODY+242
    ,resetScrollY: ODY+81
    ,scrollBarBackgroundColor: scrollBarBackgroundColor })

;Open Dental - Chart/Missing/Primary tab
missingNotMissingHiddenButtons := new ButtonList({ x: URX+62 ;Buttonlist info for missing, not missing, hidden on Chart/Missing/Primary tab
    ,yStart: ODY+54
    ,buttonHeight: 26
    ,buttonsDisplayed: 3 })
primaryPermanentButtons := new ButtonList({ x: URX+331 ;Buttonlist info for primary, permanent for selected teeth on Chart/Missing/Primary tab
    ,yStart: ODY+60
    ,buttonHeight: 32
    ,buttonsDisplayed: 2 })
primaryPermanentAllButtons := new ButtonList({ x: URX+331 ;Buttonlist info for primary, permanent for all teeth on Chart/Missing/Primary tab
    ,yStart: ODY+140
    ,buttonHeight: 29
    ,buttonsDisplayed: 3 })
edentulousButton := new Pixel({ x: URX+62 ;Button to mark pt edentulous on Chart/Missing/Primary tab
	,y: ODY+141 })
unhideButton := new Pixel({ x: URX+160 ;Button to unhide tooth on Chart/Missing/Primary tab
	,y: ODY+190 })

;Open Dental - Chart/Movements tab
mesialMovementButton := new Pixel({ x: URX+198 ;Button to move teeth mesial on Chart/Movements tab
	,y: ODY+63 })
movementsApplyButtonPixel := new Pixel({ x: URX+364 ;Apply button for Movements tab
	,y: ODY+202})
mesialMovementTextBoxPixel := new Pixel({ x: URX+111 ;Mesial Movements Text Box
	,y: ODY+62}) 

;Open Dental - Chart/Auto Notes
multiPromptCheckmarks := new ButtonList({ x: 18 ;Buttoncount info for multi prompt checkboxes in autonote
    ,yStart: 106
    ,buttonHeight: 15
    ,buttonsDisplayed: 12 ;Technically 13 are displayed, but sometimes only 12 with x axis scroll bar
	,scrollDownButtonX: 504
    ,scrollDownButtonY: 290
    ,resetScrollY: 114
    ,scrollBarBackgroundColor: scrollBarBackgroundColor
    ,color1: "0xFFFFFF"
	,color2: "0xD2EFFF"
	,colorIsButton: true })
onePromptButtons := new ButtonList({ x: multiPromptCheckmarks.x ;Buttons for one prompt use in autonote
    ,yStart: multiPromptCheckmarks.yStart
    ,buttonHeight: multiPromptCheckmarks.buttonHeight
    ,buttonsDisplayed: 13
	,scrollDownButtonX: multiPromptCheckmarks.scrollDownButtonX
    ,scrollDownButtonY: multiPromptCheckmarks.scrollDownButtonX
    ,resetScrollY: multiPromptCheckmarks.resetScrollY
    ,scrollBarBackgroundColor: scrollBarBackgroundColor })
procedureInfoAutoNote := new Pixel({ x: 800 ;Auto Note button for Procedure Info
	,y: 170 })
groupNoteAutoNote := new Pixel({ x: 376 ;Auto Note button for Group Note
	,y: 85 })
autoNoteButtons := new ButtonList({ x: 90 ;Buttonlist info for autonote descriptions
    ,yStart: 62
    ,buttonHeight: 16
    ,buttonsDisplayed: 33
    ,scrollDownButtonX: 258
    ,scrollDownButtonY: 581
    ,resetScrollY: 73
    ,scrollBarBackgroundColor: scrollBarBackgroundColor })
directPulpCapToothNumberPixel := new Pixel({ x: 68 ;Location of TOOTHNUMBER text for direct pulp cap prompt
	,y: 57 })
indirectPulpCapToothNumberPixel := new Pixel({ x: 277 ;Location of TOOTHNUMBER text for indirect pulp cap prompt
	,y: 47 })
deepRestoToothNumberPixel := new Pixel({ x: 206 ;Location of TOOTHNUMBER text for indirect pulp cap prompt
	,y: 43 })
compositePromptScrolledPixel := new Pixel({ x: 503 ;Pixel to check to see if scrollbar for the composite autonote is not at top, color is the scroll bar background
	,y: 116
	,color: scrollBarBackgroundColor })
promptPixels := [["CrownDiag", new Pixel({ x: 217, y: 63 })] ;Different prompts for autonotes and the pixel to check to differentiate
    ,["Bonding", new Pixel({ x: 181, y: 60 })]
    ,["InitialOrReplacement", new Pixel({ x: 154, y: 63 })]
    ,["Details", new Pixel({ x: 154, y: 60 })]
    ,["Composite", new Pixel({ x: 101, y: 60 })]
    ,["CrownMaterial", new Pixel({ x: 89, y: 60 })]
    ,["Doctor", new Pixel({ x: 79, y: 60 })]
    ,["Teeth", new Pixel({ x: 74, y: 60 })]
    ,["Anesthetic", new Pixel({ x: 66, y: 63 })]
    ,["NextVisit", new Pixel({ x: 62, y: 63 })]
    ,["Assistant", new Pixel({ x: 58, y: 63 })]]

;Chrome
yPosBrowserFrame := 121 ;yPos of first pixel of browser frame CALIBRATE
ChromeURLPixel := new Pixel({ x: 156 ;UL coord of URL Box CALIBRATE
	,y: 46 })
chromeSearchTabsButton := new Pixel({ x: ChromeURLPixel.x+23 ;Pixel to click to search tabs
	,y: ChromeURLPixel.y+218 })
chromeTopResultPixel := new Pixel({ x: ChromeURLPixel.x-5 ;Pixel is this color if there is a top result, meaning a tab that matches that patient is open
	,y: ChromeURLPixel.y+54
	,color: "0x0B57D0" })
URLBarSelectedPixel := new Pixel({ x: ChromeURLPixel.x+25 ;Pixel is this color if the URL Bar is selected/active and ready for input
	,y: ChromeURLPixel.y
	,color: "0x0B57D0"
	,timeout: 2
	,page: "URL bar to select" })
URLClickPixel := new Pixel({ x: ChromeURLPixel.x+31 ;Pixel to click to activate URL Bar
	,y: ChromeURLPixel.y+15 })
tabSearchActivePixel := new Pixel({ x: ChromeURLPixel.x+130 ;Pixel is this color if tab search is already active
	,y: ChromeURLPixel.y+16
	,color: "0xA8C7FA" })

;iTero
iTeroSearchBoxPixel := new Pixel({ x: 1781 ;Pixel to click search box for a patient in iTero
	,y: yPosBrowserFrame+171
	,color: "0xFFFFFF"
	,timeout: 5
	,page: "Patients · My iTero - Google Chrome" })
iTeroPatientXStart := 713 ;First 0xFFFFFF pixel of the main search box CALIBRATE
iTeroDividerBetweenResultsOneAndTwoPixel := new Pixel({ x: xPosMidpoint ;Divider between first two results will be this color unless there is only one result
	,y: yPosBrowserFrame+271
	,color: "0xDDDDDD" })
iTeroSearchCompletePixel := new Pixel({ x: iTeroDividerBetweenResultsOneAndTwoPixel.x ;Gray pixel of first result or No Results line, appears when search complete
	,y: iTeroDividerBetweenResultsOneAndTwoPixel.y-10
	,color: "0xF4F4F5"
	,timeout: 10
	,page: "Search to complete" })
iTeroNoResultsPixel := new Pixel({ x: iTeroDividerBetweenResultsOneAndTwoPixel.x ;Pixel right above No Results line. If white, it means No Results instead of a result, since the No Results line is narrower than a result
	,y: iTeroDividerBetweenResultsOneAndTwoPixel.y-1
	,color: "0xFFFFFF" })
iTeroPatientPageNoResultsPixel := new Pixel({ x: iTeroPatientXStart+663 ;Pixel of order status bubble, will be gray if no results
	,y: yPosBrowserFrame+236
	,color: "0xF4F4F5" })
iTeroPatientPagePixel := new Pixel({ x: iTeroPatientPageNoResultsPixel.x-346 ;Pixel of first result/scan, will be gray when loaded
	,y: iTeroPatientPageNoResultsPixel.y
	,color: "0xF4F4F5"
	,timeout: 10
	,page: "Patient Page" })
iTeroPatientPageAltColorPixel := new Pixel({ x: iTeroPatientPagePixel.x ;Pixel of first result, will be darker gray when loaded and cursor on this line
	,y: iTeroPatientPagePixel.y
	,color: "0xE7E7E9" })
iTeroPatientPageEndDrag := new Pixel({ x: iTeroPatientPageNoResultsPixel.x-112 ;Pixel of first result/scan, end of drag starting with iteroPatientPageNoResults will be gray when loaded
	,y: iTeroPatientPageNoResultsPixel.y })
iTeroCaseType1Pixel := new Pixel({ x: iTeroPatientPageNoResultsPixel.x-486 ;Pixel of viewer button
	,y: iTeroPatientPageNoResultsPixel.y+45
	,color: "0xFFFFFF" })
iTeroCaseType2Pixel := new Pixel({ x: iTeroPatientPageNoResultsPixel.x-326 ;Pixel of viewer button
	,y: iTeroPatientPageNoResultsPixel.y+45
	,color: "0xFFFFFF" })

;clinCheck
clinCheckFirstResultPixel := new Pixel({ x: 266 ;First result of clincheck is present if this pixel
	,y: yPosBrowserFrame+424
	,color: "0xDCDDDF" })
clinCheckPatientFindColorPixel := new Pixel({ x: 292 ;Coords to find patient using selection highlighting
	,y: clinCheckFirstResultPixel.y-40 })
clinCheckPatientFindColors := ["0xFFFF00", "0xDCDDDF"] ;Colors to look for for the patient
clinCheckOpenClinCheckFindColorPixel := new Pixel({ x: 1413 ;Pixel and colors for FindPixel() to find "Open ClinCheck"
	,y: yPosBrowserFrame+937
	,color: "0xFF9632" })

;xvWeb
xvWebWebsite := "wolfedental.xvweb.net"
xvWebImagingPatientSearchBlankScreenPixel := new Pixel({ x: 52 ;Blank screen to make sure imaging patient search refreshes
	,y: yPosBrowserFrame+67
	,color: "0xFFFFFF"
	,timeout: 8
	,page: "Blank Screen of Imaging Patient Search" })
xvWebImagingPatientSearchPixel := new Pixel({ x: xvWebImagingPatientSearchBlankScreenPixel.x
	,y: xvWebImagingPatientSearchBlankScreenPixel.y
	,color: "0x0069DC"
	,timeout: 6
	,page: "Imaging Patient Search" })
xvWebViewButton := new Pixel({ x: 57 ;View button and the color
	,y: yPosBrowserFrame+291
	,color: "0x00137A" })
xvWebNoResults := new Pixel({ x: 992 ;Pixel indicating no results
	,y: yPosBrowserFrame+260
	,color: "0xC9CACB" })
radiographsULPixel := new Pixel({ x: 168 ;UL coord of Radiograph frame CALIBRATE
	,y: yPosBrowserFrame })
radiographsLRPixel := new Pixel({ x: 2559 ;LR coord of Radiograph frame CALIBRATE
	,y: yAboveTaskbar })

;Dimensions for finding how many patient View buttons show up
xvWebButtonWidth := 52
xvWebButtonHeight := 31
xvWebButtonStartX := 51
xvWebButtonStartY := yPosBrowserFrame+279
xvWebyPos := xvWebButtonStartY + 5
xvWebButtonList := new ButtonList({ x: xvWebButtonStartX ;Buttonlist info for gender selection in xvWeb
    ,yStart: xvWebButtonStartY+5
    ,buttonHeight: xvWebButtonHeight
    ,buttonsDisplayed: 10
    ,color1: "0xFFFFFF"
	,colorIsButton: false })

xvWebEditButtonFindColor := [200, yPosBrowserFrame+36, "x", 12, 500, "0xF5993D", "", false] ;(xStart, yStart, xORy, increment, maxPixelsToCheck, colorToFind, altColorToFind, reverse)
xvWebCancelButton := new Pixel({ x: 153
	,y: yPosBrowserFrame+107
	,color: "0xD97F26"
	,timeout: 10
	,page: "Patient Edit" })
xvWebPatientLinePixel := new Pixel({ x: 195 ;Gray color background of patient line
	,y: yPosBrowserFrame+18
	,color: "0x1C1A17"
	,timeout: 10
	,page: "Viewing Patient" })
xvWebConfirmButtonPixel := new Pixel({ x: 153 ;Location and color of the confirm button on the patient edit screen
	,y: yPosBrowserFrame+75
	,color: "0xD97F26"
	,timeout: 10
	,page: "Patient Edit" })
xvWebGender := new Pixel({ x: 317 ;Pixel to start iterating to the left to find first color that is not this color for the gender
	,y: yPosBrowserFrame+330
	,color: "0x007BFF" })
xvWebClickOutsideDatePicker := new Pixel({ x: 331
	,y: yPosBrowserFrame+330
	,color: "0x007BFF" })
xvWebFirstRadiographViewBoxPixel := new Pixel({ x: 14
	,y: yPosBrowserFrame+95
	,color: "0x747474"
	,timeout: 10
	,page: "View box for last radiograph" })
xvWebFirstRadiographViewBoxPixelLongWait := new Pixel({ x: xvWebFirstRadiographViewBoxPixel.x
	,y: xvWebFirstRadiographViewBoxPixel.y
	,color: xvWebFirstRadiographViewBoxPixel.color
	,timeout: 16
	,page: "View box for last radiograph" })
xvWebFirstRadiographPixel := new Pixel({ x: xvWebFirstRadiographViewBoxPixel.x+6
	,y: yPosBrowserFrame+95 })
xvWebFinalMousePosition := new Pixel({ x: 900
	,y: yPosBrowserFrame+453 })
xvWebTooltip := new Pixel({ x: 174
	,y: yPosBrowserFrame+220 })
xvWebGenderButtons := new ButtonList({ x: 314 ;Buttonlist info for gender selection in xvWeb
    ,yStart: yPosBrowserFrame+366
    ,buttonHeight: 28
    ,buttonsDisplayed: 3 })
xvWebDOBEmpty := new Pixel({ x: 331 ;Pixel red if MOB empty
	,y: yPosBrowserFrame+383
	,color: "0xFFE5E5" })

; Autologin
invisalignLoginButtonPixel := new Pixel({ x: 1215
	,y: 784
	,color: "0x008AB9" })
myIteroLoginPixel := new Pixel({ x: xPosMidpoint-248
	,y: yPosBrowserFrame+396
	, color: "0x000000" })
myIteroLoginButton := new Pixel({ x: xPosMidpoint+155
	,y: yPosBrowserFrame+455 })
xvWebLoginPixel := new Pixel({ x: 872
	,y: yPosBrowserFrame+646 })
xvWebLoginColor1 := "0x00137A"
xvWebLoginColor2 := "0x000F60"
xvWebLoginButton := new Pixel({ x: 860
	,y: yPosBrowserFrame+643 })

;Variables for Treatment Planning GUI
; RegEx pattern variables for improved readability
validSurfaceCombos := ["b","bd","bdl","bdlm","bdlmo","bdlmov","bdlmv","bdlo","bdlov","bdlv","bdm","bdmo","bdmov","bdmv","bdo","bdov","bdv","bl","blm","blmo","blmov","blmv","blo","blov","blv","bm","bmo","bmov","bmv","bo","bov","bv","d","df","dfi","dfil","dfilm","dfilmv","dfim","dfimv","dfiv","dfl","dflm","dflmv","dflv","dfm","dfmv","dfv","di","dil","dilm","dilmv","dim","dimv","div","dl","dlm","dlmo","dlmov","dlmv","dlo","dlov","dlv","dm","dmo","dmov","dmv","do","dov","dv","f","fi","fil","film","filmv","fim","fimv","fiv","fl","flm","flmv","flv","fm","fmv","fv","i","il","ilm","ilmv","im","imv","iv","l","lm","lmo","lmov","lmv","lo","lov","lv","m","mo","mov","mv","o","ov","v"]
permanentMolars := "(?:1[4-9]|3[0-2]|[1-3])"
permanentPremolars := "(?:1[2-3]|2[0-1]|2[8-9]|[4-5])"
permanentPosteriorTeeth := permanentPremolars . "|" . permanentMolars
permanentAnteriorTeeth := "(?:1[0-1]|2[2-7]|[6-9])"
permanentTeeth := "(?:" . permanentAnteriorTeeth . "|" . permanentPosteriorTeeth . ")"
primaryPosteriorTeeth := "(?:[a-b]|[i-l]|[s-t]|[A-B]|[I-L]|[S-T])"
primaryAnteriorTeeth := "(?:[c-h]|[m-r]|[C-H]|[M-R])"
primaryTeeth := "(?:" . primaryPosteriorTeeth . "|" . primaryAnteriorTeeth . ")"
posteriorTeeth := "(?:" . permanentPosteriorTeeth . "|" . primaryPosteriorTeeth . ")"
anteriorTeeth := "(?:" . permanentAnteriorTeeth . "|" . primaryAnteriorTeeth . ")"
allTeeth := "(?:" . permanentTeeth . "|" . primaryTeeth . ")"
maxillaryPrimaryTeeth := "(?:[a-j]|[A-J])"
maxillaryPermanentTeeth := "(?:1[0-6]|[1-9])"
maxillaryTeeth := "(?:" . maxillaryPrimaryTeeth . "|" . maxillaryPermanentTeeth . ")"
mandibularPrimaryTeeth := "(?:[k-t]|[K-T])"
mandibularPermanentTeeth := "(?:1[7-9]|2[0-9]|3[0-2])"
mandibularTeeth := "(?:" . mandibularPrimaryTeeth . "|" . mandibularPermanentTeeth . ")"
posteriorSurfacesV := "[modblv]"
posteriorSurfaces := "[modbl]"
anteriorSurfaces := "[midflv]"
diagnoses := "NO|CA|RE|AL|CH|WE|LA|MA|FL|FR|CR|MI|PE|IP|NE|ES|ET"
bridgeRegex := "^(?=.*-)"                                          ; enforce at least 1 dash
            . "(?<Teeth>"                                         ; start capturing
            .    "-?"                                             ; optional leading dash
            .    "(?:" . permanentTeeth . "(?:," . permanentTeeth . ")*)"  ; group 1: permanent teeth
            .    "(?:-" . permanentTeeth . "(?:," . permanentTeeth . ")*)*" ; optional additional groups
            .    "-?"                                             ; optional trailing dash
            . ")" 
crownAndBridgeMaterialRegex := "(?<Material>[cpg])?$"
crownOrBridgeReplacementPattern := "(r(\d+)?)"
crownOrBridgeMaterialPattern := "(z|e|g|s)"
crownOrBridgeDiagnosisPattern := "(" . diagnoses . ")"
crownOrBridgeExpandedDiagnosisPattern := "(?:\(([^)]*)\))"
crownOrBridgePostOrNoCoreModifier := "(p|n)"
crownOrBridgeCombinedModifierPattern := crownOrBridgeReplacementPattern . "|" . crownOrBridgeMaterialPattern . "|" . crownOrBridgeDiagnosisPattern . "|" . crownOrBridgeExpandedDiagnosisPattern . "|" . crownOrBridgePostOrNoCoreModifier
validImplantModifiers := ["c", "b", "m", "^", "xi", "x", "e", "p", "r"]

;Declare Toggles and Variables
blockInputToggle := false ;Stores whether blockinput is enabled
changeCodeToggle := true ;Stores whether to change code for restos
ODState := {}

;Start Timers
SetTimer, ReloadScript, 60000, -1 ;only runs when another thread is not running
SetTimer, ClosePopups, 250 ;Loads timer that closes unneeded popups on other machines
SetTimer, CloseDeletePopups, 250, -1 ;Closes carry over popup on all computers but only runs when another thread is not running

;Settings/Cleanup
if (A_ComputerName = "DOCTOR1-PC") ;shows tray icon for charting computers
	Menu, Tray, Icon
FileDelete, Combo1.exe
FileDelete, %A_MyDocuments%\logfile.txt
FileDelete, %A_MyDocuments%\TreatmentPlanLog.ini
FileGetTime, Version, Combo.exe, M
return

;TIMERS

CloseDeletePopups: ;Closes Open Dental Delete prompt, but only if thread is not running
IfWinActive,, Delete Selected Item(s)?
	SendInput {Enter}
return

ClosePopups: ;Closes unneeded popups
IfWinActive, Change Code? ;Open Dental prompt to change code
{
	global changeCodeYesButtonPixel
	global changeCodeNoButtonPixel
	global changeCodeToggle
	if changeCodeToggle
		MouseClick,, % changeCodeYesButtonPixel.x, % changeCodeYesButtonPixel.y ;Clicks Yes
	else
		MouseClick,, % changeCodeNoButtonPixel.x, % changeCodeNoButtonPixel.y ;Clicks No
}
IfWinActive,, The signature box has not been re-signed ;Warning about note
	SendInput {enter}
IfWinActive,, This patient is already selected on workstation ;Dexis warning that chart is open on another computer
{
	if (A_ComputerName = "DOCTOR1-PC")
		SendInput {enter}
}
return

AutoLoginInvisalign: ;Automatically logs in
IfWinActive, myaccount-us.aligntech.com/u/login?
{
	global invisalignLoginButtonPixel
	MouseMove, % invisalignLoginButtonPixel.x, % invisalignLoginButtonPixel.y
	PixelGetColor, color, invisalignLoginButtonPixel.x, invisalignLoginButtonPixel.y, RGB
	if (color = invisalignLoginButtonPixel.color)
	{
		Sleep, 300
		MouseClick,, % invisalignLoginButtonPixel.x, % invisalignLoginButtonPixel.y ;Clicks login
		WinWaitNotActive, Invisalign Doctor Site Login - Google Chrome,, 3 ;Waits till page is not active to prevent repeat attempts to login
	}
}
return

AutoLoginItero: ;Automatically logs in
if WinActiveRegex("Login.*My iTero \- Google Chrome") ;Logs in to MyiTero if login page pulls up
{
	global myIteroLoginPixel
	global myIteroLoginButton
	PixelGetColor, color, myIteroLoginPixel.x, myIteroLoginPixel.y, RGB
	if (color = myIteroLoginPixel.color)
	{
		MouseClick,, % myIteroLoginButton.x, % myIteroLoginButton.y
		WinWaitNotActive, Login,, 3
	}
}
return

AutoLoginXVWeb: ;Automatically logs in
IfWinActive, Imaging Login ;Logs in to XVWeb if not logged in
{
	global xvWebLoginPixel
	global xvWebLoginColor1
	global xvWebLoginColor2
	global xvWebLoginButton
	PixelGetColor, color, xvWebLoginPixel.x, xvWebLoginPixel.y, RGB
	if (color = xvWebLoginColor1 OR color = xvWebLoginColor2)
	{
		MouseClick,, % xvWebLoginButton.x, % xvWebLoginButton.y
		WinWaitNotActive, Imaging Login,, 3
	}
}
return


!!Functions:
return

class Pixel
{
    __New(params)
    {
        this.x := params.x
        this.y := params.y
        this.color := params.HasKey("color") ? params.color : ""
        this.timeout := params.HasKey("timeout") ? params.timeout : 0
        this.page := params.HasKey("page") ? params.page : ""
        this.altColor := params.HasKey("altColor") ? params.altColor : ""
    }
}

class ButtonList
{
    __New(params)
    {
        this.x := params.x
        this.yStart := params.yStart
        this.buttonHeight := params.buttonHeight
        this.buttonsDisplayed := params.buttonsDisplayed
        this.scrollDownButtonX := params.HasKey("scrollDownButtonX") ? params.scrollDownButtonX : 0
        this.scrollDownButtonY := params.HasKey("scrollDownButtonY") ? params.scrollDownButtonY : 0
        this.resetScrollY := params.HasKey("resetScrollY") ? params.resetScrollY : 0
        this.scrollBarBackgroundColor := params.HasKey("scrollBarBackgroundColor") ? params.scrollBarBackgroundColor : ""
        this.colorIfAlreadyClicked := params.HasKey("colorIfAlreadyClicked") ? params.colorIfAlreadyClicked : ""
		this.color1 := params.HasKey("color1") ? params.color1 : ""
		this.color2 := params.HasKey("color2") ? params.color2 : ""
		this.colorIsButton := params.HasKey("colorIsButton") ? params.colorIsButton : ""
    }
}

class PatientObj
{
    __New(params) 
	{
        this.FirstNameSimp := params.HasKey("FirstNameSimp") ? params.FirstNameSimp : ""
        this.FirstName := params.HasKey("FirstName") ? params.FirstName : ""
        this.FirstInitial := params.HasKey("FirstInitial") ? params.FirstInitial : ""
        this.LastNameSimp := params.HasKey("LastNameSimp") ? params.LastNameSimp : ""
        this.LastName := params.HasKey("LastName") ? params.LastName : ""
        this.PreferredName := params.HasKey("PreferredName") ? params.PreferredName : ""
        this.ID := params.HasKey("ID") ? params.ID : ""
        this.Source := params.HasKey("Source") ? params.Source : "NA"
    }
}

; Checks if the given surfaces represent a valid onlay or inlay
; @param surfaces The tooth surface notation (e.g., "mo", "do", "mod")
; @return true if surfaces represent a valid onlay or inlay, false otherwise
isOnlayOrInlaySurfaces(surfaces) 
{
    ; Make case insensitive
    return surfaces ~= "^(bdlmo|bdlo|bdmo|bdo|blmo|blo|bmo|bo|dlmo|dlo|dmo|do|lo|mo|o)$"
}

; Checks if the given surfaces represent a valid inlay
; @param surfaces The tooth surface notation
; @return true if surfaces represent a valid inlay, false otherwise 
isInlaySurfaces(surfaces) 
{
    return surfaces ~= "^(bo|dmo|do|lo|mo|o)$"
}

; Checks if the given surfaces are part of the list of sorted valid surfaces combos
; @param surfaces The tooth surface notation
; @return true if surfaces combo are valid
validSurfaces(surfaces) 
{
	global validSurfaceCombos
    
    ; Check if surfaces string exists in valid combinations
    return HasVal(validSurfaceCombos, surfaces)
}

; Splits non-touching surfaces into an array of separate surface combinations
; @param surfaces The combined surfaces
; @return Array of surfaces
splitNonTouchingSurfaces(surfaces) 
{
    result := []
    if (surfaces ~= "^(blv|flv)$") 
        {
        ; First restoration has 'v' surface
        result.Push(SubStr(surfaces, 1, 1) . "v")
        ; Second restoration (always 'l')
        result.Push("l")
    } 
    else if (surfaces ~= "i)^(dm|bl|fl|lv|iv|ov)$") 
    {
        result.Push(SubStr(surfaces, 1, 1))
        result.Push(SubStr(surfaces, 2, 1))
    } 
    else
        result.Push(surfaces)
    return result
}

; Sorts and standardizes a surfaces string of tooth surfaces
; @param surfaces The tooth surface notation
; @return Standardized string with surfaces in sorted order
sortSurfaces(surfaces)
{
    surfacesDelimited := ""
    Loop, Parse, surfaces
        surfacesDelimited .= (surfacesDelimited = "" ? "" : "|") . A_LoopField
    Sort, surfacesDelimited, D|
    StringReplace, sortedSurfaces, surfacesDelimited,|,, All
    return sortedSurfaces
}

; Processes tooth surfaces with all necessary steps:
; 1. Sorts the surfaces in standard order
; 2. Validates if the surfaces combination is valid
; 3. Splits non-touching surfaces if needed
; @param surfaces The tooth surface notation (e.g., "mo", "do", "mod")
; @return Array of valid surface combinations, or empty array if invalid
sortAndSplitNonAdjacentSurfaces(surfaces)
{
    result := []
    
    ; First, sort the surfaces
    sortedSurfaces := sortSurfaces(surfaces)
    
    ; Then check if the sorted surfaces are valid
    if (validSurfaces(sortedSurfaces))
    {
        ; If valid, determine whether to return as one or split
        result := splitNonTouchingSurfaces(sortedSurfaces)
    }
    ; If not valid, return empty array (already initialized as empty)
    
    return result
}

; Checks if a string represents a valid tooth number
; @param tooth The tooth notation to check
; @return true if the string represents a valid tooth number, false otherwise
isTooth(tooth)
{
    global allTeeth
    return tooth ~= "^(" . allTeeth . ")$"
}

; Checks if a tooth is a primary tooth
; @param tooth The tooth notation (e.g., "a", "b", "t")
; @return true if the tooth is primary, false otherwise
isPrimary(tooth) 
{
    global primaryTeeth
    return tooth ~= "^(" . primaryTeeth . ")$"
}

; Checks if a tooth is a permanent tooth
; @param tooth The tooth notation (e.g., "1", "2", "32")
; @return true if the tooth is permanent, false otherwise
isPermanent(tooth) 
{
    global permanentTeeth
    return tooth ~= "^(" . permanentTeeth . ")$"
}

; Checks if a tooth is a permanent posterior tooth
; @param tooth The tooth notation (e.g., "1", "2", "32")
; @return true if the tooth is a permanent posterior tooth, false otherwise
isPermanentPosterior(tooth) 
{
    global permanentPosteriorTeeth
    return tooth ~= "^(" . permanentPosteriorTeeth . ")$"
}

; Checks if a tooth is a permanent molar
; @param tooth The tooth notation (e.g., "1", "2", "3", "14", "15", "16", "17", "18", "19", "30", "31", "32")
; @return true if the tooth is a permanent molar, false otherwise
isPermanentMolar(tooth)
{
    global permanentMolars
    return tooth ~= "^(" . permanentMolars . ")$"
}

; Checks if a tooth is a permanent premolar
; @param tooth The tooth notation (e.g., "4", "5", "12", "13", "20", "21", "28", "29")
; @return true if the tooth is a permanent premolar, false otherwise
isPermanentPremolar(tooth)
{
    global permanentPremolars
    return tooth ~= "^(" . permanentPremolars . ")$"
}

; Checks if a tooth is a permanent anterior tooth
; @param tooth The tooth notation (e.g., "6", "11")
; @return true if the tooth is a permanent anterior tooth, false otherwise
isPermanentAnterior(tooth) 
{
    global permanentAnteriorTeeth
    return tooth ~= "^(" . permanentAnteriorTeeth . ")$"
}

; Checks if a tooth is a posterior tooth (molar or premolar)
; @param tooth The tooth notation (e.g., "1", "2", "14", "15", "18", "19", "30", "31")
; @return true if the tooth is a posterior tooth, false otherwise
isPosterior(tooth)
{
    global posteriorTeeth
    return tooth ~= "^(" . posteriorTeeth . ")$"
}

; Checks if a tooth is an anterior tooth (canine or incisor)
; @param tooth The tooth notation (e.g., "6", "7", "8", "9", "10", "11")
; @return true if the tooth is an anterior tooth, false otherwise
isAnterior(tooth)
{
    global anteriorTeeth
    return tooth ~= "^(" . anteriorTeeth . ")$"
}

; Checks if a tooth is a primary posterior tooth
; @param tooth The tooth notation (e.g., "A", "B", "I", "J", "K", "L", "S", "T")
; @return true if the tooth is a primary posterior tooth, false otherwise
isPrimaryPosterior(tooth)
{
    global primaryPosteriorTeeth
    return tooth ~= "^(" . primaryPosteriorTeeth . ")$"
}

; Checks if a tooth is a primary anterior tooth
; @param tooth The tooth notation (e.g., "C", "D", "E", "F", "G", "H", "M", "N", "O", "P", "Q", "R")
; @return true if the tooth is a primary anterior tooth, false otherwise
isPrimaryAnterior(tooth)
{
    global primaryAnteriorTeeth
    return tooth ~= "^(" . primaryAnteriorTeeth . ")$"
}

; Checks if a tooth is in the maxillary arch (upper)
; @param tooth The tooth notation
; @return true if the tooth is maxillary, false otherwise
isMaxillary(tooth) 
{
    global maxillaryTeeth
    return tooth ~= "^(" . maxillaryTeeth . ")$"
}

; Checks if a tooth is in the mandibular arch (lower)
; @param tooth The tooth notation
; @return true if the tooth is mandibular, false otherwise
isMandibular(tooth)
{
    global mandibularTeeth
    return tooth ~= "^(" . mandibularTeeth . ")$"
}

; Checks if a number sequence is ascending
; @param start The starting number
; @param end The ending number
; @return true if start < end (ascending), false otherwise
isAscending(start, end)
{
    return start < end
}

; Checks if a string is empty or contains only whitespace
; @param str The string to check
; @return true if the string is empty or contains only whitespace, false otherwise
isWhiteSpace(str)
{
    return str ~= "^(\s*)$"
}

; Gets the primary predecessor for a permanent tooth
; @param permTooth The permanent tooth number (1-32)
; @return The corresponding primary tooth letter, or empty if no match
primaryPredecessor(permTooth)
{
    if (permTooth >= 4 && permTooth <= 13)
        return Chr(64 + (permTooth - 3))  ; Convert upper permanent (4-13) to primary (A-J)
    else if (permTooth >= 20 && permTooth <= 29)
        return Chr(74 + (permTooth - 19))  ; Convert lower permanent (20-29) to primary (K-T)
    return ""
}

; Gets the permanent successor for a primary tooth
; @param primTooth The primary tooth letter (A-T or a-t)
; @return The corresponding permanent tooth number, or 0 if no match
permanentSuccessor(primTooth)
{
    ; Convert to uppercase for consistent handling
    primTooth := Format("{:U}", primTooth)
    
    if isPrimary(primTooth) 
    {
        if isMaxillary(primTooth)
            return Asc(primTooth) - 64 + 3  ; Convert primary (A-J) to upper permanent (4-13)
        else
            return Asc(primTooth) - 74 + 19  ; Convert primary (K-T) to lower permanent (20-29)
    }
    return 0
}

; Returns an array of all teeth within a range (inclusive)
; @param start The starting tooth number
; @param end The ending tooth number
; @return Array containing all teeth numbers in the range (handles both ascending and descending order)
GetTeethInRange(start, end) 
{
    teeth := []
    
    if isAscending(start, end)  ; start < end
    {
        Loop, % end - start + 1
        {
            tooth := start + A_Index - 1
            teeth.Push(tooth)
        }
    }
    else  ; start > end (descending order)
    {
        Loop, % start - end + 1
        {
            tooth := start - A_Index + 1
            teeth.Push(tooth)
        }
    }
    
    return teeth
}

; Returns an array of teeth between start and end (exclusive)
; @param start The starting tooth number (not included)
; @param end The ending tooth number (not included) 
; @return Array containing teeth numbers between start and end
GetTeethBetween(start, end)
{
    teeth := []
    
    if isAscending(start, end)  ; start < end
    {
        Loop, % end - start - 1
        {
            tooth := start + A_Index
            teeth.Push(tooth)
        }
    }
    else  ; start > end (descending order)
    {
        Loop, % start - end - 1
        {
            tooth := start - A_Index
            teeth.Push(tooth)
        }
    }
    
    teethStr := ""
    for i, tooth in teeth
        teethStr .= tooth . ", "
    teethStr := SubStr(teethStr, 1, -2)  ; Remove trailing comma and space
    
    return teeth
}

GetActivePrompt()
{
    global promptPixels

    ; Iterate through the pixel objects
    for index, pixel in promptPixels {
        ; Check if the pixel is black and return type if it is
        PixelGetColor, color, pixel[2].x, pixel[2].y, RGB
        if (color = "0x000000")
            return pixel[1]
    }

    ; No black pixel found, return an empty string or a default value
    return ""
}

Copy(item) ;Backs up clipboard, copies, returns text, and restores clipboard
{
	clipboardBackup := clipboard
	SendInput ^c ;Copies
	ClipWait, 5
	if ErrorLevel
	{
		clipboard := clipboardBackup
		ErrorMessage("Clipboard never changed for " . item, 0) ;aborts after one second if copy doesn't register
	}
	Sleep, 100
	copiedText := clipboard
	clipboard := clipboardBackup
	return copiedText
}

DisplayArray(array) ;Displays array in a MsgBox
{
    if (!IsObject(array))
    {
        MsgBox, Error: Input is not an array.
        return
    }

    ArrayString := "Array Length: " . array.Length() . "`n`n"  ; Show array length

    for index, element in array
    {
        ArrayString .= "Element " . index . ": "
        
        if (IsObject(element))
        {
            ArrayString .= "Object`n"
            for key, value in element
            {
                ArrayString .= "  " . key . ": " . value . "`n"
            }
        }
        else
        {
            ArrayString .= element . "`n"
        }
        
        ArrayString .= "`n"  ; Add an extra newline for readability between elements
    }

    MsgBox, % ArrayString  ; Display the array contents in a message box
    return
}

^+v:: ; Ctrl+Shift+V to trigger the replacement
{
	; Get the selected text
	Clipboard := ""
	Send, ^x
	ClipWait

	; Check if the clipboard contains valid coordinates
	if (RegExMatch(Clipboard, "Click, (\d+), (\d+)(.*)", coords)) {
		; Prompt for a variable name
		InputBox, variableName, Enter Variable Name,, , 250, 120

		; Replace the coordinates with the variable and preserve the comment
		replacedText := "MouseClick,, % " . variableName . "[1], % " . variableName . "[2]" . coords3

		; Store the variable declaration in the clipboard with a newline
		variableDeclaration := "`nglobal " . variableName . "`n" . variableName . " := [" . coords1 . ", " . coords2 . "]"
		Clipboard := variableDeclaration
		Click
		; Replace the selected text
		Send, %replacedText%
	}
	else if (RegExMatch(Clipboard, "PixelGetColor(.*), (\d+), (\d+)(.*)", coords)) {
        ; Prompt for a variable name
        InputBox, variableName, Enter Variable Name,, , 250, 120

        ; Replace the coordinates with the variable and preserve the comment
        replacedText := "PixelGetColor" . coords1 . ", % " . variableName "[1], % " variableName "[2]" . coords4

        ; Store the variable declaration in the clipboard with a newline
        variableDeclaration := "`nglobal " . variableName . "`n" . variableName . " := [" . coords2 . ", " . coords3 . "]"
        Clipboard := variableDeclaration
		Click
        ; Replace the selected text
        Send, %replacedText%
    }
	else if (RegExMatch(Clipboard, "color(\d)* = (.*)", coords)) {
        ; Prompt for a variable name
        InputBox, variableName, Enter Variable Name,, , 250, 120

        ; Replace the coordinates with the variable and preserve the comment
        replacedText := "color" . coords1 . " = " . variableName

        ; Store the variable declaration in the clipboard with a newline
        variableDeclaration := "`nglobal " . variableName . "`n" . variableName . " := " . coords2
        Clipboard := variableDeclaration
		Click
        ; Replace the selected text
        Send, %replacedText%
    }
	else
		MsgBox, No valid coordinates selected.
	return
}

MouseWithin(UL, LR) ;Returns whether the mouse is within the rectangle bounded by UL and LR pixels
{
    MouseGetPos, MouseX, MouseY
    if (MouseX >= UL.x AND MouseX <= LR.x AND MouseY >= UL.y AND MouseY <= LR.y)
	    return true
    else
		return false
}

IndexOf(haystack, needle) ;Finds index of item in an array
{
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0

	for index, value in haystack
		if (value = needle)
			return index
	return 0
}

HasVal(haystack, needle) ;Checks if value exists in array
{
    return IndexOf(haystack, needle) > 0
}

Banner(message) ;Displays notice for 1 second
{
	Tooltip, % message, 550, 5
	Sleep, 1000
	Tooltip
	return
}

;Iterates from a given pixel, by a given increment of pixels, in a given direction, looking for a given color, returns those coordinates, also has toggle to reverse logic for color, and boolean for positive or negative direction
FindColor(xStart, yStart, xORy, increment, maxPixelsToCheck, colorToFind, altColorToFind := "", reverse := false, positive := true)
{
	color := 0
	x := xStart
	y := yStart
	results := {}
	results.color := 0
	while (Abs(xStart - x) <= maxPixelsToCheck AND Abs(yStart - y) <= maxPixelsToCheck)
	{
		PixelGetColor, color, x, y, RGB
		if ((reverse = 0 AND color = colorToFind) OR (reverse = 1 AND color != colorToFind AND color != altColorToFind))
		{
			results.color := 1
			results.x := x
			results.y := y
			break
		}
		else if (reverse = 0 AND color = altColorToFind)
		{
			results.color := 2
			results.x := x
			results.y := y
			break
		}
		if positive
		{
			if (xORy = "x")
				x+=increment
			else
				y+=increment
		}
		else
		{
			if (xORy = "x")
				x-=increment
			else
				y-=increment
		}
	}
	return results
}

WaitForOpenDentalPatientChart(patient, timeout := 8) ;Wait's for Open Dental to return, then waits .2 secs
{
	patientID := patient.ID

	SetTitleMatchMode RegEx
    WinWaitActive, Open Dental.*%patientID%,, %timeout%
    if (ErrorLevel)
        ErrorMessage("Open to chart of: " . patient.FirstNameSimp . " " . patient.LastName . " " . patient.ID)
	Sleep, 200
	SetTitleMatchMode, 1
    return
}


ConfirmOpenDentalPatientChart(patient) ;Confirms Open Dental is active for the given patient
{
	SetTitleMatchMode RegEx
    Loop
    {
        if (WinActive("Open Dental.*" . patient.ID) AND ConfirmChartingMode())
        {
			SetTitleMatchMode, 1
			return  ; Conditions met, exit the function
		}
        else
            ErrorMessage("Open to chart of: " . patient.FirstNameSimp . " " . patient.LastName . " " . patient.ID)
    }
}

SetSurfaces(surfaces) ;Sets surfaces, returns true if it is an anterior and should be D2335 manually set
{
	global chartSurfacesField
	global surfacesArray
	global procedureInfoCodeField
	global procedureInfoSurfacesField
	global chartSurfacesPixel
	global chartSurfacesBlankColor
	surfaces := StrUpper(surfaces)
	if (InStr(surfaces, "I") AND (InStr(surfaces, "M") OR InStr(surfaces, "D")) AND (InStr(surfaces, "F") OR InStr(surfaces, "L")))
		D2335 := true
	if WinActive("Open Dental {")
	{
		surfacesToSet := StrSplit(surfaces)

		;Checks to see if any surfaces already entered into surfaces box, if so, deselects unneeded ones and adds necessary ones, otherwise just adds surfaces
		PixelGetColor, color, chartSurfacesPixel.x, chartSurfacesPixel.y, RGB
		if (color != chartSurfacesBlankColor)
		{
			MouseClick,, % chartSurfacesField.x, % chartSurfacesField.y, 2 ;Selects surfaces box
			selectedSurfaces := StrSplit(Copy("Surfaces"))
			surfacesToSet := StrSplit(surfaces)

			; Deletes surfaces not needed
			for index, surface in selectedSurfaces
			{
				if !IndexOf(surfacesToSet, surface)
					MouseClick,, % surfacesArray[surface].x, % surfacesArray[surface].y ;deselects surface
			}

			; Adds surfaces not previously added
			for index, surface in surfacesToSet
			{
				if !IndexOf(selectedSurfaces, surface)
					MouseClick,, % surfacesArray[surface].x, % surfacesArray[surface].y ;selects surface
			}
		}
		else
		{
			; Adds surfaces
			for index, surface in surfacesToSet
				MouseClick,, % surfacesArray[surface].x, % surfacesArray[surface].y ;selects surfaces
		}
	}
	else if WinActive("Procedure Info - ") ;Sets surfaces in Procedure Info
	{
		; Checks to see if code should be updated to D2335
		if D2335
		{
			MouseClick,, % procedureInfoCodeField.x, % procedureInfoCodeField.y, 2 ;Selects code field
			if (Copy("Code Field") != "D2335")
				UpdateCode("D2335")
		}
		MouseClick,, % procedureInfoSurfacesField.x, % procedureInfoSurfacesField.y, 2 ;Selects surfaces box
		SendInput, %surfaces%
		Sleep, 100
	}
	else
		ErrorMessage("Open Dental not active for SetSurfaces()", 0) ;Otherwise throws error

	if (D2335)
		return true
	else
		return false
}

DefocusTextBox() ;Removes focus from a text box so keyboard shortcuts can be used
{
	WinGetActiveTitle, title
	ControlFocus,, % title ;Removes keyboard focus
	return
}

AutoNote() ;Opens AutoNote button
{
	global procedureInfoAutoNote
	global groupNoteAutoNote

	if WinActive("Procedure Info")
		MouseClick,, % procedureInfoAutoNote.x, % procedureInfoAutoNote.y
	else if WinActive("Group Note")
		MouseClick,, % groupNoteAutoNote.x, % groupNoteAutoNote.y
	WaitWin("Compose Auto Note",2)
	return
}

ClickOK() ;Clicks OK button
{
	global editPopupOKButton
	global previewSaveButtonPixel
	global composeAutoNoteSaveButtonPixel

	WinGetActiveTitle, title
	ControlFocus,, % title ;Removes keyboard focus
	if (RegExMatch(title, "^(Popups for Family)"))
		SendInput !c
	else if (RegExMatch(title, "^(Communication Item|Edit Appointment)"))
		SendInput !s
	else if (RegExMatch(title, "^(Task|Group Note|Procedure Info|Popup|Edit Blockout|Edit Rx)"))
		SendInput !s
	else if (RegExMatch(title, "^(Production and Income Report)"))
		SendInput !o
	else if (RegExMatch(title, "^(Edit Popup)")) ;Clicks via coords because no keyboard shortcut for OK
	{
		MouseClick,, % editPopupOKButton.x, % editPopupOKButton.y
		WaitWin("Popups for Family",2)
		SendInput !c
	}
	else if (RegExMatch(title, "^(Preview)"))
		MouseClick,, % previewSaveButtonPixel.x, % previewSaveButtonPixel.y ;Clicks Save
	else if (RegExMatch(title, "^(Compose Auto Note)"))
		MouseClick,, % composeAutoNoteSaveButtonPixel.x, % composeAutoNoteSaveButtonPixel.y
	return
}

ClickButton(buttonList, buttonIndexToClick, numClicks := 1) ;Clicks on index of buttonlist object, with the first button being at index 1
{
    ;Reset the scroll bar if one exists, and if it is not at the top already
    if (buttonList.scrollDownButtonX != 0)
    {
        PixelGetColor, color, % buttonList.scrollDownButtonX, % buttonList.resetScrollY, RGB
        if (color = buttonList.scrollBarBackgroundColor)
            MouseClick,, % buttonList.scrollDownButtonX, % buttonList.resetScrollY
    }
    Sleep, 100

    ; Calculate yPosToClick
    yPosToClick := buttonList.yStart + (buttonIndexToClick - 1) * buttonList.buttonHeight

    ; Check if button is valid
    if (buttonList.scrollDownButtonX = 0 AND (buttonIndexToClick < 1 OR buttonIndexToClick > buttonList.buttonsDisplayed))
        ErrorMessage("Invalid Button Index", 0)

    ; Check if the button is outside the visible area
    if (buttonList.scrollDownButtonX != 0 AND (yPosToClick >= buttonList.yStart + buttonList.buttonsDisplayed * buttonList.buttonHeight))
    {
        ; Calculate how many times to click the scroll arrow
        timesToClickScroll := Ceil((yPosToClick - (buttonList.yStart + buttonList.buttonsDisplayed * buttonList.buttonHeight)) / buttonList.buttonHeight)

        ; Adjust yPosToClick to be within the visible area
        yPosToClick := buttonList.yStart + (buttonList.buttonsDisplayed - 1) * buttonList.buttonHeight

        ; Click the scroll button
        Loop, %timesToClickScroll%
        {
            MouseClick,, % buttonList.scrollDownButtonX, % buttonList.scrollDownButtonY
            Sleep, 100
        }
    }

    ;Clicks if the button is not already selected
    PixelGetColor, color, % buttonList.x, %yPosToClick%, RGB
    if (color != buttonList.colorIfAlreadyClicked)
    {
        ; Click the target button
        MouseClick,, % buttonList.x, %yPosToClick%
        if (numClicks = 2) ;Double clicks if needed
        {
            Sleep, 100
            Click
        }
    }
    return
}

SetDiagnosis(diag) ;Sets diagnosis code based on numerical position
{
	global diagnosis
	global chartDiagnosisButtons
	global procedureInfoDiagnosisButtons
	global procedureInfoDiagnosisDropdown
	number := IndexOf(diagnosis, diag)
	if WinActive("Open Dental {")
		button := chartDiagnosisButtons
	else if WinActive("Procedure Info - ")
	{
		button := procedureInfoDiagnosisButtons
		MouseClick,, % procedureInfoDiagnosisDropdown.x, % procedureInfoDiagnosisDropdown.y ;Clicks dropdown for diagnosis
	}
	ClickButton(button, number)
	return
}

SetProcedureButtons(button) ;Clicks procedure button
{
	global procButtons
	global procedureButtons
	number := IndexOf(procButtons, button)
	ClickButton(procedureButtons, number)
	return
}

SingleClick(index) ;Selects button by index on the Single Click: column
{
	global singleClickButtons
	ClickButton(singleClickButtons, index)
	return
}

SetSelectedTeeth(condition) ;Sets Selected Teeth
{
	global missingNotMissingHiddenButtons
	global primaryPermanentButtons
	selection := IndexOf(["missing", "notmissing", "hidden"], condition)
	if (selection) ;condition is "missing", "notmissing", or "hidden"
		button := missingNotMissingHiddenButtons
	else
	{
		selection := IndexOf(["primary", "permanent"], condition)
		if (selection) ;condition is "primary" or "permanent"
			button := primaryPermanentButtons
		else
			ErrorMessage(condition . " is an invalid parameter for SetSelectedTeeth()", 0)
	}
    
    GetState() ;Get's state of chart
	SetChartTab("MissingPrimary") ;Sets chart tab to Missing Primary
	ClickButton(button, selection) ;Clicks missing, notmissing, hidden, primary, or permanent
    RestoreState() ;Restores state of chart
	return
}

SetAllTeeth(condition) ;Sets All Teeth
{
	global primaryPermanentAllButtons
	buttonIndexToClick := IndexOf(["primary", "permanent", "mixed"], condition)
	if (buttonIndexToClick = 0)
		ErrorMessage(condition . " is an invalid parameter for SetAllTeeth()", 0)

	SetChartTab("MissingPrimary") ;Sets chart tab to Missing Primary
	ClickButton(primaryPermanentAllButtons, buttonIndexToClick) ;Clicks primary, permanent, or mixed
	return
}

SetEdentulous() ;Sets all as edentulous
{
	global edentulousButton
	SetChartTab("MissingPrimary") ;Sets chart tab to Missing Primary
	MouseClick,, % edentulousButton.x, % edentulousButton.y ;Clicks Edentulous
	return
}

Unhide() ;Clicks Unhide button
{
	global unhideButton
	SetChartTab("MissingPrimary") ;Sets chart tab to Missing Primary
	MouseClick,, % unhideButton.x, % unhideButton.y ;Clicks unhide
	return
}

ClearMovements() ;Clears movement of selected teeth
{
	global mesialMovementTextBoxPixel
	global movementsApplyButtonPixel
	SetChartTab("Movements")
	MouseClick,, % mesialMovementTextBoxPixel.x, % mesialMovementTextBoxPixel.y, 2 ;Clicks Mesial Movement Text Box to select contents
	SendInput 0{Tab}0{Tab}0{Tab 7}0{Tab}0{Tab}0 ;Zeroes out movements
	MouseClick,, % movementsApplyButtonPixel.x, % movementsApplyButtonPixel.y ;Clicks Apply
	return
}

ToothIsPresent(teeth, APresent := -1, JPresent := -1, KPresent := -1, TPresent := -1, LPresent := -1) ;Returns whether a tooth number is present and unmoved. Accepts a string of comma-delimited teeth, a single tooth, or an array of teeth
{
	if !IsObject(teeth) ;If teeth is a string, create an array
		teeth := ToothArray(teeth)
	else if (teeth.Length() = 0) ;Single tooth passed
		teeth := [teeth]
	else if !IsObject(teeth[1]) ;Array of numbers passed
	{
        global tooth
		teethTemp := []
		for index, toothNumber in teeth
			teethTemp.push(tooth[toothNumber])
		teeth := teethTemp
}

	; Loop through the array
	for index, toothToCheck in teeth
	{
		;If tooth is a perm molar, checks to see if primary present because that determines what array to use
		if (toothToCheck.index <= 3)
		{
			if (APresent = -1)
				APresent := ToothIsPresent("A")
			if (APresent = 1)
			{
				x := toothToCheck.xPrimary
				y := toothToCheck.yPrimary
				colorIfPresent := toothToCheck.colorIfPresentPrimary
				colorIfSelected := toothToCheck.colorIfSelectedPrimary
			}
			else
			{
				x := toothToCheck.x
				y := toothToCheck.y
				colorIfPresent := toothToCheck.colorIfPresent
				colorIfSelected := toothToCheck.colorIfSelected
			}
		}
		else if (toothToCheck.index >= 14 AND toothToCheck.index <= 16)
		{
			if (JPresent = -1)
				JPresent := ToothIsPresent("J")
			if (JPresent = 1)
			{
				x := toothToCheck.xPrimary
				y := toothToCheck.yPrimary
				colorIfPresent := toothToCheck.colorIfPresentPrimary
				colorIfSelected := toothToCheck.colorIfSelectedPrimary
			}
			else
			{
				x := toothToCheck.x
				y := toothToCheck.y
				colorIfPresent := toothToCheck.colorIfPresent
				colorIfSelected := toothToCheck.colorIfSelected
			}
		}
		else if (toothToCheck.index >= 17 AND toothToCheck.index <= 19)
		{
			if (KPresent = -1)
				KPresent := ToothIsPresent("K")
			if (KPresent = 1)
			{
				x := toothToCheck.xPrimary
				y := toothToCheck.yPrimary
				colorIfPresent := toothToCheck.colorIfPresentPrimary
				colorIfSelected := toothToCheck.colorIfSelectedPrimary
			}
			else
			{
				x := toothToCheck.x
				y := toothToCheck.y
				colorIfPresent := toothToCheck.colorIfPresent
				colorIfSelected := toothToCheck.colorIfSelected
			}
		}
		else if (toothToCheck.index >= 30 AND toothToCheck.index <= 32)
		{
			if (TPresent = -1)
				TPresent := ToothIsPresent("T")
			if (TPresent = 1)
			{
				x := toothToCheck.xPrimary
				y := toothToCheck.yPrimary
				colorIfPresent := toothToCheck.colorIfPresentPrimary
				colorIfSelected := toothToCheck.colorIfSelectedPrimary
			}
			else
			{
				x := toothToCheck.x
				y := toothToCheck.y
				colorIfPresent := toothToCheck.colorIfPresent
				colorIfSelected := toothToCheck.colorIfSelected
			}
		}
		else
		{
			x := toothToCheck.x
			y := toothToCheck.y
			colorIfPresent := toothToCheck.colorIfPresent
			colorIfSelected := toothToCheck.colorIfSelected
		}

		if (toothToCheck.number = "J") ;if L is missing, J is moved right one
		{
			if (LPresent = -1)
				LPresent := ToothIsPresent("L")
			if !LPresent
				x += 1
		}

		PixelGetColor, color, x, y, RGB
		if (color != colorIfPresent AND color != colorIfSelected)
			return false
	}
	return true
}

ToothArray(teethString) ;Creates an array of teeth from a string
{
	global tooth
    toothArray := []

    ; Splits the input string by comma to extract individual tooth numbers
    Loop, Parse, teethString, `,
    {
		if !RegExMatch(A_LoopField, "^(?:[1-9]|[1-2][0-9]|3[0-2]|[A-T])$")
			ErrorMessage(A_LoopField . " is not a valid tooth for ToothArray()", 0)
        ; Adds the parsed tooth number to the array
        toothArray.Push(tooth[A_LoopField])
    }

    ; Returns the array of tooth objects
    return toothArray
}

SelectTeeth(teethParam) ;Selects teeth. Accepts a string of comma-delimited teeth, a single tooth, or an array of teeth, or an array of teeth numbers
{
	if !IsObject(teethParam) ;If teeth is a string, create an array
		teeth := ToothArray(teethParam)
	else if (teethParam.Length() = 0) ;Single tooth passed
		teeth := [teethParam]
	else if !IsObject(teethParam[1]) ;Array of numbers passed
	{
		global tooth
		teeth := []
		for index, toothNumber in teethParam
			teeth.push(tooth[toothNumber])
	}

	DeselectTeeth()
	Sleep, 300
	;Sets default for A,J,K,T,L as undefined, and this will get updated as the method iterates through the array, so as not to perform additional checks if unneeded
	APresent := -1
	JPresent := -1
	KPresent := -1
	TPresent := -1

    for index, toothToSelect in teeth
	{
		usePrimary := false

		; If tooth is a perm molar, checks to see if primary present because that determines what array to use
		if (toothToSelect.index <= 3)
		{
			if (APresent = -1)
				APresent := ToothIsPresent("A")
			if APresent
				usePrimary := true
		}
		else if (toothToSelect.index >= 14 AND toothToSelect.index <= 16)
		{
			if (JPresent = -1)
				JPresent := ToothIsPresent("J")
			if JPresent
				usePrimary := true
		}
		else if (toothToSelect.index >= 17 AND toothToSelect.index <= 19)
		{
			if (KPresent = -1)
				KPresent := ToothIsPresent("K")
			if KPresent
				usePrimary := true
		}
		else if (toothToSelect.index >= 30)
		{
			if (TPresent = -1)
				TPresent := ToothIsPresent("T")
			if TPresent
				usePrimary := true
		}

		;If a molar and the primary terminal molar is present, adjusts to use the appropriate coordinates and color
		if usePrimary
		{
			x := toothToSelect.xPrimary
			y := toothToSelect.yPrimary
			colorIfPresent := toothToSelect.colorIfPresentPrimary
		}
		else
		{
			x := toothToSelect.x
			y := toothToSelect.y
			colorIfPresent := toothToSelect.colorIfPresent
		}

		if (toothToSelect.number = "J") ;if L is not present, then J gets shifted to the right one pixel
		{
			if !ToothIsPresent("L")
				x += 1
		}

		PixelGetColor, color, x, y, RGB
        ;MsgBox, % "x: " . x . " y: " . y
        ;MsgBox, % "Color: " . color . " ColorIfPresent: " . colorIfPresent
		if (color = colorIfPresent)
			MouseClick,, % x, % y, RGB
		else
			ErrorMessage("Tooth " . toothToSelect.number . " is not present and unmoved", 0)
	}
	return
}


DeselectTeeth() ;Deselects teeth
{
	SendInput, {F1} ;Deselects teeth
	return
}

TeethUnmoved(dentition := "permanent") ;Checks to see if teeth numbers are in original position
{
	if (dentition = "primary")
		teeth := "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T"
	else if (dentition = "permanent")
		teeth := "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32"
	else
		ErrorMessage(dentition . " is incorrect dentition paramenter for TeenUnmoved()", 0)

	return ToothIsPresent(teeth)
}

GetMissingTeeth() ;Returns missing permanent teeth
{
	global tooth
	global missingToothColor
	global ODY
	missingTeeth := [] ; Initialize an array to store missing teeth numbers

	Loop 32
	{
		toothToCheck := tooth[A_Index]
		x := toothToCheck.x
		if (A_Index = 4) ;Tooth 4 needs x to be corrected by -2
			x-=2

		if !ToothIsPresent(toothToCheck)
			return false

		if (A_Index <= 16)
			PixelGetColor, color, x, ODY+95, RGB ;Checks if tooth is present
		else
			PixelGetColor, color, x, ODY+212, RGB ;Checks if tooth is present
		if (color = missingToothColor)
			missingTeeth.push(A_Index) ; Add the tooth number to the array
	}

	return missingTeeth
}

GetSelectedTeeth(permanentOnly := false) ;Returns selected teeth
{
	global tooth
	global unselectedToothColor

	selectedTeeth := [] ; Initialize an array to store selected teeth numbers

	APresent := ToothIsPresent("A")
	LPresent := ToothIsPresent("L")
	JPresent := ToothIsPresent("J",,,,,LPresent)
	KPresent := ToothIsPresent("K")
	TPresent := ToothIsPresent("T")

	for index, toothToCheck in tooth
	{
		if (!toothToCheck.permanent AND permanentOnly) ;Skips rest of iteration if only checking permanents and this is a primary
			break
		; If tooth is a perm molar, checks to see if primary present because that determines what array to use
		if ((toothToCheck.index <= 3 AND APresent) OR ((toothToCheck.index >= 14 AND toothToCheck.index <= 16) AND JPresent) OR ((toothToCheck.index >= 17 AND toothToCheck.index <= 19) AND KPresent) OR ((toothToCheck.index >= 30 AND toothToCheck.index <= 32) AND TPresent))
		{
			x := toothToCheck.xPrimary
			y := toothToCheck.yPrimary
		}
		else
		{
			x := toothToCheck.x
			y := toothToCheck.y
		}
		if (toothToCheck.number = "J" AND !LPresent) ;if L is not present, then J gets shifted to the right one pixel
			x += 1

		PixelGetColor, color, x, y, RGB
		if (color = toothToCheck.colorIfSelected)
			selectedTeeth.push(toothToCheck.number) ; Add the tooth number to the array
		else if (toothToCheck.permanent AND color != unselectedToothColor) ;for teeth 1-32, throws an error if tooth is not selected or unselected.
			return false
	}
	return selectedTeeth
}

;WinActive() with RegEx mode
WinActiveRegex(WinTitle) {
    ; Store the current SetTitleMatchMode
    SetTitleMatchMode := A_TitleMatchMode
    
    ; Set to RegEx mode
    SetTitleMatchMode, RegEx
    
    ; Check if the window is active
    isActive := WinActive(WinTitle)
    
    ; Restore the original SetTitleMatchMode
    SetTitleMatchMode, %SetTitleMatchMode%
    
    return isActive
}

DismissPopups()
{
	Sleep, 200
	while (WinActive("Popup") AND A_Index < 5) ;Dismisses up to 5 popups
	{
		Sleep, 1000 ;Gives time to read popup
		ClickOK() ;Dismisses popup
		Sleep, 200
	}
	return
}

GetState() ;Gets state of OP Charting tab
{
	global ODState
	ODState.ChartTab := GetChartTab()
	if (ODState.ChartTab = "Treatment" AND ChartingTabExpanded())
		ODState.TxMode := GetTxMode()
	return
}

RestoreState() ;restores Chart to previously selected tab and chart
{
	global ODState
	if (ODState.ChartTab != "")
	{
		SetChartTab(ODState.ChartTab)
		if(ODState.ChartTab = "Treatment" AND ODState.TxMode != "") ;If on treatment tab, restores txMode
		{
			Sleep, 100
			SetTxMode(ODState.TxMode)
		}
		ODState := {}
	}
	return
}

CountButtons(buttonList) ;finds how many buttons exist, if colorIsButton, continues until color1 or color2 no longer matches, otherwise continues until background matches either of these colors
{
    buttons := 0
    x := buttonList.x
    y := buttonList.yStart

    while (buttons < buttonList.buttonsDisplayed)
    {
        PixelGetColor, currentColor, x, y, RGB
        if (buttonList.colorIsButton)
        {
            if (currentColor != buttonList.color1 AND (buttonList.color2 = "" OR currentColor != buttonList.color2))
                return buttons
        }
        else
        {
            if (currentColor = buttonList.color1 OR (buttonList.color2 != "" AND currentColor = buttonList.color2))
                return buttons
        }
        buttons++
        y += buttonList.buttonHeight
    }
    return buttons
}

;Finds patient in appropriate database, searching Chrome tabs, and then opening chart if needed
FindPatient(database, patient)
{
	global chromeSearchTabsButton
	global chromeTopResultPixel
	global iTeroSearchBoxPixel
	global iTeroDividerBetweenResultsOneAndTwoPixel
	global iTeroSearchCompletePixel
	global iTeroNoResultsPixel
	global iTeroPatientPageNoResultsPixel
	global iTeroPatientPagePixel
	global iTeroPatientPageAltColorPixel
	global iTeroPatientPageEndDrag
	global iTeroCaseType1Pixel
	global iTeroCaseType2Pixel
	global clinCheckFirstResultPixel
	global clinCheckPatientFindColorPixel
	global clinCheckPatientFindColors
	global clinCheckOpenClinCheckFindColorPixel
	global xvWebWebsite
	global xvWebImagingPatientSearchBlankScreenPixel
	global xvWebImagingPatientSearchPixel
	global xvWebViewButton
	global xvWebNoResults
	global xvWebButtonWidth
	global xvWebButtonHeight
	global xvWebButtonStartX
	global xvWebButtonStartY
	global xvWebyPos
	global xvWebPatientLinePixel
	global xvWebEditButtonFindColor
	global xvWebConfirmButtonPixel
	global xvWebGender
	global xvWebClickOutsideDatePicker
	global xvWebFirstRadiographViewBoxPixel
	global xvWebFirstRadiographViewBoxPixelLongWait
	global xvWebFirstRadiographPixel
	global xvWebFinalMousePosition
	global xvWebTooltip
	global xvWebGenderButtons
	global xvWebDOBEmpty

	if (patient.Source = "NA") ;No patient to find
		ErrorMessage("No patient passed to FindPatient()",0)

	if (database = "DEXIS")
	{
		PatID := patient.ID
		if WinActive("DEXIS.*%PatID%") ;if Dexis open for this patient, activate, otherwise open Dexis
			WinActivate, DEXIS
		else
			Run, Dexis.exe %PatID%
		Return()
	}
	checkCurrentPage := !ChromeWinActive() ;if Chrome is active when called, no need to check current page

	if (ChromeWinExist() AND (database = "xvWeb" OR database = "iTero" OR database = "ClinCheck"))
	{
		ChromeWinActivate()
		ChromeWaitWin(5)
		if (database = "xvWeb")
		{
			/* No way to currently look for open tab
			SendEvent, ^+a ;Opens tab search
			Sleep, 400
			patientString := "&lastname=" . patient.LastName . "&firstname=" . patient.FirstNameSimp . "*"
			SendInput, %patientString%
			Sleep, 300
			PixelGetColor, color, 24, 136, RGB
			PixelGetColor, color2, 28, 137, RGB
			if (color = 0xE0E0E0 AND color2 = 0xDFDFE0) ;there is a result
			{
				Click, 24, 136 ;Clicks top result
				Return()
			}
			*/
		}
		else if (database = "ClinCheck")
		{
			; Disabled current page check for ClinCheck (Invisalign)
			/*
			if checkCurrentPage
			{
				WinGetTitle, title
				regexMatchString := "i)ClinCheck \| " . patient.FirstNameSimp . ".*" . patient.LastName
				if RegExMatch(title, regexMatchString) ;checks to see if current window is the patient
					Return()
			}
			*/
			; Disabled tab search for ClinCheck (Invisalign)
			/*
			FocusAddressBar()
			;Current window is not the correct one
			SendInput, @ ;Opens up search options
			Sleep, 200
			MouseClick,, % chromeSearchTabsButton.x, % chromeSearchTabsButton.y ;Click search tabs
			patientString := database . "*" . patient.FirstNameSimp . "*" . patient.LastName
			SendInput %patientString%
			Sleep, 300
			PixelGetColor, color, chromeTopResultPixel.x, chromeTopResultPixel.y, RGB
			if (color = chromeTopResultPixel.color)
			{
				SendInput {Enter} ;Selects top result
				Return()
			}
			else ;No result, so restores URL
				SendInput, {Esc 3} ;Restores previous URL
			*/
		}
		else if (database = "iTero")
		{
			; Disabled current page check for iTero
			/*
			FocusAddressBar()
			if (checkCurrentPage AND WinActiveRegex("Viewer.*My iTero \- Google Chrome"))
			{
				regexMatchString := "(?i)itero\\S*" . patient.LastName . ",%20" . patient.FirstNameSimp
				if RegExMatch(Copy("URL Bar"), regexMatchString)
				{
					SendInput, {Esc} ;defocuses URL Bar
					Return()
				}
			}
			*/
			; Disabled tab search for iTero
			/*
			;Current window is not the correct one
			SendInput, @ ;Opens up search options
			Sleep, 200
			MouseClick,, % chromeSearchTabsButton.x, % chromeSearchTabsButton.y, ;Click search tabs
			patientString := database . "*" . patient.LastName . ",%20" . patient.FirstNameSimp
			SendInput %patientString%
			Sleep, 300
			PixelGetColor, color, chromeTopResultPixel.x, chromeTopResultPixel.y, RGB
			if (color = chromeTopResultPixel.color)
			{
				SendInput {Enter} ;Selects top result
				Return()
			}
			else ;No result, so restores URL
				SendInput, {Esc 3} ;Restores previous URL
			*/
		}
	}

	;Patient was not open
	if (database = "iTero")
	{
		SetTimer, AutoLoginItero, 250 ;Turns autologin on
		; Need to run chrome to find patient
		Run, chrome.exe "https://bff.cloud.myitero.com/doctors/patients"
		WaitWin("My iTero",8)
		WinMaximize, My iTero
		WaitWin("Patients.*My iTero",8, true)
		Sleep, 500
		WaitForPixel(iTeroSearchBoxPixel)
		MouseClick,, % iTeroSearchBoxPixel.x, % iTeroSearchBoxPixel.y ;Clicks Search box
		Sleep, 200
		WaitForPixel(iTeroSearchBoxPixel)
		SendInput % patient.LastName . ", " . patient.FirstNameSimp . "{Enter}" ;Inputs last name and first name
		Sleep, 500
		WaitForPixel(iTeroSearchCompletePixel)
		color := 0x000000
		PixelGetColor, color, iTeroNoResultsPixel.x, iTeroNoResultsPixel.y, RGB ;Checks to see if no patients found
		if (color = iTeroNoResultsPixel.color)
		{
			SendInput ^a{del} ;deletes name
			SendInput % patient.LastName . ", " . patient.FirstInitial . "{Enter}" ;tries again with first initial
			Sleep, 500
			WaitForPixel(iTeroSearchCompletePixel)
			PixelGetColor, color, iTeroNoResultsPixel.x, iTeroNoResultsPixel.y, RGB ;Checks to see if no patients found
			if (color = iTeroNoResultsPixel.color) ;if no patients, tries with simple last name if different, or aborts
			{
				if(patient.LastName != patient.LastNameSimp)
				{
					SendInput ^a{del} ;deletes name
					SendInput % patient.LastNameSimp . ", " . patient.FirstNameSimp . "{Enter}" ;tries again with Last Name simple
					Sleep, 500
					WaitForPixel(iTeroSearchCompletePixel)
					PixelGetColor, color, iTeroNoResultsPixel.x, iTeroNoResultsPixel.y, RGB ;Checks to see if no patients found
					if (color = iTeroNoResultsPixel.color) ;if no patients, aborts
						Return()
				}
				else
					Return() ;No patients found so it aborts
			}
		}
		PixelGetColor, color, iTeroDividerBetweenResultsOneAndTwoPixel.x, iTeroDividerBetweenResultsOneAndTwoPixel.y, RGB ;Checks to see if divider is colored to indicate more than one results
		if (color = iTeroDividerBetweenResultsOneAndTwoPixel.color) ;if more than one patient, prompt for user to select patient
		{
			BlockInputOff()
			WinGetActiveTitle, title
			ToolTip, % "Select " . patient.FirstName . " " . patient.LastName . " or press Pause/Break to abort"
			KeyWait, LButton, D ; Wait for the left mouse button to be pressed and released
			WinGetActiveTitle, title2
			if (title2 != title) ; If window has been changed, abort
				Return()
			ToolTip ; Clear the tooltip
			Click ; Simulate the mouse click without blocking the actual click
			BlockInputOn()
		}
		else
			MouseClick,, % iTeroNoResultsPixel.x, % iTeroNoResultsPixel.y ;Clicks only resulting patient
		WaitWin("Patient:",10)
		WaitFor2Pixels(iTeroPatientPagePixel, iTeroPatientPageAltColorPixel, iTeroPatientPagePixel.timeout)
		PixelGetColor, color, iTeroPatientPageNoResultsPixel.x, iTeroPatientPageNoResultsPixel.y, RGB
		if (color = iTeroPatientPageNoResultsPixel.color) ;No scan
			Return()
		MouseClickDrag, left, % iTeroPatientPagePixel.x, % iTeroPatientPagePixel.y, % iTeroPatientPageEndDrag.x, % iTeroPatientPageEndDrag.y ;selects procedure
		procedure := Copy("Scan type")
		if (InStr(procedure, "Study Model") OR InStr(procedure, "iCast") OR InStr(procedure, "Denture") OR InStr(procedure, "Restorative") OR InStr(procedure, "Vivera") OR InStr(procedure, "Appliance"))
		{
			PixelGetColor, color, iTeroCaseType1Pixel.x, iTeroCaseType1Pixel.y, RGB
			if (color != iTeroCaseType1Pixel.color)
				MouseClick,, % iTeroCaseType1Pixel.x, % iTeroCaseType1Pixel.y
		}
		else if(procedure != "")
		{
			PixelGetColor, color, iTeroCaseType2Pixel.x, iTeroCaseType2Pixel.y, RGB
			if (color != iTeroCaseType2Pixel.color)
				MouseClick,, % iTeroCaseType2Pixel.x, % iTeroCaseType2Pixel.y
		}
	}
	else if (database = "ClinCheck")
	{
		SetTimer, AutoLoginInvisalign, 250 ;Turns autologin on
		; Need to run chrome to find patient
		website := """https://vip.invisalign.com/v3/auth/patient/patientList.action?display.sortColumn=TREATMENT_STATUS&display.filter=CURRENT&display.lastFilter=ACTION&display.pageNumber=1&display.itemPerPage=100&display.sortDirection=1&display.searchString=" . patient.LastName . "&display.searchInFilter=true&display.searchEntered=true&settings.collapsePhotoColumn=false&settings.strFilters=CURRENT%2CACTION%2CARCHIVED&settings.strColWidths=240%2C90%2C140%2C215&action=SAVE&isHoldFlag=N&typeToSearch=" . patient.LastName . "&display.searchPattern=" . patient.LastName . "&display.searchTreatmentType=&display.maxPages=1&progressBarBundleURL=https%3A%2F%2Fids-static.invisalign.com%2Fwms-ui%2Flatest%2Finjector.js&show_patient_portrait=true&__checkbox_show_patient_portrait=true&start_date=true&__checkbox_start_date=true&invisalign_option=true&__checkbox_invisalign_option=true&status=true&__checkbox_status=true&notes=true&__checkbox_notes=true&__checkbox_office=true&__checkbox_promised_ship_date=true&__checkbox_clinical_condition=true&__checkbox_days_since_first_clincheck=true&days_since_last_clincheck=true&__checkbox_days_since_last_clincheck=true&__checkbox_urgency=true"""
		Run, chrome.exe %website%
		WaitWin("Patients - Google Chrome",8)
		WinMaximize, Patients - Google Chrome
		Sleep, 1000
		PixelGetColor, color, clinCheckFirstResultPixel.x, clinCheckFirstResultPixel.y, RGB
		if (color = clinCheckFirstResultPixel.color) ;No patients found
			Return()
		SendInput, ^f
		Sleep, 300
		SendInput, % patient.LastName . ", " . patient.FirstNameSimp

		;Finds selected patient
		foundColor := FindColor(clinCheckPatientFindColorPixel.x, clinCheckPatientFindColorPixel.y, "y", 4, 400, clinCheckPatientFindColors[1], clinCheckPatientFindColors[2], 0)
		if (foundColor.color = 1)
			MouseClick,, % foundColor.x, % foundColor.y ;Clicks patient
		else
			Return() ;No patient found
		WaitWin("Patient file - Google Chrome",6)

		;Opens ClinCheck
		SendInput, ^f
		Sleep, 600
		SendInput, Open ClinCheck

		;Finds selected patient
		foundColor2 := FindColor(clinCheckOpenClinCheckFindColorPixel.x, clinCheckOpenClinCheckFindColorPixel.y, "y", 20, 500, clinCheckOpenClinCheckFindColorPixel.color, 0, 0)
		if (foundColor2.color = 1)
			MouseClick,, % foundColor2.x, % foundColor2.y ;Clicks Open Clincheck
		else
			SendInput {Esc} ;No patient found
	}
	else if (database = "xvWeb")
	{
		SetTimer, AutoLoginXVWeb, 250 ;Turns autologin on
		needToSave := false
		nameUpdated := false

		website := """" . xvWebWebsite . "/#query?lastname=" . patient.LastName . "&firstname=" . patient.FirstNameSimp . "*"""
		Run, chrome.exe %website%
		MouseMove, % xvWebViewButton.x , xvWebViewButton.y ;Moves cursor to view button to click
		WaitForPixel(xvWebImagingPatientSearchBlankScreenPixel)
		WaitForPixel(xvWebImagingPatientSearchPixel)
		if (WaitFor2Pixels(xvWebViewButton, xvWebNoResults, 5) = 2) ;waits for pixel on view button or No results text
			Return() ;No results
		Sleep, 200

		;Find how many buttons
		xvWebButtons := CountButtons(xvWebButtonList)
		xvWebButtonStopY := xvWebButtons * xvWebButtonHeight + xvWebButtonStartY

		if (xvWebButtons = 0)
			Return()
		else if (xvWebButtons > 1) ;if more than one patient, prompt for user to select patient
		{
			BlockInputOff()
			WinGetActiveTitle, title

			ToolTip, % "Select " . patient.FirstNameSimp . " " . patient.LastName . " " . patient.ID . " to simply open chart or drag the view button of the chart to be merged into the master chart or press Pause/Break to abort", xvWebTooltip.x, xvWebTooltip.y
			KeyWait, LButton, D ; Wait for the left mouse button to be pressed
			WinGetActiveTitle, title2
			if (title2 != title) ; If window has been changed, abort
				Return()
			MouseGetPos, chart1X, chart1Y ; Record the initial mouse position
			KeyWait, LButton, U ; Wait for the left mouse button to be released
			MouseGetPos, chart2X, chart2Y ; Record the final mouse position
			ToolTip

			;If there are only two buttons and the starting and ending click is on one button, assumes this is the master chart and merge the other into it, unless Ctrl is depressed
			if (!GetKeyState("Ctrl", "P") AND xvWebButtons = 2 AND (chart1X >= xvWebButtonStartX && chart1X <= (xvWebButtonStartX + xvWebButtonWidth) && chart2X >= xvWebButtonStartX && chart2X <= (xvWebButtonStartX + xvWebButtonWidth) && chart1Y >= xvWebButtonStartY && chart1Y <= xvWebButtonStopY && chart2Y >= xvWebButtonStartY && chart2Y <= xvWebButtonStopY && (chart1Y - xvWebButtonStartY) // xvWebButtonHeight = (chart2Y - xvWebButtonStartY) // xvWebButtonHeight))
			{
				;Set chart2Y to the other button
				if ((chart2Y - xvWebButtonStartY) // xvWebButtonHeight = 0)
					chart1Y += xvWebButtonHeight
				else
					chart1Y -= xvWebButtonHeight
			}

			if (chart1X >= xvWebButtonStartX && chart1X <= (xvWebButtonStartX + xvWebButtonWidth) && chart2X >= xvWebButtonStartX && chart2X <= (xvWebButtonStartX + xvWebButtonWidth) && chart1Y >= xvWebButtonStartY && chart1Y <= xvWebButtonStopY && chart2Y >= xvWebButtonStartY && chart2Y <= xvWebButtonStopY && (chart1Y - xvWebButtonStartY) // xvWebButtonHeight != (chart2Y - xvWebButtonStartY) // xvWebButtonHeight) ;There are two charts to merge because first and second click where in the button area, and were not on the same button
			{
				Click ;Clicks View button
				BlockInputOn()
				WaitForPixel(xvWebPatientLinePixel) ;Waits for edit button to appear
				foundColor := FindColor(xvWebEditButtonFindColor[1], xvWebEditButtonFindColor[2], xvWebEditButtonFindColor[3], xvWebEditButtonFindColor[4], xvWebEditButtonFindColor[5], xvWebEditButtonFindColor[6], xvWebEditButtonFindColor[7], xvWebEditButtonFindColor[8]) ;Finds edit button
				if (foundColor.color = 0)
					ErrorMessage("Could not find edit button", 0)
				MouseClick,, % foundColor.x, % foundColor.y ;Clicks Edit button
				WaitForPixel(xvWebConfirmButtonPixel) ;Waits for Confirm button to appear showing Patient Edit loaded
				SendInput {tab}
				xvID := Copy("Pt ID") ;Copies patient's ptID to clipboard
				if (xvID != patient.ID AND (patient.Source = "Open Dental" OR patient.Source = "Open Dental Task") )
				{
					SendInput % patient.ID
					needToSave := true
					xvID := patient.ID ;uses Open Dental ID
				}
				SendInput {tab}
				xvFirstName := Copy("Pt first name") ;Copies patient's first name to clipboard
				if RegExMatch(xvFirstName, ".*\s[A-Za-z]$") ;Detect initials and prompt if they should be removed
				{
					xvFirstName := SubStr(xvFirstName, 1, StrLen(xvFirstName) - 2)
					SendInput %xvFirstName%
					needToSave := true
					nameUpdated := true
				}
				SendInput {tab}
				xvLastName := Copy("Pt last name") ;Copies patient's last name to clipboard
				SendInput {tab 2}
				Sleep, 100
				PixelGetColor, color, xvWebDOBEmpty.x, xvWebDOBEmpty.y, RGB
				if (color = xvWebDOBEmpty.color)
				{
					BlockInputOff()
					MsgBox Date of birth empty. This may not be the master chart. If it is, please manually add birth date and gender to chart, confirm, then run again.
					Return()
				}
				xvMOB := Copy("Pt month of birth") ; Copies patient's month of birth to clipboard
				SendInput {tab}
				xvDOB := Copy("Pt day of birth") ; Copies patient's day of birth to clipboard
				SendInput {tab}
				xvYOB := Copy("Pt year of birth") ; Copies patient's year of birth to clipboard
				genderFoundColor := FindColor(xvWebGender.x, xvWebGender.y, "x", 1, 10, xvWebGender.color,, true, false) ;Finds gender by finding the first pixel to change when iterating left
				if (genderFoundColor.x = 311)
					xvGender = F
				else if (genderFoundColor.x = 316)
					xvGender = M
				else
					xvGender = O
				MouseClick,, % xvWebClickOutsideDatePicker.x, % xvWebClickOutsideDatePicker.y ;Clicks out of DOB picker
				if (needToSave) ;Saves changes
				{
					MouseClick,, % xvWebConfirmButtonPixel.x, % xvWebConfirmButtonPixel.y ;Click Confirm
					WaitForPixel(xvWebFirstRadiographViewBoxPixelLongWait) ;Waits for line of first radiograph to appear
					SetURL(xvWebWebsite . "/#query?firstname=" . patient.FirstNameSimp . "*&lastname=" . patient.LastName) ;Browse to query again
					WaitWin("Imaging Patient Search",6)
					MouseMove, % xvWebViewButton.x , xvWebViewButton.y ;Moves cursor to view button to click
					if (WaitFor2Pixels(xvWebViewButton, xvWebNoResults, 5) = 2) ;waits for result or no results
						Return() ;No results
					Sleep, 200

					;Find how many buttons
					xvWebButtons2 := CountButtons(xvWebButtonList)

					if (xvWebButtons2 = 0)
						ErrorMessage("No results found but expected", 0)
					else if (xvWebButtons2 = 1) ;Only one result now, charts must have merged
					{
						Click ;Opens Chart
						WaitForPixel(xvWebFirstRadiographViewBoxPixel) ;Waits for radiograph viewbox for first radiograph
						MouseClick,, % xvWebFirstRadiographPixel.x, % xvWebFirstRadiographPixel.y ;Clicks most recent radiographs
						MouseMove, % xvWebFinalMousePosition.x, % xvWebFinalMousePosition.y ;Moves to R bitewing
						Return()
					}
					else if (xvWebButtons != xvWebButtons2) ;One less result, but still more than one, charts must have merged, aborting
					{
						BlockInputOff()
						MsgBox, % "Charts appeared to have merged. Please open " . patient.FirstNameSimp . " " . patient.LastName . " " . patient.ID
						Return()
					}
					else if (nameUpdated OR chart1Y > chart2Y) ;if the name was updated, or the chart just edited was a lower result than the chart to be merged into it, the order may have changed
					{
						BlockInputOff()
						WinGetActiveTitle, title

						ToolTip, Click View for the old patient chart to be merged into the master chart or press Pause/Break to abort, xvWebTooltip.x, xvWebTooltip.y
						KeyWait, LButton, D ; Wait for the left mouse button to be pressed
						WinGetActiveTitle, title2
						if (title2 != title) ; If window has been changed, abort
							Return()
						ToolTip
						KeyWait, LButton, U; Wait for the left mouse button to be pressed
						BlockInputOn()
					}
					else
						MouseClick,, % chart1X, % chart1Y ;Opens up chart to merge into the other chart
				}
				else
				{
					SendInput, !{left}{F5} ;Sends back button to chrome and refreshes
					WaitWin("Imaging Patient Search",6)
					MouseMove, % xvWebViewButton.x , xvWebViewButton.y ;Moves cursor to view button to click
					if (WaitFor2Pixels(xvWebViewButton, xvWebNoResults, 5) = 2) ;waits for results or no results
						Return() ;No results
					MouseClick,, % chart1X, % chart1Y ;Opens up chart to merge into the other chart
				}
				WaitWin("Viewing Patient",6)
				WaitForPixel(xvWebPatientLinePixel) ;Waits gray of patient name to appear
				foundColor := FindColor(xvWebEditButtonFindColor[1], xvWebEditButtonFindColor[2], xvWebEditButtonFindColor[3], xvWebEditButtonFindColor[4], xvWebEditButtonFindColor[5], xvWebEditButtonFindColor[6], xvWebEditButtonFindColor[7], xvWebEditButtonFindColor[8]) ;Finds edit button
				if (foundColor.color = 0)
					ErrorMessage("Could not find edit button", 0)
				MouseClick,, % foundColor.x, % foundColor.y ;Clicks Edit button
				WaitForPixel(xvWebConfirmButtonPixel) ;Waits for Confirm button to appear showing Patient Edit loaded
				SendInput {tab}%xvID%{tab}%xvFirstName%{tab}%xvLastName%{tab 2}
				; Check the length of xvMOB and send accordingly
				Sleep, 200
				SendInput %xvMOB%
				if (StrLen(xvMOB) = 1 && xvMOB = "1") ;if one digit and 1 it won't autoadvance
					SendInput {tab}
				Sleep, 200
				SendInput %xvDOB%
				if (StrLen(xvDOB) = 1 && xvDOB >= "1" && xvDOB <= "3") ;if one digit and between 1 and 3 it won't auto advance
					SendInput {tab}
				Sleep, 200
				SendInput %xvYOB%
				Click, 314, 438 ;Click Gender
				Sleep, 200
				if (xvGender = "M")
					ClickButton(xvWebGenderButtons, 1)
				else if (xvGender = "F")
					ClickButton(xvWebGenderButtons, 2)
				else
					ClickButton(xvWebGenderButtons, 3)
				MouseClick,, % xvWebConfirmButtonPixel.x, % xvWebConfirmButtonPixel.y ;Click Confirm
				Return()
			}
			else if (chart2X < xvWebButtonStartX OR chart2X > (xvWebButtonStartX + xvWebButtonWidth) OR chart2Y < xvWebButtonStartY OR chart2Y > xvWebButtonStopY OR chart1X < xvWebButtonStartX OR chart1X > (xvWebButtonStartX + xvWebButtonWidth) OR chart1Y < xvWebButtonStartY OR chart1Y > xvWebButtonStopY) ;Did not land on a button
				Return()
			BlockInputOn()
		}
		else
			Click ;Clicks View
		WaitForPixel(xvWebFirstRadiographViewBoxPixel) ;Waits for radiograph viewbox for first radiograph
		MouseClick,, % xvWebFirstRadiographPixel.x, % xvWebFirstRadiographPixel.y ;Clicks most recent radiographs
		MouseMove, % xvWebFinalMousePosition.x, % xvWebFinalMousePosition.y ;Moves to R bitewing
	}
	Return()
}

Wait2Wins(windowTitle1, windowTitle2, timeoutSeconds, titleMatchMode) ;Waits between two windows, returns which window becomes active
{
    ; Set the title match mode
    SetTitleMatchMode, %titleMatchMode%

    ; Get the start time
    startTime := A_TickCount

    ; Loop until timeout or one of the windows is active
    while (A_TickCount - startTime < timeoutSeconds * 1000)
    {
        IfWinActive, %windowTitle1%
		{
			SetTitleMatchMode, 1
			return 1
		}
        else IfWinActive, %windowTitle2%
		{
			SetTitleMatchMode, 1
			return 2
		}

        ; Sleep for a short duration to avoid high CPU usage
        Sleep, 100
    }
	ErrorMessage("Can't find window " . %windowTitle1% . " or " . %windowTitle2% . "", 1)
	IfWinActive, %windowTitle1%
	{
		SetTitleMatchMode, 1
		return 1
	}
	else IfWinActive, %windowTitle2%
	{
		SetTitleMatchMode, 1
		return 2
	}
	else ErrorMessage("Could not find window", 0)
}

WaitFor2Pixels(testPixel1, testPixel2, timeout, reverse := false) ;Waits for two possible pixels, returns which one, with parameter to reverse logic
{
    ; Get the start time
    startTime := A_TickCount

    ; Loop until timeout or one of the windows is active
    while (A_TickCount - startTime < timeout * 1000)
    {
		PixelGetColor, actualColor1, testPixel1.x, testPixel1.y, RGB
		PixelGetColor, actualColor2, testPixel2.x, testPixel2.y, RGB
        if ((reverse = 0 AND actualColor1 = testPixel1.color) OR (reverse = 1 AND actualColor1 != testPixel1.color))
			return 1
		if ((reverse = 0 AND actualColor2 = testPixel2.color) OR (reverse = 1 AND actualColor1 != testPixel2.color))
			return 2

        ; Sleep for a short duration to avoid high CPU usage
        Sleep, 100
    }
	ErrorMessage("Can't find requested color or color change at either pixel " . actualColor1 . " " . actualColor2, 1)
	PixelGetColor, actualColor1, testPixel1.x, testPixel1.y, RGB
	PixelGetColor, actualColor2, testPixel2.x, testPixel2.y, RGB
	if ((reverse = 0 AND actualColor1 = testPixel1.color) OR (reverse = 1 AND actualColor1 != testPixel1.color))
		return 1
	else if ((reverse = 0 AND actualColor2 = testPixel2.color) OR (reverse = 1 AND actualColor1 != testPixel2.color))
		return 2
	else ErrorMessage("Can't find requested color or color change at either pixel", 0)
}

UnfocusImagingModeFrame() ;Activates Open Dental {... window if frame has focus on imaging mode
{
	CoordMode, Pixel, Screen
	global imagingCheckPixel
	global ODModeCheckColor
	if WinActive("ahk_exe OpenDental.exe")
	{
		PixelGetColor, color, imagingCheckPixel.x, imagingCheckPixel.y, RGB
		if (color = ODModeCheckColor)
			WinActivate, Open Dental {
	}
	CoordMode, Pixel, Client
	return
}

ClickODTopButton(buttonName) ;Clicks buttons on the top row of OD, right below menu
{
    global ODTopButtons

	UnfocusImagingModeFrame()

    if WinActive("Open Dental {")
	{
        MouseClick,, % ODTopButtons[buttonName].x, % ODTopButtons[buttonName].y
        return true
    }
    else
        return false
}

GetODMode() ;Get mode of OD
{
	global ODModeCheckColor
	global ODmodes

	UnfocusImagingModeFrame()
	if WinActive("Open Dental {")
	{
		for mode, coord in ODmodes
		{
			PixelGetColor, color, coord.x, coord.y, RGB
			if (color = ODModeCheckColor)
				return mode
		}
	}
	ErrorMessage("Could not detect mode for GetODMode(), Open Dental may not be active", 0) ;Otherwise throws error
}

ConfirmChartingMode() ;returns whether on Chart
{
	global ODModeCheckColor
	if WinActive("Open Dental {")
	{
		global ODmodes
		PixelGetColor, color, ODmodes["Chart"].x, ODmodes["Chart"].y, RGB
		if (color = ODModeCheckColor) ;if Mode not already selected
			return true
	}
	return false
}

SetODMode(modeToSet) ;Set mode of Open Dental
{
	global ODmodes
	global ODModeCheckColor

	if !WinActive("ahk_exe OpenDental.exe")
		ErrorMessage("SetODMode Failed since Open Dental was not active when called", 0)

	UnfocusImagingModeFrame()

	if WinActive("Open Dental {")
	{
		x := ODmodes[modeToSet].x
		y := ODmodes[modeToSet].y
		PixelGetColor, color, x, y, RGB
		if (color != ODModeCheckColor) ;if Mode not already selected
			MouseClick,, % x, % y ;Clicks proper mode
	}
	if !WinActive("Open Dental {")
		ErrorMessage("SetODMode Failed", 0)
	return
}

GetTxMode() ;Gets mode on charting mode
{
	global txModes
	global radioButtonUnSelectedColor
	SetChartTab("Treatment")
	for mode, coord in txModes
	{
		PixelGetColor, color, coord.x, coord.y, RGB
		if (color != radioButtonUnSelectedColor[1] AND color != radioButtonUnSelectedColor[2])
			return mode
	}
	ErrorMessage("Could not detect mode for GetTxMode, Open Dental may not be active", 0) ;Otherwise throws error
	return
}

SetTxMode(modeToSet) ;Sets tx planning mode (TP, EO, CO)
{
	global txModes
	global radioButtonUnSelectedColor
	SetChartTab("Treatment")
	for mode, coord in txModes
	{
		if (modeToSet = mode)
		{
			PixelGetColor, color, coord.x, coord.y, RGB
			if (color = radioButtonUnSelectedColor[1] OR color = radioButtonUnSelectedColor[2]) ;if not selected, click
				MouseClick,, % coord.x, % coord.y ;Clicks proper mode
			startTime := A_TickCount
			while (color = radioButtonUnSelectedColor[1] OR color = radioButtonUnSelectedColor[2])
			{
				PixelGetColor, color, coord.x, coord.y, RGB
				Sleep, 50
				if (A_TickCount - startTime > 500)
					ErrorMessage("SetTxMode Failed, Mode not changed after .5 seconds", 0)
			}
			return
		}
	}
	ErrorMessage("Improper charting mode index", 0)
	return
}

GetDrawTabMode() ;Gets draw tab mode (Pointer, Move, Pen, etc)
{
	global drawTabModes
	global radioButtonUnSelectedColor
	SetChartTab("Draw")
	for mode, coord in drawTabModes
	{
		PixelGetColor, color, coord.x, coord.y, RGB
		if (color != radioButtonUnSelectedColor[1] AND color != radioButtonUnSelectedColor[2])
			return mode
	}
	ErrorMessage("Could not detect mode for GetDrawTabMode, Open Dental may not be active", 0) ;Otherwise throws error
	return
}

SetDrawTabMode(modeToSet) ;Sets the Draw tab mode
{
	global drawTabModes
	global radioButtonUnSelectedColor
	SetChartTab("Draw")
	
	for mode, coord in drawTabModes
	{
		if (modeToSet = mode)
		{
			PixelGetColor, color, coord.x, coord.y, RGB
			if (color = radioButtonUnSelectedColor[1] OR color = radioButtonUnSelectedColor[2]) ;if not selected, click
				MouseClick,, % coord.x, % coord.y ;Clicks proper mode
			startTime := A_TickCount
			while (color = radioButtonUnSelectedColor[1] OR color = radioButtonUnSelectedColor[2])
			{
				PixelGetColor, color, coord.x, coord.y, RGB
				Sleep, 50
				if (A_TickCount - startTime > 500)
					ErrorMessage("SetDrawTabMode Failed, Mode not changed after .5 seconds", 0)
			}
			return
		}
	}
	ErrorMessage("Improper draw tab mode: " . modeToSet, 0)
	return
}

GetChartTab() ;Gets tab of charting mode (Enter Treatment, Missing/Primary, etc)
{
	global chartTabs
	global chartTabSelectedColor
	if !ConfirmChartingMode()
		ErrorMessage("Not on Charting Mode for GetChartTab()", 0)
	For tab, coord in chartTabs
	{
		PixelGetColor, color, coord.x, coord.y, RGB
		if (color = chartTabSelectedColor)
			return tab
	}
	ErrorMessage("Could not find chart tab, Open Dental may not be active", 0) ;Otherwise throws error
	return
}

ChartingTabExpanded() ;Confirms whether charting tab is expanded
{
	global chartTabExpandedCheckPixel

	PixelGetColor, color, chartTabExpandedCheckPixel.x, chartTabExpandedCheckPixel.y, RGB ;Check to see if chart top tab is expanded
	if (color = chartTabExpandedCheckPixel.color) ;Expanded if the pixel is white
		return true
	else
		return false
}

ConfirmTreatmentTab() ;Confirms on Enter Treatment Tab
{
	global chartTabs
	global chartTabSelectedColor
	if ConfirmChartingMode()
	{
		PixelGetColor, color, chartTabs["Treatment"].x, chartTabs["Treatment"].y, RGB
		if (color = chartTabSelectedColor AND ChartingTabExpanded())
			return true
	}
	return false
}

ConfirmMissingTab() ;Confirms on Missing/Primary Tab
{
	global chartTabs
	global chartTabSelectedColor
	if ConfirmChartingMode()
	{
		PixelGetColor, color, chartTabs["MissingPrimary"].x, chartTabs["MissingPrimary"].y, RGB
		if (color = chartTabSelectedColor AND ChartingTabExpanded())
			return true
	}
	return false
}

SetChartTab(tabToSet) ;Sets tab of charting mode
{
    global chartTabs
    global chartTabSelectedColor

    For tab, coord in chartTabs ;Selects the correct tab, and then expands if needed
    {
        if (tabToSet = tab)
        {
            PixelGetColor, color2, coord.x, coord.y, RGB ;checks to see if tab already selected
            if (color2 != chartTabSelectedColor) ;if tab is not selected, selects
                MouseClick,, % coord.x, % coord.y
            startTime := A_TickCount
            while (color2 != chartTabSelectedColor)
            {
                PixelGetColor, color2, coord.x, coord.y, RGB
                Sleep, 50
                if (A_TickCount - startTime > 500)
                    ErrorMessage("SetChartTab Failed, Tab not changed after .5 seconds", 0)
            }
            if !ChartingTabExpanded() ;if not expanded, clicks
            {
                MouseClick,, % coord.x, % coord.y
                startTime := A_TickCount
                while !ChartingTabExpanded()
                {
                    Sleep, 50
                    if (A_TickCount - startTime > 500)
                        ErrorMessage("SetChartTab Failed, Tab not expanded after .5 seconds", 0)
                }
            }
            return
        }
    }
    ErrorMessage("Improper charting tab index", 0)
    return
}

Tooth(number) ;Returns a tooth object
{
	global teethArray
	global teethArrayPrimary
	global missingToothColor
	global selectedToothColor

	tooth := {}
	tooth.number := StrUpper(number)
	tooth.valid := true

	if RegExMatch(tooth.number, "^[ABCDE]$")
	{
		tooth.permanent := false
		tooth.maxillary := true
		tooth.quadrant := 1
		tooth.index := Asc(tooth.number) - 64 + 3
	}
	else if RegExMatch(tooth.number, "^[FGHIJ]$")
	{
		tooth.permanent := false
		tooth.maxillary := true
		tooth.quadrant := 2
		tooth.index := Asc(tooth.number) - 64 + 3
	}
	else if RegExMatch(tooth.number, "^[PQRST]$")
	{
		tooth.permanent := false
		tooth.maxillary := false
		tooth.quadrant := 4
		tooth.index := Asc(tooth.number) - 64 + 9
	}
	else if RegExMatch(tooth.number, "^[KLMNO]$")
	{
		tooth.permanent := false
		tooth.maxillary := false
		tooth.quadrant := 3
		tooth.index := Asc(tooth.number) - 64 + 9
	}
	else if RegExMatch(tooth.number, "^[1-8]$")
	{
		tooth.permanent := true
		tooth.maxillary := true
		tooth.quadrant := 1
		tooth.index := tooth.number
	}
	else if RegExMatch(tooth.number, "^(9|1[0-6])$")
	{
		tooth.permanent := true
		tooth.maxillary := true
		tooth.quadrant := 2
		tooth.index := tooth.number
	}
	else if RegExMatch(tooth.number, "^(1[6-9]|2[0-4])$")
	{
		tooth.permanent := true
		tooth.maxillary := false
		tooth.quadrant := 3
		tooth.index := tooth.number
	}
	else if RegExMatch(tooth.number, "^(2[4-9]|3[0-2])$")
	{
		tooth.permanent := true
		tooth.maxillary := false
		tooth.quadrant := 4
		tooth.index := tooth.number
	}
	else
	{
		tooth.valid := false
		return tooth
	}
	if RegExMatch(tooth.number, "^([1-5]|1[2-9]|2[0-1]|2[8-9]|3[0-2]|[ABIJKLST])$")
		tooth.posterior := true
	else
		tooth.posterior := false
	if tooth.permanent ;Sets x and y coords of teeth, with a backup primary coord if A, J, K, or T end up being present
	{
		tooth.x := teethArray[tooth.index][2]
		tooth.y := teethArray[tooth.index][3]
		tooth.colorIfPresent := teethArray[tooth.index][4]
		tooth.colorIfSelected := teethArray[tooth.index][5]
		if (tooth.colorIfSelected = "") ;if no altColor, just the normal selected color
			tooth.colorIfSelected := selectedToothColor
		if (tooth.index <= 3 OR (tooth.index >= 14 AND tooth.index <= 19) OR tooth.index >= 30)
		{
			tooth.xPrimary := teethArrayPrimary[tooth.index][2]
			tooth.yPrimary := teethArrayPrimary[tooth.index][3]
			tooth.colorIfPresentPrimary := teethArrayPrimary[tooth.index][4]
			tooth.colorIfSelectedPrimary := teethArrayPrimary[tooth.index][5]
			if (tooth.colorIfSelectedPrimary = "") ;if no altColor, just the normal selected color
				tooth.colorIfSelectedPrimary := selectedToothColor
		}
	}
	else
	{
		tooth.x := teethArrayPrimary[tooth.index][2]
		tooth.y := teethArrayPrimary[tooth.index][3]
		tooth.colorIfPresent := teethArrayPrimary[tooth.index][4]
		tooth.colorIfSelected := teethArrayPrimary[tooth.index][5]
		if (tooth.colorIfSelected = "") ;if no altColor, just the normal selected color
			tooth.colorIfSelected := selectedToothColor
	}
	tooth.colorIfMissing := missingToothColor

	return tooth
}

;Displays a tooth
DisplayTooth(tooth)
{
    ; Create a message string from the tooth object properties
    message := "Tooth Number: " . tooth.number . "`n"
    . "Valid: " . (tooth.valid ? "Yes" : "No") . "`n"
    . "Permanent: " . (tooth.permanent ? "Yes" : "No") . "`n"
    . "Maxillary: " . (tooth.maxillary ? "Yes" : "No") . "`n"
    . "Quadrant: " . tooth.quadrant . "`n"
    . "Index: " . tooth.index . "`n"
    . "X Coord: " . tooth.x . "`n"
    . "Y Coord: " . tooth.y . "`n"
	. "X Coord if primary present: " . tooth.xPrimary . "`n"
    . "Y Coord if primary present: " . tooth.yPrimary . "`n"
    . "Color If Present: " . tooth.colorIfPresent . "`n"
    . "Color If Selected: " . tooth.colorIfSelected . "`n"
    . "Color If Present and primary present: " . tooth.colorIfPresentPrimary . "`n"
    . "Color If Selected and primary present: " . tooth.colorIfSelectedPrimary . "`n"
    . "Color If Missing: " . tooth.colorIfMissing

    ; Display the message in a message box
    MsgBox, % message
}

Resto(number, surfaces := "", type := "resto", material := "", diagnosis := "", existing := false) ;Takes in a tooth number, surfaces, type, material, and diagnosis, as well as if it is existing, returns if it is valid, as well as the CDT code and the surfaces
{
	tooth := Tooth(number)
	surfaces := Alphabetize(StrUpper(surfaces))

	resto := {}
	resto.number := number
    resto.valid := true
    surfaceCount := StrLen(surfaces)
    resto.posterior := tooth.posterior
	resto.permanent := tooth.permanent
	resto.material := material
    resto.surfaces := surfaces
    resto.type := type
	resto.diagnosis := diagnosis

    ;If resto, and surfaces are invalid, tooth is invalid, surfaces contain duplicate, or material is not valid, return invalid
    if (type = "resto")
    {
        if (!tooth.valid 
        || (tooth.posterior && !RegExMatch(surfaces, "^[MODBLV]+$")) 
        || (!tooth.posterior && !RegExMatch(surfaces, "^[MIDFLV]+$")) 
        || RegExMatch(surfaces, "(.)\1") 
        || (material != "c" && material != "a")
        || (!existing AND (surfaces = "LV" OR surfaces = "DM" OR surfaces = "BL" OR surfaces = "FL")))
        {
            resto.valid := false
            return resto
        }

        ; Assign CDT code based on material and surface count
        if (material = "g") ; Gold inlays
        {
            if (surfaceCount = 1)
                inlay.code := "D2510"
            else if (surfaceCount = 2)
                inlay.code := "D2520"
            else
                inlay.code := "D2530"
        }
        else if (material = "c") ; Ceramic inlays
        {
            if (surfaceCount = 1)
                inlay.code := "D2610"
            else if (surfaceCount = 2)
                inlay.code := "D2620"
            else
                inlay.code := "D2630"
        }
        else if (material = "r") ; Resin-based composite inlays
        {
            if (surfaceCount = 1)
                inlay.code := "D2650"
            else if (surfaceCount = 2)
                inlay.code := "D2651"
            else
                inlay.code := "D2652"
        }

        ;If B or F and V, surface count should be decremented
        if (RegExMatch(surfaces, "[BF].*V"))
            surfaceCount -= 1

        ; Chooses appropriate CDT code

        if (material = "a")
        {
            if (surfaceCount = 1)
                resto.code := "D2140"
            else if (surfaceCount = 2)
                resto.code := "D2150"
            else if (surfaceCount = 3)
                resto.code := "D2160"
            else
                resto.code := "D2161"
        }
        else
        {
            if tooth.posterior
            {
                if (surfaceCount = 1)
                    resto.code := "D2391"
                else if (surfaceCount = 2)
                    resto.code := "D2392"
                else if (surfaceCount = 3)
                    resto.code := "D2393"
                else
                    resto.code := "D2394"
            }
            else
            {
                if (surfaceCount = 1)
                    resto.code := "D2330"
                else if (surfaceCount = 2)
                    resto.code := "D2331"
                else if (surfaceCount = 3 AND surfaces != "FIM" AND surfaces != "ILM" AND surfaces != "DFI" AND surfaces != "DIL") ;DIL DFI MIL MFI all would be D2335 as they include the incisive angle
                    resto.code := "D2332"
                else
                    resto.code := "D2335"
            }
        }
    }

    ;If inlay, and surfaces are invalid, tooth is invalid, surfaces contain duplicate, or material is not valid, return invalid
    if (type = "inlay")
    {
        isToothValid := tooth.valid
        isNumberValid := RegExMatch(number, "^(?:[1-5]|1[2-9]|2[0-1]|2[8-9]|3[0-2])$")
        isSurfacesValid := RegExMatch(surfaces, "^[MODBL]+$")
        hasDuplicateSurfaces := RegExMatch(surfaces, "(.)\1")
        isMaterialValid := (material = "g" || material = "c" || material = "r")

        if (!isToothValid || !isNumberValid || !isSurfacesValid || hasDuplicateSurfaces || !isMaterialValid)
        {
            resto.valid := false
            return resto
        }

        ; Assign CDT code based on material and surface count
        if (material = "g") ; Gold inlays
        {
            if (surfaceCount = 1)
                resto.code := "D2510"
            else if (surfaceCount = 2)
                resto.code := "D2520"
            else
                resto.code := "D2530"
        }
        else if (material = "c") ; Ceramic inlays
        {
            if (surfaceCount = 1)
                resto.code := "D2610"
            else if (surfaceCount = 2)
                resto.code := "D2620"
            else
                resto.code := "D2630"
        }
        else if (material = "r") ; Resin-based composite inlays
        {
            if (surfaceCount = 1)
                resto.code := "D2650"
            else if (surfaceCount = 2)
                resto.code := "D2651"
            else
                resto.code := "D2652"
        }
    }

    ;If onlay, and surfaces are invalid, tooth is invalid, surfaces contain duplicate, or material is not valid, or number of surfaces invalid, return invalid
    if (type = "onlay")
    {
        isToothValid := tooth.valid
        isNumberValid := RegExMatch(number, "^(?:[1-5]|1[2-9]|2[0-1]|2[8-9]|3[0-2])$")
        isSurfacesValid := RegExMatch(surfaces, "^[MODBL]+$")
        hasDuplicateSurfaces := RegExMatch(surfaces, "(.)\1")
        isMaterialValid := (material = "g" || material = "c" || material = "r")

        if (!isToothValid || !isNumberValid || !isSurfacesValid || hasDuplicateSurfaces || !isMaterialValid)
        {
            resto.valid := false
            return resto
        }

        ; Assign CDT code based on material and surface count
        if (material = "g") ; Gold onlays
        {
            if (surfaceCount = 2)
                resto.code := "D2542"
            else if (surfaceCount = 3)
                resto.code := "D2543"
            else
                resto.code := "D2544"
        }
        else if (material = "c") ; Ceramic onlays
        {
            if (surfaceCount = 2)
                resto.code := "D2642"
            else if (surfaceCount = 3)
                resto.code := "D2643"
            else
                resto.code := "D2644"
        }
        else if (material = "r") ; Resin-based composite onlays
        {
            if (surfaceCount = 2)
                resto.code := "D2662"
            else if (surfaceCount = 3)
                resto.code := "D2663"
            else
                resto.code := "D2664"
        }
    }

	;Veneers
    if (type = "veneer")
	{
		isToothValid := tooth.valid
		isNumberValid := RegExMatch(number, "^([6-9]|1[0-3]|2[0-9])$")

		if (!isToothValid || !isNumberValid)
		{
			resto.valid := false
			return resto
		}
		resto.code := "D2962"
	}
    return resto
}

ChangeCodeTogglePause() ;Turns changeCodeToggle off for .5 seconds
{
	global changeCodeToggle
	changeCodeToggle := false
	Sleep, 700
	changeCodeToggle := true
}

AddCode(code, patient := "")
{
	global URX
	global ODY
	global chartCodeField
	if (IsObject(patient) && patient.ID != "")  // Updated check
		ConfirmOpenDentalPatientChart(patient)
	else if !ConfirmTreatmentTab()
        ErrorMessage("AddCode called but not on Enter Treatment tab", 1)
	MouseClick,, % chartCodeField.x, % chartCodeField.y, 2 ;Selects code field
	SendInput %code%{Enter}
	if (code = "D2335")
		ChangeCodeTogglePause()
	
	;Wait to return to charting tab
	if (IsObject(patient) && patient.ID != "")
		WaitForOpenDentalPatientChart(patient, 2)
	else
		WaitWin("Open Dental {", 2)
	return
}

UpdateCode(code) ;Updates code on Procedure Info window
{
	global procedureInfoChangeButton
	global procedureCodesFirstCode
	if !WinActive("Procedure Info")
		ErrorMessage("UpdateCode() called but not on Procedure Info window", 1)
	MouseClick,, % procedureInfoChangeButton.x, % procedureInfoChangeButton.y ;Clicks Change
	WaitWin("Procedure Codes", 6)
	SendInput {tab 2}%code% ;types code
	MouseClick,, % procedureCodesFirstCode.x, % procedureCodesFirstCode.y, 2 ;Double clicks top code
	WaitWin("Procedure Info", 6)
	return
}

AddCodeDetailed(code, tooth := "", surfaces := "", diagnosisToSet := "", quad := "", arch := "", note := "", replacementProsthesis := false, dateOfExisting := "", dateEstimated := false, patient := "", teethToSelect := "")
{
    global URX
    global ODY
    global procedureInfoToothField
    global procedureInfoUpperButton
    global procedureInfoLowerButton
    global procedureInfoURButton
    global procedureInfoULButton
    global procedureInfoLRButton
    global procedureInfoLLButton
    global chartCodeField
    global procedureInfoReplacementPixel
    global procedureInfoInitialPixel
    global procedureInfoEstimatedDatePixel

    ; Verify patient if provided
    if (IsObject(patient) && patient.ID != "")
        ConfirmOpenDentalPatientChart(patient)
	else if !ConfirmTreatmentTab()
        ErrorMessage("AddCodeDetailed called but not on Enter Treatment tab", 1)

    MouseClick,, % chartCodeField.x, % chartCodeField.y, 2 ; Selects code field
    SendInput %code%{Enter}

	;Check if code is a prosthesis code
    isProsthesis := false
    if code in D2740,D2750,D2790,D6740,D6750,D6790,D6210,D6240,D6245,D5110,D5120,D5130,D5140,D5211,D5212,D5213,D5214,D5221,D5222,D5223,D5224,D5225,D5226,D5227,D5228,D5282,D5283,D5284,D5286,D5820,D5821,D5863,D5864,D5865,D5866,D6110,D6111,D6112,D6113,D6114,D6115,D6116,D6117,D6210,D6240,D6245,D6740,D6750,D6790
        isProsthesis := true
	
    if (tooth != "" OR surfaces != "" OR arch != "" OR quad != "" OR note != "" OR isProsthesis OR teethToSelect != "")
    {
        Wait2Wins("Procedure Info", "Change Code?", 4, 1) ;Sometimes Change Code? pops up, so we need to dismiss it if so
        if WinActive("Change Code?")
        {
			Send, !n
        	WinWaitActive, Procedure Info,, 4
		}
        if ErrorLevel
            ErrorMessage("Procedure Info never opened but expected", 1)

        ; Enter the note if provided
        if (note != "")
        {
			SendInput ^a%note% ;Selects all and replaces
			Sleep, 50
		}

        if (tooth != "")
        {
            MouseClick,, % procedureInfoToothField.x, % procedureInfoToothField.y ; Clicks Tooth
			StringUpper, tooth, tooth
            SendInput %tooth%
			Sleep, 50
        }

        ; Handle teeth selection if array provided
        if (IsObject(teethToSelect))
        {
 			for index, toothNum in teethToSelect
            {
                if (toothNum >= 1 and toothNum <= 16)
                {
                    Send, {Control down}
					MouseClick,, % 110 + ((toothNum - 1) * 16), 134
                    Send, {Control up}
                }
                else if (toothNum >= 17 and toothNum <= 32)
                {
					Send, {Control down}
					MouseClick,, % 355 - ((toothNum - 17) * 16), 148
					Send, {Control up}
                }
                Sleep, 50
            }
        }

        if (surfaces != "")
            SetSurfaces(surfaces)
        if (arch = "U")
            MouseClick,, % procedureInfoUpperButton.x, % procedureInfoUpperButton.y ; Clicks Upper
        if (arch = "L")
            MouseClick,, % procedureInfoLowerButton.x, % procedureInfoLowerButton.y ; Clicks Lower
        if (quad = "UR")
            MouseClick,, % procedureInfoURButton.x, % procedureInfoURButton.y ; Clicks Upper Right quad
        if (quad = "UL")
            MouseClick,, % procedureInfoULButton.x, procedureInfoULButton.y ; Clicks Upper Left quad
        if (quad = "LR")
            MouseClick,, % procedureInfoLRButton.x, % procedureInfoLRButton.y ; Clicks Lower Right quad
        if (quad = "LL")
            MouseClick,, % procedureInfoLLButton.x, % procedureInfoLLButton.y ; Clicks Lower Left quad
        if (diagnosisToSet != "")
            SetDiagnosis(diagnosisToSet)

        if (isProsthesis)
        {
            if (replacementProsthesis)
            {
				Sleep, 100
                MouseClick,, % procedureInfoReplacementPixel.x, % procedureInfoReplacementPixel.y ; Clicks Replacement
                if (dateOfExisting != "")
                {
                    SendInput {Tab}%dateOfExisting%
					Sleep, 100
                    if dateEstimated
                        MouseClick,, % procedureInfoEstimatedDatePixel.x, % procedureInfoEstimatedDatePixel.y ; Clicks Estimated
                }
                else
                    dismissDateWarning := true
            }
            else
            	MouseClick,, % procedureInfoInitialPixel.x, % procedureInfoInitialPixel.y ; Clicks Initial
        }
    }
	Sleep, 50
    ClickOK()

	
    if (dismissDateWarning)
    {
        WinWaitActive,, Prosthesis date not entered, 2
        if ErrorLevel
            ErrorMessage("Crown date warning box never opened", 0)
        else
            SendInput {Enter} ; Dismiss the warning
    }

    if (code = "D2335")
        ChangeCodeTogglePause()
	
	;Wait to return to charting tab
	if (IsObject(patient) && patient.ID != "")
		WaitForOpenDentalPatientChart(patient, 2)
	else
		WaitWin("Open Dental {", 2)
    return
}


; Adds crown
AddCrown(toothNum, material := "z", core := true, post := true, replacementCrown := false, dateOfExisting := "", crownDiagnosis := "", expandedDiagnosis := "", dateEstimated := false, abutment := false, patient := "")
{
    ; Verify patient if provided
    if (IsObject(patient) && patient.ID != "")
        ConfirmOpenDentalPatientChart(patient)
    else if !ConfirmTreatmentTab()
        ErrorMessage("AddCrown called but not on Enter Treatment tab", 1)

    ; Determine the appropriate crown code based on material and whether it's an abutment
    if (abutment)
    {
        code := (material = "g") ? "D6790"
            : (material = "p") ? "D6750"
            : "D6740"
    }
    else
    {
        code := (material = "g") ? "D2790"
            : (material = "e" or material = "z") ? "D2740"
            : (material = "p") ? "D2750"
            : (material = "i") ? "D6058"
            : (material = "s" AND toothNum ~= "[a-t]") ? "D2930"
            : (material = "s" AND toothNum ~= "^[1-9]|[1-2][0-9]|3[0-2]$") ? "D2931"
            : "ERROR"
    }

    ; Prepare the note
    materialName := (material = "g") ? "Gold"
          : (material = "e") ? "eMax"
          : (material = "z") ? "Zirconia"
          : (material = "p") ? "PFM"
          : (material = "i") ? "Implant supported ceramic crown"
          : (material = "s") ? "SSC"
          : "ERROR"

	if (crownDiagnosis != "" AND expandedDiagnosis != "") ;Only make a note if there is an expanded diagnosis
    {
		note := "Tooth: " . toothNum . "`n"
		note .= "Diagnosis: " . expandedDiagnosis . "`n"
		note .= "Initial or replacement: " . (replacementCrown ? "Replacement of existing placed " : "Initial")
		if (dateOfExisting != "")
		{
			if (dateEstimated)
				note .= "approximately "
			note .= SubStr(dateOfExisting, 1, 2) . "\" . SubStr(dateOfExisting, 3, 2) . "\" . SubStr(dateOfExisting, 5, 4)
		}
		if (post)
			note .= "`nBuild up: Post required for retention`n"
		else if (core)
			note .= "`nBuild up: Required for retention`n"
		else
			note .= "`nBuild up: Not required`n"
		note .= "Material: " . materialName
	}
	else
		note := ""

    ; Add post or core code if necessary
    if (post)
        AddCodeDetailed("D2954", toothNum,, crownDiagnosis,,,,,, patient)
    else if (core)
        AddCodeDetailed("D2950", toothNum,, crownDiagnosis,,,,,, patient)

    ; Call AddCodeDetailed with the updated parameters
    AddCodeDetailed(code, toothNum, "", crownDiagnosis, "", "", note, replacementCrown, dateOfExisting, dateEstimated, patient)

	return
}

; Check if Chrome window exists
ChromeWinExist()
{
	SetTitleMatchMode, RegEx
	result := WinExist(".*Google Chrome$")
	SetTitleMatchMode, 1
	return result
}

; Check if Chrome window is active
ChromeWinActive()
{
	SetTitleMatchMode, RegEx
	result := WinActive(".*Google Chrome$")
	SetTitleMatchMode, 1
	return result
}

; Activate Chrome window if it exists
ChromeWinActivate()
{
	SetTitleMatchMode, RegEx
	if WinExist(".*Google Chrome$")
	{
		WinActivate
		SetTitleMatchMode, 1
		return true
	}
	SetTitleMatchMode, 1
	return false
}

; Wait for Chrome window to become active
ChromeWaitWin(timeoutSeconds := 5)
{
	SetTitleMatchMode, RegEx
	WinWaitActive, .*Google Chrome$,, %timeoutSeconds%
	SetTitleMatchMode, 1
	if !ErrorLevel
		return true
	BlockInput, Off
	BlockInput, MouseMoveOff
	MsgBox, 262148,Error, Can't find Chrome window`nContinue?
	IfMsgBox Yes
	{
		BlockInputRestore()
		return true
	}
	else IfMsgBox No
		Exit
	return false
}

;Focuses address bar in chrome and selects all
FocusAddressBar()
{
	global URLBarSelectedPixel
	global URLBarSelectedColor
	global URLClickPixel
	global tabSearchActiveColor
	global tabSearchActivePixel

	; If URL bar not eady selected
	PixelGetColor, color, URLBarSelectedPixel.x, URLBarSelectedPixel.y, RGB
	if (color != URLBarSelectedPixel.color)
	{
		if WinActive("ClinCheck")
			MouseClick,, % URLClickPixel.x, % URLClickPixel.y ;Clicks on URL bar
		else
			SendInput, ^l
		WaitForPixel(URLBarSelectedPixel)
	}

	;Checks to see if tab search already active, if so gets back to URL, otherwise selects all
	PixelGetColor, color, tabSearchActivePixel.x, tabSearchActivePixel.y, RGB
	if (color = tabSearchActivePixel.color)
		SendInput {Esc}
	else
		SendInput ^a
}

GetURL()
{
	if ChromeWinActive()
    {
		FocusAddressBar()
		URL := Copy("GetURL()") ;Copies and then defocuses URL bar
		SendInput, {Esc}
		return URL
	}
    ErrorMessage("GetURL() but Chrome not active", 0) ; Return an empty string if no URL found or clipboard is empty
}

ScreenColor(xcoord, ycoord) ; Gets pixel on screen coords
{
	CoordMode, Pixel, Screen
	PixelGetColor, color, xcoord, ycoord, RGB ;Checks if page loaded
	CoordMode, Pixel, Client
	return color
}

SetURL(URL)
{
    if ChromeWinActive()
    {
        FocusAddressBar()

		; Replace special characters with their braced counterparts with single quotes
		URL := StrReplace(URL, "^", "{^}")
		URL := StrReplace(URL, "+", "{+}")
		URL := StrReplace(URL, "!", "{!}")
		URL := StrReplace(URL, "#", "{#}")

		;Input new URL
		SendInput %URL%{Enter}
		return
    }
	ErrorMessage("Chrome not active for SetURL()", 0)
}

GetMouse()
{
    global originalMouseX
	global originalMouseY
	CMScreen()
    MouseGetPos, originalMouseX, originalMouseY
	CMClient()
	return
}

PutMouse()
{
	global originalMouseX
	global originalMouseY
	if (originalMouseX != 0 AND originalMouseY != 0)
	{
		CMScreen()
		MouseMove, %originalMouseX%, %originalMouseY%
		originalMouseX = 0
		originalMouseY = 0
		CMClient()
	}
	return
}

ErrorMessage(message, continue := 1)
{
	BlockInput, Off
	BlockInput, MouseMoveOff
	if (continue)
	{
		MsgBox, 262148,Error, %message% `nContinue?
		IfMsgBox Yes
		{
			BlockInputRestore()
			return
		}
		else IfMsgBox No
		{
			if (A_ComputerName != "DOCTOR1-PC")
				SetTimer, ReloadScript, 60000, -1
			Return()
		}
	}
	else
	{
		MsgBox, %message%
		if (A_ComputerName != "DOCTOR1-PC")
				SetTimer, ReloadScript, 60000, -1
		Return()
	}
}

ErrorWaitingFor(page)
{
	BlockInput, Off
	BlockInput, MouseMoveOff
	MsgBox, 262148,Error, Error waiting for: %page% `nContinue?
	IfMsgBox Yes
	{
		BlockInputRestore()
		return
	}
	else IfMsgBox No
	{
		if (A_ComputerName != "DOCTOR1-PC")
			SetTimer, ReloadScript, 60000, -1
		Exit
	}
}

WaitWin(windowTitle, timeoutSeconds, regExMode := false)
{
	if (regExMode)
		SetTitleMatchMode, RegEx
	WinWaitActive, % windowTitle,, % timeoutSeconds
    SetTitleMatchMode, 1
	if !ErrorLevel ;if window pops up return to calling function
		return
	BlockInput, Off
	BlockInput, MouseMoveOff
	MsgBox, 262148,Error, Can't find window: %windowTitle%`nContinue?
	IfMsgBox Yes
	{
		BlockInputRestore()
		return
	}
	else IfMsgBox No
		Exit
}

BlockInputOn()
{
    global treatmentPlanningGuiHidden
    global blockInputToggle
	if WinExist("Treatment Planning") ; Check if the GUI exists
	{
		Gui, TreatmentPlanning:Hide ; Hide the GUI
		treatmentPlanningGuiHidden := true
	}
	blockInputToggle := true
	BlockInput, On
	BlockInput, MouseMove
	return
}

BlockInputOff()
{
    global treatmentPlanningGuiHidden
    global blockInputToggle
	if (treatmentPlanningGuiHidden)
	{ 
		Gui, TreatmentPlanning:Show ; Show the GUI
		treatmentPlanningGuiHidden := false
	}
	blockInputToggle := false
	BlockInput, Off
	BlockInput, MouseMoveOff
	return
}

BlockInputRestore() ;Restores state of blockinput
{
	global blockInputToggle
	if (blockInputToggle)
	{
		BlockInput, On
		BlockInput, MouseMove
	}
	else
	{
		BlockInput, Off
		BlockInput, MouseMoveOff
	}
	return
}

CMClient() ;Sets coordmode to client
{
	CoordMode, Mouse, Client
	CoordMode, Pixel, Client
	return
}

CMScreen()
{
	CoordMode, Mouse, Screen
	CoordMode, Pixel, Screen
	return
}

StrUpper(inputString) ;Capitalizes string
{
    outputString := ""
    loop, parse, inputString
        outputString .= asc(a_loopfield) >= 97 && asc(a_loopfield) <= 122 ? chr(asc(a_loopfield) - 32) : a_loopfield
    return outputString
}

SortArray(arr) ;Sorts an array
{
	new :=	[]
	For each, item in arr
		list .=	item "`n"
	list :=	Trim(list,"`n")
	Sort, list
	Loop, parse, list, `n, `r
		new.Insert(A_LoopField)
	return	new
}

StrJoin(obj,delimiter:="",OmitChars:="") ;Joins an array into a string
{
	string := obj[1]
	Loop % obj.MaxIndex()-1
		string .= delimiter Trim(obj[A_Index+1],OmitChars)
	return string
}

Alphabetize(inputString) ;Alphabetizes a string
{
    ; Convert the string to an array of characters
    charArray := StrSplit(inputString)

    ; Join the sorted array back into a string
    sortedArray := SortArray(charArray)

	joinedArray := StrJoin(sortedArray)

    return joinedArray
}

WaitForPixel(testPixel, reverse := false) ;Waits for a pixel, with logic to reverse
{
    start := A_TickCount
    PixelGetColor, color, testPixel.x, testPixel.y, RGB ; Checks if page loaded

    while ((A_TickCount - start < testPixel.timeout * 1000) AND ((reverse = false AND color != testPixel.color) OR (reverse AND color = testPixel.color)))
	{
        PixelGetColor, color, testPixel.x, testPixel.y, RGB ; Checks if page loaded
        Sleep, 100 ; Add a small delay to avoid excessive loop iterations
    }
    if ((reverse = false AND color != testPixel.color) OR (reverse AND color = testPixel.color))
        ErrorWaitingFor(testPixel.page)
    Sleep, 100
    return
}

GetPatient() ;Gets patient object from iTero, Open Dental, ClinCheck, or DEXIS
{
	global xvWebEditButtonFindColor
	global xvWebCancelButton
	global taskPatientNamePixel

	params := {}
	WinGetActiveTitle, windowTitle

	if (WinActive("Open Dental {") OR WinActive("Task"))
	{
		if WinActive("Task") ;If a task, uses the patient name at the bottom instead
		{
			MouseClick,, % taskPatientNamePixel.x, % taskPatientNamePixel.y ;Clicks in patient Name box
			SendInput, ^a ;selects all
			windowTitle := Copy("Patient Name from Task Window")
			RegExMatch(windowTitle, "(?i)^(?<LastNameSimp>[^\s,-]+)(?<LastNameRest>.*), (?:'(?<PreferredName>.*)' )?(?<FirstNameSimp>[^\s,]+)(?<FirstNameRest>.*) - (?<ID>.*)", Patient)
			params.Source := "Open Dental Task"
		}
		else
		{
			RegExMatch(windowTitle, "(?i)- (?<LastNameSimp>[^\s,-]+)(?<LastNameRest>.*), (?:'(?<PreferredName>.*)' )?(?<FirstNameSimp>[^\s,]+)(?<FirstNameRest>.*) - (?<ID>.*)", Patient)
			params.Source := "Open Dental"
		}

		; Store the extracted values preserving original case
		params.FirstNameSimp := PatientFirstNameSimp
		params.FirstName := PatientFirstNameSimp . PatientFirstNameRest
		params.FirstInitial := SubStr(params.FirstNameSimp, 1, 1)
		params.LastNameSimp := PatientLastNameSimp
		params.LastName := PatientLastNameSimp . PatientLastNameRest
		params.PreferredName := PatientPreferredName
		params.ID := PatientID
	}
	else if WinActive("DEXIS - ")
	{
		RegExMatch(windowTitle, "(?i)- (?<LastNameSimp>[^\s,-]+)(?<LastNameRest>.*), (?<FirstNameSimp>[^\s,]+)(?<FirstNameRest>.*)  (?<DOB>\d{2}/\d{2}/\d{4})  \((?<ID>\d+)\)", Patient)
		params.Source := "DEXIS"

		; Store the extracted values preserving original case
		params.FirstNameSimp := PatientFirstNameSimp
		params.FirstName := PatientFirstNameSimp . PatientFirstNameRest
		params.FirstInitial := SubStr(params.FirstNameSimp, 1, 1)
		params.LastNameSimp := PatientLastNameSimp
		params.LastName := PatientLastNameSimp . PatientLastNameRest
		params.PreferredName := ""
		params.ID := PatientID
	}
	else if WinActive("Viewing Patient")
	{
		windowTitle := GetURL()
		if RegExMatch(windowTitle, "(?i)lastname=(?<Simp>[^+\s&-\*]+)(?<Rest>[^&\s\*]*)", PatientLastName)
		{
			RegExMatch(windowTitle, "(?i)firstname=(?<Simp>[^+\s&-\*]+)(?<Rest>[^&\s\*]*)", PatientFirstName)

			; Store the extracted values
			params.Source := "xvWeb"
			params.FirstNameSimp := PatientFirstNameSimp
			params.FirstName := PatientFirstNameSimp . StrReplace(PatientFirstNameRest, "+", " ")
			params.FirstInitial := SubStr(params.FirstNameSimp, 1, 1)
			params.LastNameSimp := PatientLastNameSimp
			params.LastName := PatientLastNameSimp . StrReplace(PatientLastNameRest, "+", " ")
			params.PreferredName := ""
			params.ID := ""
		}
		else ;Else name isn't in URL
		{
			params.Source := "xvWeb"
			foundColor := FindColor(xvWebEditButtonFindColor[1], xvWebEditButtonFindColor[2], xvWebEditButtonFindColor[3], xvWebEditButtonFindColor[4], xvWebEditButtonFindColor[5], xvWebEditButtonFindColor[6], xvWebEditButtonFindColor[7], xvWebEditButtonFindColor[8]) ;Finds edit button
			if (foundColor.color = 0)
				ErrorMessage("Could not find edit button", 0)
			MouseClick,, % foundColor.x, % foundColor.y ;Clicks Edit button
			WaitForPixel(xvWebCancelButton) ;Waits for Cancel button to appear showing Patient Edit loaded
			SendInput {tab}
			params.ID := Copy("Pt ID") ;Copies patient's ID to clipboard
			SendInput {tab}
			params.FirstName := Copy("Pt first name") ;Copies patient's first name to clipboard
			RegExMatch(params.FirstName, "(^\w+)", match)
			params.FirstNameSimp := match1
			params.FirstInitial := SubStr(params.FirstNameSimp, 1, 1)
			SendInput {tab}
			params.LastName := Copy("Pt last name") ;Copies patient's last name to clipboard
			RegExMatch(params.LastName, "(^\w+)", match)
			params.LastNameSimp := match1
			MouseClick,, % xvWebCancelButton.x, % xvWebCancelButton.y ;Clicks Cancel
		}
	}
	else if WinActiveRegex("Viewer.*My iTero \- Google Chrome")
	{
		windowTitle := GetURL()
		RegExMatch(windowTitle, "(?i)patientname=(?<LastNameSimp>[^,%-]+)(?<LastNameRest>[^,]*),%20(?<FirstNameSimp>[^%-]+)(?<FirstNameRest>.*)%20&", Patient)

		; Store the extracted values
		params.Source := "iTero"
		params.FirstNameSimp := PatientFirstNameSimp
		params.FirstName := PatientFirstNameSimp . StrReplace(PatientFirstNameRest, "%20", " ")
		params.FirstInitial := SubStr(params.FirstNameSimp, 1, 1)
		params.LastNameSimp := PatientLastNameSimp
		params.LastName := PatientLastNameSimp . StrReplace(PatientLastNameRest, "%20", " ")
		params.PreferredName := ""
		params.ID := ""
	}
	else if WinActive("ClinCheck | ")
	{
		RegExMatch(windowTitle, " \| (?<FirstNameSimp>[^\s]+) (?<LastNameSimp>[^\s]*) - Google Chrome", Patient)

		; Store the extracted values
		params.Source := "ClinCheck"
		params.FirstNameSimp := PatientFirstNameSimp
		params.FirstName := params.FirstNameSimp
		params.FirstInitial := SubStr(params.FirstNameSimp, 1, 1)
		params.LastNameSimp := PatientLastNameSimp
		params.LastName := params.LastNameSimp
		params.PreferredName := ""
		params.ID := ""
	}
	else
		params.Source := "NA"

	if(params.FirstNameSimp = "" AND params.Source != "NA")
		MsgBox, % "Could not find patient with this window title: " . windowTitle
	
    return new PatientObj(params)
}

Return() ;Returns from thread, Puts Mouse back, turns off BlockInput
{
	RestoreState()
	PutMouse()
	BlockInputOff()
	SetTimer, AutoLoginInvisalign, Off ;Turns auto login off
	SetTimer, AutoLoginItero, Off ;Turns auto login off
	SetTimer, AutoLoginXVWeb, Off ;Turns auto login off
	Exit
}

MouseMove(pixelObj, pauseSeconds := 5)
{
    if (IsObject(pixelObj) && pixelObj.HasKey("x") && pixelObj.HasKey("y"))
    {
        MouseMove, % pixelObj.x, % pixelObj.y

        ; Get the color at the pixel location
        PixelGetColor, pixelColor, % pixelObj.x, % pixelObj.y, RGB

        ; Display tooltip with coordinates and color
        ToolTip, % "X: " . pixelObj.x . ", Y: " . pixelObj.y . "`nColor: " . pixelColor

        ; Pause for the specified number of seconds
        Sleep, % pauseSeconds * 1000

        ; Remove the tooltip
        ToolTip

        return true
    }
    else
    {
        MsgBox, Invalid pixel object passed to MouseMove function.
        return false
    }
}

RemoveToolTip()
{
    ToolTip
}

AddCodeToTeeth(teeth, code, patient := "") {
    ; If no teeth, return
    if (!IsObject(teeth) || teeth.Length() = 0)
        return
        
    ; Iterate through array of teeth
    for index, toothNumber in teeth
        AddCodeDetailed(code, toothNumber,,,,,,,,,patient)
    
	return
}

; Add this new function after the AddCodeDetailed function
AddRestosArray(restoArray, patient := "") {
	;If array is empty, return
	if (!IsObject(restoArray) || restoArray.Length() = 0)
        return
        
    for index, resto in restoArray
        AddCodeDetailed(resto.code, resto.number, resto.surfaces, resto.diagnosis,,,,,,, patient)
    
	return
}

; Displays an error message and exits the thread if there are any errors
ifErrorsDisplayAndAbort()
{
    global ErrorMsg
    
    if (ErrorMsg != "")
    {
        BlockInputOff()
        MsgBox, 262144, Error, %ErrorMsg%
        ErrorMsg := ""
        Exit
    }
    return
}

; Initialize all teeth status arrays with false values
InitializeTeethStatusArrays()
{
    ; Initialize permanent teeth arrays (1-32)
    Loop, 32
    {
        PermanentTeethMissing[A_Index] := false
        PermanentTeethUnerupted[A_Index] := false
        PermanentTeethSimpleExt[A_Index] := false
        PermanentTeethSurgicalExt[A_Index] := false
        PermanentTeethReferredExt[A_Index] := false
    }
    
    ; Initialize primary teeth arrays (A-T, maps to indices 1-20)
    Loop, 20
    {
        PrimaryTeethMissing[A_Index] := false
        PrimaryTeethUnerupted[A_Index] := false
        PrimaryTeethSimpleExt[A_Index] := false
        PrimaryTeethSurgicalExt[A_Index] := false
        PrimaryTeethReferredExt[A_Index] := false
    }
    return
}

; Convert tooth letter (A-T) to array index (1-20)
ToothLetterToIndex(toothLetter)
{
    ; Convert to uppercase
    toothLetter := Format("{:U}", toothLetter)
    
    ; A=1, B=2, etc.
    return Asc(toothLetter) - 64
}

; Flag tooth as missing
flagMissing(tooth)
{
    if isPrimary(tooth)
        PrimaryTeethMissing[ToothLetterToIndex(tooth)] := true
    else
        PermanentTeethMissing[tooth] := true
    return
}

; Flag tooth as unerupted
flagUnerupted(tooth)
{
    if isPrimary(tooth)
        PrimaryTeethUnerupted[ToothLetterToIndex(tooth)] := true
    else
        PermanentTeethUnerupted[tooth] := true
    return
}

; Flag tooth as TP Simple Extraction
flagSimpleExt(tooth)
{
    if isPrimary(tooth)
        PrimaryTeethSimpleExt[ToothLetterToIndex(tooth)] := true
    else
        PermanentTeethSimpleExt[tooth] := true
    return
}

; Flag tooth as TP Surgical Extraction
flagSurgicalExt(tooth)
{
    if isPrimary(tooth)
        PrimaryTeethSurgicalExt[ToothLetterToIndex(tooth)] := true
    else
        PermanentTeethSurgicalExt[tooth] := true
    return
}

; Flag tooth as TP Referred Extraction
flagReferredExt(tooth)
{
    if isPrimary(tooth)
        PrimaryTeethReferredExt[ToothLetterToIndex(tooth)] := true
    else
        PermanentTeethReferredExt[tooth] := true
    return
}

; Check if tooth is flagged as missing
isFlaggedMissing(tooth)
{
    if isPrimary(tooth)
        return PrimaryTeethMissing[ToothLetterToIndex(tooth)]
    else
        return PermanentTeethMissing[tooth]
}

; Check if tooth is flagged as unerupted
isFlaggedUnerupted(tooth)
{
    if isPrimary(tooth)
        return PrimaryTeethUnerupted[ToothLetterToIndex(tooth)]
    else
        return PermanentTeethUnerupted[tooth]
}

; Check if tooth is flagged for TP Simple Extraction
isFlaggedSimpleExt(tooth)
{
    if isPrimary(tooth)
        return PrimaryTeethSimpleExt[ToothLetterToIndex(tooth)]
    else
        return PermanentTeethSimpleExt[tooth]
}

; Check if tooth is flagged for TP Surgical Extraction
isFlaggedSurgicalExt(tooth)
{
    if isPrimary(tooth)
        return PrimaryTeethSurgicalExt[ToothLetterToIndex(tooth)]
    else
        return PermanentTeethSurgicalExt[tooth]
}

; Check if tooth is flagged for TP Referred Extraction
isFlaggedReferredExt(tooth)
{
    if isPrimary(tooth)
        return PrimaryTeethReferredExt[ToothLetterToIndex(tooth)]
    else
        return PermanentTeethReferredExt[tooth]
}

; Get array of all teeth flagged as missing
getFlaggedMissing()
{
    result := []
    
    ; Check permanent teeth (1-32)
    Loop, 32
    {
        if (PermanentTeethMissing[A_Index])
            result.Push(A_Index)
    }
    
    ; Check primary teeth (A-T)
    Loop, 20
    {
        if (PrimaryTeethMissing[A_Index])
            result.Push(Chr(64 + A_Index)) ; Convert index back to letter (A-T)
    }
    
    return result
}

; Get array of all teeth flagged as unerupted
getFlaggedUnerupted()
{
    result := []
    
    ; Check permanent teeth (1-32)
    Loop, 32
    {
        if (PermanentTeethUnerupted[A_Index])
            result.Push(A_Index)
    }
    
    ; Check primary teeth (A-T)
    Loop, 20
    {
        if (PrimaryTeethUnerupted[A_Index])
            result.Push(Chr(64 + A_Index)) ; Convert index back to letter (A-T)
    }
    
    return result
}

; Get array of all teeth flagged for TP Simple Extraction
getFlaggedSimpleExt()
{
    result := []
    
    ; Check permanent teeth (1-32)
    Loop, 32
    {
        if (PermanentTeethSimpleExt[A_Index])
            result.Push(A_Index)
    }
    
    ; Check primary teeth (A-T)
    Loop, 20
    {
        if (PrimaryTeethSimpleExt[A_Index])
            result.Push(Chr(64 + A_Index)) ; Convert index back to letter (A-T)
    }
    
    return result
}

; Get array of all teeth flagged for TP Surgical Extraction
getFlaggedSurgicalExt()
{
    result := []
    
    ; Check permanent teeth (1-32)
    Loop, 32
    {
        if (PermanentTeethSurgicalExt[A_Index])
            result.Push(A_Index)
    }
    
    ; Check primary teeth (A-T)
    Loop, 20
    {
        if (PrimaryTeethSurgicalExt[A_Index])
            result.Push(Chr(64 + A_Index)) ; Convert index back to letter (A-T)
    }
    
    return result
}

; Get array of all teeth flagged for TP Referred Extraction
getFlaggedReferredExt()
{
    result := []
    
    ; Check permanent teeth (1-32)
    Loop, 32
    {
        if (PermanentTeethReferredExt[A_Index])
            result.Push(A_Index)
    }
    
    ; Check primary teeth (A-T)
    Loop, 20
    {
        if (PrimaryTeethReferredExt[A_Index])
            result.Push(Chr(64 + A_Index)) ; Convert index back to letter (A-T)
    }
    
    return result
}

; Check for warnings by comparing array items against flagged teeth
CheckForWarnings(itemsArray, description, conditions)
{
    global WarningMsg
    
    ; If array is empty, return
    if (!IsObject(itemsArray) || itemsArray.Length() = 0)
        return
    
    ; Iterate through each item in the array
    for index, item in itemsArray
    {
        ; Determine tooth number (from direct number or restoration object)
        toothNum := ""
        if (IsObject(item) && item.HasKey("number"))
            toothNum := item.number  ; Item is a restoration object
        else
            toothNum := item  ; Item is a direct tooth number
        
        ; Skip if not a valid tooth number
        if (!isTooth(toothNum))
            continue
            
        ; Check for Missing flag (if "M" is in conditions)
        if (InStr(conditions, "M") && isFlaggedMissing(toothNum))
            LogWarning(WarningMsg, "Tooth " . toothNum . " has a " . description . " but is also marked missing")
        
        ; Check for Unerupted flag (if "U" is in conditions)
        if (InStr(conditions, "U") && isFlaggedUnerupted(toothNum))
            LogWarning(WarningMsg, "Tooth " . toothNum . " has a " . description . " but is also marked unerupted")
        
        ; Check for Simple Extraction flag (if "S" is in conditions)
        if (InStr(conditions, "S") && isFlaggedSimpleExt(toothNum))
            LogWarning(WarningMsg, "Tooth " . toothNum . " has a " . description . " but is also marked for simple extraction")
        
        ; Check for Surgical Extraction flag (if "E" is in conditions)
        if (InStr(conditions, "E") && isFlaggedSurgicalExt(toothNum))
            LogWarning(WarningMsg, "Tooth " . toothNum . " has a " . description . " but is also marked for surgical extraction")
        
        ; Check for Referred Extraction flag (if "R" is in conditions)
        if (InStr(conditions, "R") && isFlaggedReferredExt(toothNum))
            LogWarning(WarningMsg, "Tooth " . toothNum . " has a " . description . " but is also marked for referred extraction")
    }
    
    return
}

; Logs a warning message
LogWarning(ByRef warningMessage, message, delimiter := "`n")
{
    if (warningMessage = "")
        warningMessage := message
    else
        warningMessage .= delimiter . message
}

; Helper function to tidy text and focus control by ClassNN
TidyAndFocus(controlNN)
{
    guiTitle := "Treatment Planning"

    ; 1. Get current text
    ControlGetText, txt, %controlNN%, %guiTitle%

    ; 2. Trim trailing whitespace and add exactly one space if nonempty
    txt := RegExReplace(txt, "\s+$")
    if (txt != "")
        txt .= " "

    ; 3. Write back into the control
    ControlSetText, %controlNN%, %txt%, %guiTitle%

    ; 4. Focus it and move caret to end
    ControlFocus, %controlNN%, %guiTitle%
    Send {End}
}

MoveCaret:
IfWinNotActive, New Hotstring
    return
; Otherwise, move the InputBox's insertion point to where the user will type the abbreviation.
Send {Home}{Right 2}
SetTimer, MoveCaret, Off
return

!!DummyHotkeys:
return

!F3::
BlockInputOn()
MsgBox, Hello
sleep, 5000
Return()

!F6::
Return()

!!ScriptFunctions:
return

^d:: ;Selects word that I am hovered over, and creates command to display that in a msgbox
{
    ; Save the current clipboard content
    OldClipboard := ClipboardAll

    ; Clear the clipboard
    Clipboard := ""

    ; Double-click to select the word under the cursor
    Click, 2

    ; Copy the selected text
    Send, ^c

    ; Wait for the clipboard to contain text
    ClipWait, 2
    if ErrorLevel
    {
        MsgBox, Failed to copy text to clipboard
        return
    }

    ; Get the selected variable name
    variableName := Clipboard

    ; Create the MsgBox command string
    msgBoxCommand := "MsgBox, % """ . variableName . ": "" . " . variableName

    ; Copy the MsgBox command to the clipboard
    Clipboard := msgBoxCommand
    Return()
}

!F2::
FileGetTime, NetworkVersion, O:\Script\Combo.exe, M
if (NetworkVersion > Version)
	Reload = Yes
else
	Reload = No
MsgBox %NetworkVersion% %Version% %Reload%
return

ReloadScript: ;Reloads script from K drive if no thread running
FileGetTime, NetworkVersion, O:\Script\Combo.exe, M
if (NetworkVersion > Version AND A_ComputerName != "DOCTOR1-PC") ;if not on back computer reload version if current version is older than network version
{
	FileMove, Combo.exe, Combo1.exe
	FileCopy, O:\Script\Combo.exe, Combo.exe
	Sleep, 2000
	Run, Combo.exe
	Sleep, 2000
	ExitApp
}
return

^1::
CoordinatesMode = 1
return

^3::
SetDrawTabMode("Pen")
	MouseClickDrag, left, % ULX+191, % ODY+98, % ULX+218, % ODY+98
	MouseClickDrag, left, % ULX+167, % ODY+98, % ULX+241, % ODY+98
	MouseClickDrag, left, % ULX+161, % ODY+194, % ULX+247, % ODY+194
SetDrawTabMode("Pointer")
Return()



^`::
$Pause:: ;Stops script and reloads
FormatTime, CurrentDateTime,, MM/dd/yy HH:mm:ss ;DEBUG
;WinGetTitle, title1, eClinicalWorks ;DEBUG
;WinGetTitle, title2, ahk_exe eclinicalworks.exe ;DEBUG
;RegExMatch(title1, "\((.*)\)", user) ;DEBUG
;RegExMatch(title2, "(.*)\(.*\)", window) ;DEBUG
;FileAppend, `n%CurrentDateTime% - BREAK ;- User: %user1%- Window:%window1%, %A_MyDocuments%\logfile.txt ;DEBUG
Reload
Return()


$^CtrlBreak::ExitApp

$^PrintScreen::
if A_IconHidden
	Menu, Tray, Icon
else
	Menu, Tray, NoIcon
return

!!CodeHelpers:
return

F8::
xCoord := ""
yCoord := ""
if (WinActive("Open Dental {") AND GetODMode() = "Chart")
{
	if MouseWithin(ULULPixel, ULLRPixel)
	{
		xOffset := ULX
		yOffset := ODY
		xCoord := "ULX"
		yCoord := "ODY"
	}
	else if MouseWithin(URULPixel, URLRPixel)
	{
		xOffset := URX
		yOffset := ODY
		xCoord := "URX"
		yCoord := "ODY"
	}
}
else if WinActive("Viewing Patient - Google Chrome")
{
	if MouseWithin(radiographsULPixel,radiographsLRPixel)
	{
		xOffset := radiographsULPixel.x
		yOffset := yPosBrowserFrame
		xCoord := "radiographsULPixel.x"
		yCoord := "yPosBrowserFrame"
	}
}
else if ChromeWinActive()
{
	yOffset := yPosBrowserFrame
	yCoord := "yPosBrowserFrame"
}
Tooltip, Select an option`n1: Wait for pixel`n2: Check pixel for color`n3: Click on pixel`n4: FindPixel - Gets start location`, Shift to get color`, and Shift again to set maximum pixel`n5: Find unique pixel for prompt window`n6: Wait until current window is active`n7: Wait until current window closes, 550, 5
Input, UserChoice, L1
Tooltip ; Remove the tooltip after input

if (UserChoice = "1") ;Wait for pixel
{
	; Gets coords of mouse
	MouseGetPos, MouseX, MouseY
	; Moves mouse to top left
	MouseMove, 0, 0
	; Pause for 1 second
	Sleep, 1000
	; Gets color of those coords
	PixelGetColor, color, MouseX, MouseY, RGB
	; Gets the active window title
	WinGetActiveTitle, winTitle
	; Prompt for variable name
	InputBox, variableName, Enter Variable Name + "Pixel",, , 250, 120
	variableName := variableName . "Pixel"
	; Format information for clipboard
	if (xCoord != "")
	{
		Difference := MouseX - xOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseXExp := xCoord . Operator . Abs(Difference)
	}
	else
		MouseXExp := MouseX
	if (yCoord != "")
	{
		Difference := MouseY - yOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseYExp := yCoord . Operator . Abs(Difference)
	}
	else
		MouseYExp := MouseY
	Clipboard := variableName . " := new Pixel(" . MouseXExp . ", " . MouseYExp . ", " . color . ", 10, """ . winTitle . """) `;`rglobal " . variableName . "`rWaitForPixel(" . variableName . ") `; Waits for"
	; Display the formatted information (assuming Banner is a custom function to display the clipboard content, replaced with MsgBox for demonstration)
}
else if (UserChoice = "2") ;Check Pixel
{
	 ; Writes code that has an if statement to check if pixels are the color of the mouse coords
	MouseGetPos, MouseX, MouseY
	MouseMove, 0, 0
	Sleep, 1000  ; Pause for 1 second
	PixelGetColor, color, MouseX, MouseY, RGB
	InputBox, variableName, Enter Variable Name + "Pixel",, , 250, 120
	variableName := variableName . "Pixel"
	; Format information for clipboard
	if (xCoord != "")
	{
		Difference := MouseX - xOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseXExp := xCoord . Operator . Abs(Difference)
	}
	else
		MouseXExp := MouseX
	if (yCoord != "")
	{
		Difference := MouseY - yOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseYExp := yCoord . Operator . Abs(Difference)
	}
	else
		MouseYExp := MouseY
	Clipboard := variableName . " := new Pixel(" . MouseXExp . ", " . MouseYExp . ", " . color . ") `;`rglobal " . variableName . "`rPixelGetColor, color, % " . variableName . ".x, % " . variableName . ".y, RGB`rif (color = " . variableName . ".color)`r"
	; Display the formatted information
}
else if (UserChoice = "3") ;Click Pixel
{
	; Writes code that creates a global variable for a pixel, and then codes for a mouseclick of that variable
	MouseGetPos, MouseX, MouseY
	MouseMove, 0, 0
	Sleep, 1000  ; Pause for 1 second
	PixelGetColor, color, MouseX, MouseY, RGB
	InputBox, variableName, Enter Variable Name + "Pixel",, , 250, 120
	variableName := variableName . "Pixel"
	; Format information for clipboard
	if (xCoord != "")
	{
		Difference := MouseX - xOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseXExp := xCoord . Operator . Abs(Difference)
	}
	else
		MouseXExp := MouseX
	if (yCoord != "")
	{
		Difference := MouseY - yOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseYExp := yCoord . Operator . Abs(Difference)
	}
	else
		MouseYExp := MouseY
	Clipboard := variableName . " := new Pixel(" . MouseXExp . ", " . MouseYExp . ", " . color . ") `;`rglobal " . variableName . "`rMouseClick,, % " . variableName . ".x, % " . variableName . ".y `;Clicks "
	; Display the formatted information
}
else if (UserChoice = "4") ;Find Pixel
{
	; Writes code to use FindPixel
	MouseGetPos, MouseX1, MouseY1

	Keywait, Shift, D
	Keywait, Shift, U
	MouseGetPos, MouseX2, MouseY2
	PixelGetColor, colorToFind, MouseX2, MouseY2, RGB

	Keywait, Shift, D
	Keywait, Shift, U
	MouseGetPos, MouseX3, MouseY3

	InputBox, variableName, Enter Variable Name + "FindColor",, , 250, 120
	variableName := variableName . "FindColor"

	if (Abs(MouseX3 - MouseX1) > Abs(MouseY3 - MouseY1))
	{
		xORy = "x"
		maxPixelsToCheck := Abs(MouseX3 - MouseX1)
	}
	else
	{
		xORy = "y"
		maxPixelsToCheck := Abs(MouseY3 - MouseY1)
	}

	; Format information for clipboard
	if (xCoord != "")
	{
		Difference := MouseX1 - xOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseX1Exp := xCoord . Operator . Abs(Difference)
	}
	else
		MouseX1Exp := MouseX1
	if (yCoord != "")
	{
		Difference := MouseY1 - yOffset
		Operator := (Difference > 0) ? "+" : "-"
		MouseY1Exp := yCoord . Operator . Abs(Difference)
	}
	else
		MouseY1Exp := MouseY1
	ClipboardData := variableName . " := [" . MouseX1Exp . "," . MouseY1Exp . "," . xORy . ",1," . maxPixelsToCheck . "," . colorToFind . ","""",false] `;(xStart, yStart, xORy, increment, maxPixelsToCheck, colorToFind, altColorToFind, reverse)`rglobal " . variableName . "`rFindColor(" . variableName . "[1]," . variableName . "[2]," . variableName . "[3]," . variableName . "[4]," . variableName . "[5]," . variableName . "[6]," . variableName . "[7]," . variableName . "[8]) `;Finds "
	; Copy information to clipboard
	Clipboard := ClipboardData
	; Display the formatted information
}
else if (UserChoice = "5") ;Find unique pixel for prompt window
{
    PixelX := 220
    PixelY := 60
    MaxY := 71

    Loop
	{
        PixelGetColor, color, %PixelX%, %PixelY%, RGB
        if (color = "0x000000")
		{
            break
        }
        PixelY++
        if (PixelY > MaxY)
		{
            PixelY := 60
            PixelX--
            if (PixelX < 0)
			{
                break
            }
        }
    }

    if (color = "0x000000")
	{
        InputBox, Name, Enter Name, Please enter a name for the coordinates., , 300, 130
        if (ErrorLevel = 0)
            Clipboard := "[""" . Name . """,new Pixel(" . PixelX . "," . PixelY . ")]"
    }
    else {
        MsgBox, 48, Not Found, No black pixel found in the specified range.
    }
}
else if (UserChoice = "6") ;Wait until current window active
{
	WinGetActiveTitle, winTitle
    Clipboard := "WaitWin(""" . wintitle . """, 6) `;Waits until "
}
else if (UserChoice = "7") ;Wait until current window closes
{
	WinGetActiveTitle, winTitle
    Clipboard := "WinWaitNotActive, " . wintitle . ",, 3 `;Waits until "
}


Return()

!!TextExpansion:
return

::;otc::Recommended 400mg ibuprofen and 500mg acetaminophen every 4-6 hours.
::;ibu::Recommended 400mg ibuprofen every 4-6 hours.
::;apap::Recommended 500mg acetaminophen every 4-6 hours.
::;temp::Advised OTC temporary filling material can be used.
::;emer::Advised pt to contact us if symptoms not resolving or worsening, seeking emergency care if needed.
::;bon::BlockInputOn()
::;bof::BlockInputOff()
::;wfp::WaitForPixel("COLOR", XCOORD, YCOORD, 10, "WAITINGFORPAGE")
::;ww::WaitWin("windowTitle", 10)
::;gm::GetMouse()
::;in::GetMouse()`rBlockInputOn()
::;out::PutMouse()`rBlockInputOff()
::;msg::MsgBox, Here

F10:: ;Double clicks, copies number selected by double clicking, converts that number to an expression using ReplacementVariableNumber and adding or subtracting the appropriate amount to that number to equal the original number, then sending input of that replacement expression to replace the selected number. So, if ReplacementVariableNumber = 121 and I hovered the mouse over the number 61, the 61 would be replaced with "ReplacementVariableNumber-60" except ReplacementVariable would be the string stored in ReplacementVariable variable. I will define ReplacementVariableNumber and ReplacementVariable.
MouseClick, left, , , 2
Clipboard := ""
Send, ^c
ClipWait
if (Clipboard ~= "^\d+(\.\d+)?$")
{
	ReplacementVariableNumber := 1280
	ReplacementVariable := "xPosMidpoint"
	Difference := ReplacementVariableNumber - Clipboard
	Operator := (Difference > 0) ? "-" : "+"
	ReplacementExpression := ReplacementVariable . Operator . Abs(Difference)
	SendRaw, %ReplacementExpression%
}
else
	Send, ^v
return

F11:: ;Double clicks, copies number selected by double clicking, converts that number to an expression using ReplacementVariableNumber and adding or subtracting the appropriate amount to that number to equal the original number, then sending input of that replacement expression to replace the selected number. So, if ReplacementVariableNumber = 121 and I hovered the mouse over the number 61, the 61 would be replaced with "ReplacementVariableNumber-60" except ReplacementVariable would be the string stored in ReplacementVariable variable. I will define ReplacementVariableNumber and ReplacementVariable.
MouseClick, left, , , 2
Clipboard := ""
Send, ^c
ClipWait
if (Clipboard ~= "^\d+(\.\d+)?$")
{
	ReplacementVariableNumber := 46
	ReplacementVariable := "ChromeURLPixel.y"
	Difference := ReplacementVariableNumber - Clipboard
	Operator := (Difference > 0) ? "-" : "+"
	ReplacementExpression := ReplacementVariable . Operator . Abs(Difference)
	SendRaw, %ReplacementExpression%
}
else
	Send, ^v
return

!F12:: ;Sets up settings for hotkeys
KeyWait Alt
Keywait F12
BlockInputOn()
WinActivate, eClinicalWorks
WinWaitActive, eClinicalWorks,, 6
if ErrorLevel
	Return()
SendInput !fsm
WinWaitActive, Settings, 4
if ErrorLevel
	Return()
Click 75, 17 ;Click Defaults 2
Sleep, 200
Click 398, 449 ;Change to classic view for send screen
Sleep, 200
SendInput !o{Enter}
SendInput {LWin}
Sleep, 500
SendInput control
Sleep, 500
SendInput {Enter}
WinWaitActive, All Control,, 8
if ErrorLevel
	Return()
SendInput p{Enter}
WinWaitActive, Performance,, 6
if ErrorLevel
	Return()
Sleep, 500
Click 72, 93 ;Clicks Adjust Visual Effects
WinWaitActive, Performance Options,, 6
if ErrorLevel
	Return()
SendInput {Tab}{Down}{Space}{Enter}
WinClose, Performance Information
Return()


$F6:: ;Copies new file from network location
if (A_ComputerName = "DOCTOR1-PC")
{
	IfWinActive, Combo.ahk * SciTE4AutoHotkey
	{
		SendInput ^s ;Save
		;Sleep, 500
	}
	FileMove, Combo.exe, Combo1.exe
	FileCopy, Combo.ahk, C:\Program Files\AutoHotkey\Compiler\Combo.ahk
	;Sleep, 500
	Run, C:\Program Files\AutoHotkey\Compiler\ahk2exe /in Combo.ahk
	Sleep, 500
	FileCopy, Combo.exe, O:\Script\Combo.exe, 1
	FileDelete, C:\Program Files\AutoHotkey\Compiler\Combo.ahk
	Run, Combo.exe
	ExitApp
}
else
{
	FileMove, Combo.exe, Combo1.exe
	FileCopy, O:\Script\Combo.exe, Combo.exe
	Sleep, 2000
	Run, Combo.exe
	Sleep, 2000
	ExitApp
}
return

; Shift+LeftClick handler for Treatment Planning GUI
~^LButton::
Sleep, 20
if WinActive("Treatment Planning")
{
    ; Get the ClassNN of the control under mouse
    MouseGetPos,,,, controlNN
    if controlNN
        TidyAndFocus(controlNN)
}
return

MButton::
RCtrl:: ;Switches to OD, toggles between schedule and chart
if !WinExist("Open Dental") ;does nothing if Open Dental does not exist
	Return()
BlockInputOn()
GetMouse()
if WinActive("ahk_exe OpenDental.exe") ;Goes to Appts if not on appts, but goes to chart if on Appts
{
	mode := GetODMode()
	if (mode = "NA")
		Return()
	else if (mode != "Appts")
		SetODMode("Appts")
	else
		SetODMode("Chart")
}
else
	WinActivate, Open Dental {
Return()

!!iTero:
return

#If WinActive("Viewing Patient")

/*
RButton:: ;Rotates radiographs
if !MouseWithin(radiographsULPixel, radiographsLRPixel) ;Returns if mouse is not within radiograph viewing frame
	Return()
xvWebTransformPixel := new Pixel({ x: 175, y: 1372, color: "0xF5993D" }) ;Pixel of T showing radiograph selected
xvWebTransformArrow := new Pixel({ x: 204, y: 1351, color: "0xF5993D" }) ;Pixel of arrow in Transform icon indicating whether it is selected
xvWebRotateButton := new Pixel({ x: 142, y: 1229, color: "0x45311D" }) ;Pixel of rotate button
xvWebRotateSave := new Pixel({ x: 135, y: 1304, color: "0xEFD7C0" }) ;Pixel of save button
BlockInputOn()
GetMouse()
PixelGetColor, color, % xvWebTransformPixel.x, % xvWebTransformPixel.y, RGB
if (color = xvWebTransformPixel.color)
{
	PixelGetColor, color, % xvWebTransformArrow.x, % xvWebTransformArrow.y, RGB
	if (color = xvWebTransformArrow.color) ;If button is not selected clicks button
		MouseClick,, % xvWebTransformArrow.x, % xvWebTransformArrow.y
	MouseClick,, % xvWebRotateButton.x, % xvWebRotateButton.y ;Clicks Rotate button
	MouseClick,, % xvWebRotateSave.x, % xvWebRotateSave.y ;Clicks Save
}
Return()
*/

#If WinActive("ahk_exe OpenDental.exe") OR WinActive("Treatment Planning") OR WinActive("Task") OR WinActiveRegex("Viewer.*My iTero \- Google Chrome") OR WinActive("Viewing Patient") OR WinActive("ClinCheck | ") OR WinActive("DEXIS - ")

~RButton & MButton::
$F10:: ;Opens itero for patient
BlockInputOn()
GetMouse()
Click, RButton, Up
Click, MButton, Up

if WinActive("Treatment Planning")
    WinActivate, Open Dental

; If on Open Dental, set ODMode to Chart
if WinActive("ahk_exe OpenDental.exe")
{
	UnfocusImagingModeFrame()
	if WinActive("Open Dental {")
		SetODMode("Chart")
}

;returns to Open Dental if called from iTero
if WinActiveRegex("Viewer.*My iTero \- Google Chrome")
{
	Gosub, MButton
	Return()
}
DismissPopups()

patient := GetPatient()

if (patient.Source != "NA") ;Opens xray if patien valid
	FindPatient("iTero", patient)
Return()

!!ClinCheck:
return

^i:: ;Opens ClinCheck
BlockInputOn()
GetMouse()
Click, RButton, Up
Click, MButton, Up

;returns to Open Dental if called from iTero
if WinActive("ClinCheck")
{
	Gosub, MButton
	Return()
}

patient := GetPatient()

if (patient.Source = "NA") ;Open Dental, XVWeb, DEXIS or iTero not active
	Return()
else if(patient.Source = "Open Dental")
	SetODMode("Chart")
FindPatient("ClinCheck", patient)
Return()

#If WinActiveRegex("Patients.*My iTero")

$F10:: ;Switch back to Open Dental
WinActivate, Open Dental
Return()

!!GlobalVariableRoutines:
return

#If CoordinatesMode

Left::
CMScreen()
MouseGetPos, xpos, ypos
xpos--
Click, %xpos%, %ypos%, 0
PixelGetColor, color, xpos, ypos, RGB
CMClient()
MouseGetPos, xposclient, yposclient
ToolTip, %xpos% %ypos%`n%xposclient% %yposclient%`n%color%
return

Right::
CMScreen()
MouseGetPos, xpos, ypos
xpos++
Click, %xpos%, %ypos%, 0
PixelGetColor, color, xpos, ypos, RGB
CMClient()
MouseGetPos, xposclient, yposclient
ToolTip, %xpos% %ypos%`n%xposclient% %yposclient%`n%color%
return

Up::
CMScreen()
MouseGetPos, xpos, ypos
ypos--
Click, %xpos%, %ypos%, 0
PixelGetColor, color, xpos, ypos, RGB
CMClient()
MouseGetPos, xposclient, yposclient
ToolTip, %xpos% %ypos%`n%xposclient% %yposclient%`n%color%
return

Down::
CMScreen()
MouseGetPos, xpos, ypos
ypos++
Click, %xpos%, %ypos%, 0
PixelGetColor, color, xpos, ypos, RGB
CMClient()
MouseGetPos, xposclient, yposclient
ToolTip, %xpos% %ypos%`n%xposclient% %yposclient%`n%color%
return

!!Xrays:
return

#If WinActive("ahk_exe OpenDental.exe") OR WinActive("Treatment Planning") OR WinActiveRegex("Viewer.*My iTero \- Google Chrome") OR WinActive("Viewing Patient") OR WinActive("ClinCheck | ") OR WinActive("DEXIS - ")

~RButton & LButton:: ;Allows for RButton and then LButton to trigger xrays
BlockInputOn()
Click, RButton, Up
Click, LButton, Up

; If on Treatment Planning, activate Open Dental
if WinActive("Treatment Planning")
    WinActivate, Open Dental

; If on Open Dental, set ODMode to Chart
if WinActive("ahk_exe OpenDental.exe")
{
	UnfocusImagingModeFrame()
	if WinActive("Open Dental {")
		SetODMode("Chart")
}

;returns to Open Dental if called from xrays
if WinActive("DEXIS - ")
{
	Gosub, Mbutton ;Returns to Open Dental
	Return()
}
DismissPopups()

patient := GetPatient()

if (patient.Source != "NA") ;Opens xray if patient valid
	FindPatient("DEXIS", patient)

/*

IfWinActive, Open Dental
{
	patient := GetPatient()
	PatID := patient.ID
	SetTitleMatchMode RegEx
	IfWinExist, DEXIS.*%PatID% ;if Dexis open for this patient, activate, otherwise open Dexis
		WinActivate, DEXIS
	else
	{
		CoordMode, Mouse, Client
		/*
		DeleteLCKFile = 0
		CreateLCKFile = 0
		if (A_ComputerName = "DOCTOR1-PC")
		{
			IDArray := StrSplit(PatID) ;Creates array from patient ID
			if (IDArray[6] = "")
			{
				LckFile := "T:\DEXIS\DATA\" . IDArray[1] . "\" . IDArray[2] . "\" . IDArray[3] . "\" . IDArray[4] . "\" . IDArray[5] . "\2.lck"
				PatFile := "T:\DEXIS\DATA\" . IDArray[1] . "\" . IDArray[2] . "\" . IDArray[3] . "\" . IDArray[4] . "\" . IDArray[5] . "\pat.ini"
			}
			else
			{
				LckFile := "T:\DEXIS\DATA\" . IDArray[1] . "\" . IDArray[2] . "\" . IDArray[3] . "\" . IDArray[4] . "\" . IDArray[5] . "\" . IDArray[6] . "\2.lck"
				PatFile := "T:\DEXIS\DATA\" . IDArray[1] . "\" . IDArray[2] . "\" . IDArray[3] . "\" . IDArray[4] . "\" . IDArray[5] . "\" . IDArray[6] . "\pat.ini"
			}
			FileRead, PatInfo, %PatFile% ;Reads PatInfo.ini file and edits if needed so it opens to intraoral
			if not ErrorLevel ;If PatFile exists, patient has been here before
			{
				if (!InStr(PatInfo, "`nbox=tx")) ;PatInfo file not set to intraoral view
				{
					NewPatInfo := RegExReplace(PatInfo, "box=.+`r`nxraybox=.+", "box=tx`r`nxraybox=tx") ;Sets to intraoral view
					FileDelete, %PatFile%
					FileAppend, %NewPatInfo%, %PatFile%
				}

				if !FileExist(LckFile) ;Creates LCK file if none existed, so that Dexis will open as read only
				{
					FileAppend, TestComputer, %LckFile%
					DeleteLCKFile = 1 ;Set flag to delete lock file
				}
			}
			else ;Otherwise new pt where Dexis has never been open, so will have to switch to pano, and then back to intraoral once lock file created
				CreateLCKFile = 1
		}

		Click 787, 67 ;Clicks Dexis
		WinWaitActive, ahk_exe DEXIS.exe,, 15
		if ErrorLevel
		{
			if DeleteLCKFile
				FileDelete, %LckFile%
			Return()
		}
		IfWinActive, Warning:
			SendInput {Enter}
		if DeleteLCKFile
			FileDelete, %LckFile%
		if CreateLCKFile ;Wait for Dexis to load to click on Pano, create lock file, and click back on intraoral
		{
			CoordMode, Mouse, Client
			start := A_TickCount
			color := 0
			while (A_TickCount-start < 10000 AND color != 0xFFFFFF)
				PixelGetColor, color, 61, 17
			if (A_TickCount-start > 10000)
				Return()
			Sleep, 9000
			Click, 97, 17 ;Click on extraoral
			Sleep, 4000
			FileAppend, TestComputer, %LckFile% ;Creates lockfile
			Click, 61, 17 ;Click intraoral
			BlockInput, MouseMoveOff
			BlockInput, Off
			Sleep, 2000
			FileDelete, %LckFile%
		}
	}
	Return()
}
else ;If Open Dental or Dexis not active, activate Dexis
	WinActivate, DEXIS
Return()


/*
; If on Open Dental, set ODMode to Chart
if WinActive("ahk_exe OpenDental.exe")
{
	UnfocusImagingModeFrame()
	if WinActive("Open Dental {")
		SetODMode("Chart")
}

;returns to Open Dental if called from xrays
if WinActive("Viewing Patient")
{
	Gosub, Mbutton ;Returns to Open Dental
	Return()
}
DismissPopups()

patient := GetPatient()

if (patient.Source != "NA") ;Opens xray if patient valid
	FindPatient("xvWeb", patient)
*/
Return()

!!OpenDentalCharting:
return

#If WinActive("Report")

Left:: ;Goes to previous month
Send, !{F4} ; Send Alt+F4 key combination
WaitWin("Production and Income Report", 6) ;Waits for production an income report
MouseClick,, % reportsPreviousMonth.x, % reportsPreviousMonth.y ;Clicks previous month
ClickOK()
Return()

Right:: ;Goes to next month
Send, !{F4} ; Send Alt+F4 key combination
WaitWin("Production and Income Report", 6) ;Waits for production an income report
MouseClick,, % reportsNextMonth.x, % reportsNextMonth.y ;Clicks previous month
ClickOK()
Return()

Esc:: ;Closes report
Send, !{F4} ; Send Alt+F4 key combination
WaitWin("Production and Income Report", 6) ;Waits for production an income report
Send, !{F4} ; Send Alt+F4 key combination
Return()

#If WinActive("Open Dental {") OR WinActive("Popup")

~RButton:: ;Allows double click to open chart
if (A_TimeSincePriorHotkey < 500 AND A_ThisHotkey = A_PriorHotkey)
{
	BlockInputOn()
	MouseMove, -1, 0, 0, R
	Click, RButton, Up
	DismissPopups()
	GetMouse()
	SetODMode("Chart")
}
Return()

~+LButton:: ;Shift + left to open chart
Send, {ShiftUp}
BlockInputOn()
Click, LButton, Up
DismissPopups()
GetMouse()
SetODMode("Chart")
Return()

#If WinActive("Open Dental {")

^t:: ;Opens a Task, fills in reminder type
BlockInputOn()
GetMouse()
ClickODTopButton("Tasks")
PutMouse()
BlockInputOff()
WinWaitActive, Task,, 10
if ErrorLevel
	Return()
BlockInputOn()
MouseClick,, taskReminderDropdown.x, taskReminderDropdown.y ;Click the reminder type dropdown
Sleep, 50
SendInput {Down}{Enter} ;Select Once
Sleep, 50
MouseClick,, taskDescriptionField.x, taskDescriptionField.y ;Click into Description field
BlockInputOff()
Return()

!t:: ;Opens a Test Patient
GetMouse()
ClickODTopButton("SelectPatient")
WaitWin("Select Patient",2)
Sleep, 200
SendInput test{tab}testy
Sleep, 200
SendInput {enter}
SetODMode("Chart")
Return()

!LButton:: ;Goes to today
if (GetODMode() = "Appts")
{
	GetMouse()
	MouseClick,, % todayButton.x, % todayButton.y ;Clicks today
	PutMouse()
}
Return()

/*
~+LButton:: ;Opens Chart, iTero, or xRays from schedule
~+RButton::
~+MButton::
{
	BlockInputOn()
	Send, +{Up}
	Click, RButton, Up
	Click, MButton, Up
	Click, LButton, Up
	DismissPopups()
	GetMouse()
	SetODMode("Chart")
	if (A_ThisHotkey = "~+MButton")
		Gosub, RButton & MButton ;Opens iTero
	else if (A_ThisHotkey = "~+RButton")
		Gosub, RButton & LButton ;Opens x-rays
	Return()
}
*/

^c:: ;Commlog
KeyWait, c ;Wait for hotkey to be released to continue
Keywait Control
GetMouse()
ClickODTopButton("CommLog")
Return()

`:: ;Gets production for Gabe
GetMouse()
BlockInputOn()
ControlFocus,, Open Dental { ;Removes keyboard focus
SendInput !r{Down}{Enter} ;Reports, Standard Favorites
WaitWin("Standard Reports Favorites",6)
MouseClick,, reportsMoreOptions.x, reportsMoreOptions.y ;Clicks more options
WaitWin("Production and Income Report", 6)
MouseClick,, reportsMonthly.x, reportsMonthly.y ;Clicks monthly
number := providers[providerInitials][3]
ClickButton(reportsProviderButtons, number) ;Selects appropriate doctor
ClickOK()
Return()

^b:: ;Adds blockout for verified
MouseGetPos, MouseX, MouseY
PixelGetColor, mouseColor, MouseX, MouseY, RGB
if (GetODMode() = "Appts" AND (mouseColor = unscheduledApptColor1 OR mouseColor = unscheduledApptColor2)) ;if Appts selected and on unschedule time
{
	BlockInputOn()
	Click, Right
	SendInput a{Tab 4}%providerInitials% Verified ;Adds blockout
	Sleep, 500
	ClickOK()
}
Return()

^w:: ;Marks wisdom teeth as unerupted or missing
if ConfirmChartingMode()
{
	GetMouse()
	ToolTip, U: Unerupted`nM: Missing`nNone: Missing, 550, 5
	Keywait Control
	Keywait w
	Input, UserInput, T1 L1, {Enter}, u,m ;simple or referred
	ErrLevel := ErrorLevel
	ToolTip
	BlockInputOn()
	GetState()
	SelectTeeth("1,16,17,32")
	if (UserInput = "m" OR UserInput ="") ;missing
		SetSelectedTeeth("missing")
	else if (UserInput = "u")
		SetSelectedTeeth("primary")
}
Return()

^p:: ;Hides premolar teeth for ext and moves posterior teeth forward
Keywait Control
Keywait h
if !ConfirmChartingMode()
	Return()
GetMouse()
BlockInputOn()
teethWithWisdoms := GetSelectedTeeth(true) ;Gets permanent teeth selected
if !teethWithWisdoms
	ErrorMessage("Teeth have been moved, must perform manually", 0)
if (teethWithWisdoms.Length() = 0) ;if no teeth selected, select missing teeth between 2 and 15 and 19 and 31
{
	teethWithWisdoms := GetMissingTeeth()
	selectTeeth := true
}
else
	selectTeeth := false

; Initialize quadrant arrays
UR := 0
UL := 0
LL := 0
LR := 0

; Initialize master array for all identified teeth
teeth := []

; Initialize quadrant flags
URFlagged := false
ULFlagged := false
LLFlagged := false
LRFlagged := false

; Main loop
Loop, 8
{
    ; Upper Right Quadrant (1 to 8)
    currentUR := A_Index
    if (!URFlagged)
    {
        if !IndexOf(teethWithWisdoms, currentUR)
            URFlagged := true
    }
    else
    {
        if IndexOf(teethWithWisdoms, currentUR)
        {
            if (UR = 0)
            {
                UR := currentUR
                teeth.Push(currentUR)
            }
            else
                Return()
        }
    }

    ; Upper Left Quadrant (16 to 9)
    currentUL := 17 - A_Index
    if (!ULFlagged)
    {
        if !IndexOf(teethWithWisdoms, currentUL)
            ULFlagged := true
    }
    else
    {
        if IndexOf(teethWithWisdoms, currentUL)
        {
            if (UL = 0)
            {
                UL := currentUL
                teeth.Push(currentUL)
            }
            else
                Return()
        }
    }

    ; Lower Left Quadrant (17 to 24)
    currentLL := 16 + A_Index
    if (!LLFlagged)
    {
        if !IndexOf(teethWithWisdoms, currentLL)
            LLFlagged := true
    }
    else
    {
        if IndexOf(teethWithWisdoms, currentLL)
        {
            if (LL = 0)
            {
                LL := currentLL
                teeth.Push(currentLL)
            }
            else
                Return()
        }
    }

    ; Lower Right Quadrant (32 to 25)
    currentLR := 33 - A_Index
    if (!LRFlagged)
    {
        if !IndexOf(teethWithWisdoms, currentLR)
            LRFlagged := true
    }
    else
    {
        if IndexOf(teethWithWisdoms, currentLR)
        {
            if (LR = 0)
            {
                LR := currentLR
                teeth.Push(currentLR)
            }
            else
				Return()
		}
    }
}

if selectTeeth ;Selects teeth if needs be
	SelectTeeth(teeth)

; Check each quadrant and select posterior teeth if one or zero teeth selected
GetState()
SetSelectedTeeth("hidden")
if (UR != 0)
{
	if UR in 2,3
		URMesialClicks := 5
	else
		URMesialClicks := 3
	MouseClickDrag, Left, % tooth[1].x, % tooth[1].y, % tooth[UR-1].x, % tooth[UR-1].y
}
if (UL != 0)
{
	if UL in 14,15
		ULMesialClicks := 5
	else
		ULMesialClicks := 3
	MouseClickDrag, Left, % tooth[16].x, % tooth[16].y, % tooth[UL+1].x, % tooth[UL+1].y
}
if (LL != 0)
{
	if LL in 20,21,22
		LLMesialClicks := 3
	else if LL in 18,19
		LLMesialClicks := 5
	else
		LLMesialClicks := 2
	MouseClickDrag, Left, % tooth[17].x, % tooth[17].y, % tooth[LL-1].x, % tooth[LL-1].y
}
if (LR != 0)
{
	if LR in 27,28,29
		LRMesialClicks := 3
	else if LR in 30,31
		LRMesialClicks := 5
	else
		LRMesialClicks := 2
	MouseClickDrag, Left, % tooth[32].x, % tooth[32].y, % tooth[LR+1].x, % tooth[LR+1].y
}
SetChartTab("Movements")
MouseClick,, % mesialMovementButton.x, % mesialMovementButton.y, 2 ;Moves teeth 2 clicks forward

;If there are more movements to make, deselects any 2 click quadrants
if (URMesialClicks = 3 OR URMesialClicks = 5 OR ULMesialClicks = 3 OR ULMesialClicks = 5 OR LLMesialClicks = 3 OR LLMesialClicks = 5 OR LRMesialClicks = 3 OR LRMesialClicks = 5)
{
	if (LLMesialClicks = 2)
		MouseClickDrag, Left, % tooth[17].x-12, % tooth[17].y, % tooth[LL-1].x-12, % tooth[LL-1].y
	if (LRMesialClicks = 2)
		MouseClickDrag, Left, % tooth[32].x+12, % tooth[32].y, % tooth[LR+1].x+12, % tooth[LR+1].y

	;Moves teeth an additional 1 click forward
	MouseClick,, % mesialMovementButton.x, % mesialMovementButton.y, 1 ;Moves teeth 1 clicks forward
}

;If there are more movements to make, deselects any 3 click quadrants
if (URMesialClicks = 5 OR ULMesialClicks = 5 OR LLMesialClicks = 5 OR LRMesialClicks = 5)
{
	if (LLMesialClicks = 3)
		MouseClickDrag, Left, % tooth[17].x-18, % tooth[17].y, % tooth[LL-1].x-18, % tooth[LL-1].y
	if (LRMesialClicks = 3)
		MouseClickDrag, Left, % tooth[32].x+18, % tooth[32].y, % tooth[LR+1].x+18, % tooth[LR+1].y
	if (ULMesialClicks = 3)
		MouseClickDrag, Left, % tooth[16].x-18, % tooth[16].y, % tooth[UL+1].x-18, % tooth[UL+1].y
	if (URMesialClicks = 3)
		MouseClickDrag, Left, % tooth[1].x+18, % tooth[1].y, % tooth[UR-1].x+18, % tooth[UR-1].y

	;Moves teeth an additional 2 clicks forward
	MouseClick,, % mesialMovementButton.x, % mesialMovementButton.y, 2 ;Moves teeth 1 clicks forward
}
DeselectTeeth()

Return()

^q:: ;Marks teeth unerupted/primary
Keywait Control
Keywait q
if ConfirmChartingMode()
{
	GetState()
	GetMouse()
	BlockInputOn()
	SetSelectedTeeth("primary")
}
Return()

^a:: ;Marks teeth unerupted/primary
Keywait Control
Keywait a
if ConfirmChartingMode()
{
	GetState()
	GetMouse()
	BlockInputOn()
	SetSelectedTeeth("permanent")
}
Return()

^n:: ;Not missing or Notes Done
Keywait Control
Keywait n
if ConfirmChartingMode()
{
	GetState()
	GetMouse()
	BlockInputOn()
	SetSelectedTeeth("notmissing")
}
else if(GetODMode() = "Appts")
{
	BlockInputOn()
	Click ;clicks on appt
	MouseClick,, % statusScrollDown.x, % statusScrollDown.y ;Scrolls down on status
	MouseClick,, % statusNotesRev.x, % statusNotesRev.y ;Sets status to notes done
}
Return()

^m:: ;Missing
Keywait Control
Keywait m
if ConfirmChartingMode()
{
	GetState()
	GetMouse()
	BlockInputOn()
	SetSelectedTeeth("missing")
}
Return()

^h:: ;Hidden
Keywait Control
Keywait h
if ConfirmChartingMode()
{
	GetState()
	GetMouse()
	BlockInputOn()
	SetSelectedTeeth("hidden")
}
Return()

^x:: ;tx plans ext
if ConfirmChartingMode()
{
	GetMouse()
	ToolTip, S: Simple`nR: Referred`nNone: Surgical, 550, 5
	Keywait Control
	Keywait x
	Input, UserInput, T1 L1, {Enter}, s,r ;simple or referred
	ErrLevel := ErrorLevel
	ToolTip
	BlockInputOn()
	GetState()
	SetChartTab("Treatment")
	if (UserInput = "r") ;Referred
		SetTxMode("Re")
	else
		SetTxMode("TP")
	if (UserInput = "s")
		AddCode("D7140") ;Simple Ext
	else
		AddCode("D7210") ;Surgical
}
Return()

^u:: ;Updates surfaces of resto, changes to surgical, routine
if ConfirmChartingMode()
{
	GetMouse()
	ToolTip, Surfaces: Updates surfaces`nS: Routine to surgical`nR: Surgical to routine, 550, 5
	KeyWait, u ;Waits till U released to continue
	Keywait Control
	Input, UserInput, T3 L5, sru{Enter} ;Lets patient enter new surfaces
	EndKey := ErrorLevel
	ToolTip
	BlockInputOn()
	IfWinNotActive, Open Dental
		Return()
	Click 2 ;Opens tx planned procedure
	WaitWin("Procedure Info", 2)
	if InStr(Endkey, "Endkey:s") ;Updates to surgical
	{
		UpdateCode("D7210")
		ClickOK()
	}
	else if InStr(Endkey, "Endkey:r") ;updates to routine
	{
		UpdateCode("D7140")
		ClickOK()
	}
	else ;updates surfaces
	{
		if (SetSurfaces(UserInput)) ;Updates code and returns true if should be a D2335 because it has M or D and I and F or L
		{
			ClickOK()
			ChangeCodeTogglePause()
		}
		else
			ClickOK()
	}
}
Return()

/*
^f:: ;Tx plans PA
Keywait Control
Keywait p
BlockInputOn()
GetMouse()
PixelGetColor, color, 481, 115, RGB ;Checks if Enter Treatment clicked
if (color != 0xAABEE6)
	Click 481, 115 ;Click Enter Treatment
Click 488, 238 ;Changes mode to treatment planned
Sleep, 300
Click 721, 205 ;Clicks Hygiene
Click 835, 179 ;Clicks PA
Return()
*/

^s:: ;Tx plans sealant
Keywait Control
Keywait s
if ConfirmChartingMode()
{
	GetState()
	GetMouse()
	BlockInputOn()
	SetChartTab("Treatment")
	SetTxMode("TP")
	AddCode("D1351")
}
Return()

^r:: ;Tx plans resto
if ConfirmChartingMode()
{
	GetMouse()
	ToolTip, Surfaces then Enter, 550, 5
	KeyWait, r ;Wait for hotkey to be release to continue
	Keywait Control
	Input, UserInput, T4 L7, {Enter} ;Lets user enter surfaces
	ToolTip
	BlockInputOn()
	GetState()
	SetChartTab("Treatment")
	SetTxMode("TP")
	D2335 := SetSurfaces(UserInput) ;Returns true if needs D2335
	SetDiagnosis("CA") ;Caries
	SetProcedureButtons("General")
	if D2335
		AddCode("D2335") ;Codes for D2335
	else
		SingleClick(1) ;Clicks "Composite" in Single Click column
}
Return()

^LWin:: ;Creates popup in Open Dental
Keywait Control
Keywait LWin
BlockInputOn()
GetMouse()
MouseClick,, % popupButton.x, % popupButton.y ;Clicks Popup
WaitWin("Popups for Family", 3)
Sleep, 500
PixelGetColor, color, popupCheckPixel.x, popupCheckPixel.y, RGB ;Checks if popup already there
if (color != popupCheckPixelcolor) ;popup already exists
{
	MouseClick,, % popupCheckPixel.x, % popupCheckPixel.y, 2 ;Clicks on popup
	WaitWin("Edit Popup", 4)
	SendInput {enter}{up}
}
else
{
	MouseClick,, % popupAddButton.x, % popupAddButton.y ;Clicks Add
	WaitWin("Edit Popup", 4)
}
Return()

^d:: ;Deletes treatment planned procedures
Keywait Control
Keywait d
if ConfirmChartingMode()
{
	BlockInputOn()
	MouseGetPos, px, py ;Gets cursor position
	if ((px > progressNoteCoords[1] AND px < progressNoteCoords[3]) AND (py > progressNoteCoords[2] AND py < progressNoteCoords[4])) ;If cursor is in progress note box
	{
		Click 2 ;Double clicks
		WinWaitActive, Procedure Info,, 2
		if ErrorLevel
			Return()
		Send !d
		Send {Enter}
	}
}
Return()

^f:: ;Starts filling autonote
KeyWait Control
KeyWait f
if ConfirmChartingMode()
{
	BlockInputOn()
	MouseGetPos, px, py ;Gets cursor position
	if ((px > progressNoteCoords[1] AND px < progressNoteCoords[3]) AND (py > progressNoteCoords[2] AND py < progressNoteCoords[4])) ;If cursor is in progress note box
	{
		MouseClick, right ;Right clicks
		SendInput, g{enter} ;Group note
		WaitWin("Group Note",2)
		Autonote()
		ClickButton(autoNoteButtons, 12, 2) ;Clicks Fillings, the 12th button down
		WaitWin("Prompt List",2)
		SendInput !p ;Opens Preview to fill out tooth and surfaces
	}
}
Return()

^o:: ;Opens up prescription box, and if r, e, c, i, a typed afterwards, sends type of script
if !ConfirmChartingMode()
	Return()

ToolTip, R: P(R)evident`nE: P(E)nicillin`nC: Clindamycin`nA: Amoxicillin`nZ: Azithromycin`nN: Norco`nH: Halcion`nP: Amoxicillin Premed`nNone: Brings up selection screen, 550, 5
KeyWait, o ;Wait for hotkey to be release to continue
Keywait Control
Input, UserInput, T1 L1, {Enter}, r,e,a,c,z,h,n,p ;Options for most prescribed choices
Error := ErrorLevel
ToolTip
BlockInputOn()
MouseClick,, % newRxButton.x, % newRxButton.y ;Clicks New Rx
WaitWin("Select Prescription", 2)
if (Error = "Timeout" OR Error = "Max" OR Error = "EndKey:Enter") ;Aborts here if nothing else entered
	Return()
SendInput, % prescriptions[UserInput][1] . "{enter}"
Sleep, 500
MouseClick,, % prescriptions[UserInput][2], % prescriptions[UserInput][3], 2 ;Clicks appropriate choice
WaitWin("Edit Rx", 2)
MouseClick,, % editRXProviderDropdown.x, % editRXProviderDropdown.y ;Click Doctor drop down
number := providers[providerInitials][3]
ClickButton(editRXProviderButtons, number) ;Selects appropriate doctor
MouseMove, % editRXPrintButton.x, % editRXPrintButton.y ;Moves to Print button
Return()

!!SpecificWindows:
return

#If WinActive("Popup")

Del:: ;Deletes popup
SendInput, {Esc} ;Closes Popup
Sleep, 300
if WinActive("Popup")
	DismissPopups()
if !WinActive("Open Dental {")
	Return()
MouseClick,, % popupButton.x, % popupButton.y ;Clicks Popups
WaitWin("Popups for Family",2)
Sleep, 200
popups := FindColor(countPopupsFindColor[1],countPopupsFindColor[2],countPopupsFindColor[3],countPopupsFindColor[4],countPopupsFindColor[5],countPopupsFindColor[6],countPopupsFindColor[7],countPopupsFindColor[8]) ;Finds how many popups there are
if (popups.color = 2)
	MouseClick,, % firstPopupPixel.x, % firstPopupPixel.y, 2 ; Clicks first popup
else
{
	CoordMode, ToolTip, Client
	ToolTip, Click on Popup to delete, 280, 0
	MouseMove, % firstPopupPixel.x, % firstPopupPixel.y ;Moves to first popup
	KeyWait, LButton, D ; Wait for the left mouse button to be pressed
	KeyWait, LButton, U ; Wait for the left mouse button to be released
	Click ;Double clicks popup
	ToolTip
	CoordMode, ToolTip
}
WaitWin("Edit Popup",2) ;Waits for Popup
MouseClick,, % editPopupDeleteButton.x, % editPopupDeleteButton.y ;Clicks Delete
WaitWin("Popups for Family",2)
SendInput, {Esc} ;Closes Edit Popup
Return()

#If WinActive("Log On")

`:: ;Selects Gabe
KeyWait ``
GetMouse()
Click, 106, 188 ;Clicks Gabe
Return()

#If WinActive("Communication Item") OR WinActive("Task") OR WinActive("Popup") OR WinActive("Popups for Family")

`:: ;Closes
KeyWait ``
ClickOK()
Return()

#If WinActive("Edit Rx")
`:: ;Prints Rx
KeyWait ``
SendInput !p
Return()

#If WinActive("Edit Appointment")

`:: ;Verifies appointment length
BlockInputOn()
GetMouse()
startY := 54
currentY := startY
Loop
{
	PixelGetColor, pixelColor, 33, %currentY%, RGB
	if (pixelColor != "0xC0C0C0" AND pixelColor != "0x000000")
	{
		clickY := currentY - 1
		MouseClick,, 33, %clickY%
		SendInput 0
		SendInput !s
		break
	}
	currentY += 12
	if (currentY > 500) ; Safety limit to prevent infinite loop
		break
}
PutMouse()
BlockInputOff()
Return()


#If WinActive("Prompt List","Exam Done By") AND A_ComputerName = "DOCTOR1-PC"


#If WinActive("Group Note") OR WinActive("Procedure Info") OR WinActive("Compose Auto Note")
`:: ;Closes Note and goes to schedule
KeyWait ``
BlockInputOn()
ClickOK()
GetMouse()
Sleep, 300
if WinActive("Edit Appointment") ;Returns without setting note complete
{
	ClickOK()
	Return()
}
if WinActive("Group Note") OR WinActive("Procedure Info")
{
	ClickOK()
	Sleep, 300
}

if WinActive(,"Prosthesis date not entered")
{
	BlockInputOff()

	; Create the GUI
	Gui, Add, Button, gInitialCrown +Center w150, Initial
	Gui, Add, Text, +Center w150, or
	Gui, Add, Edit, vDateInput r1 +Center w65, m/d/yyyy
	Gui, Add, Checkbox, vEstimated x+10 yp+4, Estimated
	Gui, Add, Button, gReplacementCrown +Center w150 xm, Replacement

	; Show the GUI and wait for user input
	Gui, Show, Autosize Center, Initial or Replacement Crown ; Added title and dimensions
	GuiControl, Focus, DateInput
	SendInput, ^a ;Preselects the date

	; Hotkeys within the GUI
	Hotkey, IfWinActive, Initial or Replacement Crown
	Hotkey, I, InitialCrown, On
	Hotkey, R, ReplacementCrown, On
	Hotkey, Enter, ReplacementCrown, On

	return

	InitialCrown:
		Gui, Destroy
		WinWaitActive,, Prosthesis date not entered, 2
		if ErrorLevel
			ErrorMessage("Crown date warning box never opened", 0)
		SendInput !n ;No
		WaitWin("Procedure Info",1)
		MouseClick,, % procedureInfoInitialPixel.x, % procedureInfoInitialPixel.y ;Clicks Initial
		ClickOK()
		Return()

	ReplacementCrown:
		GuiControlGet, dateValue,, DateInput
		GuiControlGet, isEstimated,, Estimated

		Gui, Destroy
		WinWaitActive,, Prosthesis date not entered, 2
		if ErrorLevel
			ErrorMessage("Crown date warning box never opened", 0)
		SendInput !n ;No
		WaitWin("Procedure Info",1)
		MouseClick,, % procedureInfoReplacementPixel.x, % procedureInfoReplacementPixel.y ;Clicks replacement
		if isEstimated
			MouseClick,, % procedureInfoEstimatedDatePixel.x, % procedureInfoEstimatedDatePixel.y ;Clicks Estimated
		MouseClick,, % procedureInfoDateFieldPixel.x, % procedureInfoDateFieldPixel.y ;Clicks date field
		SendInput, % dateValue
		Sleep, 100
		ClickOK()
		Return()

	GuiClose:
		Hotkey, IfWinActive, Initial or Replacement Crown
		Hotkey, I, Off
		Hotkey, R, Off
		Hotkey, Enter, Off
		Gui, Destroy
		Return()
}
SetODMode("Appts")
MouseClick,, % statusScrollDown.x, % statusScrollDown.y ;Scrolls down on status
MouseClick,, % statusNotesRev.x, % statusNotesRev.y ;Sets status to notes done
Return()

#If WinActive("Group Note") OR WinActive("Procedure Info")

^f:: ;Starts filling autonote
KeyWait Control
KeyWait f
BlockInputOn()
Autonote()
ClickButton(autoNoteButtons, 12, 2) ;Clicks Fillings, the 12th button down
WaitWin("Prompt List",2)
SendInput !p ;Opens Preview to fill out tooth and surfaces
Return()

#If WinActive("Prompt List")

Left:: ;Back
SendInput !b
Return()

Right:: ;Next
SendInput !n
Return()

1::
2::
3::
4::
s:: ;See next visit or Sadey
n:: ;No needs or no anesthetic
g:: ;Gluma or Gabey
o:: ;Courtney
c:: ;Christian
h:: ;Heather
b:: ;Bethany
k:: ;Kia
t:: ;temp asst or topical placed
e:: ;emax
z:: ;zirconia
i:: ;initial
r:: ;replacement
l:: ;lidocaine
p:: ;preview
HotkeysToCheck := "1234sngochbsgktezirlp"
Loop, Parse, HotkeysToCheck
    KeyWait, % A_LoopField, U
BlockInputOn()
prompt := GetActivePrompt()

if (A_ThisHotkey = "p") ;Preview
{
	SendInput !p
	WinWaitNotActive, Prompt List,, 1
	if WinActive(,"One response must be selected") ;If one response not selected, select one and then delete
	{
		Sleep, 200
		SendInput {Enter}
		WaitWin("Prompt List", 2) ;Waits for Win to close
		ClickButton(onePromptButtons, 1) ;Selects the first item so Preview can open
		SendInput !p
		WinWaitNotActive, Prompt List,, 1
		if WinActive("Preview")
			SendInput ^a{Del} ;Selects all and deletes
	}
	Return()
}

if (prompt = "Anesthetic")
{
	if (A_ThisHotkey = "n") ;No anesthetic
		ClickButton(onePromptButtons, 1, 2)
	else if (A_ThisHotkey = "t") ;Topical Placed
		ClickButton(onePromptButtons, 2, 2)
	else if (A_ThisHotkey = "1") ;Clicks 1 carpule
		ClickButton(onePromptButtons, 3, 2)
	else if (A_ThisHotkey = "2") ;Clicks 2 carpule
		ClickButton(onePromptButtons, 4, 2)
	else if (A_ThisHotkey = "3") ;Clicks 3 carpule
		ClickButton(onePromptButtons, 5, 2)
	else if (A_ThisHotkey = "4") ;Clicks 4 carpule
		ClickButton(onePromptButtons, 6, 2)
	else if (A_ThisHotkey = "l") ;Clicks 1 lidocaine carpule
		ClickButton(onePromptButtons, 13, 2)
	Return()
}
else if (prompt = "Bonding" AND (A_ThisHotkey = "2" OR A_ThisHotkey = "g"))
{
	ClickButton(multiPromptCheckmarks, 1) ;Etch
	ClickButton(multiPromptCheckmarks, 2) ;Gluma
	SendInput !n
	Return()
}
else if (prompt = "NextVisit" AND (A_ThisHotkey = "s" OR A_ThisHotkey = "n"))
{
	if (A_ThisHotkey = "s") ;See tx plan
		ClickButton(multiPromptCheckmarks, 1) ;Clicks See tx plan
	else if (A_ThisHotkey = "n")
		ClickButton(multiPromptCheckmarks, 2) ;Clicks No tx needed
	SendInput !n
	Return()
}
else if (prompt = "Details")
{
	if (A_ThisHotkey = "1") ;Direct pulp cap
	{
		ClickButton(multiPromptCheckmarks, 1) ;Clicks first option
		SendInput !p
		WaitWin("Preview",2)
		MouseClick,, % directPulpCapToothNumberPixel.x, % directPulpCapToothNumberPixel.y, 2 ;Selects tooth number
	}
	else if (A_ThisHotkey = "2") ;Indirect pulp cap
	{
		ClickButton(multiPromptCheckmarks, 2) ;Clicks second option
		SendInput !p
		WaitWin("Preview",2)
		MouseClick,, % indirectPulpCapToothNumberPixel.x, % indirectPulpCapToothNumberPixel.y, 2 ;Clicks
	}
	else if (A_ThisHotkey = "3") ;Deep
	{
		ClickButton(multiPromptCheckmarks, 3) ;Clicks third option
		SendInput !p
		WaitWin("Preview",2)
		MouseClick,, % deepRestoToothNumberPixel.x, % deepRestoToothNumberPixel.y, 2 ;Clicks
	}
	Return()
}
else if (prompt = "Assistant")
{
	if (A_ThisHotkey = "o") ;Courtney
		ClickButton(onePromptButtons, 1, 2)
	else if (A_ThisHotkey = "c") ;Christian
		ClickButton(onePromptButtons, 2, 2)
	else if (A_ThisHotkey = "b") ;Bethany
		ClickButton(onePromptButtons, 3, 2)
	else if (A_ThisHotkey = "s") ;Sadey
		ClickButton(onePromptButtons, 4, 2)
	else if (A_ThisHotkey = "g") ;Gabey
		ClickButton(onePromptButtons, 5, 2)
	else if (A_ThisHotkey = "e") ;Sepideh
		ClickButton(onePromptButtons, 7, 2)
	else if (A_ThisHotkey = "k") ;Kia
		ClickButton(onePromptButtons, 8, 2)
	else if (A_ThisHotkey = "t") ;Temp
		ClickButton(onePromptButtons, 9, 2)
	Return()
}
else if (prompt = "CrownMaterial" AND (A_ThisHotkey = "e" OR A_ThisHotkey = "z"))
{
	if (A_ThisHotkey = "e") ;emax
		ClickButton(onePromptButtons, 2, 2)
	else if (A_ThisHotkey = "z") ;zirconia
		ClickButton(onePromptButtons, 1, 2)
	Return()
}
else if (prompt = "InitialOrReplacement" AND (A_ThisHotkey = "i" OR A_ThisHotkey = "r"))
{
	if (A_ThisHotkey = "i") ;initial
		ClickButton(onePromptButtons, 1, 2)
	else if (A_ThisHotkey = "r") ;replacement
	{
		ClickButton(onePromptButtons, 2)
		SendInput !pReplacement: Previous crown placed{space}
	}
	Return()
}

;Selects number 1-4 if none of the above options apply
if prompt in Teeth,Bonding,Composite,Details,NextVisit ;Multi prompt
{
	ClickButton(multiPromptCheckmarks, A_ThisHotkey) ;Clicks appropriate button
	SendInput !n
}
else ;single prompt
	ClickButton(onePromptButtons, A_ThisHotkey, 2)
Return()

`:: ;Hits next
KeyWait ``
BlockInputOn()
prompt := GetActivePrompt()

if prompt in Teeth,Bonding,Composite,CrownDiag,Details,NextVisit, ;Checks to see if anything checked
{
	numUnchecked := CountButtons(multiPromptCheckmarks) ;Counts number of boxes before one is checked
	if (numUnchecked = 12)
	{
		if (prompt = "Details")
			SendInput !r ;Remove prompt
		else if prompt in CrownDiag,Teeth
			SendInput !p ;Preview
		else if (prompt = "Bonding") ;if bonding question and nothing selected, selects etch
		{
			ClickButton(multiPromptCheckmarks, 1) ;Clicks etch
			SendInput !n
		}
		else if (prompt = "Composite") ;Clicks Admira
		{
			PixelGetColor, color, % compositePromptScrolledPixel.x, % compositePromptScrolledPixel.y, RGB
			if (color != compositePromptScrolledPixel.color) ;If the scrollbar has been used, click next
				ClickButton(multiPromptCheckmarks, 2) ;Clicks admira
			SendInput !n
		}
		else if (prompt = "NextVisit") ;If nothing selected, See tx plan
		{
			ClickButton(multiPromptCheckmarks, 1) ;Clicks See tx Plan
			SendInput !n
		}
	}
	else
		SendInput !n
}
else if (prompt = "Assistant")
	SendInput !r
else if (prompt = "Doctor")
{
	ClickButton(onePromptButtons, providers[providerInitials][3], 2) ;Clicks appropriate provider twice
	WaitWin("Compose Auto Note",2)
	ClickOK()
	GetMouse()
	Sleep, 300
	if WinActive("Edit Appointment") ;Returns without setting note complete
	{
		ClickOK()
		Return()
	}
	if WinActive("Group Note") OR WinActive("Procedure Info")
	{
		ClickOK()
		Sleep, 300
	}
	SetODMode("Appts")
	Click, 2490, 589 ;Scrolls down on status
	Click, 2455, 595 ;Sets status to notes done
}
else if (prompt = "Anesthetic")
	ClickButton(onePromptButtons, 3, 2)
else if (prompt = "InitialOrReplacement")
	ClickButton(onePromptButtons, 1, 2)
else if (prompt = "CrownMaterial")
	ClickButton(onePromptButtons, 1, 2)
else ;Otherwise just go to next
	SendInput !n
Return()

#If WinActive("Text Prompt") OR WinActive("Preview")

`:: ;Hits next
KeyWait ``
GetMouse()
BlockInputOn()
if WinActive("Preview")
	ClickOK()
else ;Text Prompt
{
	SendInput !n
	WaitWin("Prompt List",2)
	Sleep, 200
	prompt := GetActivePrompt()
	if (prompt = "CrownDiag")
		SendInput !p
}
Return()

#If WinActive("Edit Popup")
`:: ;Dismisses Popup
KeyWait ``
GetMouse()
ClickOK()
Return()

#If WinActive(,"Prosthesis date not entered. Continue anyway?")
i::
`:: ;Dismisses box, selects initial
KeyWait ``
KeyWait i
SendInput !n ;No
GetMouse()
WaitWin("Procedure Info",1)
MouseClick,, % procedureInfoInitialPixel.x, % procedureInfoInitialPixel.y ;Clicks Initial
ClickOK()
Return()

r:: ;Dismisses box, selects replacement
KeyWait r
SendInput !n ;No
WaitWin("Procedure Info",1)
MouseClick,, % procedureInfoReplacementPixel.x, % procedureInfoReplacementPixel.y ;Clicks Initial
MouseClick,, % procedureInfoDateFieldPixel.x, % procedureInfoDateFieldPixel.y ;Moves to date field
Return()

!!KPIs:
return

#If WinActive("Task Search")

Enter::SendInput !r ;Clicks Search


#If WinActive("KPI's")

+`:: ;Select day manually
`:: ;Yesterday stats

KeyWait Control
Click, 2 ;Double click to open daily stats
BlockInputOn()
Run, chrome.exe "https://portal.dentalintel.com/dashboard/provider-pulse"
WaitWin("Analytics",8)
WinMaximize, Analytics
MouseMove, dentalIntelLoginPixel.x, dentalIntelLoginPixel.y ;Moves to login button so that the color of the button changes to the appropriate color when loaded
if(WaitFor2Pixels(dentalIntelCalendarPixel, dentalIntelLoginPixel, 10) = 2) ;Login page is present
{
	MouseClick,, dentalIntelLoginPixel.x, dentalIntelLoginPixel.y ;Click Login
	WaitForPixel(dentalIntelSideBar) ;Waits for Dental Intel to load
	if(GetURL() != "https://portal.dentalintel.com/dashboard/provider-pulse")
		SetURL("https://portal.dentalintel.com/dashboard/provider-pulse") ;Browse to provider dashboard
	WaitForPixel(dentalIntelCalendarPixel) ;Wait for calendar button
}

; Define the user's workdays string
workdays := providers[providerInitials][2] ; Example: Monday, Wednesday, Thursday, Friday

;Clicks Calendar
Sleep, 500
MouseClick,, % dentalIntelCalendarPixel.x, % dentalIntelCalendarPixel.y ;Clicks date

; Find gray which indicates start of calendar
foundColor := FindColor(dentalIntelxSunday, dentalIntelyBreak, "x", 2, 175, dentalIntelCalendarStartColor, 0, 0)
if (foundColor.color = 0)
	ErrorMessage("Could not find start of calendar", 0)
dentalIntelThisWeekX := foundColor.x + 350 ; Sets x coord of This Week button
MouseClick,, % dentalIntelThisWeekX, % dentalIntelThisWeekY ;Clicks This week to select current week
Sleep, 500
MouseClick,, % dentalIntelCalendarPixel.x, % dentalIntelCalendarPixel.y ;Clicks date

; Find gray which indicates start of calendar again (it may have changed now that current week selected)
foundColor := FindColor(dentalIntelxSunday, dentalIntelyBreak, "x", 2, 175, dentalIntelCalendarStartColor, 0, 0)
if (foundColor.color = 0)
	ErrorMessage("Could not find start of calendar", 0)
dentalIntelxSunday := foundColor.x + 28
dentalIntelxSaturday := dentalIntelxSunday + 6 * dentalIntelxDayIncrement

; Find what row is currently selected by looking for the blue of the Sunday, the first row checking the saturday
foundColor2 := FindColor(dentalIntelxSunday, dentalIntelyRow, "y", dentalIntelrowHeight, dentalIntelmaxCalendarHeight, dentalIntelrowSelectedColor, 0, 0)
if (foundColor2.color = 0)
{
	foundColor2 := FindColor(dentalIntelxSaturday, dentalIntelyRow, "y", dentalIntelrowHeight, dentalIntelmaxCalendarHeight, dentalIntelrowSelectedColor, 0, 0) ;checks saturday in case the week is over a month transition
	if (foundColor2.color = 0)
		ErrorMessage("Could not find selected week", 0)
}
dentalIntelyRow := foundColor2.y

; Set the coordinates for the "Go Back a Month" button
dentalIntelGoBack := new Pixel({ x: dentalIntelxSunday+44, y: dentalIntelCalendarBackAndForwardY })
dentalIntelGoForward := new Pixel({ x: dentalIntelxSunday+231, y: dentalIntelCalendarBackAndForwardY })

; Determine the current day of the week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
currentDayOfWeek := A_WDay

; Determine the current day of the month
currentDayOfMonth := A_MDay

; Find the last workday the doctor worked
lastWorkday := currentDayOfWeek

;Figures out if month displayed is the current month (0), or the previous month(-1)
if (A_WDay > A_MDay)
	displayedMonth := -1
else
	displayedMonth := 0

daysAgo := 0
prevWeek := 0

Loop ;Finds last work day
{
    if (A_Index > 7) ;Breaks after a week
		ErrorMessage("No previous workday found", 0)

	; Decrement the day of the week
    lastWorkday--
	daysAgo++

    ; If it reaches the beginning of the week (Sunday), start at the end of the week (Saturday)
    if (lastWorkday < 1)
	{
		lastWorkday := 7
		prevWeek++
	}

	if InStr(workdays, lastWorkday) ;if this day is a workday, break
		break
}

; Calculate the day to select based on the last workday
xToClick := dentalIntelxSunday + ((lastWorkday - 1) * dentalIntelxDayIncrement)

MouseClick,, % dentalIntelxSunday, % dentalIntelDayY ;Clicks Day calendar
Sleep, 500
if (A_ThisHotkey = "+``")
{
	ToolTip, Select day for stats
	BlockInputOff()
	WaitForPixel(new Pixel({ x: dentalIntelCalendarPixel.x, y: dentalIntelCalendarPixel.y, color: dentalIntelCalendarColorAfterManualSelection, timeout: 10, page: "Manual Date Selection for Stats" }))
	Tooltip
	BlockInputOn()
}
else
{
	if (currentDayOfMonth - daysAgo < 1)
		monthOfLastWorkDay := -1
	else
		monthOfLastWorkDay := 0
	if (monthOfLastWorkDay < displayedMonth) ;day is in previous month than what is displayed, so must go back a month
	{
		dentalIntelyRow := dentalIntelyBreak + 233 ;Starts at 6th row

		; Click button to go back a month
		MouseClick,, % dentalIntelGoBack.x, % dentalIntelGoBack.y

		MouseMove, %xToClick%, %dentalIntelyRow% ;Moves mouse to possible date
		PixelGetColor, color, xToClick, dentalIntelyRow, RGB
		while (color != dentalInteldaySelectorColor)
		{
			if (A_Index = 2)
				ErrorMessage("Could not find day to select", 0)
			dentalIntelyRow -= dentalIntelrowHeight
			MouseMove, %xToClick%, %dentalIntelyRow% ;Moves mouse to possible date
			PixelGetColor, color, xToClick, dentalIntelyRow, RGB
		}
	}
	else if (monthOfLastWorkDay > displayedMonth) ;Last work day is in month after what is displayed, so must go forward a month
	{
		dentalIntelyRow := dentalIntelyBreak + 18
		MouseClick,, % dentalIntelGoForward.x, % dentalIntelGoForward.y
		foundColor3 := FindColor(dentalIntelxSaturday, dentalIntelyRow, "y", dentalIntelrowHeight, dentalIntelmaxCalendarHeight, dentalIntelrowSelectedColor, 0, 0) ;checks saturday in case the week is over a month transition
		if (foundColor3.color = 0)
			ErrorMessage("Could not find selected week", 0)

		dentalIntelyRow := foundColor3.y
	}
	else ;day is in displayed month
		dentalIntelyRow := dentalIntelyRow - prevWeek * dentalIntelrowHeight ;Decrements week if needed
	MouseClick,, % xToClick, % dentalIntelyRow
}
Sleep, 500
dentalIntelStats := []
MouseClick,, % dentalIntelCase.x, % dentalIntelCase.y ;Expands Case

;Iterates through specific dental intel stats
for index, measure in dentalIntelStatInstructions
{
	if (index != 1) ;starts on first stat's page
		MouseClick,, % measure[2], % measure[3] ;Clicks measure
	Sleep, 500
	WaitForPixel(new Pixel({ x: dentalIntelPageLoadedPixel.x, y: dentalIntelPageLoadedPixel.y, color: dentalIntelPageLoadedPixel.color, timeout: 60, page: measure[1] }))
	SendInput ^a ;Select all
	stat := Copy(measure[1])
	if (RegExMatch(stat, measure[4], match))
		dentalIntelStats.push(match1)
	else
		ErrorMessage("Could not find" . measure[1], 0)
}
WinActivate, KPI's
WaitWin("KPI's", 10) ;Opens KPI's to input
Sleep, 500
MouseClick,, % NotionKPINetProduction.x, % NotionKPINetProduction.y ;Click Net Production
Sleep, 200

;Swaps the 2nd and 3rd item in array to match Notion's fields
temp := dentalIntelStats[2]
dentalIntelStats[2] := dentalIntelStats[3]
dentalIntelStats[3] := temp

;Iterates through gathered stats and inputs it into KPI's
for index, stat in dentalIntelStats
{
	if (index != 6)
		SendInput % stat . "{Tab}"
	else
		SendInput % stat . "{Enter}" ;Last stat needs to be followed by enter
	Sleep, 100
}
Return()

#If WinActive("Assign Teeth:")

r:: ;rotates scanned image
CoordMode, Mouse, Screen
MouseGetPos, px, py ;Gets cursor position
CoordMode, Mouse, Client
Click 599, 152 ;Clicks rotate
CoordMode, Mouse, Screen
Click %px%, %py%, 0 ;Puts mouse back
Return()

#If WinActive("Open Dental") OR WinActive("Demo Database")

+i::
Insert:: ;Treatment Plan Insert box
SetTimer, ReloadScript, Off

; Global arrays for tracking teeth statuses
global PermanentTeethMissing := []
global PermanentTeethUnerupted := []
global PermanentTeethSimpleExt := []
global PermanentTeethSurgicalExt := []
global PermanentTeethReferredExt := []

global PrimaryTeethMissing := []
global PrimaryTeethUnerupted := []
global PrimaryTeethSimpleExt := []
global PrimaryTeethSurgicalExt := []
global PrimaryTeethReferredExt := []

; Global variable for tracking warnings
global WarningMsg := ""

currentPatient := GetPatient()

Gui, TreatmentPlanning:New,, Treatment Planning
Gui, +AlwaysOnTop
Gui, Font, S8 CDefault Bold, Verdana
Gui, Add, Text, x2 y-1 w319 h20 , % "Patient: " . currentPatient.LastName . ", " . currentPatient.FirstName . "   ID: " . currentPatient.ID
Gui, Font, S8 CDefault Norm, Verdana
Gui, Font, S8 CDefault Underline, Verdana
Gui, Add, Text, x2 y19 w90 h20 , Existing
Gui, Add, Text, x162 y19 w110 h20 , Treatment Planned
Gui, Font, S8 CDefault Norm, Verdana

; Existing (Left Side)
; Missing
Gui, Add, Text, x2 y39 w85 h20, Missing
Gui, Add, Edit, x2 y59 w150 h40 vExistingMissing,
Gui, Add, CheckBox, x2 y99 w160 h20 vPremolarsExtDueToOrtho, 5,12,21,28 ;-Close Space DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
Gui, Add, Text, x2 y121 w40 h20, 3rds:
Gui, Add, Button, x32 y119 w50 h20 gThirdsMissing, Missing
;Gui, Add, Button, x83 y119 w70 h20 gThirdsUnerupted, Unerupted ;DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE

; Restorations/Sealants
Gui, Add, Text, x2 y148 w150 h20, Restos/Sealants
Gui, Add, Edit, x2 y168 w150 h70 vExistingRestorationsAndSealants,
Gui, Add, Button, x95 y145 w58 h20 gAmalRep, Amal->

; Crowns/Bridges
Gui, Add, Text, x2 y248 w100 h20, Crowns/Bridges
Gui, Add, Edit, x2 y268 w150 h20 vExistingCrownsAndBridges,

; Veneers/Onlays/Inlays
Gui, Add, Text, x2 y298 w140 h20, Veneers/Onlays/Inlays
Gui, Add, Edit, x2 y318 w150 h20 vExistingVeneersAndOnlays,

; Implants
Gui, Add, Text, x2 y348 w80 h20, Implants
Gui, Add, Edit, x2 y368 w150 h20 vExistingImplants,

; Endo
Gui, Add, Text, x2 y398 w50 h20, Endo
Gui, Add, Edit, x2 y418 w150 h20 vExistingEndos,

; Fixed Lingual Retainer
Gui, Add, Text, x2 y448 w140 h20, Fixed Lingual Retainer
Gui, Add, CheckBox, x2 y468 w50 h20 vFixedRetainer710, 7-10
Gui, Add, CheckBox, x55 y468 w40 h20 vFixedRetainer89, 8-9
Gui, Add, CheckBox, x100 y468 w50 h20 vFixedRetainer2227, 22-27

; Partials
Gui, Add, Text, x2 y498 w80 h20, Partials
Gui, Add, Edit, x2 y518 w150 h20 vExistingPartials,

; Complete Denture
Gui, Add, Text, x2 y545 w90 h30 , Comp Denture
Gui, Add, CheckBox, x2 y560 w30 h20 vExistingUpperDenture, U
Gui, Add, CheckBox, x32 y560 w20 h20 vExistingLowerDenture, L

; Popup
Gui, Add, Text, x2 y604 w140 h20, Popup
Gui, Add, Edit, x2 y624 w150 h162 vPopup,

; Treatment Planned (Right Side)
; Extractions
Gui, Add, Text, x162 y39 w89 h20, Extractions
Gui, Add, CheckBox, x255 y36 w50 h20 vReferExt, Refer
Gui, Add, Edit, x162 y59 w150 h40 vTreatmentPlannedExtractions,
Gui, Add, Text, x162 y102 w80 h20, Refer 3rds:
Gui, Add, Button, x242 y99 w50 h20 gReferThirdsAll, All
Gui, Add, Button, x162 y119 w34 h20 gReferThird1, 1
Gui, Add, Button, x201 y119 w34 h20 gReferThird16, 16
Gui, Add, Button, x240 y119 w34 h20 gReferThird17, 17
Gui, Add, Button, x279 y119 w34 h20 gReferThird32, 32

; Restorations/Sealants
Gui, Add, Text, x162 y148 w150 h20, Restos/Sealants
Gui, Add, Edit, x162 y168 w150 h70 vTreatmentPlannedRestorationsAndSealants,

;Crowns/Bridges
Gui, Add, Text, x162 y248 w100 h20, Crowns/Bridges
Gui, Add, Edit, x162 y268 w150 h20 vTreatmentPlannedCrownsAndBridges,

; Veneers/Onlays/Inlays
Gui, Add, Text, x162 y298 w140 h20, Veneers/Onlays/Inlays    
Gui, Add, Edit, x162 y318 w150 h20 vTreatmentPlannedVeneersAndOnlays,

;Implants
Gui, Add, Text, x162 y348 w80 h20, Implants
Gui, Add, CheckBox, x255 y345 w50 h20 vReferImplants, Refer
Gui, Add, Edit, x162 y368 w150 h20 vTreatmentPlannedImplants,

;Endo
Gui, Add, Text, x162 y398 w50 h20, Endo
Gui, Add, CheckBox, x255 y395 w50 h20 vReferEndos, Refer
Gui, Add, Edit, x162 y418 w150 h20 vTreatmentPlannedEndos,

; Pulp Caps
Gui, Add, Text, x162 y448 w80 h20, Pulp Caps
Gui, Add, Edit, x162 y468 w150 h20 vTreatmentPlannedPulpCaps,

; Partials
Gui, Add, Text, x162 y498 w80 h20, Partials
Gui, Add, CheckBox, x255 y495 w50 h20 vReferPartials, Refer
Gui, Add, Edit, x162 y518 w150 h20 vTreatmentPlannedPartials,

; Complete Denture
Gui, Add, Text, x162 y545 w90 h30 , Comp Denture
Gui, Add, CheckBox, x255 y543 w50 h20 vReferDentures, Refer
Gui, Add, CheckBox, x162 y560 w30 h20 vTreatmentPlannedUpperDenture, U
Gui, Add, CheckBox, x192 y560 w30 h20 vTreatmentPlannedLowerDenture, L

; Occlusal Guard
Gui, Add, Text, x162 y582 w90 h30 , Occ Guard
Gui, Add, Text, x162 y599 w10 h30 , F:
Gui, Add, CheckBox, x175 y597 w30 h20 vTreatmentPlannedFullOcclusalGuardUpper, U
Gui, Add, CheckBox, x205 y597 w30 h20 vTreatmentPlannedFullOcclusalGuardLower, L
Gui, Add, Text, x242 y599 w10 h30 , P:
Gui, Add, CheckBox, x257 y597 w30 h20 vTreatmentPlannedPartialOcclusalGuardUpper, U
Gui, Add, CheckBox, x287 y597 w30 h20 vTreatmentPlannedPartialOcclusalGuardLower, L

; SRP
Gui, Add, Text, x162 y621 w140 h15, SRP 1-3
Gui, Add, CheckBox, x162 y636 w37 h18 vTreatmentPlannedSRP13UR, UR
Gui, Add, CheckBox, x200 y636 w37 h18 vTreatmentPlannedSRP13UL, UL
Gui, Add, CheckBox, x162 y654 w37 h18 vTreatmentPlannedSRP13LR, LR
Gui, Add, CheckBox, x200 y654 w37 h18 vTreatmentPlannedSRP13LL, LL
Gui, Add, Text, x242 y621 w50 h15 , SRP 4+
Gui, Add, CheckBox, x242 y636 w37 h18 vTreatmentPlannedSRP4UR, UR
Gui, Add, CheckBox, x280 y636 w37 h18 vTreatmentPlannedSRP4UL, UL
Gui, Add, CheckBox, x242 y654 w37 h18 vTreatmentPlannedSRP4LR, LR
Gui, Add, CheckBox, x280 y654 w37 h18 vTreatmentPlannedSRP4LL, LL

; Invisalign
Gui, Add, Text, x162 y678 w80 h20, Invisalign
Gui, Add, CheckBox, x162 y693 w80 h20 vInvisalignComp, Comp
Gui, Add, CheckBox, x162 y711 w80 h20 vInvisalignLimited, Limited

; Retainers
Gui, Add, Text, x242 y678 w80 h20, Retainers
Gui, Add, CheckBox, x242 y693 w37 h18 vRetainers1, 1
Gui, Add, CheckBox, x280 y693 w37 h18 vRetainers2, 2
Gui, Add, CheckBox, x242 y711 w37 h18 vRetainers3, 3
Gui, Add, CheckBox, x280 y711 w37 h18 vRetainers4, 4
Gui, Add, CheckBox, x242 y729 w37 h18 vRetainersU, U
Gui, Add, CheckBox, x280 y729 w37 h18 vRetainersL, L

; Nitrous
Gui, Add, Text, x162 y750 w50 h20, Nitrous
Gui, Add, Text, x162 y770 w10 h20, x
Gui, Add, Edit, x178 y765 w30 h20 vNitrousTimes,

; Halcion
Gui, Add, Text, x242 y750 w50 h20, Halcion
Gui, Add, Text, x242 y770 w10 h20, x
Gui, Add, Edit, x258 y765 w30 h20 vHalcionTimes,

Gui, Add, Button, x2 y792 w50 h30 Default, &OK
Gui, Add, Button, x54 y792 w50 h30, &Cancel
Gui, Add, Button, x106 y792 w50 h30 gTreatmentPlanningButtonSave, &Save
Gui, Add, Button, x158 y792 w50 h30 gLoadRecent, &Load
Gui, Add, Button, x210 y792 w50 h30 gExpandTermsButton, E&xpand
Gui, Add, Button, x262 y792 w50 h30 gSortTeethButton, &Sort

ExistingMissing_TT := "
(
Enter the tooth number:

Examples:
  2     (#2 is missing)
  m     (M is missing)
)"

ExistingRestorationsAndSealants_TT := "
(
Sealants: Enter tooth number only
Restorations: Enter tooth number/letter plus surfaces in lowercase (m, o, i, d, b, f, l, v).
If you add a trailing 'a', the restoration is amalgam.

Examples:
  3o        (#3 occlusal composite)
  4moda     (#4 MOD amalgam)
  14oa      (#14 occlusal amalgam)
  20        (sealant on #20)
)"

ExistingCrownsAndBridges_TT := "
(
For single crowns, enter tooth number plus optional material:
  c = ceramic (default)
  g = gold
  p = PFM
  s = SSC
For bridges, separate double abutments with a comma and pontics with a dash.

Examples:
  3       (#3 ceramic crown)
  13s     (#13 stainless steel crown)
  15g     (#15 gold crown)
  2-4c    (bridge from #2 to #3, ceramic)
  -7      (#7 crown with cantilevered #6 pontic)
  7-9-    (bridge from #7 to #9 with cantilevered #10 pontic)
  5,6-11,12z (double-abutted ceramic bridge)
)"

ExistingVeneersAndOnlays_TT := "
(
Veneer: Enter tooth number (no surfaces). 
Onlay/Inlay: Enter tooth number plus surfaces (m, o, d, b, l, v); 
Add 'g' for gold, otherwise defaults to ceramic.

Examples:
  3modg  (#3 gold onlay with MOD surfaces)
  4modb  (#4 ceramic onlay/inlay with MODB surfaces)
  6       (#6 veneer, ceramic by default)
  7       (#7 veneer, ceramic by default)
)"

ExistingImplants_TT := "
(
Enter tooth number for an existing implant + crown.
Add a trailing 'i' if the implant is present but no crown.
For implant bridges, separate abutments with a comma and pontics with a dash.

Examples:
  3    (#3 implant + crown)
  14i  (#14 implant only, no crown)
  3-5  (implant bridge from #3 to #5)
  6,7-9 (implant bridge with abutments #6,7 and pontic #8)
  -8   (implant crown on #8 with pontic #7)
)"

ExistingEndos_TT := "
(
Enter tooth number to mark existing root canal.
Add 'p' if it includes a post/core.

Examples:
  12    (#12 with existing endo)
  15p   (#15 with existing endo + post/core)
)"

ExistingPartials_TT := "
(
List the teeth in the partial (using commas or a dash), then add one letter for material:
  m = metal
  f = flexible (default)
  a = acrylic
  i = interim

Examples:
  3,4,7-10m  (metal partial spanning #3,4 and #7-10)
  8,9,23,24  (flexible max partial replacing 8 and 9, and mand partial replacing 23 and 24)
)"

TreatmentPlannedExtractions_TT := "
(
Enter tooth number/letter plus optional extraction type:
  r = refer for extraction
  s = simple extraction
Otherwise defaults to surgical extraction.

Examples:
  3   (surgical extraction #3)
  4s  (simple extraction #4)
  19r (refer #19 for extraction)
)"

TreatmentPlannedRestorationsAndSealants_TT := "
(
Sealants - Enter a tooth number/letter.
Restorations - Enter tooth number/letter, specify surfaces in lowercase, 
and optionally add a diagnosis code in caps (otherwise defaults to caries)
(CA-Caries, RE-Recurrent, AL-Alloy Replacement, CH-Chip, WE-Wear/Erosion,
LA-Large Restoration, MA-Open/Defective Margins, FL-Fracture Line,
FR-Fracture Restoration, CR-Cracked Tooth Syndrome, MI-Missing restoration,
PE-Periodontitis, IP-Irrev. Pulpitis, NE-Necrotic, ES-Esthetics,
ET-Endodontically Treated) 

Examples:
  3moCA   (#3 MOD composite with Caries diagnosis)
  14 (Sealant)
)"

TreatmentPlannedCrownsAndBridges_TT := "
(
Crowns and Bridges:
1) Start with tooth number.
2) Optional 'r' plus date/year for replacement (e.g. r10 => replaced 10 yrs ago, r2020 => replaced in 2020).
3) Optional material:
   z = zirconia (defaults for molars)
   e = eMax (defaults for premolars and anteriors)
   g = gold
   s = stainless steel
4) Optional post or no-core modifiers:
   p = post (disables core)
   n = no core (core added by default otherwise)
5) Optional standard diagnosis codes (CA-Default, RE, AL, CH, WE, LA, MA, FL, FR, CR, MI, PE, IP, NE, ES, ET) 
6) Narrative in parentheses eg. (Large existing restoration with recurrent caries)

Bridges:
Abutments are numbered, with pontics represented by dashes.
Double abutments are separated with a comma.
Cantilevered pontics are represented by a dash before or after the terminal abutment.
Cores must be added separately

Cores:
Just tooth number followed by a 'c'

Examples:
  3r10gCA(Caries under existing restoration)    (#3 replacement from 10 yrs ago, gold crown, caries diagnosis, narrative)
  8-RE(Recurrent under existing restoration)     (#8 emax crown, no core,recurrent caries diagnosis, narrative)
  14p        (#14 crown with a post, no core)
  5-7z       (bridge from #5 to #7 zirconia)
  -7         (emax crown on #7 with cantilevered pontic for 6)
  6-9-11     (bridge from #6 to #11 with #9 present as a middle abutment)
  6-9-       (bridge from #6 to #9 with #10 cantilevered pontic)
  5,6-11,12z (double-abutted ceramic bridge)
  1c         (#1 core)
)"

TreatmentPlannedVeneersAndOnlays_TT := "
(
Veneers (anterior teeth only) are tooth number plus optional diagnosis code.
For onlays/inlays (posterior), specify tooth number, surfaces, optional diagnosis.
Note: Inlays vs. Onlays are auto-detected based on surfaces. Ceramic only.

Use one of the standard diagnosis codes (CA, RE, etc.) if needed.

Examples:
  8CA       (veneer on #8 for caries diagnosis)
  14modCA   (#14 inlay with MOD surfaces and caries diagnosis)
  5mdobFR     (#5 onlay with MODB surfaces and fractured restoration diagnosis)
)"

TreatmentPlannedImplants_TT := "
(
Enter tooth number plus any combination of these modifiers:
  c  = custom abutment
  b  = bone graft at time of implant
  m  = membrane at time of implant
  ^  = plan crown only (implant already placed)
  xi = extraction + immediate implant
  x  = extraction + graft/membrane (delayed implant)
  e  = essix interim
  p  = provisional crown (not available for bridges)
  r  = refer out for implant, treatment plan abutment and crown

For bridges, use dashes for pontics..
Cantilevered pontics use a dash at the beginning or end of bridge.

Defaults: stock abutment, surgical guide, full mouth CT (unless referred)

Examples:
  3cbmxi   (#3 extraction, bone graft & membrane at implant placement, custom abutment, immediate implant, CT, guide)
  14^c     (implant already placed, custom abutment and implant crown only for #14)
  9r       (#9 referred out for implant, stock abutment and crown treatment planned)
  30x      (#30 extraction + bone graft, CT and guide, delayed implant, stock abutment, crown)
  -8c      (cantilevered pontic mesial to #8 implant with custom abutment)
  7-9      (implant bridge from #7 to #9 with pontic at #8)
  6-8-     (implant bridge from #6 to #8 with cantilevered pontic at #9)
  9xr      (refer #9 for extraction and implant, treatment plan stock abutment and crown)
)"

TreatmentPlannedEndos_TT := "
(
Enter permanent tooth number plus optional modifiers:
  r = refer for endo
  p = post/core
  c = include composite in access on referral

Example:
  19p    (root canal on #19 with post/core)
  3r     (refer #3 for endo)
  8rc    (refer #8 with a lingual composite)
  30rp   (refer #30 for endo and post/core)
  12rc   (reger #12 with occlusal composite)
)"

TreatmentPlannedPulpCaps_TT := "
(
Enter tooth number plus pulp cap type:
  d = direct pulp cap
  i = indirect pulp cap

Examples:
  3d  (#3 direct pulp cap)
  14i (#14 indirect pulp cap)
)"

TreatmentPlannedPartials_TT := "
(
List the teeth for a partial. Separate individual teeth with commas, 
or specify a range with a dash. 
Optional modifiers:
  m = metal partial
  a = acrylic partial
  f = flexible partial (default if unspecified)
  i = interim partial
  e = essix partial
  r = refer

Examples:
  2,3-5m   (metal partial for #2,3,4,5)
  19-21    (default flex partial for #19,20,21)
  4,5-8,23r   (refer for maxillary (#4,5,6,7,8) and mandibular (#23) flex partials)
  2,3-5mr  (referred metal partial for #2,3,4,5)
  9e      (essix partial for #9)
)"

; Show the GUI set up in the above include
SysGet, screenWidth, 0
SysGet, screenHeight, 1

if (screenWidth = 2560 && screenHeight = 1440)
    Gui, Show, x230 y500 h829 w314
else if (screenWidth = 1920 && screenHeight = 1080)
    Gui, Show, x1192 y181 h829 w314
else
    Gui, Show, x1255 y0 h829 w314

; Set up tooltip handling
OnMessage(0x200, "WM_MOUSEMOVE")

WM_MOUSEMOVE()
{
	static CurrControl, PrevControl, _TT
	CurrControl := A_GuiControl
	If (CurrControl <> PrevControl)
	{
		SetTimer, DisplayToolTip, -300
		PrevControl := CurrControl
	}
	return

	DisplayToolTip:
	try
			ToolTip % %CurrControl%_TT
	catch
			ToolTip
	SetTimer, RemoveToolTip, -6000
	return

	RemoveToolTip:
	ToolTip
	return
}
return

;Buttons for the Treatment Planning GUI
ThirdsMissing:
    GuiControlGet, ExistingMissing
    GuiControl,, ExistingMissing, 1 16 17 32 %ExistingMissing%
return

/* DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
ThirdsUnerupted:
    GuiControlGet, ExistingMissing
    GuiControl,, ExistingMissing, 1u 16u 17u 32u %ExistingMissing%
return
*/

ReferThirdsAll:
    GuiControlGet, TreatmentPlannedExtractions
    GuiControl,, TreatmentPlannedExtractions, 1r 16r 17r 32r %TreatmentPlannedExtractions%
return

ReferThird1:
    GuiControlGet, TreatmentPlannedExtractions
    GuiControl,, TreatmentPlannedExtractions, 1r %TreatmentPlannedExtractions%
return

ReferThird16:
    GuiControlGet, TreatmentPlannedExtractions
    GuiControl,, TreatmentPlannedExtractions, 16r %TreatmentPlannedExtractions%
return

ReferThird17:
    GuiControlGet, TreatmentPlannedExtractions
    GuiControl,, TreatmentPlannedExtractions, 17r %TreatmentPlannedExtractions%
return

ReferThird32:
    GuiControlGet, TreatmentPlannedExtractions
    GuiControl,, TreatmentPlannedExtractions, 32r %TreatmentPlannedExtractions%
return

; Finds all amalgam restorations in the existing restorations and sealants text box and adds them as treatment planned alloy replacements
AmalRep:
    GuiControlGet, ExistingRestorationsAndSealants

    ; Initialize variables
    amalgamRestos := []
    restoSurfacesSortedAndSplit := []

    ; Parse through existing restorations to find amalgams
    Loop, Parse, ExistingRestorationsAndSealants, `n%A_Space%
    {
        ; Skip empty lines or whitespace
        if isWhitespace(A_LoopField)
            continue
            
        ; Check if it's an amalgam restoration using the existing regex pattern
        if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . posteriorTeeth . ")(?P<Surfaces>" . posteriorSurfaces . "{1,6})a$", resto) OR RegExMatch(A_LoopField, "^(?P<Toothnum>" . anteriorTeeth . ")(?P<Surfaces>" . anteriorSurfaces . "{1,6})a$", resto))
        {
            ;Sort surfaces alphabetically and split the surfaces into two separate surface combosif they are not adjacent
            restoSurfacesSortedAndSplit := sortAndSplitNonAdjacentSurfaces(restoSurfaces)
            
            ;If there are no valid surfaces, alert user of error in syntax, otherwise add the surface combos as restos to an array to be added as treatment planned alloy replacements
            if (restoSurfacesSortedAndSplit.Length() = 2)
            {
                for index, surfaces in restoSurfacesSortedAndSplit
                    amalgamRestos.Push([restoToothnum, surfaces])
            }
            else if (restoSurfacesSortedAndSplit.Length() = 1) ;Add unsorted surfaces as a single surface combo
                amalgamRestos.Push([restoToothnum, restoSurfaces])
            else
                LogError(ErrorMsg, "Existing Restorations - " . A_LoopField . " is an invalid combination of surfaces")
        }
    }

    ; If there are any errors, show the error message and abort
    ifErrorsDisplayAndAbort()
    
    ; If amalgams were found, create the string of new restorations and adds them to the treatment planned restorations and sealants text box
    if amalgamRestos.Length()
    {
        newTPRestos := ""
        for index, alloyReplacementsToAdd in amalgamRestos
            newTPRestos .= alloyReplacementsToAdd[1] . alloyReplacementsToAdd[2] . "AL "
        
        ; Adds the new alloy replacements on the the beginning of the treatment planned restorations and sealants text box
        GuiControlGet, TreatmentPlannedRestorationsAndSealants
        GuiControl,, TreatmentPlannedRestorationsAndSealants, %newTPRestos%%TreatmentPlannedRestorationsAndSealants%
    }
return

; On Escape or Close button, save the data and close the GUI
TreatmentPlanningGuiEscape:
TreatmentPlanningGuiClose:
	Save()
	Gui, TreatmentPlanning:Destroy
	;if (A_ComputerName != "DOCTOR1_PC")
	;    SetTimer, ReloadScript, 60000, -1
Exit

TreatmentPlanningButtonCancel:
	Gui, TreatmentPlanning:Destroy
	if (A_ComputerName != "DOCTOR1_PC")
		SetTimer, ReloadScript, 60000, -1
Exit

TreatmentPlanningButtonSave:
	Save()
return

LoadRecentButton:
LoadRecent()
return

; Expand the terms in the text boxes
ExpandTermsButton:
    ExpandMultiplierTerms()
return 

; Sort the teeth notations in the text boxes
SortTeethButton:
    SortToothNotations()
return

LoadRecent()
{
    ; Read the existing content of the file and split into lines
    FileRead, oldContent, %A_MyDocuments%\TreatmentPlanLog.ini
    lines := StrSplit(oldContent, "`n")
    
    ; The first line is the date and time, so start from the second line
    Loop, % lines.Length() - 1
    {
        ;Removes carriage return and new line characters
        line := StrReplace((StrReplace(lines[A_Index + 1], "`r", "")),"`n","")
        
        ;If line does not contain "=", we've finished loading the last section
        if (!InStr(line, "="))
            break

        ; Split each line into the variable name and value
        parts := StrSplit(line, "=")
        vname := parts[1]
        value := parts[2]

        ; Set the value of the control
        if (value = "true")
            GuiControl,, %vname%, 1
        else
            GuiControl,, %vname%, %value%
    }
    return
}

SplitAbutments(abutmentString) 
{
    abutments := []
    Loop, Parse, abutmentString, `,
        abutments.Push(A_LoopField + 0)
    return abutments
}

AppendArray(ByRef targetArray, sourceArray) 
{
    for i, value in sourceArray
        targetArray.Push(value)
}

; Validates the bridge object, returns an object with the abutments, pontics, and error message
ValidateBridge(bridgeString)
{
    localErrorMsg := ""
    result := { abutments: [], pontics: [], error: "", invalid: false }

    ; Check for leading/trailing dashes (cantilever)
    startingCantilever := RegExMatch(bridgeString, "^-")
    endingCantilever := RegExMatch(bridgeString, "-$")

    ; Strip them off
    if (startingCantilever)
        bridgeString := SubStr(bridgeString, 2)
    if (endingCantilever)
        bridgeString := SubStr(bridgeString, 1, StrLen(bridgeString) - 1)

    ; Build a quick array of abutments (by turning all dashes into commas)
    dashAsComma := StrReplace(bridgeString, "-", ",")
    result.abutments := StrSplit(dashAsComma, ",")

    ; Figure out direction of bridge (incrementing or decrementing)
    isIncrementing := true
    if (result.abutments.Length() > 1)
        if (result.abutments[2] < result.abutments[1])
            isIncrementing := false

    ; Now break the trimmed string on '-' to get segments, then check each segment
    bridgeSegments := StrSplit(bridgeString, "-")

    for s, seg in bridgeSegments
    {
        segAbuts := StrSplit(seg, ",")
        prevTooth := ""
        for t, segAb in segAbuts
        {
            tooth := segAb + 0

            ; direction & gap checks
            if (prevTooth != "")
            {
                ; Check if there is a space for a pontic between the abutments
                diff := Abs(tooth - prevTooth)
                if (diff = 0)
                    LogError(localErrorMsg, "Duplicate abutment: " . tooth)

                ; must not reverse direction
                if ((tooth > prevTooth) != isIncrementing)
                {
                    LogError(localErrorMsg, "Segment direction mismatch between " . prevTooth . " and " . tooth)
                    result.error := localErrorMsg
                    result.invalid := true
                    return result
                }

                ; Check if there is a space for a pontic between the abutments
                if (diff > 2)
                    LogError(localErrorMsg, "Adjacent abutments must differ by 1 or 2 but do not between " . prevTooth . " and " . tooth)
            }
            prevTooth := tooth
        }
    }

    ; Next, identify the pairs connected by dashes to fill pontics using a regex for pairs like  (\d+)-(\d+)
    pos := 1
    prevNum := ""
    while (pos := RegExMatch(bridgeString, "(\d+)(?:-|$)", m, pos))
    {
        currentNum := m1 + 0
        
        if (prevNum != "")
        {
            ; Confirm direction
            if ((currentNum > prevNum) != isIncrementing)
                LogError(localErrorMsg, "Direction mismatch between abutments in " . prevNum . "-" . currentNum)

            ; Check if there is a space for a pontic between the abutments
            diff := Abs(currentNum - prevNum)
            if (diff < 2)
                LogError(localErrorMsg, "No space for a pontic between " . prevNum . "-" . currentNum)
            else ; fill in pontics in between
                appendArray(result.pontics, GetTeethBetween(prevNum, currentNum))
        }
        
        prevNum := currentNum
        pos += StrLen(m1)
    }

    startOfBridge := result.abutments[1]
    endOfBridge   := result.abutments[result.abutments.MaxIndex()]

    ; Add cantilever pontics if needed
    if (startingCantilever)
    {
        cStep := isIncrementing ? -1 : 1
        startOfBridge += cStep
        if (!isTooth(startOfBridge))
            LogError(localErrorMsg, "Starting cantilever pontic " . startOfBridge . " is invalid.")
        else
            result.pontics.InsertAt(1, startOfBridge)
    }

    if (endingCantilever)
    {
        cStep := isIncrementing ? 1 : -1
        endOfBridge += cStep
        if (!isTooth(endOfBridge))
            LogError(localErrorMsg, "Ending cantilever pontic " . endOfBridge . " is invalid.")
        else
            result.pontics.Push(endOfBridge)
    }

    ; Confirm same arch from start to end
    if (isTooth(startOfBridge) && isTooth(endOfBridge) && (isMaxillary(startOfBridge) != isMaxillary(endOfBridge)))
        LogError(localErrorMsg, "Bridge crosses from one arch to another.")
    
    result.error := localErrorMsg
    result.invalid := localErrorMsg != ""
    return result
}

; Parses the date string and returns an object with the date, estimated, and error
ParseDate(dateString)
{
    localErrorMsg := ""
    result := {date: "", estimatedBool: false, error: "", invalid: false}

    if (dateString ~= "^[1-9][0-9]?$") ;1-99 years ago
	{
        yearsAgo := dateString
        FormatTime, currentDate,, yyyyMMdd
        result.date := SubStr(currentDate, 5, 4) . SubStr(currentDate, 1, 4) - yearsAgo
        result.estimatedBool := true
    }
    else if (dateString ~= "^(18[8-9][0-9]|19[0-9]{2}|20[0-9]{2}|2100)$") ;YYYY between 1880 and 2100
	{
        result.date := "0101" . dateString
        result.estimatedBool := true
	}
    else if (dateString ~= "^(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])(18[8-9][0-9]|19[0-9]{2}|20[0-9]{2}|2100)$") ;MMDDYYYY between 1880 and 2100
        result.date := dateString
    else
        localErrorMsg := " has an invalid date format. Expected 1-99 (years ago), YYYY (1880-2100), or MMDDYYYY (1880-2129)."
    
    result.error := localErrorMsg
    result.invalid := localErrorMsg != ""
    return result
}

;Makes sure parentheses are balanced, open first then close, and are not nested
ValidateParentheses(input)
{
    localErrorMsg := ""
    openCount := 0

    Loop, Parse, input
    {
        if (A_LoopField = "(")
        {
            if (openCount > 0)
            {
                localErrorMsg := "Nested parentheses are not allowed."
                break
            }
            openCount++
        }
        else if (A_LoopField = ")")
        {
            if (openCount = 0)
            {
                localErrorMsg := "Closing parenthesis without opening parenthesis."
                break
            }
            openCount--
        }
    }

    if (localErrorMsg = "" && openCount > 0)
        localErrorMsg := "Unclosed parenthesis detected."

    return {invalid: (localErrorMsg != ""), error: localErrorMsg}
}

;Splits into separate crowns delimited by spaces, but ignoring the spaces within parentheses
SplitCrownInput(input)
{
    result := []
    inParentheses := false
    currentItem := ""
    
    ; Process each character
    Loop, Parse, input
    {
        char := A_LoopField
        
        if (char = "(")
            inParentheses := true
        
        if (char = ")")
            inParentheses := false
            
        if (char = A_Space && !inParentheses)
        {
            if (currentItem != "")
            {
                result.Push(currentItem)
                currentItem := ""
            }
        }
        else
            currentItem .= char
    }
    
    ; Add the last item if needed
    if (currentItem != "")
        result.Push(currentItem)
    
    return result
}


; Helper function to assign partials and check for duplicates
AssignPartial(ByRef maxArray, ByRef mandArray, maxTeeth, mandTeeth, materialType, isReferred)
{
    global ErrorMsg
    if (maxTeeth.Length() > 0)
    {
        ; If the array is already populated, log an error, except for essix
        if (maxArray.Length() > 0 && materialType != "essix")
            LogError(ErrorMsg, "Treatment Planned Partials - Cannot have multiple maxillary " . materialType . " partials" . (isReferred ? " referred" : "") . ".")
        ; Otherwise, assign the array to the teeth
        else if (materialType = "essix")
        {
            ; For essix, add to the existing array instead of overwriting
            for index, tooth in maxTeeth
                maxArray.Push(tooth)
        }
        else
            maxArray := maxTeeth
    }
    if (mandTeeth.Length() > 0)
    {
        ; If the array is already populated, log an error, except for essix
        if (mandArray.Length() > 0 && materialType != "essix")
            LogError(ErrorMsg, "Treatment Planned Partials - Cannot have multiple mandibular " . materialType . " partials" . (isReferred ? " referred" : "") . ".")
        ; Otherwise, assign the array to the teeth
        else if (materialType = "essix")
        {
            ; For essix, add to the existing array instead of overwriting
            for index, tooth in mandTeeth
                mandArray.Push(tooth)
        }
        else
            mandArray := mandTeeth
    }
}

; Joins an array into a string with a delimiter
Join(array, delimiter)
{
    result := ""
    for index, element in array
    {
        if (result != "")
            result .= delimiter
        result .= element
    }
    return result
}

; Logs an error message
LogError(ByRef errorMessage, message, delimiter := "`n")
{
    if (errorMessage = "")
        errorMessage := message
    else
        errorMessage .= delimiter . message
}

;Sorts tooth notations in treatment planning form text boxes
;Primary teeth (a-t) are placed first, then permanent teeth (1-32), keeping other notations in original order
SortToothNotations()
{
    global ErrorMsg, permanentTeeth, primaryTeeth, controlList
    
    ;Arrays to store original and processed values
    originalValues := Object()
    processedValues := Object()
    
    ;First Pass: Check parentheses balance and convert spaces within parentheses
    altSpace := Chr(5)  ;Use same alternative space character as in ExpandTermsInText
    
    for index, controlName in controlList
    {
        ;Get current value
        GuiControlGet, currentValue,, %controlName%
        
        ;Store original value
        originalValues[controlName] := currentValue
        
        ;Process parentheses and spaces
        processedStr := ""
        parenthesesDepth := 0
        strLen := StrLen(currentValue)
        
        Loop, % strLen
        {
            i := A_Index
            char := SubStr(currentValue, i, 1)
            
            if (char = "(")
            {
                parenthesesDepth++
                processedStr .= char
            }
            else if (char = ")")
            {
                parenthesesDepth--
                if (parenthesesDepth < 0)
                {
                    LogError(ErrorMsg, controlName . " - Found a closed parenthesis without an opening parenthesis")
                    break
                }
                processedStr .= char
            }
            else if (char = " " && parenthesesDepth > 0)
            {
                processedStr .= altSpace
            }
            else
            {
                processedStr .= char
            }
        }
        
        if (parenthesesDepth > 0)
        {
            LogError(ErrorMsg, controlName . " - Unbalanced parentheses (missing closing parenthesis)")
        }
        
        processedValues[controlName] := processedStr
    }
    
    ;If there are any errors, show error message and abort
    ifErrorsDisplayAndAbort()
    
    ;Second Pass: Sort the tooth notations
    for controlName, processedStr in processedValues
    {
        ;Split by spaces
        tokens := StrSplit(processedStr, " ")
        
        ;Create 2D arrays for each tooth position
        primaryTeethArray := {}
        Loop, 20 {  ;20 primary teeth positions
            primaryTeethArray[A_Index] := []
        }
        
        permanentTeethArray := {}
        Loop, 32 {  ;32 permanent teeth positions
            permanentTeethArray[A_Index] := []
        }
        
        ;Array for unsortable tokens
        unsortableArray := []
        
        ;Process each token
        for _, token in tokens
        {
            if (token = "")
                continue
            
            ;Check primary teeth first
            if (RegExMatch(token, "^(" . primaryTeeth . ")", matchedTooth))
            {
                ;Convert primary tooth letter to position (a=1, b=2, etc.)
                toothLetter := SubStr(matchedTooth, 1, 1)
                toothLetter := Format("{:L}", toothLetter)  ;Convert to lowercase
                position := Asc(toothLetter) - 96  ;Convert a-t to 1-20
                
                if (position >= 1 && position <= 20)
                    primaryTeethArray[position].Push(token)
                else
                    unsortableArray.Push(token)
            }
            ;Check permanent teeth
            else if (RegExMatch(token, "^(" . permanentTeeth . ")", matchedTooth))
            {
                ;Extract the tooth number (digits at start)
                toothNumber := ""
                i := 1
                while (i <= StrLen(matchedTooth) && SubStr(matchedTooth, i, 1) >= "0" && SubStr(matchedTooth, i, 1) <= "9")
                {
                    toothNumber .= SubStr(matchedTooth, i, 1)
                    i++
                }
                
                position := toothNumber + 0  ;Convert to number
                
                if (position >= 1 && position <= 32)
                    permanentTeethArray[position].Push(token)
                else
                    unsortableArray.Push(token)
            }
            else
            {
                unsortableArray.Push(token)
            }
        }
        
        ;Combine all arrays in the correct order
        sortedTokens := []
        
        ;Add primary teeth first (a-t)
        Loop, 20 {
            for _, token in primaryTeethArray[A_Index]
                sortedTokens.Push(token)
        }
        
        ;Add permanent teeth next (1-32)
        Loop, 32 {
            for _, token in permanentTeethArray[A_Index]
                sortedTokens.Push(token)
        }
        
        ;Add all unsortable tokens in original order
        for _, token in unsortableArray
            sortedTokens.Push(token)
        
        ;Join back with spaces
        result := ""
        for index, token in sortedTokens
        {
            if (A_Index > 1)
                result .= " "
            result .= token
        }
        
        ;Convert alternative space characters back to normal spaces
        StringReplace, result, result, %altSpace%, %A_Space%, All
        
        ;Update processed value
        processedValues[controlName] := result
    }
    
    ;Update all controls with sorted values
    for controlName, sortedValue in processedValues
        GuiControl,, %controlName%, %sortedValue%
    
    return true
}

;Expands terms with multipliers in treatment planning form text boxes
;Example: (1 2 3)MA becomes 1MA 2MA 3MA
ExpandMultiplierTerms()
{
    global ErrorMsg, controlList
    
    ;Arrays to store original and processed values
    originalValues := Object()
    processedValues := Object()
    
    ;Process each control
    for index, controlName in controlList
    {
        ;Get current value
        GuiControlGet, currentValue,, %controlName%
        
        ;Store original value
        originalValues[controlName] := currentValue
        
        ;Process and store expanded value
        processedValues[controlName] := ExpandTermsInText(currentValue, controlName)
    }
    
    ;If there are any errors, show error message and abort
    ifErrorsDisplayAndAbort()
    
    ;If no errors, update all controls with expanded values
    for controlName, expandedValue in processedValues
        GuiControl,, %controlName%, %expandedValue%
    
    return true
}

;Helper function: Processes single text string, expanding terms with multipliers
ExpandTermsInText(inputStr, controlName)
{
    global ErrorMsg

    ;Alternate marker characters using rarely used Chr() codes
    altOpenTerm        := Chr(1)  ;Beginning of terms list
    altCloseTerm       := Chr(2)  ;End of terms list  
    altOpenNested      := Chr(3)  ;Beginning of nested parenthesis
    altCloseNested     := Chr(4)  ;End of nested parenthesis
    altOpenMultiplier  := Chr(6)  ;Beginning of multiplier (when "(" preceded by non-space)
    altCloseMultiplier := Chr(7)  ;End of multiplier
    altSpace           := Chr(5)  ;Replaces spaces inside terms/multiplier modes
    
    result := ""
    state := "outer"  ;Initial state
    
    ;First Pass: Convert inner spaces and change parentheses to alternate markers
    strLen := StrLen(inputStr)
    Loop, % strLen
    {
        i := A_Index
        char := SubStr(inputStr, i, 1)
        
        if (state = "outer")
        {
            if (char = "(")
            {
                ;If at beginning or preceded by whitespace, treat as terms list
                if (i = 1 or RegExMatch(SubStr(inputStr, i-1, 1), "^\s$"))
                {
                    result .= altOpenTerm
                    state := "terms"
                }
                else
                {
                    ;Otherwise treat as multiplier (or normal parenthesis) block
                    result .= altOpenMultiplier
                    state := "multiplier"
                }
            }
            else if (char = ")")
            {
                LogError(ErrorMsg, controlName . " - Found a closed parenthesis without an opening parenthesis")
                return inputStr
            }
            else
                result .= char
        }
        else if (state = "terms")
        {
            if (char = "(")
            {
                ;Enter nested mode (all spaces inside nested mode are converted)
                result .= altOpenNested
                state := "nested"
            }
            else if (char = ")")
            {
                result .= altCloseTerm
                state := "outer"
            }
            else if (char = " ")
                result .= altSpace
            else
                result .= char
        }
        else if (state = "nested")
        {
            if (char = "(")
            {
                LogError(ErrorMsg, controlName . " - Only one level of nested parenthesis is allowed in the terms list")
                return inputStr
            }
            else if (char = ")")
            {
                result .= altCloseNested
                state := "terms"
            }
            else if (char = " ")
                result .= altSpace
            else
                result .= char
        }
        else if (state = "multiplier")
        {
            if (char = "(")
            {
                LogError(ErrorMsg, controlName . " - Nested parenthesis not allowed in the multiplier")
                return inputStr
            }
            else if (char = ")")
            {
                result .= altCloseMultiplier
                state := "outer"
            }
            else if (char = " ")
                result .= altSpace
            else
                result .= char
        }
    }
    
    if (state != "outer")
    {
        LogError(ErrorMsg, controlName . " - Unbalanced parentheses")
        return inputStr
    }
    
    ;Second Pass: Expand each terms list with its multiplier
    pos := 1
    while (true)
    {
        startPos := InStr(result, altOpenTerm, false, pos)
        if (!startPos)
            break
        endPos := InStr(result, altCloseTerm, false, startPos+1)
        
        ;Get terms inside alt markers
        termsContent := SubStr(result, startPos+1, endPos - startPos - 1)
        
        ;Extract multiplier: contiguous chars after altCloseTerm until literal space
        multiplier := ""
        multiplierStart := endPos + 1
        while (multiplierStart <= StrLen(result))
        {
            c := SubStr(result, multiplierStart, 1)
            if (c = " ")  ;Real space ends multiplier
                break
            multiplier .= c
            multiplierStart++
        }
        
        ;Split terms (delimited by altSpace)
        tokens := StrSplit(termsContent, altSpace)
        newStr := ""
        for index, token in tokens
        {
            if (token != "")
            {
                if (newStr != "")
                    newStr .= " "
                newStr .= token . multiplier
            }
        }
        
        ;Replace entire block with expanded version
        before := SubStr(result, 1, startPos - 1)
        after := SubStr(result, multiplierStart)
        result := before . newStr . after
        
        pos := startPos + StrLen(newStr)
    }
    
    ;Final Pass: Convert alternate markers back to normal chars
    StringReplace, result, result, %altOpenMultiplier%, (, All
    StringReplace, result, result, %altCloseMultiplier%, ), All
    StringReplace, result, result, %altOpenNested%, (, All
    StringReplace, result, result, %altCloseNested%, ), All
    StringReplace, result, result, %altSpace%, %A_Space%, All
    
    return result
} 

TreatmentPlanningButtonOK:
; Check if any Procedure Info or Group Note windows are open and if so, prompts the user to save and close them
if WinExist("Procedure Info") || WinExist("Group Note")
{
	LogError(ErrorMsg, "Please save and close all Procedure Info or Group Note windows before continuing")
	ifErrorsDisplayAndAbort()
}
BlockInput, MouseMove
BlockInput, On

ErrorMsg := ""
CoordMode, Mouse, Client
CoordMode, Pixel, Client
Gui, TreatmentPlanning:Submit, NoHide

; Automatically expand any terms with multipliers
ExpandMultiplierTerms()

; Update the GUI with the expanded terms
Gui, TreatmentPlanning:Submit, NoHide

; Initialize the teeth status arrays to false
InitializeTeethStatusArrays()

; Object arrays for storing existing and treatment planned conditions/treatments
ExistMissing := Object()
ExistUnerupted := Object()
ExistErupted := Object()
ExistResto := Object()
ExistSealants := Object()
ExistCeramicCrowns := Object()
ExistPFMCrowns := Object()
ExistGoldCrowns := Object()
ExistSSCPrim := Object()
ExistSSCPerm := Object()
ExistPFMPontics := Object()
ExistGoldPontics := Object()
ExistCeramicPontics := Object()
ExistPFMAbutments := Object()
ExistGoldAbutments := Object()
ExistCeramicAbutments := Object()
ExistVeneers := Object()
ExistInlays := Object()
ExistOnlays := Object()
ExistImplants := Object()
ExistImplantRetainers := Object()
ExistImplantPontics := Object()
ExistImplantCrowns := Object()
ExistEndosMolar := Object()
ExistEndosPremolar := Object()
ExistEndosAnterior := Object()
ExistPostCore := Object()
ExistMaxFlexPartial := Object()
ExistMandFlexPartial := Object()
ExistMaxAcrylicPartial := Object()
ExistMandAcrylicPartial := Object()
ExistMaxMetalPartial := Object()
ExistMandMetalPartial := Object()
ExistMaxInterimPartial := Object()
ExistMandInterimPartial := Object()
TPExtSimp := Object()
TPExtSurg := Object()
TPResto := Object()
TPSealants := Object()
TPCrowns := Object()
TPCores := Object()
TPAbutments := Object()
TPPontics := Object()
TPSSCPrim := Object()
TPSSCPerm := Object()
TPVeneers := Object()
TPInlays := Object()
TPOnlays := Object()
TPImplants := Object()
TPImplantStockAbutments := Object()
TPImplantCustomAbutments := Object()
TPImplantCrowns := Object()
TPImplantRetainers := Object()
TPImplantPontics := Object()
TPBoneGraftDuringExtraction := Object()
TPBoneGraftDuringImplant := Object()
TPMembraneDuringExtraction := Object()
TPMembraneDuringImplant := Object()
TPImplantProvisionals := Object()
TPImplantSurgicalGuide := Object()
TPEndosMolar := Object()
TPEndosPremolar := Object()
TPEndosAnterior := Object()
TPPostCore := Object()
TPDirectPulpCaps := Object()
TPIndirectPulpCaps := Object()
TPMaxFlexPartial := Object()
TPMandFlexPartial := Object()
TPMaxAcrylicPartial := Object()
TPMandAcrylicPartial := Object()
TPMaxMetalPartial := Object()
TPMandMetalPartial := Object()
TPMaxInterimPartial := Object()
TPMandInterimPartial := Object()
TPMaxEssixInterimPartial := Object()
TPMandEssixInterimPartial := Object()
TPNitrous := 0
TPHalcion := 0
TPRetainers := Object()
RefExt := Object()
RefEndosMolar := Object()
RefEndosPremolar := Object()
RefEndosAnterior := Object()
RefRestos := Object()
RefPostCore := Object()
RefImplants := Object()
RefMaxFlexPartial := Object()
RefMandFlexPartial := Object()
RefMaxAcrylicPartial := Object()
RefMandAcrylicPartial := Object()
RefMaxMetalPartial := Object()
RefMandMetalPartial := Object()
RefMaxInterimPartial := Object()
RefMandInterimPartial := Object()
; closePremolarsSpaces := false ;DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE

;Parse through Missing
Loop, Parse, ExistingMissing, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		; MISSING
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")$", missing))
		{
			ExistMissing.Insert(missingToothnum)
			flagMissing(missingToothnum)
		}
	
		/* DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
		; UNERUPTED
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentTeeth . ")(?:-|u)$", unerupted))
		{
			ExistUnerupted.Insert(uneruptedToothnum)
			flagUnerupted(uneruptedToothnum)
		}
	
		; IMPACTED
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentTeeth . ")i$", impacted))
		{
			ExistUnerupted.Insert(impactedToothnum)
			flagUnerupted(impactedToothnum)
	
			if (isPermanentPremolar(impactedToothnum) OR isPermanentAnterior(impactedToothnum))
			{
				ExistMissing.Insert(primaryPredecessor(impactedToothnum))
				flagMissing(primaryPredecessor(impactedToothnum))
			}
		}
	
		/* DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
		; ERUPTED
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentTeeth . ")\+$", erupted))
			ExistErupted.Insert(eruptedToothnum)
		*/
	
		; INVALID
		else
			LogError(ErrorMsg, "Existing Missing - " . A_LoopField . " is not a valid tooth number")
	}
	
	; Add premolars to ExistMissing if checkbox is checked
	if (PremolarsExtDueToOrtho)
	{
		ExistMissing.Insert(5)
		flagMissing(5)
		ExistMissing.Insert(12)
		flagMissing(12)
		ExistMissing.Insert(21)
		flagMissing(21)
		ExistMissing.Insert(28)
		flagMissing(28)
		;closePremolarsSpaces := true ;DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
	}
	
	;Parse through Existing Restorations
	Loop, Parse, ExistingRestorationsAndSealants, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		; SEALANTS
		if isTooth(A_Loopfield)
			ExistSealants.Insert(A_LoopField)
		
		; RESTORATIONS
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . posteriorTeeth . ")(?P<Surfaces>" . posteriorSurfacesV . "{0,6})(?P<Amalgam>a)?$", resto) OR RegExMatch(A_LoopField, "^(?P<Toothnum>" . anteriorTeeth . ")(?P<Surfaces>" . anteriorSurfaces . "{0,6})(?P<Amalgam>a)?$", resto))
		{
			; Sort and split non-adjacent surfaces
			restoSurfacesSortedAndSplit := sortAndSplitNonAdjacentSurfaces(restoSurfaces)
	
			; If there are no surfaces, add to error message
			if (restoSurfacesSortedAndSplit.Length() = 0)
				LogError(ErrorMsg, "Existing Restorations - " . A_LoopField . " is not a valid restoration")
			else
			{
				for index, surfaces in restoSurfacesSortedAndSplit
					ExistResto.Push(Resto(restoToothnum, surfaces, "resto", restoAmalgam = "a" ? "a" : "c",, true))
			}
		}
	
		; CHARTING OTHER EXISTING RESTORATIONS
		else if RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")(?P<Modifier>s|c|p|g|e|r|-)$", otherExisting) ; DISABLED UNERUPTED, ERUPTED,AND IMPACTED MODIFIERSFOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
		{
			; SSC
			if (otherExistingModifier = "s")
				isPrimary(otherExistingToothnum) ? ExistSSCPrim.Insert(otherExistingToothnum) : ExistSSCPerm.Insert(otherExistingToothnum)
			
			; CROWN
			else if (otherExistingModifier = "c")
				ExistCeramicCrowns.Insert(otherExistingToothnum)
			else if (otherExistingModifier = "p")
				ExistPFMCrowns.Insert(otherExistingToothnum)
			else if (otherExistingModifier = "g")
				ExistGoldCrowns.Insert(otherExistingToothnum)
			
			; ENDO
			else if (otherExistingModifier = "e" OR otherExistingModifier = "r")
			{
				if isPrimary(otherExistingToothnum)
					LogError(ErrorMsg, "Existing Restorations - " . A_LoopField . " cannot chart endos on primary teeth")
				else if isPermanentMolar(otherExistingToothnum)
					ExistEndosMolar.Insert(otherExistingToothnum)
				else if isPermanentPremolar(otherExistingToothnum)
					ExistEndosPremolar.Insert(otherExistingToothnum)
				else
					ExistEndosAnterior.Insert(otherExistingToothnum)
			}
			
			; MISSING   
			else if (otherExistingModifier = "-")
			{
				ExistMissing.Insert(otherExistingToothnum)
				flagMissing(otherExistingToothnum)
			}
	
			/* DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
			; UNERUPTED
			else if (otherExistingModifier = "u") 
			{
				ExistUnerupted.Insert(otherExistingToothnum)
				flagUnerupted(otherExistingToothnum)
			}
	
			; IMPACTED
			else if (otherExistingModifier = "i")
			{
				ExistUnerupted.Insert(otherExistingToothnum)
				flagUnerupted(otherExistingToothnum)
				
				if (isPermanentPremolar(otherExistingToothnum) OR isPermanentAnterior(otherExistingToothnum))
					ExistMissing.Insert(primaryPredecessor(otherExistingToothnum))
					flagMissing(primaryPredecessor(otherExistingToothnum))
			}
	
			; ERUPTED
			else if (otherExistingModifier = "+")
				ExistErupted.Insert(otherExistingToothnum)
			*/
		}
		
		; INVALID   
		else ;If input does not match regex, add to error message
			LogError(ErrorMsg, "Existing Restorations - " . A_LoopField . " is not a valid restoration")
	}
	
	;Parse through Existing Crowns and Bridges
	Loop, Parse, ExistingCrownsAndBridges, `n%A_Space%
	{  
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		; CROWNS
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")(?P<Type>[cpgs]?)$", crown))
		{
			; MATERIAL (Default to ceramic)
			if (crownType = "p")
				ExistPFMCrowns.Insert(crownToothnum)
			else if (crownType = "g")
				ExistGoldCrowns.Insert(crownToothnum)
			else if (crownType = "s")
				isPrimary(crownToothnum) ? ExistSSCPrim.Insert(crownToothnum) : ExistSSCPerm.Insert(crownToothnum)
			else
				ExistCeramicCrowns.Insert(crownToothnum)
		}
	
		; BRIDGES
		else if (RegExMatch(A_LoopField, bridgeRegex . crownAndBridgeMaterialRegex, bridge)) 
		{
			; Validates the bridge object
			bridgeResult := ValidateBridge(bridgeTeeth)
			if (bridgeResult.invalid)
				LogError(ErrorMsg, "Existing Crowns and Bridges - " . A_LoopField . " is incorrect bridge notation. " . bridgeResult.error)
			else
			{
				; MATERIAL (Default to ceramic)
				if (bridgeMaterial = "p")
				{
					for index, abutmentTooth in bridgeResult.abutments
						ExistPFMAbutments.Insert(abutmentTooth)
					for index, ponticTooth in bridgeResult.pontics
						ExistPFMPontics.Insert(ponticTooth)
				}
				else if (bridgeMaterial = "g")
				{
					for index, abutmentTooth in bridgeResult.abutments
						ExistGoldAbutments.Insert(abutmentTooth)
					for index, ponticTooth in bridgeResult.pontics
						ExistGoldPontics.Insert(ponticTooth)
				}
				else 
				{
					for index, abutmentTooth in bridgeResult.abutments
						ExistCeramicAbutments.Insert(abutmentTooth)
					for index, ponticTooth in bridgeResult.pontics
						ExistCeramicPontics.Insert(ponticTooth)
				}
			}
		} 
		
		; INVALID  
		else
			LogError(ErrorMsg, "Existing Crowns and Bridges - " . A_LoopField . " is invalid crown or bridge notation")
	}
	
	;Parse through Existing Veneers and Onlays
	Loop, Parse, ExistingVeneersAndOnlays, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		; VENEERS
		if isPermanent(A_LoopField)
			ExistVeneers.Push(Resto(A_LoopField,, "veneer", "c",, true))
		
		; ONLAYS/INLAYS
		else if RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentPosteriorTeeth . ")(?P<Surfaces>" . posteriorSurfaces . "{1,5})(?P<Material>[cg]?)$", onlay)
		{
			; Alphabetically sort surfaces
			onlaySurfacesSorted := sortSurfaces(onlaySurfaces)
	
			; Adds inlays or onlays to appropriate arrays, defaults to ceramic
			if isOnlayOrInlaySurfaces(onlaySurfacesSorted)
			{
				; If the surfaces are bo|dmo|do|lo|mo|o, consider it an inlay
				if isInlaySurfaces(onlaySurfacesSorted)
					ExistInlays.Push(Resto(onlayToothnum, onlaySurfacesSorted, "inlay", onlayMaterial = "" ? "c" : onlayMaterial,, true))
				else
					ExistOnlays.Push(Resto(onlayToothnum, onlaySurfacesSorted, "onlay", onlayMaterial = "" ? "c" : onlayMaterial,, true))
			}
	
			; INVALID (matched the regex, but did not match valid surfaces, like "mood" or "dd"
			else
				LogError(ErrorMsg, "Existing Veneers and Onlays - " . A_LoopField . " is not a valid inlay or onlay")
		}
	
		; INVALID
		else
			LogError(ErrorMsg, "Existing Veneers and Onlays - " . A_LoopField . " is not a valid veneer, inlay, or onlay.")
	}
	
	;Parse through Existing Implants
	Loop, Parse, ExistingImplants, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		; SINGLE IMPLANT
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentTeeth . ")i?$", implant))
		{
			; Add implant, mark tooth missing
			ExistImplants.Insert(implantToothnum) ; Add tooth to array
			ExistMissing.Insert(implantToothnum) ; Add as missing tooth
			flagMissing(implantToothnum)
	
			; Unless "i" modifier is present, signifying implant only, add crown
			if (!InStr(A_LoopField, "i"))
				ExistImplantCrowns.Insert(implantToothnum)
		}
	
		; IMPLANT BRIDGE
		else if (RegExMatch(A_LoopField, bridgeRegex . "$", implantBridge))
		{
			bridgeResult := ValidateBridge(implantBridgeTeeth)
			
			; INVALID (matched regex, but incrementing/decrementing is incorrect, no space between abutments, abutments jump more than 1 tooth (3-4,6 would be allowed signifiying premolar extraction), bridge crosses arch, or cantilever is 0 or 33)
			if (bridgeResult.invalid)
			{
				LogError(ErrorMsg, "Existing Implants - " . A_LoopField . " is incorrect bridge notation. " . bridgeResult.error)
				continue
			}
	
			; Adds each abutment tooth to the implants, retainers, and marks the tooth missing
			for index, abutmentTooth in bridgeResult.abutments
			{
				ExistImplants.Insert(abutmentTooth)
				ExistImplantRetainers.Insert(abutmentTooth)
				ExistMissing.Insert(abutmentTooth)
				flagMissing(abutmentTooth)
			}
	
			; Adds each pontic tooth to the implants and marks the tooth missing
			for index, ponticTooth in bridgeResult.pontics
			{
				ExistImplantPontics.Insert(ponticTooth)
				ExistMissing.Insert(ponticTooth)
				flagMissing(ponticTooth)
			}
		}
	
		; INVALID
		else
			LogError(ErrorMsg, "Existing Implants - " . A_LoopField . " is not a valid permanent tooth")
	}
	
	;Parse through Existing Endos
	Loop, Parse, ExistingEndos, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		; ENDO 
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentTeeth . ")(?P<Type>p?)$", endo))
		{
			; Adds to the appropriate array based on tooth type
			if isPermanentMolar(endoToothnum)
				ExistEndosMolar.Insert(endoToothnum)
			else if isPermanentPremolar(endoToothnum)
				ExistEndosPremolar.Insert(endoToothnum)
			else
				ExistEndosAnterior.Insert(endoToothnum)
	
			; POST/CORE
			if (endoType = "p")
				ExistPostCore.Insert(endoToothnum)
		}
		
		; INVALID
		else
			LogError(ErrorMsg, "Existing Endos - " . A_LoopField . " is not a valid tooth")
	}
	
	;Parse through Existing Partials
	Loop, Parse, ExistingPartials, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		partialMatch := A_LoopField
		
		; Check for material modifier at the end
		if (RegExMatch(partialMatch, "^(?P<Teeth>.+?)(?P<Material>[fmai])?$", partial))
		{
			; Initialize variables
			material := partialMaterial
			maxTeeth := []
			mandTeeth := []
	
			; Parse teeth numbers by splitting on commas
			Loop, Parse, partialTeeth, `,
			{
				; RANGE (e.g. 3-6)
				if (RegExMatch(A_LoopField, "^(?P<Start>" . permanentTeeth . ")-(?P<End>" . permanentTeeth . ")$", range))
					teethRange := GetTeethInRange(rangeStart, rangeEnd)
				
				; SINGLE TOOTH
				else if isPermanent(A_LoopField)
					teethRange := [A_LoopField]
				
				; INVALID
				else
				{
					LogError(ErrorMsg, "Existing Partials - Invalid tooth number or range in " . partialMatch . ": " . A_LoopField)
					continue
				}
				
				; Categorize teeth into maxillary or mandibular
				for index, tooth in teethRange
				{
					if isMaxillary(tooth)
						maxTeeth.Push(tooth)
					else
						mandTeeth.Push(tooth)
				}
			}
			
			; Add teeth to appropriate arrays based on material, default to acrylic
			if (material = "m")
				AssignPartial(ExistMaxMetalPartial, ExistMandMetalPartial, maxTeeth, mandTeeth, "metal", false)
			else if (material = "f")
				AssignPartial(ExistMaxFlexPartial, ExistMandFlexPartial, maxTeeth, mandTeeth, "flex", false)
			else if (material = "i")
				AssignPartial(ExistMaxInterimPartial, ExistMandInterimPartial, maxTeeth, mandTeeth, "interim", false)
			else
				AssignPartial(ExistMaxAcrylicPartial, ExistMandAcrylicPartial, maxTeeth, mandTeeth, "acrylic", false)
		}
		
		; INVALID   
		else
		{
			LogError(ErrorMsg, "Existing Partials - Invalid partial notation: " . A_LoopField)
			continue
		}
	}
	
	;Parse through TP Ext
	Loop, Parse, TreatmentPlannedExtractions, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
		
		; EXTRACTION
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")(?P<Type>r|s)?$", ext))
		{
			if (extType = "r" OR ReferExt)
			{
				RefExt.Insert(extToothnum)
				flagReferredExt(extToothnum)
			}
			else if (extType = "s")
			{
				TPExtSimp.Insert(extToothnum)
				flagSimpleExt(extToothnum)
			}
			else
			{
				TPExtSurg.Insert(extToothnum)
				flagSurgicalExt(extToothnum)
			}
		}
	
		; INVALID
		else
			LogError(ErrorMsg, "Treatment Planned Extractions - " . A_LoopField . " is not a valid tooth and/or extraction type")
	}
	
	;Parse through TP Restorations
	Loop, Parse, TreatmentPlannedRestorationsAndSealants, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
		
		; EXISTING CONDITIONS
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")e(?P<Modifier>s|c|p|g|e|r)?$", existing))
		{
			; EXISTING CROWNS (SSC, CERAMIC, PFM, GOLD)
			if (existingModifier = "s")
				isPrimary(existingToothnum) ? ExistSSCPrim.Insert(existingToothnum) : ExistSSCPerm.Insert(existingToothnum)
			else if (existingModifier = "c")
				ExistCeramicCrowns.Insert(existingToothnum)
			else if (existingModifier = "p")
				ExistPFMCrowns.Insert(existingToothnum)
			else if (existingModifier = "g")
				ExistGoldCrowns.Insert(existingToothnum)
			
			; EXISTING ENDOS
			else if (existingModifier = "e" OR existingModifier = "r")
			{
				if isPrimary(existingToothnum)
					LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . " cannot chart endos on primary teeth")
				else if isPermanentMolar(existingToothnum)
					ExistEndosMolar.Insert(existingToothnum)
				else if isPermanentPremolar(existingToothnum)
					ExistEndosPremolar.Insert(existingToothnum)
				else
					ExistEndosAnterior.Insert(existingToothnum)
			}
			
			; EXISTING SEALANTS
			else
				ExistSealants.Insert(existingToothnum)
		}
	
		; EXISTING RESTORATIONS
		else if RegExMatch(A_LoopField, "^(?P<Toothnum>" . posteriorTeeth . ")e(?P<Surfaces>" . posteriorSurfacesV . "{0,6})(?P<Amalgam>a)?$", existing) OR RegExMatch(A_LoopField, "^(?P<Toothnum>" . anteriorTeeth . ")e(?P<Surfaces>" . anteriorSurfaces . "{0,6})(?P<Amalgam>a)?$", existing)
		{ 
			restoSurfacesSortedAndSplit := sortAndSplitNonAdjacentSurfaces(existingSurfaces)
		
			if (restoSurfacesSortedAndSplit.Length() = 0)
				LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . " is not a valid restoration")
			else
			{
				for index, surfaces in restoSurfacesSortedAndSplit
					ExistResto.Push(Resto(existingToothnum, surfaces, "resto", existingAmalgam = "a" ? "a" : "c",, true))
			}
		}
	
		; EXISTING MISSING, UNERUPTED, ERUPTED, IMPACTED
		else if RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")(?P<Modifier>-)$", existing) ; DISABLED UNERUPTED, ERUPTED,AND IMPACTED MODIFIERSFOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
		{
			; MISSING
			if (existingModifier = "-")
			{
				ExistMissing.Insert(existingToothnum)
				flagMissing(existingToothnum)
			}
			
			/* DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
			; UNERUPTED
			else if (existingModifier = "u")
			{
				if isPrimary(existingToothnum)
					LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . ": can only mark unerupted on adult teeth")
				else
				{
					ExistUnerupted.Insert(existingToothnum)
					flagUnerupted(existingToothnum)
				}
			}
	
			; ERUPTED
			else if (existingModifier = "+")
			{
				if isPrimary(existingToothnum)
					LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . ": can only mark erupted on adult teeth") 
				else
					ExistErupted.Insert(existingToothnum)
			}
	
			; IMPACTED
			else if (existingModifier = "i")
			{
				if isPrimary(existingToothnum)
					LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . ": can only mark impacted on adult teeth")
				else
				{
					ExistUnerupted.Insert(existingToothnum)
					flagUnerupted(existingToothnum)
	
					if (isPermanentPremolar(existingToothnum) OR isPermanentAnterior(existingToothnum))
					{
						ExistMissing.Insert(primaryPredecessor(existingToothnum))
						flagMissing(primaryPredecessor(existingToothnum))
					}
				}
			}
			*/
		}
	
		; TREATMENT PLANNED AND REFERRED EXTRACTIONS AND ENDOS
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")(?P<Modifier>sx|xs|x|rx|xr|rr|re|e|r)$", other))
		{
			; TREATMENT PLANNED EXTRACTION
			if (otherModifier = "sx" OR otherModifier = "xs" OR otherModifier = "x")
			{
				TPExtSurg.Insert(otherToothnum)
				flagSurgicalExt(otherToothnum)
			}
			
			; REFER EXTRACTION
			else if (otherModifier = "rx" OR otherModifier = "xr")
			{
				RefExt.Insert(otherToothnum)
				flagReferredExt(otherToothnum)
			}
	
			; REFER ENDOS
			else if (otherModifier = "rr" OR otherModifier = "re")
			{
				if isPrimary(otherToothnum)
					LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . " cannot refer endos on primary teeth")
				else if isPermanentMolar(otherToothnum)
					RefEndosMolar.Insert(otherToothnum)
				else if isPermanentPremolar(otherToothnum)
					RefEndosPremolar.Insert(otherToothnum)
				else
					RefEndosAnterior.Insert(otherToothnum)
			}
			
			; TREATMENT PLANNED ENDOS
			else if (otherModifier = "e" OR otherModifier = "r")
			{
				if isPrimary(otherToothnum)
					LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . " cannot chart endos on primary teeth")
				else if isPermanentMolar(otherToothnum)
					TPEndosMolar.Insert(otherToothnum)
				else if isPermanentPremolar(otherToothnum)
					TPEndosPremolar.Insert(otherToothnum)
				else
					TPEndosAnterior.Insert(otherToothnum)
			}
		}
	
		; TREATMENT PLANNED SEALANTS  
		else if isTooth(A_LoopField)
			TPSealants.Insert(A_LoopField) ;Add tooth to array
		
		; TREATMENT PLANNED CROWNS
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . allTeeth . ")(?P<Material>s|c|p|g)(?P<Diagnosis>" . diagnoses . ")?$", crown))
			TPCrowns.Insert([crownToothnum, crownMaterial, crownDiagnosis ? crownDiagnosis : "CA"])
	
		; TREATMENT PLANNED RESTORATIONS
		else if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . posteriorTeeth . ")(?P<Surfaces>" . posteriorSurfacesV . "{0,6})(?P<Diagnosis>" . diagnoses . ")?$", resto) OR RegExMatch(A_LoopField, "^(?P<Toothnum>" . anteriorTeeth . ")(?P<Surfaces>" . anteriorSurfaces . "{0,6})(?P<Diagnosis>" . diagnoses . ")?$", resto))
		{
			restoSurfacesSortedAndSplit := sortAndSplitNonAdjacentSurfaces(restoSurfaces)
				
			if (restoSurfacesSortedAndSplit.Length() = 0)
				LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . " is not a valid restoration")
			else
			{
				for index, surfaces in restoSurfacesSortedAndSplit
					TPResto.Push(Resto(restoToothnum, surfaces, "resto", "c", restoDiagnosis ? restoDiagnosis : "CA"))
			}
	
		}
	
		; INVALID
		else
			LogError(ErrorMsg, "Treatment Planned Restorations - " . A_LoopField . " is not a valid restoration")
	}
	
	; Parse through Treatment Planned Crowns and Bridges
	{
		; VALIDATES PARENTHESES
		validation := ValidateParentheses(TreatmentPlannedCrownsAndBridges)
		if (validation.invalid)
			LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . validation.error)
		
		; PROCESSES TREATMENT PLANNED CROWNS AND BRIDGES
		else
		{
			; SPLITS INPUT INTO ARRAYS
			treatmentPlannedCrownsAndBridgesArray := SplitCrownInput(TreatmentPlannedCrownsAndBridges)
	
			; PARSES EACH ENTRY IN THE ARRAY
			for index, crownOrBridgeEntry in treatmentPlannedCrownsAndBridgesArray
			{
				crownToAdd := ""
				crownAndBridgeModifier := ""
				bridgeResult := Object()
				post := false
				core := true
				replacement := false
				dateOfExisting := ""
				material := ""
				diagnosisOfCrown := ""
				expandedDiagnosis := ""
				dateEstimatedBool := false
				hasErrors := false
	
				; TREATMENT PLANNED CORES
				if (RegExMatch(crownOrBridgeEntry, "^(?P<Toothnum>" . allTeeth . ")c$", coreOnly))
					TPCores.Insert(coreOnlyToothnum)
	
				; BRIDGE
				else if (RegExMatch(crownOrBridgeEntry, bridgeRegex . "(?P<Modifier>.*)$", bridge)) 
				{
					bridgeResult := ValidateBridge(bridgeTeeth)
					if (bridgeResult.invalid)
						LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . " is incorrect bridge notation. " . bridgeResult.error)
					crownAndBridgeModifier := bridgeModifier
					
				} 
	
				; CROWN
				else if (RegExMatch(crownOrBridgeEntry, "^(?P<Toothnum>" . allTeeth . ")(?P<Modifier>.*)$", crown))
				{
					crownToAdd := crownToothnum
					crownAndBridgeModifier := crownModifier
				}
	
				; INVALID
				else 
				{
					LogError(ErrorMsg, "Treatment Planned Crowns and Bridges- " . crownOrBridgeEntry . " has no valid tooth number or bridge range")
					continue
				}
	
				; MODIFIERS
				modifierPos := 1
				backupPos := 1
				while (modifierPos := RegExMatch(crownAndBridgeModifier, crownOrBridgeCombinedModifierPattern, modifierMatch, modifierPos))
				{
					; REPLACEMENT
					if (RegExMatch(modifierMatch, "^" . crownOrBridgeReplacementPattern . "$", rMatch)) 
					{
						if replacement
						{
							LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . " contains duplicate Replacement modifier.")
							hasErrors := true
							break
						}

						replacement := true
						dateString := rMatch2
						if (dateString != "")
						{
							; Convert date from either YYYY or YA (years ago) or MMDDYYYY to MMDDYYYY
							dateResult := ParseDate(dateString)
							if (dateResult.invalid)
							{
								LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . ": " . dateResult.error)
								hasErrors := true
								break
							}
							dateOfExisting := dateResult.date
							dateEstimatedBool := dateResult.estimatedBool
						}
					}
					
					; MATERIAL
					else if (RegExMatch(modifierMatch, "^" . crownOrBridgeMaterialPattern . "$", matMatch)) 
					{
						; Duplicate
						if (material != "")
						{
							LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . " contains duplicate Crown Material modifier.")
							hasErrors := true
							break
						}
	
						; Set material
						material := matMatch
					}
					
					; DIAGNOSIS
					else if (RegExMatch(modifierMatch, "^" . crownOrBridgeDiagnosisPattern . "$", diagMatch))
					{
						; Duplicate
						if (diagnosisOfCrown != "")
						{
							LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . " contains duplicate Diagnosis modifier.")
							hasErrors := true
							break
						}
	
						; Set diagnosis
						diagnosisOfCrown := diagMatch
					}
					
					; EXPANDED DIAGNOSIS
					else if (RegExMatch(modifierMatch, "^" . crownOrBridgeExpandedDiagnosisPattern . "$", expMatch))
					{
						if (expandedDiagnosis != "")
						{
							LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . " contains duplicate Expanded Diagnosis modifier.")
							hasErrors := true
							break
						}
						expandedDiagnosis := expMatch1
					}
	
					; POST OR NO CORE
					else if (RegExMatch(modifierMatch, "^" . crownOrBridgePostOrNoCoreModifier . "$", postOrNoCore))
					{
						; DISALLOW DUPLICATE POST/CORE MODIFIERS
						if (post || !core)
						{
							LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . " contains duplicate Post/Core modifier.")
							hasErrors := true
							break
						}
	
						; POST
						if (postOrNoCore = "p")
						{
							post := true
							core := false
						}
	
						; NO CORE
						else if (postOrNoCore = "n")
							core := false
					}
	
					; INVALID MODIFIER
					else
						LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - " . crownOrBridgeEntry . " has an invalid syntax of " . modifierMatch)
	
					; INCREMENT MODIFIER POSITION
					modifierPos += StrLen(modifierMatch)
					backupPos := modifierPos ;modifierPos gets reset when no more matches
				}
	
				; SKIP TO NEXT ENTRY IF ERRORS
				if (hasErrors)
					continue
	
				; CONFIRM END OF MODIFIER
				else if (backupPos <= StrLen(crownAndBridgeModifier)) 
				{
					remainingText := SubStr(crownAndBridgeModifier, backupPos)
					if !isWhitespace(remainingText)  ; If there's any non-whitespace remaining
					{
						LogError(ErrorMsg, "Treatment Planned Crowns and Bridges - Remaining portion that doesn't meet modifier syntax: " . remainingText)
						continue ;Skip to next crownOrBridgeEntry without adding this crown
					}
				}
	
				; ADD CROWN TO TPCrowns
				if isTooth(crownToAdd)
				{
					if (diagnosisOfCrown = "")
						diagnosisOfCrown := "CA"
	
					; DEFAULT MATERIAL FOR MOLARS IS ZIRCONIA, PRIMARY IS SSC, AND EMAX FOR OTHERS
					if (material = "")
					{
						if isPermanentMolar(crownToAdd)
							material := "z"
						else if isPrimary(crownToAdd)
							material := "s"
						else
							material := "e"
					}
	
					; DEFAULT CORE FOR SSC IS FALSE
					if (material = "s")
						core := false
	
					TPCrowns.Push([crownToAdd, material, core, post, replacement, dateOfExisting, diagnosisOfCrown, expandedDiagnosis, dateEstimatedBool])
				}
	
				; ADD BRIDGE TO TPAbutments and TPPontics
				else 
				{
					; DEFAULT CORE FOR BRIDGES IS FALSE
					core := false
					
					; DEFAULT MATERIAL FOR BRIDGES IS ZIRCONIA
					if (material = "")
						material := "z"
	
					; ADD ABUTMENTS
					for index, abutmentTooth in bridgeResult.abutments
						TPAbutments.Push([abutmentTooth, material, core, post, replacement, dateOfExisting, diagnosisOfCrown, expandedDiagnosis, dateEstimatedBool])
	
					; ADD PONTICS
					for index, ponticTooth in bridgeResult.pontics
						TPPontics.Push([ponticTooth, material, core, post, replacement, dateOfExisting, diagnosisOfCrown, expandedDiagnosis, dateEstimatedBool])
				}
			}
		}
	}
	
	;Parse through Treatment Planned Veneers and Onlays
	Loop, Parse, TreatmentPlannedVeneersAndOnlays, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
		
		; VENEER
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentAnteriorTeeth . ")(?P<Diagnosis>" . diagnoses . ")?$", veneer))
			TPVeneers.Push(Resto(veneerToothnum,, "veneer",, veneerDiagnosis ? veneerDiagnosis : ""))
		
		; ONLAY/INLAY
		else if RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentPosteriorTeeth . ")(?P<Surfaces>" . posteriorSurfacesV . "{1,6})(?P<Diagnosis>" . diagnoses . ")?$", onlay)
		{
			; SORT SURFACES
			onlaySurfacesSorted := sortSurfaces(onlaySurfaces)
	
			; VALIDATE SURFACES
			if isOnlayOrInlaySurfaces(onlaySurfacesSorted)
			{
				; Determine if inlay or onlay
				restoType := isInlaySurfaces(onlaySurfacesSorted) ? "inlay" : "onlay"
	
				; Set diagnosis
				diagnosisValue := onlayDiagnosis ? onlayDiagnosis : "CA"
				
				; Add to inlays or onlays
				if (restoType = "inlay")
					TPInlays.Push(Resto(onlayToothnum, onlaySurfacesSorted, restoType, "c", diagnosisValue))
				else
					TPOnlays.Push(Resto(onlayToothnum, onlaySurfacesSorted, restoType, "c", diagnosisValue))
			}
		}
		
		; INVALID
		else
			LogError(ErrorMsg, "Treatment Planned Veneers and Onlays - " . A_LoopField . " is not a valid veneer, inlay, or onlay.")
	}
	
	;Parse through Treatment Planned Implants
	Loop, Parse, TreatmentPlannedImplants, %A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
	
		; INITIALIZE VARIABLES
		implantNotation := A_LoopField
		singleTooth := false
		bridgeResult := Object()
		customAbutment := false
		boneGraftWithImplant := false
		membraneWithImplant := false
		implantCrownOnly := false
		extractionAndImmediate := false
		extractionAndGraft := false
		essix := false
		implantProvisional := false
		referImplant := false
		maxEssixTeeth := []
		mandEssixTeeth := []
	
		;IMPLANT BRIDGE 
		if (RegExMatch(implantNotation, bridgeRegex . "(?P<Modifiers>\D*$)", implantBridge))
		{
			bridgeResult := ValidateBridge(implantBridgeTeeth)
			if (bridgeResult.invalid)
			{
				LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " is incorrect bridge notation. " . bridgeResult.error)
				continue
			}
			; Set implantModifiers from bridge capture
			implantModifiers := implantBridgeModifiers
		}
	
		;IMPLANT SINGLE TOOTH
		else if (RegExMatch(implantNotation, "^(?P<Toothnum>" . permanentTeeth . ")(?P<Modifiers>\D*$)", implant))
			singleTooth := true
		else
		{
			LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " does not contain a valid tooth number notation for a single tooth or bridge")
			continue
		}
	
		; PROCESS TWO-LETTER MODIFIERS (XI - EXTRACTION AND IMMEDIATE)
		if (InStr(implantModifiers, "xi"))
		{
			; PROCESS AND CONSUME FIRST INSTANCE OF XI
			extractionAndImmediate := true
			implantModifiers := StrReplace(implantModifiers, "xi", "", , 1)
			
			; CHECK FOR DUPLICATE XI
			if (InStr(implantModifiers, "xi"))
			{
				LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " has duplicate modifier 'xi'")
				implantModifiers := StrReplace(implantModifiers, "xi", "") ;remove all instances of xi
			}
	
			; DISALLOW XI AND X
			if (extractionAndImmediate && InStr(implantModifiers, "x"))
				LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " cannot have both 'xi' and 'x' modifiers")
		}
		
		; PROCESS SINGLE-LETTER MODIFIERS
		Loop, Parse, implantModifiers
		{
			currentModifier := A_LoopField
			
			; CUSTOM ABUTMENT
			if (currentModifier = "c" && !customAbutment)
				customAbutment := true
			
			; BONE GRAFT WITH IMPLANT
			else if (currentModifier = "b" && !boneGraftWithImplant)
				boneGraftWithImplant := true
			
			; MEMBRANE WITH IMPLANT
			else if (currentModifier = "m" && !membraneWithImplant)
				membraneWithImplant := true
			
			; IMPLANT CROWN ONLY
			else if (currentModifier = "^" && !implantCrownOnly)
				implantCrownOnly := true
			
			; EXTRACTION AND GRAFT
			else if (currentModifier = "x" && !extractionAndGraft)
				extractionAndGraft := true
			
			; ESSIX 
			else if (currentModifier = "e" && !essix)
				essix := true
			
			; PROVISIONAL
			else if (currentModifier = "p" && !implantProvisional)
				implantProvisional := true
			
			; REFER
			else if (currentModifier = "r" && !referImplant)
				referImplant := true
			
			; INVALID
			else
			{
				; DUPLICATE
				if (HasVal(validImplantModifiers, currentModifier))
					LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " has duplicate modifier '" . currentModifier . "'")
				
				; INVALID
				else
					LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " has invalid modifier '" . currentModifier . "'")
			}
		}
	
		; DISALLOW EXTRACTION, GRAFTING, MEMBRANE, OR REFERAL WITH "IMPLANT CROWN ONLY"
		if (implantCrownOnly && (extractionAndImmediate || extractionAndGraft || boneGraftWithImplant || membraneWithImplant))
			LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " cannot have extraction, grafting, membrane, or referral modifiers with Implant Crown Only modifier '^'")
	
		    ; SET REFERRAL STATUS
    referImplant := referImplant || ReferImplants
	
		; DISALLOW BONE GRAFT, MEMBRANE, OR IMPLANT CROWN ONLY WITH REFERRAL
		if (referImplant && (boneGraftWithImplant || membraneWithImplant || implantCrownOnly))
			LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . " cannot have bone graft, membrane, or implant crown only modifiers when referring")
	
		; CREATE ARRAY OF TEETH THAT NEED IMPLANT ABUTMENTS/CROWNS
		implantTeeth := []
		if singleTooth
			implantTeeth.Push(implantToothnum)
		else
		{
			for index, abutmentTooth in bridgeResult.abutments
				implantTeeth.Push(abutmentTooth)
		}
	
		; PROCESS EACH IMPLANT TOOTH
		for index, tooth in implantTeeth
		{
			; UNLESS IMPLANT CROWN ONLY, ADD TO IMPLANT ARRAY OR REFERRAL ARRAY
			if (!implantCrownOnly)
			{
				if (referImplant)
					RefImplants.Insert(tooth)
				else
					TPImplants.Insert(tooth)
			}
	
			; ADD EXTRACTION AND GRAFT AND MEMBRANE (G&M FOR DELAYED ONLY)
			if (extractionAndGraft || extractionAndImmediate)
			{
				; REFER EXTRACTION IF REFERRING IMPLANT
				if (referImplant)
				{
					RefExt.Insert(tooth)
					flagReferredExt(tooth)
				}
				; ADD EXTRACTION AND GRAFT
				else
				{
					TPExtSurg.Insert(tooth)
					flagSurgicalExt(tooth)
					
					; ADD BONE GRAFT AND MEMBRANE IF EXTRACTION AND GRAFT
					if (extractionAndGraft)
					{
						TPBoneGraftDuringExtraction.Insert(tooth)
						TPMembraneDuringExtraction.Insert(tooth)
					}
				}
			}
	
			; CUSTOM ABUTMENT
			if customAbutment
				TPImplantCustomAbutments.Insert(tooth)
			
			; STOCK ABUTMENT
			else 
				TPImplantStockAbutments.Insert(tooth)
	
			; BONE GRAFT WITH IMPLANT
			if (boneGraftWithImplant || extractionAndImmediate)
				TPBoneGraftDuringImplant.Insert(tooth)
			
			; MEMBRANE WITH IMPLANT
			if membraneWithImplant
				TPMembraneDuringImplant.Insert(tooth)
	
			; ESSIX INTERIM
			if essix
			{
				if isMaxillary(tooth)
					maxEssixTeeth.Insert(tooth)
				else
					mandEssixTeeth.Insert(tooth)
			}
	
			; PROVISIONAL
			if implantProvisional
				TPImplantProvisionals.Insert(tooth)
	
			; SURGICAL GUIDE TOOTH NUMBER (WILL SORT INTO MAXILLARY AND MANDIBULAR AND DETERMINE HOW MANY GUIDES NEEDED LATER)
			if (!implantCrownOnly AND !referImplant)
				TPImplantSurgicalGuide.Insert(tooth)
	
			; BRIDGE ABUTMENT CROWN
			if bridgeResult.pontics.Length()
				TPImplantRetainers.Insert(tooth)
			
			; SINGLE IMPLANT CROWN
			else
				TPImplantCrowns.Insert(tooth)
		}
	
		; IF BRIDGE, ADD PONTICS AND ESSIX AND PROVISIONAL
		if bridgeResult.pontics.Length()
		{
			for index, ponticTooth in bridgeResult.pontics
			{
				; PONTIC
				TPImplantPontics.Insert(ponticTooth)
				
				; ESSIX INTERIM
				if essix
				{   
					if isMaxillary(ponticTooth)
						maxEssixTeeth.Insert(ponticTooth)
					else
						mandEssixTeeth.Insert(ponticTooth)
				}
	
				; PROVISIONAL
				if implantProvisional
					LogError(ErrorMsg, "Treatment Planned Implants - " . implantNotation . ": Cannot provisionalize implant bridges")
			}
		}
		
		; ASSIGN ESSIX INTERIM TEETH TO PARTIALS
		AssignPartial(TPMaxEssixInterimPartial, TPMandEssixInterimPartial, maxEssixTeeth, mandEssixTeeth, "essix", false)
	}
	
	;Parse through Treatment Planned Endos
	Loop, Parse, TreatmentPlannedEndos, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
		
		; ENDO
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentTeeth . ")(?P<Modifiers>[rpc]*)$", endo))
		{
			modifierCounts := {p: 0, r: 0, c: 0}
			hasDuplicates := false
			duplicateModifiers := ""
			
			; COUNT MODIFIERS
			Loop, Parse, endoModifiers
			{
				modifierCounts[A_LoopField]++
				if (modifierCounts[A_LoopField] > 1)
				{
					hasDuplicates := true
					if (duplicateModifiers != "")
						duplicateModifiers .= ", "
					duplicateModifiers .= A_LoopField
				}
			}
			
			; DUPLICATE MODIFIERS
			if (hasDuplicates)
			{
				ErrorMsg .= "Treatment Planned Endos - " . A_LoopField . " has duplicate modifier(s): " . duplicateModifiers . "`n"
				continue
			}
	
			; DETERMINE MODIFIERS
			hasPost := modifierCounts.p > 0
			hasRefer := modifierCounts.r > 0 || ReferEndos
			hasComposite:= modifierCounts.c > 0
			
			; POST/CORE
			if (hasPost)
			{
				; COMPOSITE INVALID WITH POST/CORE
				if (hasComposite)
					ErrorMsg .= "Treatment Planned Endos - " . A_LoopField . " cannot have composite modifier with post/core.`n"
				else
				{
					; REFER
					if (hasRefer)
					{
						if isPermanentMolar(endoToothnum)
							RefEndosMolar.Insert(endoToothnum)
						else if isPermanentPremolar(endoToothnum)
							RefEndosPremolar.Insert(endoToothnum)
						else
							RefEndosAnterior.Insert(endoToothnum)
						RefPostCore.Insert(endoToothnum)
					}
	
					; TREATMENT PLANNED
					else
					{
						if isPermanentMolar(endoToothnum)
							TPEndosMolar.Insert(endoToothnum)
						else if isPermanentPremolar(endoToothnum)
							TPEndosPremolar.Insert(endoToothnum)
						else
							TPEndosAnterior.Insert(endoToothnum)
						TPPostCore.Insert(endoToothnum)
					}
				}
			}
	
			; NO POST/CORE
			else
			{
				; COMPOSITE INVALID WITH REFERRAL
				if (hasComposite && !hasRefer)
					ErrorMsg .= "Treatment Planned Endos - " . A_LoopField . " composite modifier can only be used with referred endos.`n"
				
				; REFER
				else if (hasRefer)
				{
					if isPermanentMolar(endoToothnum)
					{
						RefEndosMolar.Insert(endoToothnum)
						if (hasComposite)
							RefRestos.Push(Resto(endoToothnum, "o", "resto", "c", "ET"))
					}
					else if isPermanentPremolar(endoToothnum)
					{
						RefEndosPremolar.Insert(endoToothnum)
						if (hasComposite)
							RefRestos.Push(Resto(endoToothnum, "o", "resto", "c", "ET"))
					}
					else
					{
						RefEndosAnterior.Insert(endoToothnum)
						if (hasComposite)
							RefRestos.Push(Resto(endoToothnum, "l", "resto", "c", "ET"))
					}
				}
	
				; TREATMENT PLANNED
				else
				{
					if isPermanentMolar(endoToothnum)
						TPEndosMolar.Insert(endoToothnum)
					else if isPermanentPremolar(endoToothnum)
						TPEndosPremolar.Insert(endoToothnum)
					else
						TPEndosAnterior.Insert(endoToothnum)
				}
			}
		}
	
		; INVALID
		else
			ErrorMsg .= "Treatment Planned Endos - " . A_LoopField . " is not a valid endo.`n"
	}
	
	;Parse through Treatment Planned Pulp Caps
	Loop, Parse, TreatmentPlannedPulpCaps, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
		
		; PULP CAP
		if (RegExMatch(A_LoopField, "^(?P<Toothnum>" . permanentTeeth . ")(?P<Type>[di])$", pulpCap))
		{
			if (pulpCapType = "d")
				TPDirectPulpCaps.Insert(pulpCapToothnum)
			else if (pulpCapType = "i")
				TPIndirectPulpCaps.Insert(pulpCapToothnum)
		}
	
		; INVALID
		else
			ErrorMsg .= "Treatment Planned Pulp Caps - " . A_LoopField . " is not a valid pulp cap.`n"
	}
	
	;Parse through Treatment Planned Partials
	Loop, Parse, TreatmentPlannedPartials, `n%A_Space%
	{
		; WHITE SPACE
		if isWhitespace(A_LoopField)
			continue
		
		partialMatch := A_LoopField
		isReferred := ReferPartials  ; Start with the checkbox value
		
		; MODIFIERS
		if (RegExMatch(partialMatch, "^(?P<Teeth>.+?)(?P<Modifiers>r[fmai]|[fmai]r|[fmai]|e)?$", partial))
		{
			modifiers := partialModifiers
			
			; Check if r is present
			if (InStr(modifiers, "r"))
			{
				isReferred := true
	
				; Remove the r, leaving only material modifier
				modifiers := StrReplace(modifiers, "r")
			}
			
			; At this point modifiers should be exactly one character for material
			material := modifiers
		}
	
		; INVALID
		else
		{
			LogError(ErrorMsg, "Treatment Planned Partials - Invalid partial notation: " . A_LoopField)
			continue
		}
		
		; PARSE TEETH
		maxTeeth := []
		mandTeeth := []
		Loop, Parse, partialTeeth, `,
		{
			; RANGE (e.g. 3-6)
			if (RegExMatch(A_LoopField, "^(?P<Start>" . permanentTeeth . ")-(?P<End>" . permanentTeeth . ")$", range))
				teethRange := GetTeethInRange(rangeStart, rangeEnd)
			
			; SINGLE TOOTH
			else if isPermanent(A_LoopField)
				teethRange := [A_LoopField]
			
			; INVALID
			else
			{
				LogError(ErrorMsg, "Treatment Planned Partials - Invalid tooth number or range: " . A_LoopField)
				continue
			}
	
			; SORT TEETH INTO MAXILLARY AND MANDIBULAR
			for index, tooth in teethRange
			{
				if isMaxillary(tooth)
					maxTeeth.Push(tooth)
				else
					mandTeeth.Push(tooth)
			}
		}
		
		; ADD TEETH TO APPROPRIATE PARTIAL ARRAYS
		if (isReferred)
		{
			if (material = "m")
				AssignPartial(RefMaxMetalPartial, RefMandMetalPartial, maxTeeth, mandTeeth, "metal", true)
			else if (material = "a")
				AssignPartial(RefMaxAcrylicPartial, RefMandAcrylicPartial, maxTeeth, mandTeeth, "acrylic", true)
			else if (material = "i")
				AssignPartial(RefMaxInterimPartial, RefMandInterimPartial, maxTeeth, mandTeeth, "interim", true)
			else
				AssignPartial(RefMaxFlexPartial, RefMandFlexPartial, maxTeeth, mandTeeth, "flex", true)
		}
		else
		{
			if (material = "m")
				AssignPartial(TPMaxMetalPartial, TPMandMetalPartial, maxTeeth, mandTeeth, "metal", false)
			else if (material = "a")
				AssignPartial(TPMaxAcrylicPartial, TPMandAcrylicPartial, maxTeeth, mandTeeth, "acrylic", false)
			else if (material = "i")
				AssignPartial(TPMaxInterimPartial, TPMandInterimPartial, maxTeeth, mandTeeth, "interim", false)
			else if (material = "e")
				AssignPartial(TPMaxEssixInterimPartial, TPMandEssixInterimPartial, maxTeeth, mandTeeth, "essix", false)
			else
				AssignPartial(TPMaxFlexPartial, TPMandFlexPartial, maxTeeth, mandTeeth, "flex", false)
		}
	}
		
	;Error checking for SRP, Invisalign, Nitrous, and Halcion
	{
		;Make sure 1-3 teeth and 4+ teeth are not selected for same quadrant
		if (TreatmentPlannedSRP13UR AND TreatmentPlannedSRP4UR)
			LogError(ErrorMsg, "Treatment Planned SRP - UR Quadrant cannot be marked 1-3 teeth and 4+")
		if (TreatmentPlannedSRP13UL AND TreatmentPlannedSRP4UL)
			LogError(ErrorMsg, "Treatment Planned SRP - UL Quadrant cannot be marked 1-3 teeth and 4+")
		if (TreatmentPlannedSRP13LR AND TreatmentPlannedSRP4LR)
			LogError(ErrorMsg, "Treatment Planned SRP - LR Quadrant cannot be marked 1-3 teeth and 4+")
		if (TreatmentPlannedSRP13LL AND TreatmentPlannedSRP4LL)
			LogError(ErrorMsg, "Treatment Planned SRP - LL Quadrant cannot be marked 1-3 teeth and 4+")
	
		;Make sure both Invisalign options are not selected
		if (InvisalignComp AND InvisalignLimited)
			LogError(ErrorMsg, "Treatment Planned Invisalign - Cannot select both Comprehensive and Limited")
	
		;Parse Nitrous times
		if (NitrousTimes != "")
		{
			if NitrousTimes is not number
				LogError(ErrorMsg, "Nitrous x times must be a number")
			else
				TPNitrous := NitrousTimes
		}
	
		;Parse Halcion times
		if (HalcionTimes != "")
		{
			if HalcionTimes is not number
				LogError(ErrorMsg, "Halcion x times must be a number")
			else
				TPHalcion := HalcionTimes
		}
	}
	
	;Parse Retainers
	{
		if (Retainers1)
			TPRetainers.Push("D87000")
		if (Retainers2)
			TPRetainers.Push("D87001")
		if (Retainers3)
			TPRetainers.Push("D87002")
		if (Retainers4)
			TPRetainers.Push("D87003")
		if (RetainersU)
			TPRetainers.Push("D8703")
		if (RetainersL)
			TPRetainers.Push("D8704")
		if (TPRetainers.Length() > 0)
			TPRetainers.Push("Deliv Ret") ;Add Deliv Ret code if any retainers are planned
	}
	
	; Display any errors and abort if there are any
	ifErrorsDisplayAndAbort()
	
	; Save specific variables to new variables
	ExistUpperDenture := ExistingUpperDenture
	ExistLowerDenture := ExistingLowerDenture
	ExistFixedRetainer89 := FixedRetainer89
	ExistFixedRetainer710 := FixedRetainer710
	ExistFixedRetainer2227 := FixedRetainer2227
	TPUpperDenture := TreatmentPlannedUpperDenture && !ReferDentures
	TPLowerDenture := TreatmentPlannedLowerDenture && !ReferDentures
	RefUpperDenture := TreatmentPlannedUpperDenture && ReferDentures
	RefLowerDenture := TreatmentPlannedLowerDenture && ReferDentures
	TPFullOccGuardUpper := TreatmentPlannedFullOcclusalGuardUpper
	TPFullOccGuardLower := TreatmentPlannedFullOcclusalGuardLower
	TPPartialOccGuardUpper := TreatmentPlannedPartialOcclusalGuardUpper
	TPPartialOccGuardLower := TreatmentPlannedPartialOcclusalGuardLower
	TPSRP13UR := TreatmentPlannedSRP13UR
	TPSRP13UL := TreatmentPlannedSRP13UL
	TPSRP13LR := TreatmentPlannedSRP13LR
	TPSRP13LL := TreatmentPlannedSRP13LL
	TPSRP4UR := TreatmentPlannedSRP4UR
	TPSRP4UL := TreatmentPlannedSRP4UL
	TPSRP4LR := TreatmentPlannedSRP4LR
	TPSRP4LL := TreatmentPlannedSRP4LL
	popupToAdd := Popup
	
	Save()
	Gui, TreatmentPlanning:Hide ; Hide the GUI after saving the values
	
	; If Open Dental not active, activate
	IfWinNotActive, Open Dental {
	{
		WinActivate, Open Dental {
		WaitWin("Open Dental {", 2)
	}
	
	SetODMode("Chart")
	Sleep, 500
	
	ConfirmOpenDentalPatientChart(currentPatient)
	
	GetState()
	
	/* DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
	SendInput {F1} ;deselects any teeth
	;Marks Existing Unerupted
	if ExistUnerupted.Length() ;if there are entries in the arrays, process
	{
		SelectTeeth(ExistUnerupted)
		SetSelectedTeeth("primary")
	}
	
	;Marks Existing Erupted
	if ExistErupted.Length() ;if there are entries in the arrays, process
	{
		SelectTeeth(ExistErupted)
		ClearMovements() ;Clears movements of the primary teeth
		SetSelectedTeeth("permanent")
	}
	*/
	
	; Deselects any teeth
	DeselectTeeth()
	
	;Changes chart to add existing procedures
	SetChartTab("Treatment")
	if (ExistMissing.Length() ||ExistResto.Length() || ExistSealants.Length() || ExistPostCore.Length() || ExistEndosMolar.Length() || ExistEndosPremolar.Length() || ExistEndosAnterior.Length() || ExistCeramicCrowns.Length() || ExistPFMCrowns.Length() || ExistGoldCrowns.Length() || ExistSSCPrim.Length() || ExistSSCPerm.Length() || ExistCeramicAbutments.Length() || ExistPFMAbutments.Length() || ExistGoldAbutments.Length() || ExistCeramicPontics.Length() || ExistPFMPontics.Length() || ExistGoldPontics.Length() || ExistVeneers.Length() || ExistInlays.Length() || ExistOnlays.Length() || ExistImplants.Length() || ExistImplantCrowns.Length() || ExistingUpperDenture || ExistingLowerDenture || ExistMaxFlexPartial.Length() || ExistMandFlexPartial.Length() || ExistMaxAcrylicPartial.Length() || ExistMandAcrylicPartial.Length() || ExistMaxMetalPartial.Length() || ExistMandMetalPartial.Length() || ExistMaxInterimPartial.Length() || ExistMandInterimPartial.Length())
	{
		SetTxMode("EO")
		
		;Marks existing missing
		AddCodeToTeeth(ExistMissing, "D7140", currentPatient)
	
		;Marks existing restos
		  AddRestosArray(ExistResto, currentPatient)
	
		;Marks existing sealants
		AddCodeToTeeth(ExistSealants, "D1351", currentPatient)
	
		;Marks existing crowns
		AddCodeToTeeth(ExistCeramicCrowns, "D2740", currentPatient)
		AddCodeToTeeth(ExistPFMCrowns, "D2750", currentPatient)
		AddCodeToTeeth(ExistGoldCrowns, "D2790", currentPatient)
	
		;Marks existing SSCs on primary teeth
		AddCodeToTeeth(ExistSSCPrim, "D2930", currentPatient)
		
		;Marks existing SSCs on permanent teeth
		AddCodeToTeeth(ExistSSCPerm, "D2931", currentPatient)
		
		;Marks existing ceramic abutments
		AddCodeToTeeth(ExistCeramicAbutments, "D6740", currentPatient)
		
		;Marks existing PFM abutments
		AddCodeToTeeth(ExistPFMAbutments, "D6750", currentPatient)
		
		;Marks existing gold abutments
		AddCodeToTeeth(ExistGoldAbutments, "D6790", currentPatient)
		
		;Marks existing ceramic pontics missing and then pontics
		AddCodeToTeeth(ExistCeramicPontics, "D7140", currentPatient)
		AddCodeToTeeth(ExistCeramicPontics, "D6245", currentPatient)
		
		;Marks existing PFM pontics
		AddCodeToTeeth(ExistPFMPontics, "D7140", currentPatient)
		AddCodeToTeeth(ExistPFMPontics, "D6240", currentPatient)
		
		;Marks existing gold pontics
		AddCodeToTeeth(ExistGoldPontics, "D7140", currentPatient)
		AddCodeToTeeth(ExistGoldPontics, "D6210", currentPatient)
	
		;Marks existing veneers
		AddRestosArray(ExistVeneers, currentPatient)
		
		;Marks existing onlays
		AddRestosArray(ExistOnlays, currentPatient)
	
		;Marks existing inlays
		AddRestosArray(ExistInlays, currentPatient)
	
		;Marks existing implant
		AddCodeToTeeth(ExistImplants, "D6010", currentPatient) ;Adds code for implants
		AddCodeToTeeth(ExistImplantCrowns, "D6058", currentPatient) ;Adds code for implant crowns
		AddCodeToTeeth(ExistImplantRetainers, "D6068", currentPatient) ;Adds code for implant bridge retainers
		AddCodeToTeeth(ExistImplantPontics, "D7140", currentPatient) ;Marks pontic space as missing
		AddCodeToTeeth(ExistImplantPontics, "D6245", currentPatient) ;Adds code for implant pontics
	
		;Marks existing post and cores
		AddCodeToTeeth(ExistPostCore, "D2954", currentPatient)
		
		; Add existing endos
		AddCodeToTeeth(ExistEndosMolar, "D3330", currentPatient)
		AddCodeToTeeth(ExistEndosPremolar, "D3320", currentPatient)
		AddCodeToTeeth(ExistEndosAnterior, "D3310", currentPatient)
	
		;Marks existing max dentures
		if (ExistUpperDenture) ;if there were entries in the box, process
			AddCodeDetailed("D5110",,,,, "U",,,,, currentPatient)
		;Marks existing mand dentures
		if (ExistLowerDenture) ;if there were entries in the box, process
			AddCodeDetailed("D5120",,,,, "L",,,,, currentPatient)
	
		;Add existing partials
		; Metal partials
		if (ExistMaxMetalPartial.Length())
			AddCodeDetailed("D5213",,,,,,,,,, currentPatient, ExistMaxMetalPartial)
		if (ExistMandMetalPartial.Length())
			AddCodeDetailed("D5214",,,,,,,,,, currentPatient, ExistMandMetalPartial)
	
		; Acrylic partials
		if (ExistMaxAcrylicPartial.Length())
			AddCodeDetailed("D5211",,,,,,,,,, currentPatient, ExistMaxAcrylicPartial)
		if (ExistMandAcrylicPartial.Length())
			AddCodeDetailed("D5212",,,,,,,,,, currentPatient, ExistMandAcrylicPartial)
	
		; Flexible partials
		if (ExistMaxFlexPartial.Length())
			AddCodeDetailed("D5225",,,,,,,,,, currentPatient, ExistMaxFlexPartial)
		if (ExistMandFlexPartial.Length())
			AddCodeDetailed("D5226",,,,,,,,,, currentPatient, ExistMandFlexPartial)
	
		; Interim partials
		if (ExistMaxInterimPartial.Length())
			AddCodeDetailed("D5820",,,,,,,,,, currentPatient, ExistMaxInterimPartial)
		if (ExistMandInterimPartial.Length())
			AddCodeDetailed("D5821",,,,,,,,,, currentPatient, ExistMandInterimPartial)
	}
	
	;Start Treatment Planned items
	;Check if any TP items exist
	if (TPExtSimp.Length() || TPExtSurg.Length() || TPResto.Length() || TPSealants.Length() || TPCrowns.Length() || TPCores.Length() || TPSSCPrim.Length() || TPSSCPerm.Length() || TPAbutments.Length() || TPPontics.Length() || TPVeneers.Length() || TPInlays.Length() || TPOnlays.Length() || TPImplants.Length() || TPImplantStockAbutments.Length() || TPImplantCustomAbutments.Length() || TPImplantCrowns.Length() || TPImplantRetainers.Length() || TPImplantPontics.Length() || TPBoneGraftDuringExtraction.Length() || TPBoneGraftDuringImplant.Length() || TPMembraneDuringExtraction.Length() || TPMembraneDuringImplant.Length() || TPImplantProvisionals.Length() || TPImplantSurgicalGuide.Length() || TPEndosMolar.Length() || TPEndosPremolar.Length() || TPEndosAnterior.Length() || TPPostCore.Length() || TPDirectPulpCaps.Length() || TPIndirectPulpCaps.Length() || TPMaxFlexPartial.Length() || TPMandFlexPartial.Length() || TPMaxAcrylicPartial.Length() || TPMandAcrylicPartial.Length() || TPMaxMetalPartial.Length() || TPMandMetalPartial.Length() || TPMaxInterimPartial.Length() || TPMandInterimPartial.Length() || TPMaxEssixInterimPartial.Length() || TPMandEssixInterimPartial.Length() || TPUpperDenture || TPLowerDenture || TPFullOccGuardUpper || TPFullOccGuardLower || TPPartialOccGuardUpper || TPPartialOccGuardLower || TPSRP13UR || TPSRP13UL || TPSRP13LR || TPSRP13LL || TPSRP4UR || TPSRP4UL || TPSRP4LR || TPSRP4LL || InvisalignComp || InvisalignLimited || TPNitrous > 0 || TPHalcion > 0 || TPRetainers.Length())
	{
		SetTxMode("TP")
	
		; Add treatment planned partials
		; Acrylic partials
		if (TPMaxAcrylicPartial.Length())
			AddCodeDetailed("D5211",,,,,,,,,, currentPatient, TPMaxAcrylicPartial)
		if (TPMandAcrylicPartial.Length())
			AddCodeDetailed("D5212",,,,,,,,,, currentPatient, TPMandAcrylicPartial)
	
		; Flexible partials
		if (TPMaxFlexPartial.Length())
			AddCodeDetailed("D5225",,,,,,,,,, currentPatient, TPMaxFlexPartial)
		if (TPMandFlexPartial.Length())
			AddCodeDetailed("D5226",,,,,,,,,, currentPatient, TPMandFlexPartial)
	
		; Metal partials
		if (TPMaxMetalPartial.Length())
			AddCodeDetailed("D5213",,,,,,,,,, currentPatient, TPMaxMetalPartial)
		if (TPMandMetalPartial.Length())
			AddCodeDetailed("D5214",,,,,,,,,, currentPatient, TPMandMetalPartial)
	
		; Interim partials
		if (TPMaxInterimPartial.Length())
			AddCodeDetailed("D5820",,,,,,,,,, currentPatient, TPMaxInterimPartial)
		if (TPMandInterimPartial.Length())
			AddCodeDetailed("D5821",,,,,,,,,, currentPatient, TPMandInterimPartial)
	
		; Essix interim partials
		if (TPMaxEssixInterimPartial.Length())
			AddCodeDetailed("D9938",,,,,,,,,, currentPatient, TPMaxEssixInterimPartial)
		if (TPMandEssixInterimPartial.Length())
			AddCodeDetailed("D9938",,,,,,,,,, currentPatient, TPMandEssixInterimPartial)
		if (TPMaxEssixInterimPartial.Length() OR TPMandEssixInterimPartial.Length())
			AddCode("D9939", currentPatient)
	
		;Marks treatment planned simple extractions and adds PA xrays
		AddCodeToTeeth(TPExtSimp, "D7140", currentPatient)
		AddCodeToTeeth(TPExtSimp, "D0220X", currentPatient)
	
		;Marks treatment planned surgical extractions and adds PA xrays
		AddCodeToTeeth(TPExtSurg, "D7210", currentPatient)
		AddCodeToTeeth(TPExtSurg, "D0220X", currentPatient)
	
		;Marks treatment planned restos
		AddRestosArray(TPResto, currentPatient)
	
		;Marks Treatment Planned sealants
		AddCodeToTeeth(TPSealants, "D1351", currentPatient)
	
		;Marks treatment planned crowns
		for index, crown in TPCrowns
			AddCrown(crown[1], crown[2], crown[3], crown[4], crown[5], crown[6], crown[7], crown[8], crown[9],, currentPatient)
	
		;Marks treatment planned abutments
		for index, abutment in TPAbutments
			AddCrown(abutment[1], abutment[2], abutment[3], abutment[4], abutment[5], abutment[6], abutment[7], abutment[8], abutment[9], true, currentPatient)
	
		;Marks treatment planned pontics
		for index, pontic in TPPontics
		{
			if (pontic[2] = "p")
				AddCodeDetailed("D6240", pontic[1],,,,,,,,, currentPatient)
			else if (pontic[2] = "g")
				AddCodeDetailed("D6210", pontic[1],,,,,,,,, currentPatient)
			else
				AddCodeDetailed("D6245", pontic[1],,,,,,,,, currentPatient)
		}
		
		;Marks treatment planned veneers
		AddRestosArray(TPVeneers, currentPatient)
	
		;Marks treatment planned onlays
		AddRestosArray(TPOnlays, currentPatient)
	
		;Marks treatment planned inlays
		AddRestosArray(TPInlays, currentPatient)
	
		;Add CBCT code if implants are planned
		if (TPImplants.Length() != 0)
			AddCode("D0367", currentPatient)
	
		;Marks treatment planned implants and related procedures
		AddCodeToTeeth(TPImplants, "D6010", currentPatient)
		AddCodeToTeeth(TPImplantStockAbutments, "D6056", currentPatient)
		AddCodeToTeeth(TPImplantCustomAbutments, "D6057", currentPatient)	
		AddCodeToTeeth(TPImplantCrowns, "D6058", currentPatient)
		AddCodeToTeeth(TPImplantRetainers, "D6068", currentPatient)
		AddCodeToTeeth(TPImplantPontics, "D6245", currentPatient)
		AddCodeToTeeth(TPBoneGraftDuringExtraction, "D7953", currentPatient)
		AddCodeToTeeth(TPBoneGraftDuringImplant, "D6104", currentPatient)
		AddCodeToTeeth(TPMembraneDuringExtraction, "D7957", currentPatient)
		AddCodeToTeeth(TPMembraneDuringImplant, "D6107", currentPatient)
	
		AddCodeToTeeth(TPImplantProvisionals, "D6085", currentPatient)
	
		;Check surgical guide locations and add one code per arch
		hasMaxGuide := false
		hasMandGuide := false
		for index, tooth in TPImplantSurgicalGuide
		{
			if (tooth <= 16)
				hasMaxGuide := true
			else
				hasMandGuide := true
		}
		if (hasMaxGuide)
			AddCode("D6190", currentPatient)
		if (hasMandGuide)
			AddCode("D6190", currentPatient)
	
		;Marks treatment planned post and cores
		AddCodeToTeeth(TPPostCore, "D2954", currentPatient)
	
		;Marks treatment planned cores
		AddCodeToTeeth(TPCores, "D2950", currentPatient)
	
		;Marks treatment planned endos
		AddCodeToTeeth(TPEndosMolar, "D3330", currentPatient)
		AddCodeToTeeth(TPEndosPremolar, "D3320", currentPatient) 
		AddCodeToTeeth(TPEndosAnterior, "D3310", currentPatient)
	
		;Marks treatment planned direct pulp caps
		AddCodeToTeeth(TPDirectPulpCaps, "D3110", currentPatient)
	
		;Marks treatment planned indirect pulp caps
		AddCodeToTeeth(TPIndirectPulpCaps, "D3120", currentPatient)
		
		;Marks Treatment Planned SRP
		if (TPSRP13UR)
			AddCodeDetailed("D4342",,,,"UR",,,,,, currentPatient)
		if (TPSRP13UL)
			AddCodeDetailed("D4342",,,,"UL",,,,,, currentPatient)
		if (TPSRP13LR)
			AddCodeDetailed("D4342",,,,"LR",,,,,, currentPatient)
		if (TPSRP13LL)
			AddCodeDetailed("D4342",,,,"LL",,,,,, currentPatient)
		if (TPSRP4UR)
			AddCodeDetailed("D4341",,,,"UR",,,,,, currentPatient)
		if (TPSRP4UL)
			AddCodeDetailed("D4341",,,,"UL",,,,,, currentPatient)
		if (TPSRP4LR)
			AddCodeDetailed("D4341",,,,"LR",,,,,, currentPatient)
		if (TPSRP4LL)
			AddCodeDetailed("D4341",,,,"LL",,,,,, currentPatient)
		
		;Marks Treatment Planned dentures and occlusal guards
		if (TPUpperDenture)
			AddCodeDetailed("D5110",,,,,"U",,,,, currentPatient)
		if (TPLowerDenture)
			AddCodeDetailed("D5120",,,,,"L",,,,, currentPatient)
		if (TPFullOccGuardUpper)
			AddCodeDetailed("D9944",,,,,"U",,,,, currentPatient)
		if (TPFullOccGuardLower)
			AddCodeDetailed("D9944",,,,,"L",,,,, currentPatient)
		if (TPPartialOccGuardUpper)
			AddCodeDetailed("D9946",,,,,"U",,,,, currentPatient)
		if (TPPartialOccGuardLower)
			AddCodeDetailed("D9946",,,,,"L",,,,, currentPatient)
	
		;Marks Treatment Planned Invisalign
		if (InvisalignComp)
			AddCode("D8090", currentPatient)
		if (InvisalignLimited)
			AddCode("D8090L", currentPatient)
	
		;Add Nitrous codes
		Loop, %TPNitrous%
			AddCode("D9230", currentPatient)
	
		;Add Halcion codes
		Loop, %TPHalcion%
			AddCode("D9248", currentPatient)
	
		;Add Retainer codes
		for index, code in TPRetainers
			AddCode(code, currentPatient)
	}
	
	;Check if any Referred items exist
	if (RefExt.Length() || RefEndosMolar.Length() || RefEndosPremolar.Length() || RefEndosAnterior.Length() || ReferPartials || RefRestos.Length() || RefPostCore.Length() || RefImplants.Length() || RefMaxFlexPartial.Length() || RefMandFlexPartial.Length() || RefMaxAcrylicPartial.Length() || RefMandAcrylicPartial.Length() || RefMaxMetalPartial.Length() || RefMandMetalPartial.Length() || RefMaxInterimPartial.Length() || RefMandInterimPartial.Length() || RefUpperDenture || RefLowerDenture)
	{
		SetTxMode("Re")
	
		; Add referred partials
		; Acrylic partials
		if (RefMaxAcrylicPartial.Length())
				AddCodeDetailed("D5211",,,,,,,,,, currentPatient, RefMaxAcrylicPartial)
		if (RefMandAcrylicPartial.Length())
				AddCodeDetailed("D5212",,,,,,,,,, currentPatient, RefMandAcrylicPartial)
	
		; Flexible partials
		if (RefMaxFlexPartial.Length())
				AddCodeDetailed("D5225",,,,,,,,,, currentPatient, RefMaxFlexPartial)
		if (RefMandFlexPartial.Length())
				AddCodeDetailed("D5226",,,,,,,,,, currentPatient, RefMandFlexPartial)
	
		; Metal partials
		if (RefMaxMetalPartial.Length())
				AddCodeDetailed("D5213",,,,,,,,,, currentPatient, RefMaxMetalPartial)
		if (RefMandMetalPartial.Length())
				AddCodeDetailed("D5214",,,,,,,,,, currentPatient, RefMandMetalPartial)
	
		; Interim partials
		if (RefMaxInterimPartial.Length())
				AddCodeDetailed("D5820",,,,,,,,,, currentPatient, RefMaxInterimPartial)
		if (RefMandInterimPartial.Length())
				AddCodeDetailed("D5821",,,,,,,,,, currentPatient, RefMandInterimPartial)
	
		; Add referred dentures
		if (RefUpperDenture)
			AddCodeDetailed("D5110",,,,,"U",,,,, currentPatient)
		if (RefLowerDenture)
			AddCodeDetailed("D5120",,,,,"L",,,,, currentPatient)
	
		;Marks referred extractions
		AddCodeToTeeth(RefExt, "D7210", currentPatient)
	
		;Marks referred endos
		AddCodeToTeeth(RefEndosMolar, "D3330", currentPatient)
		AddCodeToTeeth(RefEndosPremolar, "D3320", currentPatient)
		AddCodeToTeeth(RefEndosAnterior, "D3310", currentPatient)
	
		;Marks referred post and cores
		AddCodeToTeeth(RefPostCore, "D2954", currentPatient)
		
		;Marks referred implants
		AddCodeToTeeth(RefImplants, "D6010", currentPatient)
	
		;Marks referred restorations
		AddRestosArray(RefRestos, currentPatient)
	}
	
	; Marks fixed retainers
	if (ExistFixedRetainer89 OR ExistFixedRetainer710 OR ExistFixedRetainer2227)
	{
		SetDrawTabMode("Pen")
		if (ExistFixedRetainer89)
			MouseClickDrag, left, % ULX+191, % ODY+108, % ULX+218, % ODY+108
		if (ExistFixedRetainer710)
			MouseClickDrag, left, % ULX+167, % ODY+108, % ULX+241, % ODY+108
		if (ExistFixedRetainer2227)
			MouseClickDrag, left, % ULX+161, % ODY+204, % ULX+247, % ODY+204
		SetDrawTabMode("Pointer")
	}
	
	/* DISABLED FOR DEPLOYMENT: NO SELECTION OF TEETH AS IT IS UNRELIABLE
	; Add the premolar space closure code here
	if (closePremolarsSpaces) 
	{
		; Select and hide the premolars
		SelectTeeth("5,12,21,28")
		SetSelectedTeeth("hidden")
	
		; Close spaces in each quadrant
		; Upper Right (5)
		MouseClickDrag, Left, % tooth[1].x, % tooth[1].y, % tooth[4].x, % tooth[4].y
		; Upper Left (12) 
		MouseClickDrag, Left, % tooth[16].x, % tooth[16].y, % tooth[13].x, % tooth[13].y
		; Lower Left (21)
		MouseClickDrag, Left, % tooth[17].x, % tooth[17].y, % tooth[20].x, % tooth[20].y
		; Lower Right (28)
		MouseClickDrag, Left, % tooth[32].x, % tooth[32].y, % tooth[29].x, % tooth[29].y
	
		SetChartTab("Movements")
	
		; Move all selected teeth 3 clicks mesially
		MouseClick,, % mesialMovementButton.x, % mesialMovementButton.y, 3
	
		DeselectTeeth()
	}
	*/
	
	;Makes Popup if field filled
	if (popupToAdd != "")
	{
		MouseClick,, % popupButton.x, % popupButton.y ;Clicks Popup
		WaitWin("Popups for Family", 3)
		MouseClick,, % popupAddButton.x, % popupAddButton.y ;Clicks Add
		WaitWin("Edit Popup", 4)
		SendInput {raw}%popupToAdd%
		ClickOK()
		WaitWin("Popups for Family", 4)
		ClickOK()
	}
	BlockInput, MouseMoveOff
	BlockInput, Off
	RestoreState()
	Gui, TreatmentPlanning:Destroy
	if (A_ComputerName != "DOCTOR1_PC")
		SetTimer, ReloadScript, 60000, -1
Return()

Save()
{
    FormatTime, CurrentDateTime,, MM/dd/yy HH:mm
    WinGet, List_controls, ControlList    ; get list of all controls active gui
    newContent := CurrentDateTime . "`n" ; Initialize a variable to hold the new content
    Loop, Parse, List_controls, `n
    {
        GuiControlGet, vname, Name, %A_Loopfield%     ; get controls vname
        if (vname = "")   ; only save controls which have a vname
            continue
        GuiControlGet, value ,, %A_Loopfield%         ; get controls value
        ControlGet, checked, Checked,, %A_Loopfield% ; get control type
        if (checked) ; if control is checked
            value := "true" ; if checkbox is checked
        else if (value = "")   ; only save controls which have a value
            continue
        value := RegExReplace(value, "`n", "|")       ; convert newlines to pipes (for multiline edit fields, because newlines are not valid for ini file)
        newContent .= vname . "=" . value . "`n" ; Append the new content
    }
    ; Read the existing content of the file
    FileRead, oldContent, %A_MyDocuments%\TreatmentPlanLog.ini
    ; Write the new content at the beginning, followed by a newline and the old content
    FileDelete, %A_MyDocuments%\TreatmentPlanLog.ini
    FileAppend, % newContent . "`n" . oldContent, %A_MyDocuments%\TreatmentPlanLog.ini
    return
}

XButton1::
    ; Your code for the back button here
    MsgBox, Back button pressed!
return

XButton2::
    ; Your code for the forward button here
    MsgBox, Forward button pressed!
return

^!r::
SelectTeeth(1)

#If
/*
^0::
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
CoordMode, ToolTip, Window
VerifyAndUpdateTextBoxPosition()
return

VerifyAndUpdateTextBoxPosition() {
    windowTitle := "Patients · My iTero - Google Chrome"
    targetColor := 0xCCCCCC
    yCoord := 249

    if (!WinExist(windowTitle)) {
        MsgBox, Cannot find the window. Please ensure Chrome with iTero is open.
        return
    }

    WinActivate, %windowTitle%
    WinMove, %windowTitle%,, 0, 0, 800, 1440

    ; Find initial position
    initialX := FindPixelX(590, 615, yCoord, targetColor)
    if (initialX = -1) {
        MsgBox, Could not find the initial position of the text box.
        return
    }

    ; Find break points
    breakPoint1 := FindBreakPoint(1020, 1030, expectedx, yCoord, targetColor)
    breakPoint2 := FindBreakPoint(1550, 1560, expectedx, yCoord, targetColor)

    ; Generate and copy new code
    ;newCode := GenerateNewCode(initialX, breakPoint1, breakPoint2)
    Clipboard := newCode

    MsgBox, % "Updated code has been copied to clipboard.`n`n"
           . "Initial X: " initialX "`n"
           . "Break Point 1: " breakPoint1 "`n"
           . "Break Point 2: " breakPoint2
}

FindPixelX(startX, endX, y, color) {
    Loop, % endX - startX + 1 {
        x := startX + A_Index - 1
        MouseMove, %x%, %y%
        Sleep, 500
        PixelGetColor, checkColor, %x%, %y%, RGB
        ToolTip, % "X: " . x . ", Color: " . checkColor
        if (checkColor = color) {
            return x
        }
    }
    return -1
}

FindBreakPoint(startWidth, endWidth, exectedx, y, color) {
    Loop, % endWidth - startWidth + 1 {
        width := startWidth + A_Index - 1
        WinMove, %windowTitle%,, 0, 0, %width%, 1440
        Sleep, 100 ; Wait for window resize
        expectedX := CalculateExpectedX(width, initialX, previousBreakPoint)
        actualX := FindPixelX(expectedX - 5, expectedX + 5, y, color)
        if (Abs(actualX - expectedX) > 1) { ; Allow 1 pixel tolerance
            return width - 1
        }
    }
    return endWidth
}
*/
^m::
    ; Set the coordinate mode to the active window for window coordinates
    CoordMode, Window, Screen

    ; Get the active window's ID
    WinGet, active_id, ID, A

    ; Get the window's position and size
    WinGetPos, X, Y, WindowWidth, WindowHeight, ahk_id %active_id%

    ; Calculate the middle of the window
    MiddleX := X + (WindowWidth / 2)
    MiddleY := Y + (WindowHeight / 2)

    ; Move the cursor to the middle of the window
    MouseMove, MiddleX, MiddleY
return
    MouseMove, MiddleX, MiddleY
return