DECLARE @InvoiceEntityCode INT = 840;
DECLARE @ReceiptDepositEntityCode INT = 450;

SELECT AccountTransactionAnalysisID FROM FIN3.AccountTransactionAnalysis
WHERE 
	DebitEntityCode = @InvoiceEntityCode AND
	DebitEntityRef IN (
		SELECT RR.ReferenceRef
		FROM RPA3.ReceiptRequest RR
		INNER JOIN RPA3.ReceiptRequestOrdinaryItem RROI on RR.ReceiptRequestID = RROI.ReceiptRequestRef
		INNER JOIN RPA3.DocumentItemAnalyze DIA ON RROI.ReceiptRequestOrdinaryItemID = DIA.RequestItemRef
		INNER JOIN RPA3.ReceiptDeposit RD ON DIA.DocumentItemRef = RD.ReceiptDepositID
		INNER JOIN RPA3.Receipt R ON RD.ReceiptRef = R.ReceiptID
		WHERE 
			RR.ReferenceType = 4 AND 
			DIA.DocumentItemType = 3 AND
			RD.AccountRef IS NOT NULL AND
			R.ApproveState IN (2, 3) AND
			NOT EXISTS (
				SELECT AccountTransactionAnalysisID
				FROM FIN3.AccountTransactionAnalysis 
				WHERE 
					DebitEntityCode = @InvoiceEntityCode AND
					DebitEntityRef = RR.ReferenceRef AND 
					CreditEntityCode = @ReceiptDepositEntityCode AND
					CreditEntityRef = DIA.DocumentItemRef
			) AND DIA.DocumentItemRef NOT IN (
				SELECT CreditEntityRef 
				FROM FIN3.AccountTransactionAnalysis 
				WHERE CreditEntityCode = @ReceiptDepositEntityCode
			)
)