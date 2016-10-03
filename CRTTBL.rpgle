**FREE
// ===================================================================================================================================
    CTL-OPT DFTACTGRP(*NO) ACTGRP('TIMETRACK') BNDDIR('TSBNDDIR') DEBUG(*YES) OPTION(*NODEBUGIO);
// ===================================================================================================================================
// Program ID       :   CRTTBL
// Description      :   Create Table
// Author           :   Vinayak Mahajan
// Date written     :   August 26, 2016
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
// ===================================================================================================================================
// Internal Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
// ===================================================================================================================================
// External Data Structures
// -----------------------------------------------------------------------------------------------------------------------------------
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
    /COPY /QOpenSys/QIBM/UserData/OPS/Orion/serverworkspace/vi/vinayakmahajan/OrionContent/TSP/TS9901PR.sqlrpgle
// ===================================================================================================================================
// Parameters for Various Programs
// -----------------------------------------------------------------------------------------------------------------------------------

// Parameters for this Program

    DCL-PR      CRTTBL;
    DCL-PARM    TableName CHAR(10);
    END-PR;
// ===================================================================================================================================
// Program Entry Parameters
// -----------------------------------------------------------------------------------------------------------------------------------
    DCL-PI      CRTTBL;
    DCL-PARM    TableName CHAR(10);
    END-PI;
// ===================================================================================================================================
//
// -----------------------------------------------------------------------------------------------------------------------------------

    SELECT;
        WHEN    TableName   =   'TSDTL';
        COMN_CreateDetailsTable();

        WHEN    TableName   =   'TSSUM';
        COMN_CreateSummaryTable();

        WHEN    TableName   =   'USRACTS';
        COMN_CreateActivitiesTable();

        WHEN    TableName   =   'ERRMSG';
        COMN_CreateErrorMessageTable();

        WHEN    TableName   =   'ERRLOG';
        COMN_CreateErrorLogTable();
    ENDSL;

    *InLR   =   *On;
    RETURN;

// ===================================================================================================================================