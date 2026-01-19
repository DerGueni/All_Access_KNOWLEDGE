UPDATE tbl_VA_AnzTage SET tbl_VA_AnzTage.TVA_Offen = True
WHERE (((tbl_VA_AnzTage.TVA_Soll)=0)) OR ((([TVA_Soll]-[TVA_Ist])>0));

