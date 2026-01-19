SELECT M.Nachname, M.Vorname, J.Jahr, J.Jan, J.Feb, J.Mrz, J.Apr, J.Mai, J.Jun, J.Jul, J.Aug, J.Sep, J.Okt, J.Nov, J.Dez, Nz(J.Jan,0) +
    Nz(J.Feb,0) +
    Nz(J.Mrz,0) +
    Nz(J.Apr,0) +
    Nz(J.Mai,0) +
    Nz(J.Jun,0) +
    Nz(J.Jul,0) +
    Nz(J.Aug,0) +
    Nz(J.Sep,0) +
    Nz(J.Okt,0) +
    Nz(J.Nov,0) +
    Nz(J.Dez,0) AS JahresSumme
FROM tbl_MA_Mitarbeiterstamm AS M INNER JOIN tbl_MA_Jahresuebersicht AS J ON M.ID = J.MA_ID
ORDER BY M.Nachname, M.Vorname;

