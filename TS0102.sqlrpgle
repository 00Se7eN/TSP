**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS0102
// Description      :   Add Entries (Controller)
// Author           :   Vinayak Mahajan
// Date written     :   September 21, 2016
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
    DCL-DS  TSEntryArray    DIM(5)      QUALIFIED   INZ;
            ActID           ZONED(5:0);
            StartHH         ZONED(2:0);
            StartMM         ZONED(2:0);
            EndHH           ZONED(2:0);
            EndMM           ZONED(2:0);
            DurationHH      ZONED(2:0);
            DurationMM      ZONED(2:0);
            Activity        CHAR(50);
    END-DS;

    DCL-DS  TmpArray        DIM(999)    QUALIFIED   INZ;
            EntryTime       CHAR(8);
            Status          CHAR(2);
    END-DS;
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// External Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  UserProfileDS   EXTNAME('TSPPARA') QUALIFIED INZ;
    END-DS;

    DCL-DS  UserActsDS      EXTNAME('USRACTS') QUALIFIED INZ;
    END-DS;
// ===================================================================================================================================
// System Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Internal Standalone Fields
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   Count               ZONED(5:0);
    DCL-S   Duration            CHAR(8);
    DCL-S   EndTime             CHAR(8);
    DCL-S   EntryDate           ZONED(8:0);
    DCL-S   ErrorID             ZONED(5:0);
    DCL-S   ErrorLine           ZONED(5:0);
    DCL-S   Index               ZONED(5:0);
    DCL-S   LangCode            CHAR(3)     INZ('ENG');
    DCL-S   MaxDuration         CHAR(8);
    DCL-S   Message             CHAR(78);
    DCL-S   pTmpArray           POINTER     INZ(%addr(TmpArray));
    DCL-S   pTSEntryArray       POINTER     INZ(%addr(TSEntryArray));
    DCL-S   pUserActsDS         POINTER     INZ(%addr(UserActsDS));
    DCL-S   pUserProfileDS      POINTER     INZ(%addr(UserProfileDS));
    DCL-S   StartTime           CHAR(8);
    DCL-S   TmpEntryDate        CHAR(8);
    DCL-S   TmpEntryTime        CHAR(8);
    DCL-S   TmpIndex            ZONED(5:0);
    DCL-S   TmpStatus           CHAR(2);
    DCL-S   TotalDurationHH     ZONED(5:0);
    DCL-S   TotalDurationMM     ZONED(5:0);
    DCL-S   UserID              CHAR(10)    INZ(*USER);
// ===================================================================================================================================
// Constants
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// Switches
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   ActivityExists  CHAR(1);
    DCL-S   ExitProgram     CHAR(1);
    DCL-S   F3Pressed       CHAR(1);
    DCL-S   F12Pressed      CHAR(1);
    DCL-S   IsValid         CHAR(1);
    DCL-S   ProcessArray    CHAR(1);
    DCL-S   ProtectFields   CHAR(1);
    DCL-S   UserExists      CHAR(1);
    DCL-S   ValidScr01      CHAR(1);
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9901PR.sqlrpgle
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9902PR.sqlrpgle
// ===================================================================================================================================
// Parameters for Various Programs 
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for TS0103 - Add Entries (View)

    DCL-PR      TS0103          EXTPGM;
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

            ProtectFields   =   'N';
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

        IF  F12Pressed  =   'Y';
            EXSR    ProcCancel;
            ValidScr01  =   'N';
            F12Pressed  =   'N';
            LEAVESR;
        ELSE;
            
            IF  ProtectFields   =   'N';
                EXSR    ElementCheck;
                EXSR    OnScreenCheck;
                EXSR    ComputeParameter;
                EXSR    DatabaseCheck;
                EXSR    TotalHoursCheck;
            ENDIF;

        ENDIF;

        IF  ValidScr01  =   'Y';
        EXSR    ProcRequest;
        ENDIF;
        
    ENDSR;
// ===================================================================================================================================
// Element Check
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ElementCheck;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        EXSR    VldtDate;

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            EXSR    VldtActID;
            EXSR    VldtStartTime;
            EXSR    VldtEndTime;
            EXSR    VldtDuration;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Validate Date
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   VldtDate;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  EntryDate   =   *Zeros;
            ValidScr01  =   'N';
            ErrorID     =   28;         //Date is blank.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;

        CALLP   COMN_ValidateDate(%editc(EntryDate:'X'):UserProfileDS.PR1001:IsValid);
        
        IF  IsValid     =   'N';
            ValidScr01  =   'N';
            ErrorID     =   18;         //Date is invalid.
            EXSR    GetErrorMsg;
            LEAVESR;
        ENDIF;
        
    ENDSR;
