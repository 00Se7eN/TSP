**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0103
// Description      :   Add Entries (View)
// Author           :   Vinayak Mahajan
// Date written     :   September 23, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Modification History
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Files
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-F   TS0103DS    WORKSTN;
// ===================================================================================================================================
// Arrays
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  TSEntryArray    BASED(pTSEntryArray) DIM(5) QUALIFIED;
            ActID           ZONED(5:0);
            StartHH         ZONED(2:0);
            StartMM         ZONED(2:0);
            EndHH           ZONED(2:0);
            EndMM           ZONED(2:0);
            DurationHH      ZONED(2:0);
            DurationMM      ZONED(2:0);
            Activity        CHAR(50);
    END-DS;
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

    DCL-PR      TS0103;
    DCL-PARM    EntryDate       ZONED(8:0);
    DCL-PARM    pUserProfileDS  POINTER;
    DCL-PARM    pTSEntryArray   POINTER;
    DCL-PARM    ProtectFields   CHAR(1);
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    F12Pressed      CHAR(1);
    DCL-PARM    Message         CHAR(78);
    DCL-PARM    ErrorID         ZONED(5:0);
    DCL-PARM    ErrorLine       ZONED(5:0);
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI      TS0103;
    DCL-PARM    EntryDate       ZONED(8:0);
    DCL-PARM    pUserProfileDS  POINTER;
    DCL-PARM    pTSEntryArray   POINTER;
    DCL-PARM    ProtectFields   CHAR(1);
    DCL-PARM    F3Pressed       CHAR(1);
    DCL-PARM    F12Pressed      CHAR(1);
    DCL-PARM    Message         CHAR(78);
    DCL-PARM    ErrorID         ZONED(5:0);
    DCL-PARM    ErrorLine       ZONED(5:0);
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

        *In31   =   *Off;
        *In32   =   *Off;
        *In33   =   *Off;
        *In34   =   *Off;

        *In50   =   *Off;

        *In51   =   *Off;
        *In52   =   *Off;
        *In53   =   *Off;
        *In54   =   *Off;
        *In55   =   *Off;
        *In56   =   *Off;
        *In57   =   *Off;
        *In58   =   *Off;
        *In59   =   *Off;
        *In60   =   *Off;
        *In61   =   *Off;
        *In62   =   *Off;
        *In63   =   *Off;
        *In64   =   *Off;
        *In65   =   *Off;
        *In66   =   *Off;
        *In67   =   *Off;
        *In68   =   *Off;
        *In69   =   *Off;
        *In70   =   *Off;
        *In71   =   *Off;
        *In72   =   *Off;
        *In73   =   *Off;
        *In74   =   *Off;
        *In75   =   *Off;
        *In76   =   *Off;
        *In77   =   *Off;
        *In78   =   *Off;
        *In79   =   *Off;
        *In80   =   *Off;
        *In81   =   *Off;
        *In82   =   *Off;
        *In83   =   *Off;
        *In84   =   *Off;
        *In85   =   *Off;
        *In86   =   *Off;

        *In91   =   *Off;
        *In92   =   *Off;
        *In93   =   *Off;

    ENDSR;
