DECLARE @InvoiceEntityCode INT = 840;
DECLARE @ReceiptDepositEntityCode INT = 450;

SELECT DIA.RequestItemRef, * 
FROM RPA3.Receipt R
INNER JOIN RPA3.ReceiptDeposit RD ON R.ReceiptID = RD.ReceiptRef AND RD.AccountRef IS NOT NULL
INNER JOIN RPA3.DocumentItemAnalyze DIA ON DIA.DocumentItemRef = RD.ReceiptDepositID AND DIA.DocumentItemType = 3
INNER JOIN RPA3.ReceiptRequestOrdinaryItem RROI ON RROI.ReceiptRequestOrdinaryItemID = DIA.RequestItemRef
INNER JOIN RPA3.ReceiptRequest RR ON RR.ReceiptRequestID = RROI.ReceiptRequestRef AND RR.ReferenceType = 4 AND NOT EXISTS
(
	SELECT CreditEntityRef 
	FROM FIN3.AccountTransactionAnalysis 
	WHERE 
		DebitEntityCode = @InvoiceEntityCode AND
		DebitEntityRef = RR.ReferenceRef AND 
		CreditEntityCode = @ReceiptDepositEntityCode AND
		CreditEntityRef = DIA.DocumentItemRef
) AND DIA.DocumentItemRef IN (
	SELECT CreditEntityRef 
	FROM FIN3.AccountTransactionAnalysis 
	WHERE CreditEntityCode = @ReceiptDepositEntityCode
) AND RR.ReferenceRef IN (
	SELECT DebitEntityRef 
	FROM FIN3.AccountTransactionAnalysis 
	WHERE DebitEntityCode = @InvoiceEntityCode
)
WHERE R.ApproveState IN (2, 3)
ORDER BY DIA.RequestItemRef