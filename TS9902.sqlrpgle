**FREE
// ===================================================================================================================================
    CTL-OPT NOMAIN BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS9902
// Description      :   Main Procedures
// Author           :   Vinayak Mahajan
// Date written     :   August 31, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Files
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-F   TSDTL   USROPN KEYED USAGE(*INPUT) RENAME(TSDTL:F1FMT) PREFIX(F1);
    DCL-F   TSSUM   USROPN KEYED USAGE(*INPUT) RENAME(TSSUM:F2FMT) PREFIX(F2);
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9901PR.sqlrpgle
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9902PR.sqlrpgle
// ===================================================================================================================================
// Global Variables
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-S   ErrorDate   ZONED(8:0);
    DCL-S   ErrorTime   ZONED(6:0);
    DCL-S   ProcName    CHAR(100);
    DCL-S   Input       CHAR(1024);
// ===================================================================================================================================
// System Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-DS  *N          PSDS;
            #JobName    CHAR(10) POS(244);
            #User       CHAR(10) POS(254);
            #JobNo      CHAR(10) POS(264);
    END-DS;
// ===================================================================================================================================
// Procedures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// TIME_GetUserProfile(): Get User Profile
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetUserProfile EXPORT;

        DCL-PI      TIME_GetUserProfile;
        DCL-PARM    UserID          CHAR(10)    CONST;
        DCL-PARM    pUserProfileDS  POINTER     CONST;
        DCL-PARM    UserExists      CHAR(1);
        END-PI;

        DCL-DS  UserProfileDS   EXTNAME('TSPPARA') BASED(pUserProfileDS) QUALIFIED;
        END-DS;

        // Initialize Variables
        CLEAR   UserProfileDS;
        UserExists  =   *Blanks;

        EXEC SQL
        SELECT  *   INTO    :UserProfileDS
                    FROM    TSPPARA
                    WHERE   PRKEY1    =   :UserID;

        SELECT;
            WHEN    SQLCODE     =   *Zero;
                    UserExists  =   'Y';

            WHEN    SQLCODE     =   100;
                    UserExists  =   'N';

            OTHER;
                    UserExists  =   'N';
                    ErrorDate   =   %dec(%date);
                    ErrorTime   =   %dec(%time);
                    ProcName    =   'TIME_GetUserProfile';
                    Input       =   UserID;
                    CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDSL;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateDateFormat(): Validate Date Format
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateDateFormat EXPORT;

        DCL-PI      TIME_ValidateDateFormat;
        DCL-PARM    DateFormat  CHAR(3)     CONST;
        DCL-PARM    IsValid     CHAR(1);
        DCL-PARM    ErrorID     ZONED(5:0);
        END-PI;

        // Initialize Variables
        IsValid =   *Blanks;
        ErrorID =   *Zeros;

        SELECT;
            WHEN    DateFormat  =   'DMY';
                    IsValid     =   'Y';

            WHEN    DateFormat  =   'MDY';
                    IsValid     =   'Y';

            WHEN    DateFormat  =   'YMD';
                    IsValid     =   'Y';

            WHEN    DateFormat  =   *Blanks;
                    IsValid     =   'N';
                    ErrorID     =   1;          //Date Format is blank.

            OTHER;
                    IsValid     =   'N';
                    ErrorID     =   2;          //Date Format is invalid.
        ENDSL;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateDataFormat(): Validate Data Format
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateDataFormat EXPORT;

        DCL-PI      TIME_ValidateDataFormat;
        DCL-PARM    DataFormat  ZONED(1:0)  CONST;
        DCL-PARM    IsValid     CHAR(1);
        DCL-PARM    ErrorID     ZONED(5:0);
        END-PI;

        // Initialize Variables
        IsValid =   *Blanks;
        ErrorID =   *Zeros;

        SELECT;
            WHEN    DataFormat  =   1;          //Duration
                    IsValid     =   'Y';

            WHEN    DataFormat  =   2;          //Start-End
                    IsValid     =   'Y';

            WHEN    DataFormat  =   3;          //Start-Duration
                    IsValid     =   'Y';

            WHEN    DataFormat  =   4;          //End-Duration
                    IsValid     =   'Y';

            WHEN    DataFormat  =   *Zeros;
                    IsValid     =   'N';
                    ErrorID     =   3;          //Data Format is blank.

            OTHER;
                    IsValid     =   'N';
                    ErrorID     =   4;          //Data Format is invalid.
        ENDSL;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_InsertUserProfile(): Insert User Profile
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_InsertUserProfile EXPORT;

        DCL-PI      TIME_InsertUserProfile;
        DCL-PARM    pUserProfileDS  POINTER CONST;
        END-PI;

        DCL-DS  UserProfileDS   EXTNAME('TSPPARA') BASED(pUserProfileDS) QUALIFIED;
        END-DS;

        UserProfileDS.PR3001    =   'PRKEY1 = User ID';
        UserProfileDS.PR3002    =   'PR1001 = Date Entry Format';
        UserProfileDS.PR3003    =   'PR1002 = Date Display Format';
        UserProfileDS.PR3004    =   'PR0501 = Data Entry Format';
        UserProfileDS.PR3005    =   '1 = Duration, 2 = Start-End,';
        UserProfileDS.PR3006    =   '3 = Start-Duration,';
        UserProfileDS.PR3007    =   '4 = End-Duration';
        UserProfileDS.PR3008    =   'PR0502 = Activity ID';

        EXEC SQL
        INSERT  INTO    TSPPARA
                VALUES( :UserProfileDS);

        IF  SQLCODE     <>  *Zero;
            ErrorDate   =   %dec(%date);
            ErrorTime   =   %dec(%time);
            ProcName    =   'TIME_InsertUserProfile';
            Input       =   *Blanks;
            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_UpdateUserProfile(): Update User Profile
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_UpdateUserProfile EXPORT;

        DCL-PI      TIME_UpdateUserProfile;
        DCL-PARM    pUserProfileDS  POINTER CONST;
        END-PI;

        DCL-DS  UserProfileDS   EXTNAME('TSPPARA') BASED(pUserProfileDS) QUALIFIED;
        END-DS;

        EXEC SQL
        UPDATE  TSPPARA
                SET     ROW     =   :UserProfileDS
                WHERE   PRKEY1  =   :UserProfileDS.PRKEY1;

        IF  SQLCODE     <>  *Zero;
            ErrorDate   =   %dec(%date);
            ErrorTime   =   %dec(%time);
            ProcName    =   'TIME_UpdateUserProfile';
            Input       =   *Blanks;
            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetErrorMessage(): Get Error Message
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetErrorMessage EXPORT;

        DCL-PI      TIME_GetErrorMessage;
        DCL-PARM    ErrorID     ZONED(5:0)  CONST;
        DCL-PARM    LangCode    CHAR(3)     CONST;
        DCL-PARM    ErrorMsg    CHAR(78);
        END-PI;

        // Initialize Variables
        ErrorMsg    =   *Blanks;

        EXEC SQL
        SELECT  ERRORMSG    INTO    :ErrorMsg
                            FROM    ERRMSG
                            WHERE   ERRORID     =   :ErrorID    AND
                                    LANGCODE    =   :LangCode;

        IF  SQLCODE     <>  *Zero;
            ErrorDate   =   %dec(%date);
            ErrorTime   =   %dec(%time);
            ProcName    =   'TIME_GetErrorMessage';
            Input       =   %char(ErrorID) + ' ' + LangCode;
            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetAllActivities(): Get All Activities
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetAllActivities EXPORT;

        DCL-PI      TIME_GetAllActivities;
        DCL-PARM    UserID              CHAR(10)    CONST;
        DCL-PARM    Count               ZONED(5:0);
        DCL-PARM    pActivitiesArray    POINTER     CONST;
        END-PI;

        DCL-S   TmpUserID       CHAR(10);
        DCL-S   TmpActivityID   ZONED(5:0);
        DCL-S   TmpActivity     CHAR(50);

        DCL-DS  ActivitiesArray BASED(pActivitiesArray) DIM(999) QUALIFIED;
                Opt             ZONED(1:0);
                User            CHAR(10);
                ActivityID      ZONED(5:0);
                Activity        CHAR(50);
        END-DS;

        //Initialize Variables
        Count   =   *Zeros;
        CLEAR   ActivitiesArray;

        EXEC SQL
        DECLARE C1  CURSOR  FOR
                    SELECT  *   FROM    USRACTS
                                WHERE   USER    =   :UserID
                                ORDER   BY  ACTID;

        EXEC SQL
        OPEN C1;

        EXEC SQL
        FETCH   FROM    C1
                INTO    :TmpUserID, :TmpActivityID, :TmpActivity;

        DOW SQLCODE <>  100;
            Count   =   Count + 1;

            ActivitiesArray(Count).Opt          =   0;
            ActivitiesArray(Count).User         =   TmpUserID;
            ActivitiesArray(Count).ActivityID   =   TmpActivityID;
            ActivitiesArray(Count).Activity     =   TmpActivity;

            EXEC SQL
            FETCH   FROM    C1
                    INTO    :TmpUserID, :TmpActivityID, :TmpActivity;

        ENDDO;

        EXEC SQL
        CLOSE C1;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetNextActivityID(): Get Next Activity ID
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetNextActivityID  EXPORT;

        DCL-PI      TIME_GetNextActivityID;
        DCL-PARM    UserID      CHAR(10)    CONST;
        DCL-PARM    ActivityID  ZONED(5:0);
        END-PI;

        //Initialize Variables
        ActivityID   =  *Zeros;

        EXEC SQL
        SELECT  PR0502  INTO    :ActivityID
                        FROM    TSPPARA
                        WHERE   PRKEY1  =   :UserID;

        ActivityID  =   ActivityID + 1;

        EXEC SQL
        UPDATE  TSPPARA
                SET     PR0502  =   :ActivityID
                WHERE   PRKEY1  =   :UserID;

        IF  SQLCODE     <>  *Zeros;
            ErrorDate   =   %dec(%date);
            ErrorTime   =   %dec(%time);
            ProcName    =   'TIME_GetNextActivityID';
            Input       =   UserID;
            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_AddActivity(): Add Activity
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_AddActivity EXPORT;

        DCL-PI      TIME_AddActivity;
        DCL-PARM    pActivityDS POINTER CONST;
        END-PI;

        DCL-DS  ActivityDS  BASED(pActivityDS) QUALIFIED;
                Opt         ZONED(1:0);
                User        CHAR(10);
                ActivityID  ZONED(5:0);
                Activity    CHAR(50);
        END-DS;

        EXEC SQL
        INSERT  INTO    USRACTS
                VALUES( :ActivityDS.User,
                        :ActivityDS.ActivityID,
                        :ActivityDS.Activity);

        IF  SQLCODE     <>  *Zeros;
            ErrorDate   =   %dec(%date);
            ErrorTime   =   %dec(%time);
            ProcName    =   'TIME_AddActivity';
            Input       =   *Blanks;
            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ChangeActivity(): Change Activity
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ChangeActivity EXPORT;

        DCL-PI      TIME_ChangeActivity;
        DCL-PARM    pActivityDS POINTER CONST;
        END-PI;

        DCL-DS  ActivityDS  BASED(pActivityDS) QUALIFIED;
                Opt         ZONED(1:0);
                User        CHAR(10);
                ActivityID  ZONED(5:0);
                Activity    CHAR(50);
        END-DS;

        EXEC SQL
        UPDATE  USRACTS
                SET     ACTIVITY    =   :ActivityDS.Activity
                WHERE   USER        =   :ActivityDS.User        AND
                        ACTID       =   :ActivityDS.ActivityID;

        IF  SQLCODE     <>  *Zeros;
            ErrorDate   =   %dec(%date);
            ErrorTime   =   %dec(%time);
            ProcName    =   'TIME_ChangeActivity';
            Input       =   *Blanks;
            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_DeleteActivity(): Delete Activity
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_DeleteActivity EXPORT;

        DCL-PI      TIME_DeleteActivity;
        DCL-PARM    pActivityDS POINTER CONST;
        END-PI;

        DCL-DS  ActivityDS  BASED(pActivityDS) QUALIFIED;
                Opt         ZONED(1:0);
                User        CHAR(10);
                ActivityID  ZONED(5:0);
                Activity    CHAR(50);
        END-DS;

        EXEC SQL
        DELETE  FROM    USRACTS
                WHERE   USER    =   :ActivityDS.User        AND
                        ACTID   =   :ActivityDS.ActivityID;

        IF  SQLCODE     <>  *Zeros;
            ErrorDate   =   %dec(%date);
            ErrorTime   =   %dec(%time);
            ProcName    =   'TIME_DeleteActivity';
            Input       =   *Blanks;
            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateActivity(): Validate Activity
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateActivity EXPORT;

        DCL-PI      TIME_ValidateActivity;
        DCL-PARM    Activity    CHAR(50)    CONST;
        DCL-PARM    IsValid     CHAR(1);
        DCL-PARM    ErrorID     ZONED(5:0);
        END-PI;

        // Initialize Variables
        IsValid =   *Blanks;
        ErrorID =   *Zeros;

        IF  Activity    =   *Blanks;
            IsValid     =   'N';
            ErrorID     =   11;         //Activity Description is blank.
        ELSE;
            IsValid     =   'Y';
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateStartTime(): Validate Start Time
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateStartTime EXPORT;

        DCL-PI      TIME_ValidateStartTime;
        DCL-PARM    StartHH ZONED(2:0)  CONST;
        DCL-PARM    StartMM ZONED(2:0)  CONST;
        DCL-PARM    IsValid CHAR(1);
        DCL-PARM    ErrorID ZONED(5:0);
        END-PI;

        // Initialize Variables
        ErrorID =   *Zeros;

        CALLP   TIME_ValidateHours(StartHH:IsValid);

        IF  IsValid =   'N';
            ErrorID =   12;         //Start Hours is invalid.
            RETURN;
        ENDIF;

        CALLP   TIME_ValidateMinutes(StartMM:IsValid);

        IF  IsValid =   'N';
            ErrorID =   13;         //Start Minutes is invalid.
            RETURN;
        ENDIF;

        IsValid =   'Y';

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateEndTime(): Validate End Time
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateEndTime EXPORT;

        DCL-PI      TIME_ValidateEndTime;
        DCL-PARM    EndHH   ZONED(2:0)  CONST;
        DCL-PARM    EndMM   ZONED(2:0)  CONST;
        DCL-PARM    IsValid CHAR(1);
        DCL-PARM    ErrorID ZONED(5:0);
        END-PI;

        // Initialize Variables
        ErrorID =   *Zeros;

        CALLP   TIME_ValidateHours(EndHH:IsValid);

        IF  IsValid =   'N';
            ErrorID =   14;         //End Hours is invalid.
            RETURN;
        ENDIF;

        CALLP   TIME_ValidateMinutes(EndMM:IsValid);

        IF  IsValid =   'N';
            ErrorID =   15;         //End Minutes is invalid.
            RETURN;
        ENDIF;

        IsValid =   'Y';

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateDuration(): Validate Duration
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateDuration EXPORT;

        DCL-PI      TIME_ValidateDuration;
        DCL-PARM    DurationHH  ZONED(2:0)  CONST;
        DCL-PARM    DurationMM  ZONED(2:0)  CONST;
        DCL-PARM    IsValid     CHAR(1);
        DCL-PARM    ErrorID     ZONED(5:0);
        END-PI;

        // Initialize Variables
        IsValid =   *Blanks;
        ErrorID =   *Zeros;

        CALLP   TIME_ValidateHours(DurationHH:IsValid);

        IF  IsValid =   'N';
            ErrorID =   16;         //Duration Hours is invalid.
            RETURN;
        ENDIF;

        CALLP   TIME_ValidateMinutes(DurationMM:IsValid);

        IF  IsValid =   'N';
            ErrorID =   17;         //Duration Minutes is invalid.
            RETURN;
        ENDIF;

        IsValid =   'Y';

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateHours(): Validate Hours
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateHours EXPORT;

        DCL-PI      TIME_ValidateHours;
        DCL-PARM    Hours   ZONED(2:0)  CONST;
        DCL-PARM    IsValid CHAR(1);
        END-PI;

        // Initialize Variables
        IsValid =   *Blanks;

        IF  Hours   >   23;
            IsValid =   'N';
        ELSE;
            IsValid =   'Y';
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ValidateMinutes(): Validate Minutes
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ValidateMinutes EXPORT;

        DCL-PI      TIME_ValidateMinutes;
        DCL-PARM    Minutes ZONED(2:0)  CONST;
        DCL-PARM    IsValid CHAR(1);
        END-PI;

        // Initialize Variables
        IsValid =   *Blanks;

        IF  Minutes >   59;
            IsValid =   'N';
        ELSE;
            IsValid =   'Y';
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ComputeStartTime(): Compute Start Time
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ComputeStartTime EXPORT;

        DCL-PI      TIME_ComputeStartTime;
        DCL-PARM    pTSEntryArray   POINTER CONST;
        END-PI;

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

        DCL-S   StartTime   CHAR(8);
        DCL-S   EndTime     CHAR(8);
        DCL-S   Index       ZONED(1:0);

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            EndTime =   %editc(TSEntryArray(Index).EndHH:'X') + '.' + %editc(TSEntryArray(Index).EndMM:'X') + '.' + '00';

            StartTime   =   %char((%time(EndTime:*ISO) - %hours(TSEntryArray(Index).DurationHH)):*ISO);
            StartTime   =   %char((%time(StartTime:*ISO) - %minutes(TSEntryArray(Index).DurationMM)):*ISO);

            TSEntryArray(Index).StartHH   =   %dec(%subst(StartTime:1:2):2:0);
            TSEntryArray(Index).StartMM   =   %dec(%subst(StartTime:4:2):2:0);

        ENDDO;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ComputeEndTime(): Compute End Time
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ComputeEndTime EXPORT;

        DCL-PI      TIME_ComputeEndTime;
        DCL-PARM    pTSEntryArray   POINTER CONST;
        END-PI;

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

        DCL-S   StartTime   CHAR(8);
        DCL-S   EndTime     CHAR(8);
        DCL-S   Index       ZONED(1:0);

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            StartTime   =   %editc(TSEntryArray(Index).StartHH:'X') + '.' + %editc(TSEntryArray(Index).StartMM:'X') + '.' + '00';

            EndTime =   %char((%time(StartTime:*ISO) + %hours(TSEntryArray(Index).DurationHH)):*ISO);
            EndTime =   %char((%time(EndTime:*ISO) + %minutes(TSEntryArray(Index).DurationMM)):*ISO);

            TSEntryArray(Index).EndHH   =   %dec(%subst(EndTime:1:2):2:0);
            TSEntryArray(Index).EndMM   =   %dec(%subst(EndTime:4:2):2:0);

        ENDDO;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_ComputeDuration(): Compute Duration
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_ComputeDuration EXPORT;

        DCL-PI      TIME_ComputeDuration;
        DCL-PARM    pTSEntryArray   POINTER CONST;
        END-PI;

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

        DCL-S   EndTime     CHAR(8);
        DCL-S   Duration    CHAR(8);
        DCL-S   Index       ZONED(1:0);

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            EndTime =   %editc(TSEntryArray(Index).EndHH:'X') + '.' + %editc(TSEntryArray(Index).EndMM:'X') + '.' + '00';

            Duration    =   %char((%time(EndTime:*ISO) - %hours(TSEntryArray(Index).StartHH)):*ISO);
            Duration    =   %char((%time(Duration:*ISO) - %minutes(TSEntryArray(Index).StartMM)):*ISO);

            TSEntryArray(Index).DurationHH  =   %dec(%subst(Duration:1:2):2:0);
            TSEntryArray(Index).DurationMM  =   %dec(%subst(Duration:4:2):2:0);

        ENDDO;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetActivityDescription(): Get Activity Description
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetActivityDescription EXPORT;

        DCL-PI      TIME_GetActivityDescription;
        DCL-PARM    ActID           ZONED(5:0)  CONST;
        DCL-PARM    UserID          CHAR(10)    CONST;
        DCL-PARM    pUserActsDS     POINTER     CONST;
        DCL-PARM    ActivityExists  CHAR(1);
        END-PI;

        DCL-DS  UserActsDS  EXTNAME('USRACTS') BASED(pUserActsDS) QUALIFIED;
        END-DS;

        //Initialize Variables
        CLEAR   UserActsDS;
        ActivityExists  =   *Blanks;

        EXEC SQL
        SELECT  *   INTO    :UserActsDS
                    FROM    USRACTS
                    WHERE   USER    =   :UserID AND
                            ACTID   =   :ActID;

        SELECT;
            WHEN    SQLCODE         =   *Zero;
                    ActivityExists  =   'Y';

            WHEN    SQLCODE         =   100;
                    ActivityExists  =   'N';

            OTHER;
                    ActivityExists  =   'N';
                    ErrorDate       =   %dec(%date);
                    ErrorTime       =   %dec(%time);
                    ProcName        =   'TIME_GetActivityDescription';
                    Input           =   %char(ActID) + ' ' + UserID;
                    CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
        ENDSL;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_AddDetailEntries(): Add Detail Entries
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_AddDetailEntries EXPORT;

        DCL-PI      TIME_AddDetailEntries;
        DCL-PARM    UserID          CHAR(10)    CONST;
        DCL-PARM    EntryDate       ZONED(8:0)  CONST;
        DCL-PARM    pTSEntryArray   POINTER     CONST;
        END-PI;

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

        DCL-DS  TSDetailDS  EXTNAME('TSDTL') QUALIFIED INZ;
        END-DS;

        DCL-S   Index   ZONED(1:0);

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            IF  TSEntryArray(Index).ActID   <>  *Zeros;

                TSDetailDS.User             =   UserID;
                TSDetailDS.EntryDate        =   EntryDate;
                TSDetailDS.StartHH          =   TSEntryArray(Index).StartHH;
                TSDetailDS.StartMM          =   TSEntryArray(Index).StartMM;
                TSDetailDS.ActID            =   TSEntryArray(Index).ActID;
                TSDetailDS.EndHH            =   TSEntryArray(Index).EndHH;
                TSDetailDS.EndMM            =   TSEntryArray(Index).EndMM;
                TSDetailDS.DrtnHH           =   TSEntryArray(Index).DurationHH;
                TSDetailDS.DrtnMM           =   TSEntryArray(Index).DurationMM;

                EXEC SQL
                INSERT  INTO    TSDTL
                        VALUES( :TSDetailDS);

                IF  SQLCODE     <>  *Zeros;
                    ErrorDate   =   %dec(%date);
                    ErrorTime   =   %dec(%time);
                    ProcName    =   'TIME_AddDetailEntries';
                    Input       =   UserID + ' ' + %editc(EntryDate:'X');
                    CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
                ENDIF;

                CLEAR   TSDetailDS;

            ENDIF;

        ENDDO;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_BuildSummary(): Build Summary
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_BuildSummary EXPORT;

        DCL-PI      TIME_BuildSummary;
        DCL-PARM    UserID          CHAR(10)    CONST;
        DCL-PARM    EntryDate       ZONED(8:0)  CONST;
        DCL-PARM    pTSEntryArray   POINTER     CONST;
        END-PI;

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

        DCL-DS  TSSummaryDS  EXTNAME('TSSUM') QUALIFIED INZ;
        END-DS;

        DCL-S   TmpActID    ZONED(5:0);
        DCL-S   TmpDrtnHH   ZONED(5:0);
        DCL-S   TmpDrtnMM   ZONED(5:0);
        DCL-S   Index       ZONED(1:0);
        DCL-S   EntryExists CHAR(1);

            Index   =   *Zeros;
        DOW Index   <   5;
            Index   =   Index + 1;

            IF  TSEntryArray(Index).ActID   <>  *Zeros;

                TmpActID    =   TSEntryArray(Index).ActID;

                EXEC SQL
                SELECT  DRTNHH, DRTNMM  INTO    :TmpDrtnHH, :TmpDrtnMM
                                        FROM    TSSUM
                                        WHERE   USER        =   :UserID     AND
                                                ENTRYDATE   =   :EntryDate  AND
                                                ACTID       =   :TmpActID;

                SELECT;
                    WHEN    SQLCODE     =   *Zeros;
                            EntryExists =   'Y';

                    WHEN    SQLCODE     =   100;
                            EntryExists =   'N';

                    OTHER;
                            ErrorDate   =   %dec(%date);
                            ErrorTime   =   %dec(%time);
                            ProcName    =   'TIME_BuildSummary';
                            Input       =   UserID + ' ' + %editc(EntryDate:'X');
                            CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
                ENDSL;

                IF  EntryExists =   'Y';
                    TmpDrtnHH   =   TmpDrtnHH + TSEntryArray(Index).DurationHH;
                    TmpDrtnMM   =   TmpDrtnMM + TSEntryArray(Index).DurationMM;

                    TmpDrtnHH   =   TmpDrtnHH +   %div(TmpDrtnMM:60);
                    TmpDrtnMM   =   %rem(TmpDrtnMM:60);

                    EXEC SQL
                    UPDATE  TSSUM
                            SET     DRTNHH      =   :TmpDrtnHH,
                                    DRTNMM      =   :TmpDrtnMM
                            WHERE   USER        =   :UserID     AND
                                    ENTRYDATE   =   :EntryDate  AND
                                    ACTID       =   :TmpActID;

                    IF  SQLCODE     <>  *Zeros;
                        ErrorDate   =   %dec(%date);
                        ErrorTime   =   %dec(%time);
                        ProcName    =   'TIME_BuildSummary';
                        Input       =   UserID + ' ' + %editc(EntryDate:'X');
                        CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
                    ENDIF;

                ELSE;

                    TSSummaryDS.User        =   UserID;
                    TSSummaryDS.EntryDate   =   EntryDate;
                    TSSummaryDS.DrtnHH      =   TSEntryArray(Index).DurationHH;
                    TSSummaryDS.DrtnMM      =   TSEntryArray(Index).DurationMM;
                    TSSummaryDS.ActID       =   TSEntryArray(Index).ActID;

                    EXEC SQL
                    INSERT  INTO    TSSUM
                            VALUES( :TSSummaryDS);

                    IF  SQLCODE     <>  *Zeros;
                        ErrorDate   =   %dec(%date);
                        ErrorTime   =   %dec(%time);
                        ProcName    =   'TIME_BuildSummary';
                        Input       =   UserID + ' ' + %editc(EntryDate:'X');
                        CALLP   COMN_LogError(#User:ErrorDate:ErrorTime:SQLCODE:ProcName:Input:#JobName:#JobNo);
                    ENDIF;
                ENDIF;

                CLEAR   TSSummaryDS;
                EntryExists =   *Blanks;

            ENDIF;

        ENDDO;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetTSDetails(): Get TSDetails
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetTSDetails EXPORT;

        DCL-PI      TIME_GetTSDetails;
        DCL-PARM    UserID          CHAR(10)    CONST;
        DCL-PARM    pFromDTL        POINTER     CONST;
        DCL-PARM    pToDTL          POINTER     CONST;
        DCL-PARM    Count           ZONED(5:0);
        DCL-PARM    pTSDetailsArray POINTER     CONST;
        END-PI;

        DCL-DS  FromDTL     BASED(pFromDTL) QUALIFIED;
                EntryDate   ZONED(8:0);
                ActID       ZONED(5:0);
                StartHH     ZONED(2:0);
                StartMM     ZONED(2:0);
                EndHH       ZONED(2:0);
                EndMM       ZONED(2:0);
                DrtnHH      ZONED(2:0);
                DrtnMM      ZONED(2:0);
        END-DS;

        DCL-DS  ToDTL       BASED(pToDTL) QUALIFIED;
                EntryDate   ZONED(8:0);
                ActID       ZONED(5:0);
                StartHH     ZONED(2:0);
                StartMM     ZONED(2:0);
                EndHH       ZONED(2:0);
                EndMM       ZONED(2:0);
                DrtnHH      ZONED(2:0);
                DrtnMM      ZONED(2:0);
        END-DS;

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

        DCL-DS  UserProfileDS   EXTNAME('TSPPARA') QUALIFIED INZ;
        END-DS;

        DCL-S   TmpActivity     CHAR(50);
        DCL-S   TmpEntryDate    CHAR(8);
        DCL-S   TmpFromDate     CHAR(8);
        DCL-S   TmpToDate       CHAR(8);
        DCL-S   FromDate        ZONED(8:0);
        DCL-S   ToDate          ZONED(8:0);
        DCL-S   pUserProfileDS  POINTER     INZ(%addr(UserProfileDS));
        DCL-S   UserExists      CHAR(1);
        DCL-S   ValidF1         CHAR(1);
        DCL-S   DBStartTime     ZONED(4:0);
        DCL-S   DBEndTime       ZONED(4:0);
        DCL-S   DBDuration      ZONED(4:0);
        DCL-S   FromStartTime   ZONED(4:0);
        DCL-S   FromEndTime     ZONED(4:0);
        DCL-S   FromDuration    ZONED(4:0);
        DCL-S   ToStartTime     ZONED(4:0);
        DCL-S   ToEndTime       ZONED(4:0);
        DCL-S   ToDuration      ZONED(4:0);

        //Initialize Variables
        Count   =   *Zeros;
        CLEAR   TSDetailsArray;

        CALLP   TIME_GetUserProfile(UserID:pUserProfileDS:UserExists);

        TmpFromDate =   %editc(FromDTL.EntryDate:'X');
        TmpToDate   =   %editc(ToDTL.EntryDate:'X');

        SELECT;
            WHEN    UserProfileDS.PR1001    =   'DMY';
                    TmpFromDate             =   %subst(TmpFromDate:5:4) + %subst(TmpFromDate:3:2) + %subst(TmpFromDate:1:2);
                    TmpToDate               =   %subst(TmpToDate:5:4) + %subst(TmpToDate:3:2) + %subst(TmpToDate:1:2);
                    FromDate                =   %dec(TmpFromDate:8:0);
                    ToDate                  =   %dec(TmpToDate:8:0);

            WHEN    UserProfileDS.PR1001    =   'MDY';
                    TmpFromDate             =   %subst(TmpFromDate:5:4) + %subst(TmpFromDate:1:2) + %subst(TmpFromDate:3:2);
                    TmpToDate               =   %subst(TmpToDate:5:4) + %subst(TmpToDate:1:2) + %subst(TmpToDate:3:2);
                    FromDate                =   %dec(TmpFromDate:8:0);
                    ToDate                  =   %dec(TmpToDate:8:0);

            WHEN    UserProfileDS.PR1001    =   'YMD';
                    FromDate                =   FromDTL.EntryDate;
                    ToDate                  =   ToDTL.EntryDate;
        ENDSL;

        OPEN    TSDTL;

        SETLL   *Hival  F1FMT;

        READP   F1FMT;

        DOW NOT %eof;

            ValidF1 =   'Y';

            DBStartTime     =   %dec(%editc(F1STARTHH:'X') + %editc(F1STARTMM:'X'):4:0);
            DBEndTime       =   %dec(%editc(F1ENDHH:'X') + %editc(F1ENDMM:'X'):4:0);
            DBDuration      =   %dec(%editc(F1DRTNHH:'X') + %editc(F1DRTNMM:'X'):4:0);

            FromStartTime   =   %dec(%editc(FromDTL.StartHH:'X') + %editc(FromDTL.StartMM:'X'):4:0);
            FromEndTime     =   %dec(%editc(FromDTL.EndHH:'X') + %editc(FromDTL.EndMM:'X'):4:0);
            FromDuration    =   %dec(%editc(FromDTL.DrtnHH:'X') + %editc(FromDTL.DrtnMM:'X'):4:0);

            ToStartTime     =   %dec(%editc(ToDTL.StartHH:'X') + %editc(ToDTL.StartMM:'X'):4:0);
            ToEndTime       =   %dec(%editc(ToDTL.EndHH:'X') + %editc(ToDTL.EndMM:'X'):4:0);
            ToDuration      =   %dec(%editc(ToDTL.DrtnHH:'X') + %editc(ToDTL.DrtnMM:'X'):4:0);

            SELECT;
                WHEN    F1USER      <>  UserID;
                        ValidF1     =   'N';

                WHEN    F1ENTRYDATE >   ToDate      OR
                        F1ENTRYDATE <   FromDate;
                        ValidF1     =   'N';

                WHEN    F1ACTID     >   ToDTL.ActID OR
                        F1ACTID     <   FromDTL.ActID;
                        ValidF1     =   'N';

                WHEN    DBStartTime >   ToStartTime OR
                        DBStartTime <   FromStartTime;
                        ValidF1     =   'N';

                WHEN    DBEndTime   >   ToEndTime   OR
                        DBEndTime   <   FromEndTime;
                        ValidF1     =   'N';

                WHEN    DBDuration  >   ToDuration  OR
                        DBDuration  <   FromDuration;
                        ValidF1     =   'N';
            ENDSL;

            IF  ValidF1 =   'N';
                READP   F1FMT;
                ITER;
            ENDIF;

            Count   =   Count + 1;

            TmpEntryDate    =   %editc(F1ENTRYDATE:'X');

            SELECT;
                WHEN    UserProfileDS.PR1002    =   'DMY';
                        TmpEntryDate            =   %subst(TmpEntryDate:7:2) + %subst(TmpEntryDate:5:2) + %subst(TmpEntryDate:1:4);

                WHEN    UserProfileDS.PR1002    =   'MDY';
                        TmpEntryDate            =   %subst(TmpEntryDate:5:2) + %subst(TmpEntryDate:7:2) + %subst(TmpEntryDate:1:4);

                        //Date is already in YMD Format.
            ENDSL;

            TSDetailsArray(Count).EntryDate     =   %dec(TmpEntryDate:8:0);
            TSDetailsArray(Count).StartHH       =   F1STARTHH;
            TSDetailsArray(Count).StartMM       =   F1STARTMM;
            TSDetailsArray(Count).EndHH         =   F1ENDHH;
            TSDetailsArray(Count).EndMM         =   F1ENDMM;
            TSDetailsArray(Count).DurationHH    =   F1DRTNHH;
            TSDetailsArray(Count).DurationMM    =   F1DRTNMM;
            TSDetailsArray(Count).ActID         =   F1ACTID;

            EXEC SQL
            SELECT  ACTIVITY    INTO    :TmpActivity
                                FROM    USRACTS
                                WHERE   USER    =   :UserID             AND
                                        ACTID   =   :F1ACTID;

            TSDetailsArray(Count).Activity      =   TmpActivity;

            READP   F1FMT;

        ENDDO;

        CLOSE   TSDTL;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetTSSummary(): Get TSSummary
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetTSSummary EXPORT;

        DCL-PI      TIME_GetTSSummary;
        DCL-PARM    UserID          CHAR(10)    CONST;
        DCL-PARM    pFromSUM        POINTER     CONST;
        DCL-PARM    pToSUM          POINTER     CONST;
        DCL-PARM    Count           ZONED(5:0);
        DCL-PARM    pTSSummaryArray POINTER     CONST;
        END-PI;

        DCL-DS  FromSUM     BASED(pFromSUM) QUALIFIED;
                EntryDate   ZONED(8:0);
                ActID       ZONED(5:0);
                DrtnHH      ZONED(2:0);
                DrtnMM      ZONED(2:0);
        END-DS;

        DCL-DS  ToSUM       BASED(pToSUM)   QUALIFIED;
                EntryDate   ZONED(8:0);
                ActID       ZONED(5:0);
                DrtnHH      ZONED(2:0);
                DrtnMM      ZONED(2:0);
        END-DS;

        DCL-DS  TSSummaryArray  BASED(pTSSummaryArray) DIM(999) QUALIFIED;
                Opt             ZONED(1:0);
                EntryDate       ZONED(8:0);
                DurationHH      ZONED(2:0);
                DurationMM      ZONED(2:0);
                ActID           ZONED(5:0);
                Activity        CHAR(50);
        END-DS;

        DCL-DS  UserProfileDS   EXTNAME('TSPPARA') QUALIFIED INZ;
        END-DS;

        DCL-S   TmpActivity     CHAR(50);
        DCL-S   TmpEntryDate    CHAR(8);
        DCL-S   TmpFromDate     CHAR(8);
        DCL-S   TmpToDate       CHAR(8);
        DCL-S   FromDate        ZONED(8:0);
        DCL-S   ToDate          ZONED(8:0);
        DCL-S   pUserProfileDS  POINTER     INZ(%addr(UserProfileDS));
        DCL-S   UserExists      CHAR(1);
        DCL-S   ValidF2         CHAR(1);
        DCL-S   DBDuration      ZONED(4:0);
        DCL-S   FromDuration    ZONED(4:0);
        DCL-S   ToDuration      ZONED(4:0);

        //Initialize Variables
        Count   =   *Zeros;
        CLEAR   TSSummaryArray;

        CALLP   TIME_GetUserProfile(UserID:pUserProfileDS:UserExists);

        TmpFromDate =   %editc(FromSUM.EntryDate:'X');
        TmpToDate   =   %editc(ToSUM.EntryDate:'X');

        SELECT;
            WHEN    UserProfileDS.PR1001    =   'DMY';
                    TmpFromDate             =   %subst(TmpFromDate:5:4) + %subst(TmpFromDate:3:2) + %subst(TmpFromDate:1:2);
                    TmpToDate               =   %subst(TmpToDate:5:4) + %subst(TmpToDate:3:2) + %subst(TmpToDate:1:2);
                    FromDate                =   %dec(TmpFromDate:8:0);
                    ToDate                  =   %dec(TmpToDate:8:0);

            WHEN    UserProfileDS.PR1001    =   'MDY';
                    TmpFromDate             =   %subst(TmpFromDate:5:4) + %subst(TmpFromDate:1:2) + %subst(TmpFromDate:3:2);
                    TmpToDate               =   %subst(TmpToDate:5:4) + %subst(TmpToDate:1:2) + %subst(TmpToDate:3:2);
                    FromDate                =   %dec(TmpFromDate:8:0);
                    ToDate                  =   %dec(TmpToDate:8:0);

            WHEN    UserProfileDS.PR1001    =   'YMD';
                    //Date is already in YMD Format.
                    FromDate                =   FromSUM.EntryDate;
                    ToDate                  =   ToSUM.EntryDate;
        ENDSL;

        OPEN    TSSUM;

        SETLL   *Hival  F2FMT;

        READP   F2FMT;

        DOW NOT %eof;

            ValidF2 =   'Y';

            DBDuration      =   %dec(%editc(F2DRTNHH:'X') + %editc(F2DRTNMM:'X'):4:0);
            FromDuration    =   %dec(%editc(FromSUM.DrtnHH:'X') + %editc(FromSUM.DrtnMM:'X'):4:0);
            ToDuration      =   %dec(%editc(ToSUM.DrtnHH:'X') + %editc(ToSUM.DrtnMM:'X'):4:0);

            SELECT;
                WHEN    F2USER      <>  UserID;
                        ValidF2     =   'N';

                WHEN    F2ENTRYDATE >   ToDate      OR
                        F2ENTRYDATE <   FromDate;
                        ValidF2     =   'N';

                WHEN    F2ACTID     >   ToSUM.ActID OR
                        F2ACTID     <   FromSUM.ActID;
                        ValidF2     =   'N';

                WHEN    DBDuration  >   ToDuration  OR
                        DBDuration  <   FromDuration;
                        ValidF2     =   'N';
            ENDSL;

            IF  ValidF2 =   'N';
                READP   F2FMT;
                ITER;
            ENDIF;

            Count   =   Count + 1;

            TmpEntryDate    =   %editc(F2ENTRYDATE:'X');

            SELECT;
                WHEN    UserProfileDS.PR1002    =   'DMY';
                        TmpEntryDate            =   %subst(TmpEntryDate:7:2) + %subst(TmpEntryDate:5:2) + %subst(TmpEntryDate:1:4);

                WHEN    UserProfileDS.PR1002    =   'MDY';
                        TmpEntryDate            =   %subst(TmpEntryDate:5:2) + %subst(TmpEntryDate:7:2) + %subst(TmpEntryDate:1:4);

                WHEN    UserProfileDS.PR1002    =   'YMD';
                        //Do Nothing
            ENDSL;

            TSSummaryArray(Count).EntryDate     =   %dec(TmpEntryDate:8:0);
            TSSummaryArray(Count).DurationHH    =   F2DRTNHH;
            TSSummaryArray(Count).DurationMM    =   F2DRTNMM;
            TSSummaryArray(Count).ActID         =   F2ACTID;

            EXEC SQL
            SELECT  ACTIVITY    INTO    :TmpActivity
                                FROM    USRACTS
                                WHERE   USER    =   :UserID     AND
                                        ACTID   =   :F2ACTID;

            TSSummaryArray(Count).Activity      =   TmpActivity;

            READP   F2FMT;

        ENDDO;

        CLOSE   TSSUM;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetTotalDuration(): Get Total Duration
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetTotalDuration EXPORT;

        DCL-PI      TIME_GetTotalDuration;
        DCL-PARM    UserID          CHAR(10)    CONST;
        DCL-PARM    EntryDate       ZONED(8:0)  CONST;
        DCL-PARM    TotalDurationHH ZONED(5:0);
        DCL-PARM    TotalDurationMM ZONED(5:0);
        END-PI;

        DCL-DS  TSSummaryDS     EXTNAME('TSSUM')    QUALIFIED   INZ;
        END-DS;

        DCL-DS  UserProfileDS   EXTNAME('TSPPARA')  QUALIFIED   INZ;
        END-DS;

        DCL-S   TmpEntryDate    CHAR(8);
        DCL-S   pUserProfileDS  POINTER INZ(%addr(UserProfileDS));
        DCL-S   UserExists      CHAR(1);

        //Initialize Variables
        TotalDurationHH =   *Zeros;
        TotalDurationMM =   *Zeros;

        CALLP   TIME_GetUserProfile(UserID:pUserProfileDS:UserExists);

        TmpEntryDate    =   %editc(EntryDate:'X');

        SELECT;
            WHEN    UserProfileDS.PR1001    =   'DMY';
                    TmpEntryDate            =   %subst(TmpEntryDate:5:4) + %subst(TmpEntryDate:3:2) + %subst(TmpEntryDate:1:2);

            WHEN    UserProfileDS.PR1001    =   'MDY';
                    TmpEntryDate            =   %subst(TmpEntryDate:5:4) + %subst(TmpEntryDate:1:2) + %subst(TmpEntryDate:3:2);

            WHEN    UserProfileDS.PR1001    =   'YMD';
                    //Do Nothing
        ENDSL;

        EXEC SQL
        DECLARE C2  CURSOR  FOR
                    SELECT  *   FROM    TSSUM
                                WHERE   USER        =   :UserID         AND
                                        ENTRYDATE   =   :TmpEntryDate;

        EXEC SQL
        OPEN C2;

        EXEC SQL
        FETCH   FROM    C2
                INTO    :TSSummaryDS;

        DOW SQLCODE <>  100;

            TotalDurationHH =   TotalDurationHH + TSSummaryDS.DrtnHH;
            TotalDurationMM =   TotalDurationMM + TSSummaryDS.DrtnMM;

            CLEAR   TSSummaryDS;

            EXEC SQL
            FETCH   FROM    C2
                    INTO    :TSSummaryDS;

        ENDDO;

        EXEC SQL
        CLOSE C2;

        TotalDurationHH =   TotalDurationHH + %div(TotalDurationMM:60);
        TotalDurationMM =   %rem(TotalDurationMM:60);

        RETURN;

    END-PROC;
// ===================================================================================================================================
// TIME_GetDatabaseArray(): Get Database Array
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        TIME_GetDatabaseArray EXPORT;

        DCL-PI      TIME_GetDatabaseArray;
        DCL-PARM    UserID      CHAR(10)    CONST;
        DCL-PARM    EntryDate   ZONED(8:0)  CONST;
        DCL-PARM    Count       ZONED(5:0);
        DCL-PARM    pTmpArray   POINTER     CONST;
        END-PI;

        DCL-DS  TmpArray    BASED(pTmpArray) DIM(999) QUALIFIED;
                EntryTime   CHAR(8);
                Status      CHAR(2);
        END-DS;

        DCL-DS  TSDetailDS      EXTNAME('TSDTL')    QUALIFIED   INZ;
        END-DS;

        DCL-DS  UserProfileDS   EXTNAME('TSPPARA')  QUALIFIED   INZ;
        END-DS;

        DCL-S   EndTime         CHAR(8);
        DCL-S   pUserProfileDS  POINTER INZ(%addr(UserProfileDS));
        DCL-S   StartTime       CHAR(8);
        DCL-S   TmpEntryDate    CHAR(8);
        DCL-S   UserExists      CHAR(1);

        //Initialize Variables
        Count   =   *Zeros;
        CLEAR   TmpArray;

        CALLP   TIME_GetUserProfile(UserID:pUserProfileDS:UserExists);

        TmpEntryDate    =   %editc(EntryDate:'X');

        SELECT;
            WHEN    UserProfileDS.PR1001    =   'DMY';
                    TmpEntryDate            =   %subst(TmpEntryDate:5:4) + %subst(TmpEntryDate:3:2) + %subst(TmpEntryDate:1:2);

            WHEN    UserProfileDS.PR1001    =   'MDY';
                    TmpEntryDate            =   %subst(TmpEntryDate:5:4) + %subst(TmpEntryDate:1:2) + %subst(TmpEntryDate:3:2);

                    //Date is already in YMD Format.
        ENDSL;

        EXEC SQL
        DECLARE C3  CURSOR  FOR
                    SELECT  *   FROM    TSDTL
                                WHERE   USER        =   :UserID         AND
                                        ENTRYDATE   =   :TmpEntryDate;

        EXEC SQL
        OPEN C3;

        EXEC SQL
        FETCH   FROM    C3
                INTO    :TSDetailDS;

        IF  SQLCODE <>  100;
            Count   =   -1;
        ENDIF;

        DOW SQLCODE <>  100;
            Count   =   Count + 2;

            StartTime   =   %editc(TSDetailDS.StartHH:'X') + %editc(TSDetailDS.StartMM:'X') + '00';
            EndTime     =   %editc(TSDetailDS.EndHH:'X') + %editc(TSDetailDS.EndMM:'X') + '00';

            TmpArray(Count).EntryTime        =   StartTime;
            TmpArray(Count + 1).EntryTime    =   EndTime;

            TmpArray(Count).Status           =   'DS';
            TmpArray(Count + 1).Status       =   'DE';

            CLEAR   TSDetailDS;

            EXEC SQL
            FETCH   FROM    C3
                    INTO    :TSDetailDS;

        ENDDO;

        EXEC SQL
        CLOSE C3;

        IF  Count   <>  *Zeros;
            Count   =   Count + 1;
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================