DECLARE @InvoiceEntityCode INT = 840;
DECLARE @ReceiptDepositEntityCode INT = 450;

-- مطابقت با کوئری 1 واقع در PBI

DECLARE @tbl TABLE (ReceiptDepositID BIGINT, InvoiceID BIGINT)

INSERT INTO @tbl(ReceiptDepositID, InvoiceID)
	SELECT RD.ReceiptDepositID, RR.ReferenceRef as [InvoiceID] 
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

DELETE FROM FIN3.AccountTransactionAnalysis
WHERE (
		DebitEntityCode = @InvoiceEntityCode AND
		DebitEntityRef IN (SELECT InvoiceID from @tbl)
) OR (
		CreditEntityCode = @ReceiptDepositEntityCode AND
		CreditEntityRef = (SELECT ReceiptDepositID FROM @tbl)
)