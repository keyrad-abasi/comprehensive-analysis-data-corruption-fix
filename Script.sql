DECLARE @InvoiceEntityCode INT = 840;
DECLARE @ReceiptDepositEntityCode INT = 450;

--select DIA.* 
--from RPA3.DocumentItemAnalyze DIA
--inner join RPA3.ReceiptDeposit RD on DIA.DocumentItemRef = RD.ReceiptDepositID and DIA.DocumentItemType = 3
--inner join RPA3.Receipt R on RD.ReceiptRef = R.ReceiptID
--inner join RPA3.ReceiptRequestOrdinaryItem RROI on DIA.RequestItemRef = RROI.ReceiptRequestOrdinaryItemID
--inner join RPA3.ReceiptRequest RR on RROI.ReceiptRequestRef = RR.ReceiptRequestID
--WHERE R.ApproveState IN (2, 3) and RD.AccountRef is not null and RR.ReferenceType = 4

-- 4,327,943 به مدت 3:41
select * from FIN3.AccountTransactionAnalysis

-- 1,709,132 به مدت 2:38
select * from RPA3.ReceiptDeposit

-- 216,427 به مدت 24 ثانیه
select * from RPA3.Receipt

-- 2,264,567 به مدت 1:23
select * from RPA3.ReceiptRequestOrdinaryItem

-- 2,264,567 به مدت 2:13
select * from RPA3.ReceiptRequest

-- 3,514,976 به مدت 5:28
select * from RPA3.DocumentItemAnalyze

SELECT * FROM FIN3.AccountTransactionAnalysis
WHERE 
	DebitEntityCode = @InvoiceEntityCode AND
	DebitEntityRef IN (
		SELECT ReferenceRef
		FROM RPA3.ReceiptRequest RR
		INNER JOIN RPA3.ReceiptRequestOrdinaryItem RROI on RR.ReceiptRequestID = RROI.ReceiptRequestRef
		INNER JOIN RPA3.DocumentItemAnalyze DIA ON RROI.ReceiptRequestOrdinaryItemID = DIA.RequestItemRef
		INNER JOIN RPA3.ReceiptDeposit RD ON DIA.DocumentItemRef = RD.ReceiptDepositID
		WHERE RR.ReferenceType = 4 AND DIA.DocumentItemType = 3
)