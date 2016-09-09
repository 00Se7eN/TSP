**FREE
// ===================================================================================================================================
// Program ID       :   TS9901PR
// Description      :   Common Procedures - Prototypes
// Author           :   Vinayak Mahajan
// Date written     :   August 26, 2016
// Based On Pgm     :   None
// Reviewer         :
// Date Reviewed    :
// ===================================================================================================================================
// Prototypes
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// COMN_CreateDetailsTable(): Create Details Table
// -----------------------------------------------------------------------------------------------------------------------------------
        DCL-PR  COMN_CreateDetailsTable;
        END-PR;
// ===================================================================================================================================
// COMN_CreateSummaryTable(): Create Summary Table
// -----------------------------------------------------------------------------------------------------------------------------------
        DCL-PR  COMN_CreateSummaryTable;
        END-PR;
// ===================================================================================================================================
// COMN_CreateActivitiesTable(): Create Activities Table
// -----------------------------------------------------------------------------------------------------------------------------------
        DCL-PR  COMN_CreateActivitiesTable;
        END-PR;
// ===================================================================================================================================
// COMN_CreateErrorMessageTable(): Create Error Messages Table
// -----------------------------------------------------------------------------------------------------------------------------------
        DCL-PR  COMN_CreateErrorMessageTable;
        END-PR;
// ===================================================================================================================================
// COMN_CreateErrorLogTable(): Create Error Log Table
// -----------------------------------------------------------------------------------------------------------------------------------
        DCL-PR  COMN_CreateErrorLogTable;
        END-PR;
// ===================================================================================================================================
// COMN_LogError(): Log Error
// -----------------------------------------------------------------------------------------------------------------------------------
        DCL-PR      COMN_LogError;
        DCL-PARM    User        CHAR(10);
        DCL-PARM    ErrorDate   ZONED(8:0);
        DCL-PARM    ErrorTime   ZONED(6:0);
        DCL-PARM    ErrorCode   INT(10);
        DCL-PARM    ProcName    CHAR(100);
        DCL-PARM    Input       CHAR(1024);
        DCL-PARM    JobName     CHAR(10);
        DCL-PARM    JobNo       CHAR(10);
        END-PR;
// ===================================================================================================================================
