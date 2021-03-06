**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0402
// Description      :   Work with Activities (Controller)
// Author           :   Vinayak Mahajan
// Date written     :   September 13, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Modification History
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Files
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Arrays
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  ActivitiesArray LIKEDS(ActivityDS) DIM(999);
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  ActivityDS  QUALIFIED;
            Opt         ZONED(1:0);
            User        CHAR(10);
            ActivityID  ZONED(5:0);
            Activity    CHAR(50);
    END-DS;
// ===================================================================================================================================
// External Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// System Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Internal Standalone Fields
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   Count               ZONED(5:0);
    DCL-S   ErrorID             ZONED(5:0);
    DCL-S   LangCode            CHAR(3)     INZ('ENG');
    DCL-S   Message             CHAR(78);
    DCL-S   Mode                CHAR(10);
    DCL-S   pActivitiesArray    POINTER     INZ(%addr(ActivitiesArray));
    DCL-S   pActivityDS         POINTER     INZ(%addr(ActivityDS));
    DCL-S   PosDesc             CHAR(50);
    DCL-S   PosID               ZONED(5:0);
    DCL-S   SortBy              CHAR(10);
    DCL-S   StrLength           ZONED(2:0);
    DCL-S   TmpActivity         CHAR(50);
    DCL-S   TmpActivityID       ZONED(5:0);
    DCL-S   TmpCount            ZONED(5:0);
    DCL-S   TmpDesc             CHAR(50);
    DCL-S   TmpDSLRD            ZONED(4:0)  INZ(1);
    DCL-S   TmpOpt              ZONED(1:0);
    DCL-S   TmpUser             CHAR(10);
    DCL-S   UserID              CHAR(10)    INZ(*USER);
// ===================================================================================================================================
// Constants
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Switches
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   BlankScreen     CHAR(1);
    DCL-S   ExitProgram     CHAR(1);
    DCL-S   F3Pressed       CHAR(1);
    DCL-S   F5Pressed       CHAR(1);
    DCL-S   F6Pressed       CHAR(1);
    DCL-S   F13Pressed      CHAR(1);
    DCL-S   FKeyPressed     CHAR(1);
    DCL-S   ProcessArray    CHAR(1);
    DCL-S   ValidScr01      CHAR(1);
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9902PR.sqlrpgle
// ===================================================================================================================================
// Parameters for Various Programs
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for TS0403 - Work with Activities (View)

    DCL-PR      TS0403              EXTPGM;
    DCL-PARM    PosID               ZONED(5:0);
    DCL-PARM    PosDesc             CHAR(50);
    DCL-PARM    Count               ZONED(5:0);
    DCL-PARM    pActivitiesArray    POINTER;
    DCL-PARM    TmpDSLRD            ZONED(4:0);
    DCL-PARM    BlankScreen         CHAR(1);
    DCL-PARM    F3Pressed           CHAR(1);
    DCL-PARM    F5Pressed           CHAR(1);
    DCL-PARM    F6Pressed           CHAR(1);
    DCL-PARM    F13Pressed          CHAR(1);
    DCL-PARM    Message             CHAR(78);
    DCL-PARM    ErrorID             ZONED(5:0);
    END-PR;

// Parameters for TS0404 - Maintain Activity (Controller)

    DCL-PR      TS0404      EXTPGM;
    DCL-PARM    Mode        CHAR(10);
    DCL-PARM    pActivityDS POINTER;
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
//
// -----------------------------------------------------------------------------------------------------------------------------------

    EXSR    InitFirstTime;
    EXSR    InitAlways;
    EXSR    MainProcessing;
    EXSR    ExitAlways;
    EXSR    ExitLastTime;