// ===================================================================================================================================
// Set Screen 01 Field Values
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetScr01Flds;

        SELECT;
            WHEN    UserProfileDS.PR0501    =    1;         //Duration
                    *In31   =   *On;
                    *In91   =   *On;
                    *In32   =   *On;
                    *In92   =   *On;

            WHEN    UserProfileDS.PR0501    =    2;         //Start-End
                    *In33   =   *On;
                    *In93   =   *On;

            WHEN    UserProfileDS.PR0501    =    3;         //Start-Duration
                    *In32   =   *On;
                    *In92   =   *On;

            WHEN    UserProfileDS.PR0501    =    4;         //End-Duration
                    *In31   =   *On;
                    *In91   =   *On;
        ENDSL;

        SELECT;
            WHEN    UserProfileDS.PR1001    =   'DMY';
                    DATEFORMAT  =   'DDMMYYYY';

            WHEN    UserProfileDS.PR1001    =   'MDY';
                    DATEFORMAT  =   'MMDDYYYY';

            WHEN    UserProfileDS.PR1001    =   'YMD';
                    DATEFORMAT  =   'YYYYMMDD';
        ENDSL;

        IF  ProtectFields   =   'Y';
            *In34   =   *On;
        ENDIF;

        ACTID1      =   TSEntryArray(1).ActID;
        STARTHH1    =   TSEntryArray(1).StartHH;
        STARTMM1    =   TSEntryArray(1).StartMM;
        ENDHH1      =   TSEntryArray(1).EndHH;
        ENDMM1      =   TSEntryArray(1).EndMM;
        DRTNHH1     =   TSEntryArray(1).DurationHH;
        DRTNMM1     =   TSEntryArray(1).DurationMM;
        ACTIVITY1   =   TSEntryArray(1).Activity;

        ACTID2      =   TSEntryArray(2).ActID;
        STARTHH2    =   TSEntryArray(2).StartHH;
        STARTMM2    =   TSEntryArray(2).StartMM;
        ENDHH2      =   TSEntryArray(2).EndHH;
        ENDMM2      =   TSEntryArray(2).EndMM;
        DRTNHH2     =   TSEntryArray(2).DurationHH;
        DRTNMM2     =   TSEntryArray(2).DurationMM;
        ACTIVITY2   =   TSEntryArray(2).Activity;

        ACTID3      =   TSEntryArray(3).ActID;
        STARTHH3    =   TSEntryArray(3).StartHH;
        STARTMM3    =   TSEntryArray(3).StartMM;
        ENDHH3      =   TSEntryArray(3).EndHH;
        ENDMM3      =   TSEntryArray(3).EndMM;
        DRTNHH3     =   TSEntryArray(3).DurationHH;
        DRTNMM3     =   TSEntryArray(3).DurationMM;
        ACTIVITY3   =   TSEntryArray(3).Activity;

        ACTID4      =   TSEntryArray(4).ActID;
        STARTHH4    =   TSEntryArray(4).StartHH;
        STARTMM4    =   TSEntryArray(4).StartMM;
        ENDHH4      =   TSEntryArray(4).EndHH;
        ENDMM4      =   TSEntryArray(4).EndMM;
        DRTNHH4     =   TSEntryArray(4).DurationHH;
        DRTNMM4     =   TSEntryArray(4).DurationMM;
        ACTIVITY4   =   TSEntryArray(4).Activity;

        ACTID5      =   TSEntryArray(5).ActID;
        STARTHH5    =   TSEntryArray(5).StartHH;
        STARTMM5    =   TSEntryArray(5).StartMM;
        ENDHH5      =   TSEntryArray(5).EndHH;
        ENDMM5      =   TSEntryArray(5).EndMM;
        DRTNHH5     =   TSEntryArray(5).DurationHH;
        DRTNMM5     =   TSEntryArray(5).DurationMM;
        ACTIVITY5   =   TSEntryArray(5).Activity;

        ENTRYDATE   =   EntryDate;
        MESSAGE     =   Message;

    ENDSR;