// ===================================================================================================================================
// Validate Activity ID
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   VldtActID;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  TSEntryArray(Index).ActID   <>  *Zeros;
            CALLP   TIME_GetActivityDescription(TSEntryArray(Index).ActID:UserID:pUserActsDS:ActivityExists);

            IF  ActivityExists  =   'N';
                ValidScr01      =   'N';
                ErrorID         =   9;         //Activity ID is invalid.
                EXSR    GetErrorMsg;
                ErrorLine       =   Index;
                LEAVESR;
            ELSE;
                TSEntryArray(Index).Activity    =   UserActsDS.Activity;
            ENDIF;

        ELSE;

            TSEntryArray(Index).Activity    =   *Blanks;

            SELECT;
                WHEN    TSEntryArray(Index).StartHH     <>  *Zeros  OR
                        TSEntryArray(Index).StartMM     <>  *Zeros;

                        IF  UserProfileDS.PR0501    =   2   OR          //Start-End
                            UserProfileDS.PR0501    =   3;              //Start-Duration
                            ValidScr01  =   'N';
                            ErrorID     =   19;                         //Activity ID is blank.
                            EXSR    GetErrorMsg;
                            ErrorLine   =   Index;
                            LEAVESR;
                        ENDIF;

                WHEN    TSEntryArray(Index).EndHH       <>  *Zeros  OR
                        TSEntryArray(Index).EndMM       <>  *Zeros;

                        IF  UserProfileDS.PR0501    =   2   OR          //Start-End
                            UserProfileDS.PR0501    =   4;              //End-Duration
                            ValidScr01  =   'N';
                            ErrorID     =   19;                         //Activity ID is blank.
                            EXSR    GetErrorMsg;
                            ErrorLine   =   Index;
                            LEAVESR;
                        ENDIF;

                WHEN    TSEntryArray(Index).DurationHH  <>  *Zeros  OR
                        TSEntryArray(Index).DurationMM  <>  *Zeros;

                        IF  UserProfileDS.PR0501    =   1   OR          //Duration
                            UserProfileDS.PR0501    =   3   OR          //Start-Duration
                            UserProfileDS.PR0501    =   4;              //End-Duration
                            ValidScr01  =   'N';
                            ErrorID     =   19;                         //Activity ID is blank.
                            EXSR    GetErrorMsg;
                            ErrorLine   =   Index;
                            LEAVESR;
                        ENDIF;
            ENDSL;

        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Validate Start Time
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   VldtStartTime;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  TSEntryArray(Index).StartHH =   23  AND
            TSEntryArray(Index).StartMM =   59;
            ValidScr01  =   'N';
            ErrorID     =   20;         //Start Time is invalid.
            EXSR    GetErrorMsg;
            ErrorLine   =   Index;
            LEAVESR;
        ELSE;
            CALLP   TIME_ValidateStartTime(TSEntryArray(Index).StartHH:TSEntryArray(Index).StartMM:IsValid:ErrorID);

            IF  IsValid     =   'N';
                ValidScr01  =   'N';
                EXSR    GetErrorMsg;
                ErrorLine   =   Index;
                LEAVESR;
            ENDIF;

        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Validate End Time
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   VldtEndTime;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  TSEntryArray(Index).EndHH   =   *Zeros  AND
            TSEntryArray(Index).EndMM   =   *Zeros  AND
            TSEntryArray(Index).ActID   <>  *Zeros;

            IF  UserProfileDS.PR0501    =   2   OR          //Start-End
                UserProfileDS.PR0501    =   4;              //End-Duration
                ValidScr01  =   'N';
                ErrorID     =   21;                         //End Time is blank.
                EXSR    GetErrorMsg;
                ErrorLine   =   Index;
                LEAVESR;
            ENDIF;

        ELSE;
            CALLP   TIME_ValidateEndTime(TSEntryArray(Index).EndHH:TSEntryArray(Index).EndMM:IsValid:ErrorID);

            IF  IsValid     =   'N';
                ValidScr01  =   'N';
                EXSR    GetErrorMsg;
                ErrorLine   =   Index;
                LEAVESR;
            ENDIF;

        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Validate Duration
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   VldtDuration;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        IF  TSEntryArray(Index).DurationHH  =   *Zeros  AND
            TSEntryArray(Index).DurationMM  =   *Zeros  AND
            TSEntryArray(Index).ActID   <>  *Zeros;

            IF  UserProfileDS.PR0501    <>  2;          //Start-End
                ValidScr01  =   'N';
                ErrorID     =   22;                     //Duration is blank.
                EXSR    GetErrorMsg;
                ErrorLine   =   Index;
                LEAVESR;
            ENDIF;

        ELSE;
            CALLP   TIME_ValidateDuration(TSEntryArray(Index).DurationHH:TSEntryArray(Index).DurationMM:IsValid:ErrorID);

            IF  IsValid     =   'N';
                ValidScr01  =   'N';
                EXSR    GetErrorMsg;
                ErrorLine   =   Index;
                LEAVESR;
            ENDIF;

        ENDIF;

    ENDSR;