// ===================================================================================================================================
// Main Processing
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   MainProcessing;

            ExitProgram  =   'N';
        DOW ExitProgram  =   'N';

            EXSR    ProcScr01;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Process Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcScr01;

            ValidScr01  =   'N';
        DOW ValidScr01  =   'N';

            EXSR    CallView;
            EXSR    VldtScr01;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Validate Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   VldtScr01;

        Message     =   *Blanks;
        ErrorID     =   *Zeros;
        ValidScr01  =   'Y';

        EXSR    CheckFKeys;

        IF  F3Pressed   =   'Y';
            ExitProgram =   'Y';
            F3Pressed   =   'N';
            LEAVESR;
        ENDIF;

        IF  PosID       <>  *Zeros  AND
            FKeyPressed =   'N';
            EXSR    ProcPosID;
            ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  PosDesc     <>  *Blanks AND
            FKeyPressed =   'N';
            EXSR    ProcPosDesc;
            ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  FKeyPressed =   'Y';
            EXSR    TakeAction01;
            ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        EXSR    ProcRequest;

    ENDSR;
// ===================================================================================================================================
// Process Position to ID
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcPosID;

        SortBy  =   'ActID';
        EXSR    SortArray;

            TmpCount    =   *Zeros;
        DOW TmpCount    <   Count;
            TmpCount    =   TmpCount + 1;

            IF  ActivitiesArray(TmpCount).ActivityID    >=  PosID;
                TmpDSLRD    =   TmpCount;
                Message     =   *Blanks;
                PosID       =   *Zeros;
                PosDesc     =   *Blanks;
                LEAVESR;
            ENDIF;

        ENDDO;

        BlankScreen = 'Y';
        Message     =   *Blanks;
        PosID       =   *Zeros;
        PosDesc     =   *Blanks;

    ENDSR;
// ===================================================================================================================================
// Process Position to Description
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcPosDesc;

        SortBy  =   'ActDesc';
        EXSR    SortArray;

            StrLength   =   *Zeros;
            StrLength   =   %len(%trimr(PosDesc));

            TmpCount    =   *Zeros;
        DOW TmpCount    <   Count;
            TmpCount    =   TmpCount + 1;

            TmpDesc =   *Blanks;
            TmpDesc =   %subst(ActivitiesArray(TmpCount).Activity:1:StrLength);

            IF  TmpDesc     >=  PosDesc;
                TmpDSLRD    =   TmpCount;
                Message     =   *Blanks;
                PosDesc     =   *Blanks;
                LEAVESR;
            ENDIF;

        ENDDO;

        BlankScreen = 'Y';
        Message     =   *Blanks;
        PosDesc     =   *Blanks;

    ENDSR;
// ===================================================================================================================================
// Sort Array
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SortArray;

            ProcessArray    =   'Y';
        DOW ProcessArray    =   'Y';
            ProcessArray    =   'N';

                TmpCount        =   *Zeros;
            DOW TmpCount + 1    <   Count;
                TmpCount        =   Tmpcount + 1;

                SELECT;
                    WHEN    SortBy  =   'ActID';

                            IF  ActivitiesArray(TmpCount).ActivityID    >   ActivitiesArray(TmpCount+1).ActivityID;
                                EXSR    SwitchFields;
                                ProcessArray    =   'Y';
                            ENDIF;

                    WHEN    SortBy  =   'ActDesc';

                            IF  ActivitiesArray(TmpCount).Activity      >   ActivitiesArray(TmpCount+1).Activity;
                                EXSR    SwitchFields;
                                ProcessArray    =   'Y';
                            ENDIF;

                ENDSL;

            ENDDO;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Switch Fields
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SwitchFields;

        TmpOpt                                  =   ActivitiesArray(TmpCount).Opt;
        TmpUser                                 =   ActivitiesArray(TmpCount).User;
        TmpActivityID                           =   ActivitiesArray(TmpCount).ActivityID;
        TmpActivity                             =   ActivitiesArray(TmpCount).Activity;

        ActivitiesArray(TmpCount).Opt           =   ActivitiesArray(TmpCount+1).Opt;
        ActivitiesArray(TmpCount).User          =   ActivitiesArray(TmpCount+1).User;
        ActivitiesArray(TmpCount).ActivityID    =   ActivitiesArray(TmpCount+1).ActivityID;
        ActivitiesArray(TmpCount).Activity      =   ActivitiesArray(TmpCount+1).Activity;

        ActivitiesArray(TmpCount+1).Opt         =   TmpOpt;
        ActivitiesArray(TmpCount+1).User        =   TmpUser;
        ActivitiesArray(TmpCount+1).ActivityID  =   TmpActivityID;
        ActivitiesArray(TmpCount+1).Activity    =   TmpActivity;

    ENDSR;
