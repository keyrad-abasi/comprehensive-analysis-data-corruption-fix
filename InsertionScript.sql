DECLARE @InvoiceEntityCode INT = 840;
DECLARE @ReceiptDepositEntityCode INT = 450;
DECLARE @ID BIGINT

EXEC SYS3.spGetNextId 'FIN3.AccountTransactionAnalysis', @ID OUTPUT

INSERT INTO [FIN3].[AccountTransactionAnalysis] (
            [AccountTransactionAnalysisID]
		   ,[AccountRef]
           ,[DebitEntityRef]
           ,[DebitEntityCode]
           ,[DebitTransactionRef]
           ,[CreditEntityRef]
           ,[CreditEntityCode]
           ,[CreditTransactionRef]
           ,[Amount]
           ,[CurrencyRef]
           ,[IsSystematic]
           ,[Date]
           ,[Creator]
           ,[CreationDate]
           ,[LastModifier]
           ,[LastModificationDate]
)
SELECT
	@ID + (ROW_NUMBER() OVER (ORDER BY DIA.DocumentItemAnalyzeID ASC)) AS [AccountTransactionAnalysisID],
	RD.AccountRef AS [AccountRef],
	RR.ReferenceRef AS [DebitEntityRef],
	@InvoiceEntityCode AS [DebitEntityCode],
	NULL AS [DebitTransactionRef],
	RD.ReceiptDepositID AS [CreditEntityRef],
	@ReceiptDepositEntityCode AS [CreditEntityCode],
	T.TransactionID AS [CreditTransactionRef],
	DIA.Amount AS [Amount],
	RD.CurrencyRef AS [CurrencyRef],
	1 AS [IsSystematic],
	DIA.DocumentDate AS [Date],
	DIA.Creator AS [Creator],
	DIA.CreationDate AS [CreationDate],
	DIA.LastModifier AS [LastModifier],
	DIA.LastModificationDate AS [LastModificationDate]
FROM RPA3.Receipt R
INNER JOIN RPA3.ReceiptDeposit RD ON R.ReceiptID = RD.ReceiptRef AND RD.AccountRef IS NOT NULL
INNER JOIN FIN3.[Transaction] T ON T.ReferenceRef = R.ReceiptID AND T.ReferenceItemRef = RD.ReceiptDepositID
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
) AND DIA.DocumentItemRef NOT IN (
	SELECT CreditEntityRef 
	FROM FIN3.AccountTransactionAnalysis 
	WHERE CreditEntityCode = @ReceiptDepositEntityCode
) AND RR.ReferenceRef NOT IN (
	SELECT DebitEntityRef 
	FROM FIN3.AccountTransactionAnalysis 
	WHERE DebitEntityCode = @InvoiceEntityCode
)
WHERE 
	R.ApproveState IN (2, 3) AND
	T.ReferenceTypeEntityName = 'Receipt' AND
	T.ReferenceItemTypeEntityName = 'ReceiptDeposit' AND
	T.EntryType = ''