**FREE
// ===================================================================================================================================
    CTL-OPT NOMAIN BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   TS9901
// Description      :   Common Procedures
// Author           :   Vinayak Mahajan
// Date written     :   August 26, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9901PR.sqlrpgle
// ===================================================================================================================================
// Procedures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// COMN_CreateDetailsTable(): Create Details Table
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC    COMN_CreateDetailsTable EXPORT;

        DCL-PI  COMN_CreateDetailsTable;
        END-PI;

        EXEC SQL
        CREATE TABLE            TSDTL (
            USER_ID             FOR COLUMN USER         CHAR(10)        NOT NULL WITH DEFAULT,
            ENTRY_DATE          FOR COLUMN ENTRYDATE    NUMERIC(8,0)    NOT NULL WITH DEFAULT,
            START_HOURS         FOR COLUMN STARTHH      NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            START_MINUTES       FOR COLUMN STARTMM      NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            ACTIVITY_ID         FOR COLUMN ACTID        NUMERIC(5,0)    NOT NULL WITH DEFAULT,
            END_HOURS           FOR COLUMN ENDHH        NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            END_MINUTES         FOR COLUMN ENDMM        NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            DURATION_HOURS      FOR COLUMN DRTNHH       NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            DURATION_MINUTES    FOR COLUMN DRTNMM       NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            PRIMARY KEY (USER_ID, ENTRY_DATE, START_HOURS, START_MINUTES, ACTIVITY_ID)
                                       );

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_CreateSummaryTable(): Create Summary Table
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC    COMN_CreateSummaryTable EXPORT;

        DCL-PI  COMN_CreateSummaryTable;
        END-PI;

        EXEC SQL
        CREATE TABLE            TSSUM (
            USER_ID             FOR COLUMN USER         CHAR(10)        NOT NULL WITH DEFAULT,
            ENTRY_DATE          FOR COLUMN ENTRYDATE    NUMERIC(8,0)    NOT NULL WITH DEFAULT,
            DURATION_HOURS      FOR COLUMN DRTNHH       NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            DURATION_MINUTES    FOR COLUMN DRTNMM       NUMERIC(2,0)    NOT NULL WITH DEFAULT,
            ACTIVITY_ID         FOR COLUMN ACTID        NUMERIC(5,0)    NOT NULL WITH DEFAULT,
            PRIMARY KEY (USER_ID, ENTRY_DATE, DURATION_HOURS, DURATION_MINUTES, ACTIVITY_ID)
                                       );

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_CreateActivitiesTable(): Create Activities Table
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC    COMN_CreateActivitiesTable EXPORT;

        DCL-PI  COMN_CreateActivitiesTable;
        END-PI;

        EXEC SQL
        CREATE TABLE        USRACTS (
            USER_ID         FOR COLUMN USER     CHAR(10)        NOT NULL WITH DEFAULT,
            ACTIVITY_ID     FOR COLUMN ACTID    NUMERIC(5,0)    NOT NULL WITH DEFAULT,
            ACTIVITY_DESC   FOR COLUMN ACTIVITY CHAR(50)        NOT NULL WITH DEFAULT,
            PRIMARY KEY (USER_ID, ACTIVITY_ID)
                                     );

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_CreateErrorMessageTable(): Create Error Messages Table
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC    COMN_CreateErrorMessageTable EXPORT;

        DCL-PI  COMN_CreateErrorMessageTable;
        END-PI;

        EXEC SQL
        CREATE TABLE        ERRMSG (
            ERROR_ID        FOR COLUMN ERRORID  NUMERIC(5,0)    NOT NULL WITH DEFAULT,
            LANGUAGE_CODE   FOR COLUMN LANGCODE CHAR(3)         NOT NULL WITH DEFAULT,
            ERROR_MESSAGE   FOR COLUMN ERRORMSG CHAR(78)        NOT NULL WITH DEFAULT,
            PRIMARY KEY (ERROR_ID, LANGUAGE_CODE)
                                    );

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_CreateErrorLogTable(): Create Error Log Table
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC    COMN_CreateErrorLogTable EXPORT;

        DCL-PI  COMN_CreateErrorLogTable;
        END-PI;

        EXEC SQL
        CREATE TABLE        ERRLOG (
            USER_ID         FOR COLUMN USER         CHAR(10)        NOT NULL WITH DEFAULT,
            ERROR_DATE      FOR COLUMN ERRORDATE    NUMERIC(8,0)    NOT NULL WITH DEFAULT,
            ERROR_TIME      FOR COLUMN ERRORTIME    NUMERIC(6,0)    NOT NULL WITH DEFAULT,
            ERROR_CODE      FOR COLUMN ERRORCODE    CHAR(10)        NOT NULL WITH DEFAULT,
            PROCEDURE_NAME  FOR COLUMN PROCNAME     CHAR(100)       NOT NULL WITH DEFAULT,
            INPUT_DATA      FOR COLUMN INPUT        CHAR(1024)      NOT NULL WITH DEFAULT,
            JOB_NAME        FOR COLUMN JOBNAME      CHAR(10)        NOT NULL WITH DEFAULT,
            JOB_NUMBER      FOR COLUMN JOBNO        CHAR(10)        NOT NULL WITH DEFAULT,
            PRIMARY KEY (USER_ID, ERROR_DATE, ERROR_TIME)
                                    );

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_LogError(): Log Error
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        COMN_LogError EXPORT;

        DCL-PI      COMN_LogError;
        DCL-PARM    User        CHAR(10);
        DCL-PARM    ErrorDate   ZONED(8:0);
        DCL-PARM    ErrorTime   ZONED(6:0);
        DCL-PARM    ErrorCode   INT(10);
        DCL-PARM    ProcName    CHAR(100);
        DCL-PARM    Input       CHAR(1024);
        DCL-PARM    JobName     CHAR(10);
        DCL-PARM    JobNo       CHAR(10);
        END-PI;

        EXEC SQL
        INSERT  INTO    ERRLOG
                VALUES( :User,      :ErrorDate,
                        :ErrorTime, :ErrorCode,
                        :ProcName,  :Input,
                        :JobName,   :JobNo);

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_ValidateDate(): Validate Date
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        COMN_ValidateDate EXPORT;

        DCL-PI      COMN_ValidateDate;
        DCL-PARM    Date        CHAR(8)     CONST;
        DCL-PARM    DateFormat  CHAR(3)     CONST;
        DCL-PARM    IsValid     CHAR(1);
        END-PI;

        DCL-S   Day     ZONED(2:0);
        DCL-S   Month   ZONED(2:0);
        DCL-S   Year    ZONED(4:0);

        SELECT;
            WHEN    DateFormat  =   'DMY';
                    Day         =   %dec(%subst(Date:1:2):2:0);
                    Month       =   %dec(%subst(Date:3:2):2:0);
                    Year        =   %dec(%subst(Date:5:4):4:0);

            WHEN    DateFormat  =   'MDY';
                    Month       =   %dec(%subst(Date:1:2):2:0);
                    Day         =   %dec(%subst(Date:3:2):2:0);
                    Year        =   %dec(%subst(Date:5:4):4:0);

            WHEN    DateFormat  =   'YMD';
                    Year        =   %dec(%subst(Date:1:4):4:0);
                    Month       =   %dec(%subst(Date:5:2):2:0);
                    Day         =   %dec(%subst(Date:7:2):2:0);
        ENDSL;

        CALLP   COMN_ValidateMonth(Month:IsValid);

        IF      IsValid = 'Y';
        CALLP   COMN_ValidateDay(Day:Month:Year:IsValid);
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_ValidateMonth(): Validate Month
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        COMN_ValidateMonth EXPORT;

        DCL-PI      COMN_ValidateMonth;
        DCL-PARM    Month   ZONED(2:0)  CONST;
        DCL-PARM    IsValid CHAR(1);
        END-PI;

        //Initialize Variables
        IsValid =   *Blanks;

        IF  Month   >   12;
            IsValid =   'N';
        ELSE;
            IsValid =   'Y';
        ENDIF;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_ValidateDay(): Validate Day
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        COMN_ValidateDay EXPORT;

        DCL-PI      COMN_ValidateDay;
        DCL-PARM    Day     ZONED(2:0)  CONST;
        DCL-PARM    Month   ZONED(2:0)  CONST;
        DCL-PARM    Year    ZONED(4:0)  CONST;
        DCL-PARM    IsValid CHAR(1);
        END-PI;

        DCL-S   LeapYear    CHAR(1);

        //Initialize Variables
        IsValid =   *Blanks;

        CALLP   COMN_CheckLeapYear(Year:LeapYear);

        SELECT;
            WHEN    Day         >   31;
                    IsValid     =   'N';

            WHEN    LeapYear    =   'Y'         AND
                    Month       =   2           AND
                    Day         >   29;
                    IsValid     =   'N';

            WHEN    LeapYear    =   'N'         AND
                    Month       =   2           AND
                    Day         >   28;
                    IsValid     =   'N';

            WHEN    Day         >   30;

                    IF  Month   =   4           OR
                        Month   =   6           OR
                        Month   =   9           OR
                        Month   =   11;
                        IsValid =   'N';
                    ENDIF;

            OTHER;
                    IsValid     =   'Y';
        ENDSL;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_CheckLeapYear(): Check Leap Year
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        COMN_CheckLeapYear EXPORT;

        DCL-PI      COMN_CheckLeapYear;
        DCL-PARM    Year        ZONED(4:0)  CONST;
        DCL-PARM    LeapYear    CHAR(1);
        END-PI;

        //Initialize Variables
        LeapYear    =   *Blanks;

        SELECT;
            WHEN    %rem(Year:400)  =   *Zeros;
                    LeapYear        =   'Y';

            WHEN    %rem(Year:4)    =   *Zeros  AND
                    %rem(Year:100)  <>  *Zeros;
                    LeapYear        =   'Y';

            OTHER;
                    LeapYear        =   'N';
        ENDSL;

        RETURN;

    END-PROC;
