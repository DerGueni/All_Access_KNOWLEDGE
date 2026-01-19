SELECT Q.MA_ID, Nz(Q.[1],0) AS Jan, Nz(Q.[2],0) AS Feb, Nz(Q.[3],0) AS Mrz, Nz(Q.[4],0) AS Apr, Nz(Q.[5],0) AS Mai, Nz(Q.[6],0) AS Jun, Nz(Q.[7],0) AS Jul, Nz(Q.[8],0) AS Aug, Nz(Q.[9],0) AS Sep, Nz(Q.[10],0) AS Okt, Nz(Q.[11],0) AS Nov, Nz(Q.[12],0) AS Dez, Nz(Q.[1],0)
    + Nz(Q.[2],0)
    + Nz(Q.[3],0)
    + Nz(Q.[4],0)
    + Nz(Q.[5],0)
    + Nz(Q.[6],0)
    + Nz(Q.[7],0)
    + Nz(Q.[8],0)
    + Nz(Q.[9],0)
    + Nz(Q.[10],0)
    + Nz(Q.[11],0)
    + Nz(Q.[12],0) AS Gesamt
FROM qry_MA_Krank_KT AS Q
ORDER BY Q.MA_ID;

