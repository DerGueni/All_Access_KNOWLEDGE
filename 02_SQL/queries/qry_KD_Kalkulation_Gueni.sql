SELECT qry_Kundenpreise_gueni.kun_Id, qry_Kundenpreise_gueni.kun_Firma, qry_Kundenpreise_gueni.Sicherheitspersonal, ([Sicherheitspersonal]*100/13.5) AS Kalk
FROM qry_Kundenpreise_gueni;

