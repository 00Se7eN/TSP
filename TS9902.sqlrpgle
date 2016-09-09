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
        DCL-PARM    DataFormat  ZONED(1)    CONST;
        DCL-PARM    IsValid     CHAR(1);
        DCL-PARM    ErrorID     ZONED(5:0);
        END-PI;

        // Initialize Variables
        IsValid =   *Blanks;
        ErrorID =   *Zeros;

        SELECT;
            WHEN    DataFormat  =   1;
                    IsValid     =   'Y';

            WHEN    DataFormat  =   2;
                    IsValid     =   'Y';

            WHEN    DataFormat  =   3;
                    IsValid     =   'Y';

            WHEN    DataFormat  =   4;
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
        UserProfileDS.PR3005    =   '1=Duration, 2=Start-End,';
        UserProfileDS.PR3006    =   '3=Start-Duration,';
        UserProfileDS.PR3007    =   '4=End-Duration';

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