// ===================================================================================================================================
// COMN_CheckFutureDate(): Check Future Date
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PROC        COMN_CheckFutureDate EXPORT;

        DCL-PI      COMN_CheckFutureDate;
        DCL-PARM    Date        CHAR(8)     CONST;
        DCL-PARM    DateFormat  CHAR(3)     CONST;
        DCL-PARM    FutureDate  CHAR(1);
        END-PI;

        DCL-S   Day         ZONED(2:0);
        DCL-S   Month       ZONED(2:0);
        DCL-S   Year        ZONED(4:0);
        DCL-S   TmpDate     CHAR(8);
        DCL-S   TmpDay      ZONED(2:0);
        DCL-S   TmpMonth    ZONED(2:0);
        DCL-S   TmpYear     ZONED(4:0);

        //Initialize Variables
        FutureDate  =   *Blanks;

        SELECT;
            WHEN    DateFormat  =   'DMY';
                    Day         =   %dec(%subst(Date:1:2):2:0);
                    Month       =   %dec(%subst(Date:3:2):2:0);
                    Year        =   %dec(%subst(Date:5:4):4:0);

            WHEN    DateFormat  =   'MDY';
                    Month       =   %dec(%subst(Date:1:2):2:0);
                    Day         =   %dec(%subst(Date:3:2):2:0);
                    Year        =   %dec(%subst(Date:5:4):4:0);

            WHEN    DateFormat  =   'YMD';
                    Year        =   %dec(%subst(Date:1:4):4:0);
                    Month       =   %dec(%subst(Date:5:2):2:0);
                    Day         =   %dec(%subst(Date:7:2):2:0);
        ENDSL;

        TmpDate     =   %char(%dec(%date));
        TmpDay      =   %dec(%subst(TmpDate:7:2):2:0);
        TmpMonth    =   %dec(%subst(TmpDate:5:2):2:0);
        TmpYear     =   %dec(%subst(TmpDate:1:4):4:0);

        SELECT;
            WHEN    Year        >   TmpYear;
                    FutureDate  =   'Y';

            WHEN    Month       >   TmpMonth    AND
                    Year        =   TmpYear;
                    FutureDate  =   'Y';

            WHEN    Day         >   TmpDay      AND
                    Month       =   TmpMonth    AND
                    Year        =   TmpYear;
                    FutureDate  =   'Y';

            OTHER;
                    FutureDate  =   'N';
        ENDSL;

        RETURN;

    END-PROC;
// ===================================================================================================================================