// ===================================================================================================================================
// On-Screen Check
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   OnScreenCheck;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            StartTime   =   %editc(TSEntryArray(Index).StartHH:'X') + %editc(TSEntryArray(Index).StartMM:'X') + '00';
            EndTime     =   %editc(TSEntryArray(Index).EndHH:'X') + %editc(TSEntryArray(Index).EndMM:'X') + '00';
            Duration    =   %editc(TSEntryArray(Index).DurationHH:'X') + %editc(TSEntryArray(Index).DurationMM:'X') + '00';
            MaxDuration =   %editc(%dec((%time('23.59.00':*ISO) - %hours(TSEntryArray(Index).StartHH) - %minutes(TSEntryArray(Index).StartMM))):'X');

            SELECT;
                WHEN    UserProfileDS.PR0501    =   2;          //Start-End
                    
                        SELECT;
                            WHEN    TSEntryArray(Index).ActID   <>  *Zeros  AND
                                    StartTime   =   EndTime;
                                    ValidScr01  =   'N';
                                    ErrorID     =   36;         //Start Time = End Time.
                                    EXSR    GetErrorMsg;
                                    ErrorLine   =   Index;
                                    LEAVESR;

                            WHEN    StartTime   >   EndTime;
                                    ValidScr01  =   'N';
                                    ErrorID     =   23;         //Start Time > End Time.
                                    EXSR    GetErrorMsg;
                                    ErrorLine   =   Index;
                                    LEAVESR;
                        ENDSL;

                WHEN    UserProfileDS.PR0501    =   3;          //Start-Duration
                        IF  Duration    >   MaxDuration;
                            ValidScr01  =   'N';
                            ErrorID     =   24;                 //Duration > Maximum Duration.
                            EXSR    GetErrorMsg;
                            ErrorLine   =   Index;
                            LEAVESR;
                        ENDIF;

                WHEN    UserProfileDS.PR0501    =   4;          //End-Duration
                        IF  Duration    >   EndTime;
                            ValidScr01  =   'N';
                            ErrorID     =   25;                 //Duration > End Time.
                            EXSR    GetErrorMsg;
                            ErrorLine   =   Index;
                            LEAVESR;
                        ENDIF;
            ENDSL;

        ENDDO;
        
    ENDSR;
// ===================================================================================================================================
// Compute Parameter
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ComputeParameter;

        IF  ValidScr01  =   'N';
            LEAVESR;
        ENDIF;

        SELECT;
            WHEN    UserProfileDS.PR0501    =   2;                  //Start-End
                    CALLP   TIME_ComputeDuration(pTSEntryArray);

            WHEN    UserProfileDS.PR0501    =   3;                  //Start-Duration
                    CALLP   TIME_ComputeEndTime(pTSEntryArray);

            WHEN    UserProfileDS.PR0501    =   4;                  //End-Duration
                    CALLP   TIME_ComputeStartTime(pTSEntryArray);
        ENDSL;
        
    ENDSR;
// ===================================================================================================================================
// Database Check
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   DatabaseCheck;

        IF  ValidScr01              =   'N' OR
            UserProfileDS.PR0501    =   1;          //Duration
            LEAVESR;
        ENDIF;

        CALLP   TIME_GetDatabaseArray(UserID:EntryDate:Count:pTmpArray);

        EXSR    PopArray;
        EXSR    SortArray;
        EXSR    CheckArray;

    ENDSR;
