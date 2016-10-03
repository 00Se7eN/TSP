**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0302
// Description      :   Display Summary (Controller)
// Author           :   Vinayak Mahajan
// Date written     :   September 27, 2016
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
    DCL-DS  TSSummaryArray  DIM(999)    QUALIFIED   INZ;
            Opt             ZONED(1:0);
            EntryDate       ZONED(8:0);
            DurationHH      ZONED(2:0);
            DurationMM      ZONED(2:0);
            ActID           ZONED(5:0);
            Activity        CHAR(50);
    END-DS;
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  FromDTL     QUALIFIED;
            EntryDate   ZONED(8:0)  INZ(00000000);
            ActID       ZONED(5:0)  INZ(00000);
            StartHH     ZONED(2:0)  INZ(00);
            StartMM     ZONED(2:0)  INZ(00);
            EndHH       ZONED(2:0)  INZ(00);
            EndMM       ZONED(2:0)  INZ(00);
            DrtnHH      ZONED(2:0)  INZ(00);
            DrtnMM      ZONED(2:0)  INZ(00);
    END-DS;

    DCL-DS  ToDTL       QUALIFIED;
            EntryDate   ZONED(8:0)  INZ(99999999);
            ActID       ZONED(5:0)  INZ(99999);
            StartHH     ZONED(2:0)  INZ(99);
            StartMM     ZONED(2:0)  INZ(99);
            EndHH       ZONED(2:0)  INZ(99);
            EndMM       ZONED(2:0)  INZ(99);
            DrtnHH      ZONED(2:0)  INZ(99);
            DrtnMM      ZONED(2:0)  INZ(99);
    END-DS;

    DCL-DS  FromSUM     QUALIFIED;
            EntryDate   ZONED(8:0)  INZ(00000000);
            ActID       ZONED(5:0)  INZ(00000);
            DrtnHH      ZONED(2:0)  INZ(00);
            DrtnMM      ZONED(2:0)  INZ(00);
    END-DS;

    DCL-DS  ToSUM       QUALIFIED;
            EntryDate   ZONED(8:0)  INZ(99999999);
            ActID       ZONED(5:0)  INZ(99999);
            DrtnHH      ZONED(2:0)  INZ(99);
            DrtnMM      ZONED(2:0)  INZ(99);
    END-DS;
// ===================================================================================================================================
// External Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  UserProfileDS   EXTNAME('TSPPARA') QUALIFIED INZ;
    END-DS;
// ===================================================================================================================================
// System Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Internal Standalone Fields
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   Count           ZONED(5:0);
    DCL-S   FromDate        CHAR(8);
    DCL-S   pFromSUM        POINTER     INZ(%addr(FromSUM));
    DCL-S   pToSUM          POINTER     INZ(%addr(ToSUM));
    DCL-S   pTSSummaryArray POINTER     INZ(%addr(TSSummaryArray));
    DCL-S   pUserProfileDS  POINTER     INZ(%addr(UserProfileDS));
    DCL-S   TmpCount        ZONED(5:0);
    DCL-S   TmpDSLRD        ZONED(4:0)  INZ(1);
    DCL-S   ToDate          CHAR(8);
    DCL-S   UserID          CHAR(10)    INZ(*USER);
// ===================================================================================================================================
// Constants
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Switches
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   ExitProgram CHAR(1);
    DCL-S   F3Pressed   CHAR(1);
    DCL-S   F5Pressed   CHAR(1);
    DCL-S   F13Pressed  CHAR(1);
    DCL-S   F17Pressed  CHAR(1);
    DCL-S   FKeyPressed CHAR(1);
    DCL-S   HideSubset  CHAR(1)     INZ('Y');
    DCL-S   UserExists  CHAR(1);
    DCL-S   ValidScr01  CHAR(1);
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9902PR.sqlrpgle
// ===================================================================================================================================
// Parameters for Various Programs 
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for TS0303 - Display Summary (View)

    DCL-PR      TS0303          EXTPGM;
    DCL-PARM    Count           ZONED(5:0);
    DCL-PARM    pTSSummaryArray POINTER;
    DCL-PARM    TmpDSLRD        ZONED(4:0);
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    F5Pressed       CHAR(1);
    DCL-PARM    F13Pressed      CHAR(1);
    DCL-PARM    F17Pressed      CHAR(1);
    END-PR;

// Parameters for TS0304 - Subset for Display Summary (Controller)

    DCL-PR      TS0304  EXTPGM;
    DCL-PARM    pFromDS POINTER;
    DCL-PARM    pToDS   POINTER;
    END-PR;

// Parameters for TS0202 - Display Details (Controller)

    DCL-PR      TS0202      EXTPGM;
    DCL-PARM    FromDS      LIKEDS(FromDTL);
    DCL-PARM    ToDS        LIKEDS(ToDTL);
    DCL-PARM    HideSubset  CHAR(1);
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

        ValidScr01  =   'Y';

        EXSR    CheckFKeys;

        IF  F3Pressed   =   'Y';
            ExitProgram =   'Y';
            F3Pressed   =   'N';
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
// Take Action 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   TakeAction01;

        SELECT;
            WHEN    F5Pressed   =   'Y';
                    EXSR    ProcRefresh;
                    F5Pressed   =   'N';

            WHEN    F13Pressed  =   'Y';
                    EXSR    ProcRepeat;
                    F13Pressed  =   'N';

            WHEN    F17Pressed  =   'Y';
                    EXSR    ProcSubset;
                    F17Pressed  =   'N';
        ENDSL;

    ENDSR;
