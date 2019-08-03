MODULE WRAP;

    FROM System IMPORT GetArg, Terminate;
    FROM DevIO IMPORT WriteErr, LineErr;
    FROM InOut IMPORT Write, WriteString, WriteLine, RedirectOutput, CloseOutput, Done;
    FROM XDOS IMPORT BlockReadCreate, BlockReadDestroy, BlockReadLine;
    FROM Files IMPORT Open, Close, READ, FileStatus;
    FROM NumberConversion IMPORT StringToCard;
    FROM Strings IMPORT Length, Copy, Assign, Append;
    FROM XString IMPORT RightTrim;
    FROM ARGQUERY IMPORT ArgQuery, ArgEntry;
    FROM INLine IMPORT IsIn;
    TYPE
        tString = ARRAY [0..255] OF CHAR;

    VAR
        pcount,
        c,
        cWrap,
        cLimit,
        cPos,
        cLen : CARDINAL;
        iIN    : INTEGER;

        sBreak,
        sTemp,
        sRecord,
        sInputFile,
        sOutputFile,
        sWrapPoint : tString;

        bFlag : BOOLEAN;


    PROCEDURE Usage;
        BEGIN
            LineErr("usage: wrap [/X<chars>] <wrap-point> <inputfile> <outputfile>")
        END Usage;


    PROCEDURE Process( sArg : ArgEntry);
        VAR
            sTemp : ARRAY [0..127] OF CHAR;
        BEGIN
            IF sArg[0] # "/" THEN
                INC(pcount);
                CASE pcount OF
                    1 : Assign(sArg,sWrapPoint)
                    |
                    2 : Assign(sArg,sInputFile)
                    |
                    3 : Assign(sArg,sOutputFile)
                END
            ELSE
                IF CAP(sArg[1])="X" THEN
                    Copy(sArg,2,255,sTemp);
                    Append(sBreak,sTemp)
                END
            END
        END Process;



    BEGIN
        sBreak := " ";

        LineErr("WRAP v1.2 (c) Copyright Bruce M. Axtens, 1993.");

        pcount := 0;

        IF NOT ArgQuery( Process) THEN
            Usage;
            Terminate(1)
        END;

        IF pcount # 3 THEN
            Usage;
            Terminate(1)
        END;

        StringToCard( sWrapPoint, cWrap, bFlag);
        IF NOT bFlag THEN
            LineErr("Could not convert <wrap-point> to CARDINAL.");
            Terminate(0)
        END;
        cLimit := 1 (* cWrap DIV 7 *);
        Open( iIN, sInputFile, READ);
        IF FileStatus # 0 THEN
            WriteErr("Could not open ");
            LineErr( sInputFile);
            Terminate(0)
        END;
        RedirectOutput( sOutputFile);
        IF NOT Done THEN
            WriteErr("Could not create ");
            LineErr( sInputFile);
            Terminate(0)
        END;

        BlockReadCreate(32767);
        BlockReadLine( iIN, sRecord, c);
        WHILE c # 0 DO
            RightTrim( sRecord);
            LOOP
                cLen := Length( sRecord);
                IF cLen > cWrap THEN
                    cPos := cWrap;
                    LOOP
                        IF IsIn(sRecord[cPos],sBreak) OR (cPos <= cLimit) THEN
                            EXIT
                        ELSE
                            DEC(cPos)
                        END;
                    END;
                    IF cPos <= cLimit THEN
                        WriteLine( sRecord);
                        EXIT
                    ELSE
                        Copy(sRecord,0,cPos+1,sTemp);
                        Copy(sRecord,cPos+1,255,sRecord);
                        WriteLine(sTemp);
                        WriteString("- ");
                    END;
                ELSE
                    WriteLine(sRecord);
                    EXIT

                END;
            END;
            BlockReadLine( iIN, sRecord, c);
        END;
        Close(iIN);
        CloseOutput;
        BlockReadDestroy;
    END WRAP.