// ===================================================================================================================================
// Set Screen 01 Field Cursor
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetScr01Cursor;

        SELECT;
            WHEN    ErrorID =   18  OR          //Date is invalid.
                    ErrorID =   28;             //Date is blank.
                    *In51   =   *On;

            WHEN    ErrorID =   9   OR          //Activity ID is invalid.
                    ErrorID =   19;             //Activity ID is blank.

                    SELECT;
                        WHEN    ErrorLine   =   1;
                                *In52       =   *On;

                        WHEN    ErrorLine   =   2;
                                *In59       =   *On;

                        WHEN    ErrorLine   =   3;
                                *In66       =   *On;

                        WHEN    ErrorLine   =   4;
                                *In73       =   *On;

                        WHEN    ErrorLine   =   5;
                                *In80       =   *On;
                    ENDSL;

            WHEN    ErrorID =   20  OR          //Start Time is invalid.
                    ErrorID =   12  OR          //Start Hours is invalid.
                    ErrorID =   23  OR          //Start Time > End Time.
                    ErrorID =   34;             //Start Time = End Time.

                    SELECT;
                        WHEN    ErrorLine   =   1;
                                *In53       =   *On;

                        WHEN    ErrorLine   =   2;
                                *In60       =   *On;

                        WHEN    ErrorLine   =   3;
                                *In67       =   *On;

                        WHEN    ErrorLine   =   4;
                                *In74       =   *On;

                        WHEN    ErrorLine   =   5;
                                *In81       =   *On;
                    ENDSL;

            WHEN    ErrorID =   13;             //Start Minutes is invalid.

                    SELECT;
                        WHEN    ErrorLine   =   1;
                                *In54       =   *On;

                        WHEN    ErrorLine   =   2;
                                *In61       =   *On;

                        WHEN    ErrorLine   =   3;
                                *In68       =   *On;

                        WHEN    ErrorLine   =   4;
                               *In75        =   *On;

                        WHEN    ErrorLine   =   5;
                                *In82       =   *On;
                    ENDSL;

            WHEN    ErrorID =   21  OR          //End Time is blank.
                    ErrorID =   14;             //End Hours is invalid.

                    SELECT;
                        WHEN    ErrorLine   =   1;
                                *In55       =   *On;

                        WHEN    ErrorLine   =   2;
                                *In62       =   *On;

                        WHEN    ErrorLine   =   3;
                                *In69       =   *On;

                        WHEN    ErrorLine   =   4;
                                *In76       =   *On;

                        WHEN    ErrorLine   =   5;
                                *In83       =   *On;
                    ENDSL;

            WHEN    ErrorID =   15;             //End Minutes is invalid.

                    SELECT;
                        WHEN    ErrorLine   =   1;
                                *In56       =   *On;

                        WHEN    ErrorLine   =   2;
                                *In63       =   *On;

                        WHEN    ErrorLine   =   3;
                                *In70       =   *On;

                        WHEN    ErrorLine   =   4;
                                *In77       =   *On;

                        WHEN    ErrorLine   =   5;
                                *In84       =   *On;
                    ENDSL;

            WHEN    ErrorID =   22  OR          //Duration is blank.
                    ErrorID =   16  OR          //Duration Hours is invalid.
                    ErrorID =   24  OR          //Duration > Maximum Duration.
                    ErrorID =   25;             //Duration > End Time.

                    SELECT;
                        WHEN    ErrorLine   =   1;
                                *In57       =   *On;

                        WHEN    ErrorLine   =   2;
                                *In64       =   *On;

                        WHEN    ErrorLine   =   3;
                                *In71       =   *On;

                        WHEN    ErrorLine   =   4;
                                *In78       =   *On;

                        WHEN    ErrorLine   =   5;
                                *In85       =   *On;
                    ENDSL;

            WHEN    ErrorID =   17;             //Duration Minutes is invalid.

                    SELECT;
                        WHEN    ErrorLine   =   1;
                                *In58       =   *On;

                        WHEN    ErrorLine   =   2;
                                *In65       =   *On;

                        WHEN    ErrorLine   =   3;
                                *In72       =   *On;

                        WHEN    ErrorLine   =   4;
                                *In79       =   *On;

                        WHEN    ErrorLine   =   5;
                                *In86       =   *On;
                    ENDSL;

            WHEN    ErrorID =   26;             //Entry Time is Overlapping.

                    SELECT;
                        WHEN    UserProfileDS.PR0501    =   2   OR          //Start-End
                                UserProfileDS.PR0501    =   3;              //Start-Duration

                                SELECT;
                                    WHEN    ErrorLine   =   1;
                                            *In53       =   *On;

                                    WHEN    ErrorLine   =   2;
                                            *In60       =   *On;

                                    WHEN    ErrorLine   =   3;
                                            *In67       =   *On;

                                    WHEN    ErrorLine   =   4;
                                            *In74       =   *On;

                                    WHEN    ErrorLine   =   5;
                                            *In81       =   *On;
                                ENDSL;

                        WHEN    UserProfileDS.PR0501    =   4;              //End-Duration

                                SELECT;
                                    WHEN    ErrorLine   =   1;
                                            *In55       =   *On;

                                    WHEN    ErrorLine   =   2;
                                            *In62       =   *On;

                                    WHEN    ErrorLine   =   3;
                                            *In69       =   *On;

                                    WHEN    ErrorLine   =   4;
                                            *In76       =   *On;

                                    WHEN    ErrorLine   =   5;
                                            *In83       =   *On;
                                ENDSL;

                    ENDSL;

        ENDSL;

    ENDSR;
