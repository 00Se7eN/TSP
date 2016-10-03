**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0204
// Description      :   Subset for Details (Controller)
// Author           :   Vinayak Mahajan
// Date written     :   September 26, 2016
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
    DCL-DS  FromDTL     BASED(pFromDTL)  QUALIFIED;
            EntryDate   ZONED(8:0);
            ActID       ZONED(5:0);
            StartHH     ZONED(2:0);
            StartMM     ZONED(2:0);
            EndHH       ZONED(2:0);
            EndMM       ZONED(2:0);
            DrtnHH      ZONED(2:0);
            DrtnMM      ZONED(2:0);
    END-DS;

    DCL-DS  ToDTL       BASED(pToDTL)    QUALIFIED;
            EntryDate   ZONED(8:0);
            ActID       ZONED(5:0);
            StartHH     ZONED(2:0);
            StartMM     ZONED(2:0);
            EndHH       ZONED(2:0);
            EndMM       ZONED(2:0);
            DrtnHH      ZONED(2:0);
            DrtnMM      ZONED(2:0);
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
    DCL-S   ErrorID         ZONED(5:0);
    DCL-S   LangCode        CHAR(3)     INZ('ENG');
    DCL-S   Message         CHAR(78);
// ===================================================================================================================================
// Constants
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Switches
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   ExitProgram     CHAR(1);
    DCL-S   F3Pressed       CHAR(1);
    DCL-S   ValidScr01      CHAR(1);
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9902PR.sqlrpgle
// ===================================================================================================================================
// Parameters for Various Programs 
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for TS0204 - Display Details (View)

    DCL-PR      TS0205      EXTPGM;
    DCL-PARM    pFromDTL    POINTER;
    DCL-PARM    pToDTL      POINTER;
    DCL-PARM    F3Pressed   CHAR(1);
    DCL-PARM    Message     CHAR(78);
    DCL-PARM    ErrorID     ZONED(5:0);
    END-PR;

// Parameters for this Program

    DCL-PR      TS0204;
    DCL-PARM    pFromDTL    POINTER;
    DCL-PARM    pToDTL      POINTER;
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI      TS0204;
    DCL-PARM    pFromDTL    POINTER;
    DCL-PARM    pToDTL      POINTER;
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

        IF  F3Pressed   =   'Y';
            ExitProgram =   'Y';
            F3Pressed   =   'N';
            LEAVESR;
        ENDIF;

        IF  FromDTL.EntryDate   >   ToDTL.EntryDate;
            ValidScr01          =   'N';
            ErrorID             =   29;         //From Date > To Date.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

        IF  FromDTL.ActID       >   ToDTL.ActID;
            ValidScr01          =   'N';
            ErrorID             =   30;         //From Activity ID > To Activity ID.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

        IF  FromDTL.StartHH     >   ToDTL.StartHH;
            ValidScr01          =   'N';
            ErrorID             =   31;         //From Start Time > To Start Time.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;
                
        IF  FromDTL.StartHH     =   ToDTL.StartHH   AND
            FromDTL.StartMM     >   ToDTL.StartMM;
            ValidScr01          =   'N';
            ErrorID             =   31;         //From Start Time > To Start Time.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;
                
        IF  FromDTL.EndHH       >   ToDTL.EndHH;
            ValidScr01          =   'N';
            ErrorID             =   32;         //From End Time > To End Time.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

        IF  FromDTL.EndHH       =   ToDTL.EndHH     AND
            FromDTL.EndMM       >   ToDTL.EndMM;
            ValidScr01          =   'N';
            ErrorID             =   32;         //From End Time > To End Time.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

        IF  FromDTL.DrtnHH      >   ToDTL.DrtnHH;
            ValidScr01          =   'N';
            ErrorID             =   33;         //From Duration > To Duration.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

        IF  FromDTL.DrtnHH      =   ToDTL.DrtnHH    AND
            FromDTL.DrtnMM      >   ToDTL.DrtnMM;
            ValidScr01          =   'N';
            ErrorID             =   33;         //From Duration > To Duration.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Call View
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CallView;

        TS0205(pFromDTL:pToDTL:F3Pressed:Message:ErrorID);

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