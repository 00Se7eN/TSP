**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0503
// Description      :   Change Settings (View)
// Author           :   Vinayak Mahajan
// Date written     :   September 12, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Modification History
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Files
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-F   TS0503DS    WORKSTN;
// ===================================================================================================================================
// Arrays
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// External Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  UserProfileDS   EXTNAME('TSPPARA') BASED(pUserProfileDS) QUALIFIED;
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

    DCL-PR      TS0503;
    DCL-PARM    pUserProfileDS  POINTER;
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    Message         CHAR(78);
    DCL-PARM    ErrorID         ZONED(5:0);
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI      TS0503;
    DCL-PARM    pUserProfileDS  POINTER;
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    Message         CHAR(78);
    DCL-PARM    ErrorID         ZONED(5:0);
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
        *In53   =   *Off;

    ENDSR;
// ===================================================================================================================================
// Set Screen 01 Field Values
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetScr01Flds;

        DATEENTRY   =   UserProfileDS.PR1001;
        DATEDSPLY   =   UserProfileDS.PR1002;
        DATAENTRY   =   UserProfileDS.PR0501;
        MESSAGE     =   Message;

    ENDSR;
// ===================================================================================================================================
// Set Screen 01 Field Cursor
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetScr01Cursor;

        SELECT;
            WHEN    ErrorID =   5;          //Date Entry Format is blank.
                    *In51   =   *On;

            WHEN    ErrorID =   6;          //Date Entry Format is invalid.
                    *In51   =   *On;

            WHEN    ErrorID =   7;          //Date Display Format is blank.
                    *In52   =   *On;

            WHEN    ErrorID =   8;          //Date Display Format is invalid.
                    *In52   =   *On;

            WHEN    ErrorID =   3;          //Data Format is blank.
                    *In53   =   *On;

            WHEN    ErrorID =   4;          //Data Format is invalid.
                    *In53   =   *On;
        ENDSL;

    ENDSR;
// ===================================================================================================================================
// Display Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   DispScr01;

        IF  Message <>  *Blanks;
            *In50   =   *On;
        ENDIF;

        WRITE   TS05031;

    ENDSR;
// ===================================================================================================================================
// Accept Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   AcptScr01;

        READ    TS05031;

    ENDSR;
// ===================================================================================================================================
// Set Return Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetRtrnParms;

        // Move Screen Fields to Database Fields
        UserProfileDS.PR1001    =   DATEENTRY;
        UserProfileDS.PR1002    =   DATEDSPLY;
        UserProfileDS.PR0501    =   DATAENTRY;

        IF  *In03       =   *On;
            F3Pressed   =   'Y';
        ENDIF;

    ENDSR;
// ===================================================================================================================================