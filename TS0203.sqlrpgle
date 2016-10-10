**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0203
// Description      :   Display Details (View)
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
    DCL-F   TS0203DS    WORKSTN INFDS(DSPFINFDS) SFILE(TS02031:RRN1);
// ===================================================================================================================================
// Arrays
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  TSDetailsArray  BASED(pTSDetailsArray) DIM(999) QUALIFIED;
            EntryDate       ZONED(8:0);
            StartHH         ZONED(2:0);
            StartMM         ZONED(2:0);
            EndHH           ZONED(2:0);
            EndMM           ZONED(2:0);
            DurationHH      ZONED(2:0);
            DurationMM      ZONED(2:0);
            ActID           ZONED(5:0);
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

    DCL-PR      TS0203;
    DCL-PARM    Count           ZONED(5:0);
    DCL-PARM    pTSDetailsArray POINTER;
    DCL-PARM    TmpDSLRD        ZONED(4:0);
    DCL-PARM    HideSubset      CHAR(1);
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    F17Pressed      CHAR(1);
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI      TS0203;
    DCL-PARM    Count           ZONED(5:0);
    DCL-PARM    pTSDetailsArray POINTER;
    DCL-PARM    TmpDSLRD        ZONED(4:0);
    DCL-PARM    HideSubset      CHAR(1);
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    F17Pressed      CHAR(1);
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

        *In95   =   *Off;

    ENDSR;
// ===================================================================================================================================
// Set Screen 01 Field Values
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetScr01Flds;

        IF  HideSubset  =   'Y';
            *In95       =   *On;
        ENDIF;

        MESSAGE =   Message;

        EXSR    BuildSFL;

    ENDSR;
// ===================================================================================================================================
// Build the Subfile
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   BuildSFL;

        RRN1    =   *Zeros;
        *In31   =   *On;
        WRITE   TS02031C;
        *In31   =   *Off;

        DOW RRN1        <   Count;

            RRN1        =   RRN1 + 1;
            DATE99      =   TSDetailsArray(RRN1).EntryDate;
            STRHH99     =   TSDetailsArray(RRN1).StartHH;
            STRMM99     =   TSDetailsArray(RRN1).StartMM;
            ENDHH99     =   TSDetailsArray(RRN1).EndHH;
            ENDMM99     =   TSDetailsArray(RRN1).EndMM;
            DRTNHH99    =   TSDetailsArray(RRN1).DurationHH;
            DRTNMM99    =   TSDetailsArray(RRN1).DurationMM;
            ACTID99     =   TSDetailsArray(RRN1).ActID;
            ACTIVITY99  =   TSDetailsArray(RRN1).Activity;
            WRITE   TS02031;

        ENDDO;

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

    ENDSR;
// ===================================================================================================================================
// Display Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   DispScr01;

        IF  Message <>  *Blanks;
            *In50   =   *On;
        ENDIF;

        WRITE   TS02031K;
        WRITE   TS02031C;

    ENDSR;
// ===================================================================================================================================
// Accept Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   AcptScr01;

        READ    TS02031C;

    ENDSR;
// ===================================================================================================================================
// Set Return Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetRtrnParms;

        SELECT;
            WHEN    *In03       =   *On;
                    F3Pressed   =   'Y';

            WHEN    *In17       =   *On     AND
                    HideSubset  =   'N';
                    F17Pressed  =   'Y';
        ENDSL;

        TmpDSLRD    =   DSLRD;

    ENDSR;
// ===================================================================================================================================