// ===================================================================================================================================
// Process Refresh
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRefresh;

        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Process Repeat
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRepeat;

            TmpCount        =   *Zeros;
        DOW TmpCount + 1    <=  Count;
            TmpCount        =   TmpCount + 1;

            IF  TSSummaryArray(TmpCount).Opt       <>  0;
                TSSummaryArray(TmpCount + 1).Opt    = TSSummaryArray(TmpCount).Opt;
            ENDIF;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Process Subset
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcSubset;

        TS0304(pFromSUM:pToSUM);
        
        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Process Request
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRequest;

            TmpCount    =   *Zeros;
        DOW TmpCount    <   Count;
            TmpCount    =   TmpCount + 1;

            IF  TSSummaryArray(TmpCount).Opt    <>  *Zeros;

                FromDate            =   %editc(TSSummaryArray(TmpCount).EntryDate:'X');
                ToDate              =   %editc(TSSummaryArray(TmpCount).EntryDate:'X');
                
                EXSR    AdjustDate;

                FromDTL.EntryDate   =   %dec(FromDate:8:0);
                ToDTL.EntryDate     =   %dec(ToDate:8:0);

                FromDTL.ActID       =   TSSummaryArray(TmpCount).ActID;
                ToDTL.ActID         =   TSSummaryArray(TmpCount).ActID;

                TS0202(FromDTL:ToDTL:HideSubset);

                TSSummaryArray(TmpCount).Opt    =   *Zeros;

            ENDIF;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Adjust Date
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   AdjustDate;

        SELECT;
            WHEN    UserProfileDS.PR1002    =   'DMY';
                        
                SELECT;
                            //Date is already in DMY Format.

                    WHEN    UserProfileDS.PR1001    =   'MDY';
                            FromDate    =   %subst(FromDate:3:2) + %subst(FromDate:1:2) + %subst(FromDate:5:4);
                            ToDate      =   %subst(ToDate:3:2) + %subst(ToDate:1:2) + %subst(ToDate:5:4);

                    WHEN    UserProfileDS.PR1001    =   'YMD';
                            FromDate    =   %subst(FromDate:5:4) + %subst(FromDate:3:2) + %subst(FromDate:1:2);
                            ToDate      =   %subst(ToDate:5:4) + %subst(ToDate:3:2) + %subst(ToDate:1:2);
                ENDSL;

            WHEN    UserProfileDS.PR1002    =   'MDY';
                        
                SELECT;
                    WHEN    UserProfileDS.PR1001    =   'DMY';
                            FromDate    =   %subst(FromDate:3:2) + %subst(FromDate:1:2) + %subst(FromDate:5:4);
                            ToDate      =   %subst(ToDate:3:2) + %subst(ToDate:1:2) + %subst(ToDate:5:4);

                            //Date is already in MDY Format.

                    WHEN    UserProfileDS.PR1001    =   'YMD';
                            FromDate    =   %subst(FromDate:5:4) + %subst(FromDate:1:2) + %subst(FromDate:3:2);
                            ToDate      =   %subst(ToDate:5:4) + %subst(ToDate:1:2) + %subst(ToDate:3:2);
                ENDSL;

            WHEN    UserProfileDS.PR1002    =   'YMD';
                        
                SELECT;
                    WHEN    UserProfileDS.PR1001    =   'DMY';
                            FromDate    =   %subst(FromDate:7:2) + %subst(FromDate:5:2) + %subst(FromDate:1:4);
                            ToDate      =   %subst(ToDate:7:2) + %subst(ToDate:5:2) + %subst(ToDate:1:4);

                    WHEN    UserProfileDS.PR1001    =   'MDY';
                            FromDate    =   %subst(FromDate:5:2) + %subst(FromDate:7:2) + %subst(FromDate:1:4);
                            ToDate      =   %subst(ToDate:5:2) + %subst(ToDate:7:2) + %subst(ToDate:1:4);

                            //Date is already in YMD Format.
                ENDSL;

        ENDSL;

    ENDSR;
// ===================================================================================================================================
// Check Function Keys
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CheckFKeys;

        IF  F5Pressed   =   'Y' OR
            F13Pressed  =   'Y' OR
            F17Pressed  =   'Y';
            FKeyPressed =   'Y';
        ELSE;
            FKeyPressed =   'N';
        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Call View
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CallView;

        TS0303(Count:pTSSummaryArray:TmpDSLRD:F3Pressed:F5Pressed:F13Pressed:F17Pressed);

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

        CALLP   TIME_GetUserProfile(UserID:pUserProfileDS:UserExists);

        EXSR    BuildArray;

    ENDSR;
// ===================================================================================================================================
// Build Array
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   BuildArray;

        CALLP   TIME_GetTSSummary(UserID:pFromSUM:pToSUM:Count:pTSSummaryArray);

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