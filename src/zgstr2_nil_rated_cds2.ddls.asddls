@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZGSTR2_NIL_RATED_CDS1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGSTR2_NIL_RATED_CDS2 
as select distinct from ZGSTR2_NIL_RATED_CDS1 as a
    left outer join       ZPRODUST_HSN    as B on(
      B.Product = a.Product )
      left outer join ZJournalEntryItem as k on a.AccountingDocument = k.AccountingDocument and a.CompanyCode = k.CompanyCode and a.FiscalYear = k.FiscalYear
 and a.Product = k.Product      
{
      key a.CompanyCode,
  key a.AccountingDocument,
  key a.TaxItemAcctgDocItemRef                               as doc_item,
  key case when k.ProfitCenter <> '' then substring(k.ProfitCenter,7,10) else substring(a.ProfitCenter,7,10) end as ProfitCenter,
      a.SupplierInvoice,
      a.ProductDescription,
      B.ConsumptionTaxCtrlCode,
      a.FiscalYear,
      a.DocumentDate,
      a.PostingDate,
      a.TaxCode,
      a.Product,
      a.Plant,
      a.FiscalPeriod,
      a.Supplier,
      a.SupplierName,
      a.AccountingDocumentType,
      a.BusinessPlace,
      a.DocumentReferenceID,

      a.IN_GSTPlaceOfSupply,
      a.SUP_GST,
      a.BaseUnit,
      a.TransactionCurrency,
      a.CompanyCodeCurrency,
      sum(a.AmountInCompanyCodeCurrency)                     as AmountInCompanyCodeCurrency,

       a.Quantity                                         as Quantity,
       a.TAXABLE_AMT                                      as TAXABLE_AMT,
       a.Cgst_amt                                         as Cgst_amt,
       a.sgst_amt                                         as sgst_amt,
       a.igst_amt                                         as igst_amt,

      a.cgst_rate,
      a.sgst_rate,
      a.igst_rate,

      cast( ( coalesce( sum( a.AmountInCompanyCodeCurrency ) , 0 ) + coalesce( a.Cgst_amt, 0 ) + coalesce( a.sgst_amt, 0 )
      + coalesce( a.igst_amt, 0 )  )  as abap.dec( 20, 2 ) ) as INVOICE_AMT,

      a.REPORT                                       as REPORT,
      '' as SupplierFullName,
      '' as IN_HSNOrSACCode
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
       a.IsReversal             <> 'X'
  and  a.IsReversed             <> 'X'

  
//  and(
//       A.cgst_rate               is not initial
//    or A.igst_rate               is not initial
//  )

group by
  a.CompanyCode,
  a.AccountingDocument,
  a.TaxItemAcctgDocItemRef,
  a.ProfitCenter,
  k.ProfitCenter,
  a.SupplierInvoice,
  a.ProductDescription,
  B.ConsumptionTaxCtrlCode,
  a.FiscalYear,
  a.DocumentDate,
  a.PostingDate,
  a.TaxCode,
  a.Product,
  a.Plant,
  a.FiscalPeriod,
  a.Supplier,
  a.SupplierName,
  a.AccountingDocumentType,
  a.BusinessPlace,
  a.DocumentReferenceID,

  a.IN_GSTPlaceOfSupply,
  a.SUP_GST,
  a.BaseUnit,
  a.TransactionCurrency,
  a.CompanyCodeCurrency,


  a.cgst_rate,
  a.sgst_rate,
  a.igst_rate,
  a.REPORT ,
  a.Quantity     ,
  a.TAXABLE_AMT  ,
  a.Cgst_amt     ,
  a.sgst_amt     ,
  a.igst_amt    