// ===================================================================================================================================
// Display Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   DispScr01;

        IF  Message <>  *Blanks;
            *In50   =   *On;
        ENDIF;

        WRITE   TS01031;

    ENDSR;
// ===================================================================================================================================
// Accept Screen 01
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   AcptScr01;

        READ    TS01031;

    ENDSR;
// ===================================================================================================================================
// Set Return Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SetRtrnParms;

        // Move Screen Fields to Database Fields
        EntryDate   =   ENTRYDATE;

        TSEntryArray(1).ActID       =   ACTID1;
        TSEntryArray(1).StartHH     =   STARTHH1;
        TSEntryArray(1).StartMM     =   STARTMM1;
        TSEntryArray(1).EndHH       =   ENDHH1;
        TSEntryArray(1).EndMM       =   ENDMM1;
        TSEntryArray(1).DurationHH  =   DRTNHH1;
        TSEntryArray(1).DurationMM  =   DRTNMM1;
        TSEntryArray(1).Activity    =   ACTIVITY1;

        TSEntryArray(2).ActID       =   ACTID2;
        TSEntryArray(2).StartHH     =   STARTHH2;
        TSEntryArray(2).StartMM     =   STARTMM2;
        TSEntryArray(2).EndHH       =   ENDHH2;
        TSEntryArray(2).EndMM       =   ENDMM2;
        TSEntryArray(2).DurationHH  =   DRTNHH2;
        TSEntryArray(2).DurationMM  =   DRTNMM2;
        TSEntryArray(2).Activity    =   ACTIVITY2;

        TSEntryArray(3).ActID       =   ACTID3;
        TSEntryArray(3).StartHH     =   STARTHH3;
        TSEntryArray(3).StartMM     =   STARTMM3;
        TSEntryArray(3).EndHH       =   ENDHH3;
        TSEntryArray(3).EndMM       =   ENDMM3;
        TSEntryArray(3).DurationHH  =   DRTNHH3;
        TSEntryArray(3).DurationMM  =   DRTNMM3;
        TSEntryArray(3).Activity    =   ACTIVITY3;

        TSEntryArray(4).ActID       =   ACTID4;
        TSEntryArray(4).StartHH     =   STARTHH4;
        TSEntryArray(4).StartMM     =   STARTMM4;
        TSEntryArray(4).EndHH       =   ENDHH4;
        TSEntryArray(4).EndMM       =   ENDMM4;
        TSEntryArray(4).DurationHH  =   DRTNHH4;
        TSEntryArray(4).DurationMM  =   DRTNMM4;
        TSEntryArray(4).Activity    =   ACTIVITY4;

        TSEntryArray(5).ActID       =   ACTID5;
        TSEntryArray(5).StartHH     =   STARTHH5;
        TSEntryArray(5).StartMM     =   STARTMM5;
        TSEntryArray(5).EndHH       =   ENDHH5;
        TSEntryArray(5).EndMM       =   ENDMM5;
        TSEntryArray(5).DurationHH  =   DRTNHH5;
        TSEntryArray(5).DurationMM  =   DRTNMM5;
        TSEntryArray(5).Activity    =   ACTIVITY5;

        SELECT;
            WHEN    *In03       =   *On;
                    F3Pressed   =   'Y';

            WHEN    *In12       =   *On;
                    F12Pressed  =   'Y';
        ENDSL;

    ENDSR;
// ===================================================================================================================================