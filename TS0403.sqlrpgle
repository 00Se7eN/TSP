**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0403
// Description      :   Work with Activities (View)
// Author           :   Vinayak Mahajan
// Date written     :   September 14, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Modification History
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Files
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-F   TS0403DS    WORKSTN INFDS(DSPFINFDS) SFILE(TS04031:RRN1);
// ===================================================================================================================================
// Arrays
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  ActivitiesArray BASED(pActivitiesArray) DIM(999) QUALIFIED;
            Opt             ZONED(1:0);
            User            CHAR(10);
            ActivityID      ZONED(5:0);
            Activity        CHAR(50);
    END-DS;
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// External Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  DSPFINFDS   EXTNAME('DSPFIDS');
    END-DS;
// ===================================================================================================================================
// System Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Internal Standalone Fields
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Constants
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Switches
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9902PR.sqlrpgle
// ===================================================================================================================================
// Parameters for Various Programs
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for this Program

    DCL-PR      TS0403;
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
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI      TS0403;
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
    END-PI;
// ===================================================================================================================================
//
// -----------------------------------------------------------------------------------------------------------------------------------

    EXSR    InitScr01;
    EXSR    DispScr01;
    EXSR    AcptScr01;
    EXSR    SetRtrnParms;

    RETURN;

// ===================================================================================================================================
// Initialize Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   InitScr01;

        EXSR    ResetScr01Ind;
        EXSR    SetScr01Flds;
        EXSR    SetScr01Cursor;

    ENDSR;
// ===================================================================================================================================
// Reset Screen 01 Indicators
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ResetScr01Ind;

        *In50   =   *Off;

        *In51   =   *Off;
        *In52   =   *Off;

    ENDSR;
// ===================================================================================================================================
// Set Screen 01 Field Values
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetScr01Flds;

        POSID   =   PosID;
        POSDESC =   PosDesc;
        MESSAGE =   Message;

        EXSR    BuildSFL;

    ENDSR;
// ===================================================================================================================================
// Build the Subfile
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   BuildSFL;

        RRN1    =   *Zeros;
        *In31   =   *On;
        WRITE   TS04031C;
        *In31   =   *Off;

        DOW RRN1        <   Count;

            RRN1        =   RRN1 + 1;
            OPT99       =   ActivitiesArray(RRN1).Opt;
            ACTID99     =   ActivitiesArray(RRN1).ActivityID;
            ACTDESC99   =   ActivitiesArray(RRN1).Activity;
            WRITE   TS04031;

        ENDDO;

        IF  BlankScreen =   'Y';
            *In32       =   *On;
            BlankScreen =   'N';
            LEAVESR;
        ENDIF;

        IF  TmpDSLRD    =   *Zeros  AND
            Count       <>  *Zeros;
            TmpDSLRD    =   1;
        ENDIF;

        IF  TmpDSLRD    >   Count;
            TmpDSLRD    =   1;
        ENDIF;

        IF  RRN1        =   *Zeros;
            *In32       =   *On;
        ELSE;
            *In32       =   *Off;
            RRN1        =   TmpDSLRD;
        ENDIF;

        *In91   =   *On;

    ENDSR;
// ===================================================================================================================================
// Set Screen 01 Field Cursor
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetScr01Cursor;

        SELECT;
            WHEN    ErrorID =   9;          //Activity ID is invalid.
                    *In51   =   *On;

            WHEN    ErrorID =   10;         //Activity Description is invalid.
                    *In52   =   *On;
        ENDSL;

    ENDSR;
// ===================================================================================================================================
// Display Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   DispScr01;

        IF  Message <>  *Blanks;
            *In50   =   *On;
        ENDIF;

        WRITE   TS04031K;
        WRITE   TS04031C;

    ENDSR;
// ===================================================================================================================================
// Accept Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   AcptScr01;

        READ    TS04031C;

    ENDSR;
// ===================================================================================================================================
// Set Return Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetRtrnParms;

        // Move Screen Fields to Database Fields
        PosID   =   POSID;
        PosDesc =   POSDESC;

        SELECT;
            WHEN    *In03       =   *On;
                    F3Pressed   =   'Y';

            WHEN    *In05       =   *On;
                    F5Pressed   =   'Y';

            WHEN    *In06       =   *On;
                    F6Pressed   =   'Y';

            WHEN    *In13       =   *On;
                    F13Pressed  =   'Y';
        ENDSL;

        TmpDSLRD    =   DSLRD;

        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Build Array
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   BuildArray;

        IF  Count   =   *Zeros;
            LEAVESR;
        ENDIF;

        READC   TS04031;

        DOW NOT %eof;

            ActivitiesArray(RRN1).Opt   =   OPT99;
            READC   TS04031;

        ENDDO;

    ENDSR;
// ===================================================================================================================================