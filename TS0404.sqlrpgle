**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0404
// Description      :   Maintain Activity (Controller)
// Author           :   Vinayak Mahajan
// Date written     :   September 19, 2016
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
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  ActivityDS  BASED(pActivityDS) QUALIFIED;
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
    DCL-S   Activity    CHAR(50);
    DCL-S   ActivityID  ZONED(5:0);
    DCL-S   ErrorID     ZONED(5:0);
    DCL-S   LangCode    CHAR(3)     INZ('ENG');
    DCL-S   Message     CHAR(78);
// ===================================================================================================================================
// Constants
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Switches
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   ExitProgram CHAR(1);
    DCL-S   F3Pressed   CHAR(1);
    DCL-S   IsValid     CHAR(1);
    DCL-S   ValidScr01  CHAR(1);
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9902PR.sqlrpgle
// ===================================================================================================================================
// Parameters for Various Programs 
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for TS0405 - Maintain Activity (View)

    DCL-PR      TS0405      EXTPGM;
    DCL-PARM    Mode        CHAR(10);
    DCL-PARM    pActivityDS POINTER;
    DCL-PARM    F3Pressed   CHAR(1);
    DCL-PARM    Message     CHAR(78);
    DCL-PARM    ErrorID     ZONED(5:0);
    END-PR;

// Parameters for this Program

    DCL-PR      TS0404;
    DCL-PARM    Mode        CHAR(10);
    DCL-PARM    pActivityDS POINTER;
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI      TS0404;
    DCL-PARM    Mode        CHAR(10);
    DCL-PARM    pActivityDS POINTER;
    END-PI;
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

            SELECT;
                WHEN    Mode    =   'Add';
                        EXSR    ProcScr01;

                WHEN    Mode    =   'Change';
                        EXSR    ProcScr01;

                WHEN    Mode    =   'Copy';
                        EXSR    ProcCopy;

                WHEN    Mode    =   'Delete';
                        EXSR    ProcDelete;

                WHEN    Mode    =   'Display';
                        EXSR    ProcDisplay;
            ENDSL;

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

        IF  F3Pressed   =   'Y';
            ExitProgram =   'Y';
            F3Pressed   =   'N';
            LEAVESR;
        ENDIF;

        EXSR    VldtActivity;
        IF  IsValid     =   'N';
            ValidScr01  =   'N';
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

        EXSR    ProcRequest;
        
    ENDSR;
// ===================================================================================================================================
// Process Request
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRequest;

        SELECT;
            WHEN    Mode    =   'Add';
                    EXSR    ProcAdd;

            WHEN    Mode    =   'Change';
                    EXSR    ProcChange;
        ENDSL;

        ExitProgram =   'Y';

    ENDSR;
// ===================================================================================================================================
// Process Add
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcAdd;

        CALLP   TIME_GetNextActivityID(ActivityDS.User:ActivityID);
        ActivityDS.ActivityID   =   ActivityID;

        CALLP   TIME_AddActivity(pActivityDS);

    ENDSR;
// ===================================================================================================================================
// Process Change
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcChange;

        CALLP   TIME_ChangeActivity(pActivityDS);

    ENDSR;
// ===================================================================================================================================
// Process Copy
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcCopy;

        CALLP   TIME_GetNextActivityID(ActivityDS.User:ActivityID);
        ActivityDS.ActivityID   =   ActivityID;

        CALLP   TIME_AddActivity(pActivityDS);

        ExitProgram =   'Y';

    ENDSR;
// ===================================================================================================================================
// Process Delete
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcDelete;

        EXSR    CallView;

        IF  F3Pressed   =   'Y';
            ExitProgram =   'Y';
            F3Pressed   =   'N';
            LEAVESR;
        ENDIF;
        
        CALLP   TIME_DeleteActivity(pActivityDS);

        ExitProgram =   'Y';

    ENDSR;
// ===================================================================================================================================
// Process Display
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcDisplay;

        EXSR    CallView;

        IF  F3Pressed   =   'Y';
            F3Pressed   =   'N';
        ENDIF;
        
        ExitProgram =   'Y';

    ENDSR;
// ===================================================================================================================================
// Call View
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CallView;

        TS0405(Mode:pActivityDS:F3Pressed:Message:ErrorID);

    ENDSR;
// ===================================================================================================================================
// Validate Activity
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   VldtActivity;

        Activity    =   ActivityDS.Activity;
        CALLP   TIME_ValidateActivity(Activity:IsValid:ErrorID);

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