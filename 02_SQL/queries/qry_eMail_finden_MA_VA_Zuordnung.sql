UPDATE tbl_eMail_Import SET tbl_eMail_Import.MA_ID = eMail_Ausles(1,[Betreff],[Sender]), tbl_eMail_Import.VA_ID = eMail_Ausles(2,[Betreff],[Sender]), tbl_eMail_Import.VADatum_ID = eMail_Ausles(3,[Betreff],[Sender]), tbl_eMail_Import.VAStart_ID = eMail_Ausles(4,[Betreff],[Sender])
WHERE (((tbl_eMail_Import.IstErledigt)=2 Or (tbl_eMail_Import.IstErledigt)=0));