// ===================================================================================================================================
// Take Action 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   TakeAction01;

        SELECT;
            WHEN    F5Pressed   =   'Y';
                    EXSR    ProcRefresh;
                    F5Pressed   =   'N';

            WHEN    F6Pressed   =   'Y';
                    EXSR    ProcAdd;
                    F6Pressed   =   'N';

            WHEN    F13Pressed  =   'Y';
                    EXSR    ProcRepeat;
                    F13Pressed  =   'N';
        ENDSL;

    ENDSR;
// ===================================================================================================================================
// Process Refresh
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRefresh;

        PosID   =   *Zeros;
        PosDesc =   *Blanks;

        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Process Add
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcAdd;

        Mode            =   'Add';
        CLEAR   ActivityDS;
        ActivityDS.User =   UserID;

        EXSR    CallMaintain;
        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Process Repeat
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRepeat;

            TmpCount        =   *Zeros;
        DOW TmpCount + 1    <=  Count;
            TmpCount        =   TmpCount + 1;

            IF  ActivitiesArray(TmpCount).Opt       <>  0;
                ActivitiesArray(TmpCount + 1).Opt    = ActivitiesArray(TmpCount).Opt;
            ENDIF;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Process Request
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRequest;

            TmpCount    =   *Zeros;
        DOW TmpCount    <   Count;
            TmpCount    =   TmpCount + 1;

            IF  ActivitiesArray(TmpCount).Opt   <>  *Zeros;

                SELECT;
                    WHEN    ActivitiesArray(TmpCount).Opt   =   2;
                            Mode    =   'Change';

                    WHEN    ActivitiesArray(TmpCount).Opt   =   3;
                            Mode    =   'Copy';

                    WHEN    ActivitiesArray(TmpCount).Opt   =   4;
                            Mode    =   'Delete';

                    WHEN    ActivitiesArray(TmpCount).Opt   =   5;
                            Mode    =   'Display';
                ENDSL;

                EXSR    LoadActivityDS;
                EXSR    CallMaintain;
                ActivitiesArray(TmpCount).Opt   =   *Zeros;

            ENDIF;

        ENDDO;

        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Load ActivityDS
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   LoadActivityDS;

        CLEAR   ActivityDS;

        ActivityDS.Opt          =   *Zeros;
        ActivityDS.User         =   ActivitiesArray(TmpCount).User;
        ActivityDS.ActivityID   =   ActivitiesArray(TmpCount).ActivityID;
        ActivityDS.Activity     =   ActivitiesArray(TmpCount).Activity;

    ENDSR;
// ===================================================================================================================================
// Check Function Keys
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CheckFKeys;

        IF  F5Pressed   =   'Y' OR
            F6Pressed   =   'Y' OR
            F13Pressed  =   'Y';
            FKeyPressed =   'Y';
        ELSE;
            FKeyPressed =   'N';
        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Call View
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CallView;

        CALLP   TS0403(PosID:PosDesc:Count:pActivitiesArray:TmpDSLRD:BlankScreen:F3Pressed:F5Pressed:F6Pressed:F13Pressed:Message:ErrorID);

    ENDSR;
// ===================================================================================================================================
// Call Maintain
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CallMaintain;

        CALLP   TS0404(Mode:pActivityDS);

    ENDSR;
// ===================================================================================================================================
// Get Error Message
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   GetErrorMsg;

        CALLP   TIME_GetErrorMessage(ErrorID:LangCode:Message);

    ENDSR;
// ===================================================================================================================================
// Init First Time Subroutine
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   InitFirstTime;

    ENDSR;
// ===================================================================================================================================
// Init Always Subroutine
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   InitAlways;

        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Build Array
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   BuildArray;

        CALLP   TIME_GetAllActivities(UserID:Count:pActivitiesArray);

    ENDSR;
// ===================================================================================================================================
// Exit Always Subroutine
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ExitAlways;

    ENDSR;
// ===================================================================================================================================
// Exit Last Time Subroutine
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ExitLastTime;

        *InLR   =   *On;
        RETURN;

    ENDSR;
// ===================================================================================================================================