// ===================================================================================================================================
// Populate Array
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   PopArray;

            Index       =   *Zeros;
            TmpIndex    =   Count + 1;
        DOW Index   <   5;
            Index   =   Index + 1;

            IF  TSEntryArray(Index).DurationHH  <>  *Zeros  OR
                TSEntryArray(Index).DurationMM  <>  *Zeros;

                StartTime   =   %editc(TSEntryArray(Index).StartHH:'X') + %editc(TSEntryArray(Index).StartMM:'X') + '00';
                EndTime     =   %editc(TSEntryArray(Index).EndHH:'X') + %editc(TSEntryArray(Index).EndMM:'X') + '00';

                TmpArray(TmpIndex).EntryTime        =   StartTime;
                TmpArray(TmpIndex + 1).EntryTime    =   EndTime;
                TmpArray(TmpIndex).Status           =   'SS';
                TmpArray(TmpIndex + 1).Status       =   'SE';

                Count       =   Count + 2;
                TmpIndex    =   TmpIndex + 2;

            ENDIF;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Sort Array
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   SortArray;

            ProcessArray    =   'Y';
        DOW ProcessArray    =   'Y';
            ProcessArray    =   'N';

                TmpIndex        =   *Zeros;
            DOW TmpIndex + 1    <   Count;
                TmpIndex        =   TmpIndex + 1;

                SELECT;
                    WHEN    TmpArray(TmpIndex).EntryTime    =   TmpArray(TmpIndex + 1).EntryTime;

                            IF  TmpArray(TmpIndex + 1).Status       = 'SE'    OR
                                TmpArray(TmpIndex + 1).Status       = 'DE';
                                TmpEntryTime                        =   TmpArray(TmpIndex).EntryTime;
                                TmpStatus                           =   TmpArray(TmpIndex).Status;
            
                                TmpArray(TmpIndex).EntryTime        =   TmpArray(TmpIndex + 1).EntryTime;
                                TmpArray(TmpIndex).Status           =   TmpArray(TmpIndex + 1).Status;
            
                                TmpArray(TmpIndex + 1).EntryTime    =   TmpEntryTime;
                                TmpArray(TmpIndex + 1).Status       =   TmpStatus;
                            ENDIF;

                    WHEN    TmpArray(TmpIndex).EntryTime        >   TmpArray(TmpIndex + 1).EntryTime;
                            TmpEntryTime                        =   TmpArray(TmpIndex).EntryTime;
                            TmpStatus                           =   TmpArray(TmpIndex).Status;
        
                            TmpArray(TmpIndex).EntryTime        =   TmpArray(TmpIndex + 1).EntryTime;
                            TmpArray(TmpIndex).Status           =   TmpArray(TmpIndex + 1).Status;
        
                            TmpArray(TmpIndex + 1).EntryTime    =   TmpEntryTime;
                            TmpArray(TmpIndex + 1).Status       =   TmpStatus;
        
                            ProcessArray    =   'Y';
                ENDSL;

            ENDDO;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Check Array
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CheckArray;

            TmpIndex    =   *Zeros;
        DOW TmpIndex    <   Count;
            TmpIndex    =   TmpIndex + 2;

            SELECT;
                WHEN    TmpArray(TmpIndex).Status   =   'SS';

                            Index   =   *Zeros;
                        DOW Index   <   5;
                            Index   =   Index + 1;

                            StartTime   =   %editc(TSEntryArray(Index).StartHH:'X') + %editc(TSEntryArray(Index).StartMM:'X') + '00';

                            IF  TmpArray(TmpIndex).EntryTime    =   StartTime;

                                IF  UserProfileDS.PR0501    =   4;          //End-Duration
                                    ValidScr01  =   'N';
                                    ErrorID     =   26;                     //End Time or Duration is invalid.
                                    EXSR    GetErrorMsg;
                                    ErrorLine   =   Index;
                                    LEAVESR;
                                ELSE;
                                    ValidScr01  =   'N';
                                    ErrorID     =   20;                     //Start Time is invalid.
                                    EXSR    GetErrorMsg;
                                    ErrorLine   =   Index;
                                    LEAVESR;
                                ENDIF;

                            ENDIF;

                        ENDDO;

                WHEN    TmpArray(TmpIndex).Status   =   'DS';

                            Index   =   *Zeros;
                        DOW Index   <   5;
                            Index   =   Index + 1;

                            StartTime   =   %editc(TSEntryArray(Index).StartHH:'X') + %editc(TSEntryArray(Index).StartMM:'X') + '00';

                            IF  TmpArray(TmpIndex - 1).EntryTime    =   StartTime;

                                IF  UserProfileDS.PR0501    =   3;          //Start-Duration
                                    ValidScr01  =   'N';
                                    ErrorID     =   35;                     //Start Time or Duration is invalid.
                                    EXSR    GetErrorMsg;
                                    ErrorLine   =   Index;
                                    LEAVESR;
                                ELSE;
                                    ValidScr01  =   'N';
                                    ErrorID     =   34;                     //End Time is invalid.
                                    EXSR    GetErrorMsg;
                                    ErrorLine   =   Index;
                                    LEAVESR;
                                ENDIF;

                            ENDIF;

                        ENDDO;
            ENDSL;

        ENDDO;

    ENDSR;
