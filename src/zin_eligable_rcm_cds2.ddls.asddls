@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IN ELIGABLE RCM CDS 2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZIN_ELIGABLE_RCM_CDS2
  as select from    ZIN_ELIGABLE_RCM_CDS1 as A
    left outer join ZPRODUST_HSN          as B on(
      B.Product = A.Product
    )
      left outer join ZJournalEntryItem as k on A.AccountingDocument = k.AccountingDocument and A.CompanyCode = k.CompanyCode and A.FiscalYear = k.FiscalYear
 and A.Product = k.Product    
{
  key A.CompanyCode,
  key A.AccountingDocument,
  key A.TaxItemAcctgDocItemRef                  as doc_item,
  key case when k.ProfitCenter <> '' then substring(k.ProfitCenter,7,10) else substring(A.ProfitCenter,7,10) end as ProfitCenter,
      A.SupplierInvoice,
      A.ProductDescription,
      B.ConsumptionTaxCtrlCode,
      A.FiscalYear,
      A.DocumentDate,
      A.PostingDate,
//      A.GLAccount, 
      A.TaxCode,
      A.Product,
      A.Plant,
      A.DocumentReferenceID,
      A.FiscalPeriod,
      A.Supplier,
      A.SupplierName,
      A.AccountingDocumentType,
      A.BusinessPlace,
      A.SUP_GST,
      A.IN_GSTPlaceOfSupply,


      A.REPORT,
      A.BaseUnit,
      A.TransactionCurrency,
      A.CompanyCodeCurrency,
      A.AmountInCompanyCodeCurrency,

      @DefaultAggregation: #SUM
      //    @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      cast(A.Quantity as abap.dec( 20, 3 ) )    as Quantity,

      @DefaultAggregation: #SUM
      //    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      cast(A.TAXABLE_AMT as abap.dec( 20, 2 ) ) as TAXABLE_AMT,

      @DefaultAggregation: #SUM
      cast(A.Cgst_amt as abap.dec( 20, 2 ) )    as Cgst_amt,

      @DefaultAggregation: #SUM
      cast(A.sgst_amt as abap.dec( 20, 2 ) )    as sgst_amt,

      @DefaultAggregation: #SUM
      cast(A.igst_amt as abap.dec( 20, 2 ) )    as igst_amt,

      A.cgst_rate,
      A.sgst_rate,
      A.igst_rate,


      @DefaultAggregation: #SUM
      A.TAXABLE_AMT                             as INVOICE_AMT,
      A.SupplierFullName,
      A.IN_HSNOrSACCode
//      A.YY1_Transporter_MIH,
//      A.YY1_GRRRNo_MIH,
//      A.YY1_BillofEntryDate_MIH,
//      A.YY1_BillofEntryNo_MIH,
//      A.YY1_BillofEntryValue_MIHC,
//      @Semantics.amount.currencyCode: 'YY1_BillofEntryValue_MIHC'
//      A.YY1_BillofEntryValue_MIH,
//      A.YY1_EWAYBILLNO_MIH,
//      A.YY1_GSTIN_MIH,
//      A.YY1_Import_MIH,
//      A.YY1_PortCode_MIH,
//      A.YY1_VehicleNo_MIH




}

where
  (
           A.AccountingDocumentType = 'KR'
    or     A.AccountingDocumentType = 'KG'
    or     A.AccountingDocumentType = 'Y1'
    or(
      (
           A.AccountingDocumentType = 'RE'
        or A.AccountingDocumentType = 'VC'
        or A.AccountingDocumentType = 'ZA'
        or A.AccountingDocumentType = 'AA'
      )
      and  A.ReverseDocument        = ''
      and  A.SupplierInvoiceStatus  = '5'
    ) // POST DOCUMENT ONLY
  )

group by
  A.REPORT,
  A.CompanyCode,
  A.AccountingDocument,
  A.TaxItemAcctgDocItemRef,
  A.ProfitCenter,
  k.ProfitCenter ,
  A.FiscalYear,
  A.DocumentDate,
  A.PostingDate,
//  A.GLAccount,
  A.MasterFixedAsset,
  A.TaxCode,
  A.Product,
  A.Plant,
  A.DocumentReferenceID,
  A.FiscalPeriod,
  A.Supplier,
  A.SupplierName,
  A.AccountingDocumentType,
  A.BusinessPlace,
  A.SUP_GST,
  A.IN_GSTPlaceOfSupply,
  A.BaseUnit,
  A.TransactionCurrency,
  A.CompanyCodeCurrency,
  A.AmountInCompanyCodeCurrency,
  A.Quantity,
  A.TAXABLE_AMT,
  A.Cgst_amt,
  A.sgst_amt,
  A.igst_amt,
  A.cgst_rate,
  A.sgst_rate,
  A.igst_rate,
  //    A.INVOICE_AMT ,
  A.SupplierInvoice,
  A.ProductDescription,
  B.ConsumptionTaxCtrlCode,
  A.SupplierFullName,
  A.IN_HSNOrSACCode
//      A.YY1_Transporter_MIH,
//      A.YY1_GRRRNo_MIH,
//      A.YY1_BillofEntryDate_MIH,
//      A.YY1_BillofEntryNo_MIH,
//      A.YY1_BillofEntryValue_MIHC,
//      A.YY1_BillofEntryValue_MIH,
//      A.YY1_EWAYBILLNO_MIH,
//      A.YY1_GSTIN_MIH,
//      A.YY1_Import_MIH,
//      A.YY1_PortCode_MIH,
//      A.YY1_VehicleNo_MIH
