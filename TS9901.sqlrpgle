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