// ===================================================================================================================================
// Total Hours Check
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   TotalHoursCheck;

        IF  ValidScr01              =   'N' OR
            UserProfileDS.PR0501    <>  1;          //Duration
            LEAVESR;
        ENDIF;
        
        CALLP   TIME_GetTotalDuration(UserID:EntryDate:TotalDurationHH:TotalDurationMM);

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            TotalDurationHH =   TotalDurationHH + TSEntryArray(Index).DurationHH;
            TotalDurationMM =   TotalDurationMM + TSEntryArray(Index).DurationMM;

        ENDDO;

        TotalDurationHH =   TotalDurationHH + %div(TotalDurationMM:60);
        TotalDurationMM =   %rem(TotalDurationMM:60);

        IF  TotalDurationHH >   23;
            ValidScr01      =   'N';
            ErrorID         =   27;         //Total Duration > 24 Hours.
            EXSR    GetErrorMsg;
        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Process Cancel
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcCancel;

        ProtectFields   =   'N';

    ENDSR;
// ===================================================================================================================================
// Process Request
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   ProcRequest;

        IF  ProtectFields   =   'N';
            ProtectFields   =   'Y';
            ValidScr01      =   'N';
        ELSE;
            EXSR    WriteToDB;
            EXSR    InitScreen;

        ENDIF;

    ENDSR;
// ===================================================================================================================================
// Write to Database
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   WriteToDB;

        SELECT;
            WHEN    UserProfileDS.PR1001    =   'DMY';
                    EntryDate   =   %dec(%date(EntryDate:*EUR));

            WHEN    UserProfileDS.PR1001    =   'MDY';
                    EntryDate   =   %dec(%date(EntryDate:*USA));
        ENDSL;

        CALLP   TIME_AddDetailEntries(UserID:EntryDate:pTSEntryArray);
        CALLP   TIME_BuildSummary(UserID:EntryDate:pTSEntryArray);

    ENDSR;
// ===================================================================================================================================
// Call View
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   CallView;

        TS0103(EntryDate:pUserProfileDS:pTSEntryArray:ProtectFields:F3Pressed:F12Pressed:Message:ErrorID:ErrorLine);

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

        CALLP   TIME_GetUserProfile(UserID:pUserProfileDS:UserExists);

        EXSR    InitScreen;

    ENDSR;
// ===================================================================================================================================
// Initialize Screen
// -----------------------------------------------------------------------------------------------------------------------------------
    BEGSR   InitScreen;

        CLEAR   TSEntryArray;

        TmpEntryDate   =   %editc(%dec(%date):'X');

        SELECT;
            WHEN    UserProfileDS.PR1001    =   'DMY';
                    TmpEntryDate    =   %subst(TmpEntryDate:7:2) + %subst(TmpEntryDate:5:2) + %subst(TmpEntryDate:1:4);
                    EntryDate       =   %dec(TmpEntryDate:8:0);

            WHEN    UserProfileDS.PR1001    =   'MDY';
                    TmpEntryDate    =   %subst(TmpEntryDate:5:2) + %subst(TmpEntryDate:7:2) + %subst(TmpEntryDate:1:4);
                    EntryDate       =   %dec(TmpEntryDate:8:0);

            WHEN    UserProfileDS.PR1001    =   'YMD';
                    EntryDate       =   %dec(TmpEntryDate:8:0);
        ENDSL;

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