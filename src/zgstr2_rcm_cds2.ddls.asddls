@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GSTR2 B2B CDS2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGSTR2_RCM_CDS2
  as select distinct from ZGSTR2_RCM_CDS1 as A
    left outer join       ZPRODUST_HSN    as B on(
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
      A.TaxCode,
      A.Product,
      A.Plant,
      A.FiscalPeriod,
      A.Supplier,
      A.SupplierName,
      A.AccountingDocumentType,
      A.BusinessPlace,
      A.SUP_GST,
      A.IN_GSTPlaceOfSupply,
      A.DocumentReferenceID,


//      case  A.AccountingDocumentType when 'KG'
//       then cast( A.AccountingDocument as abap.char( 20 ) )
//       when 'ZA'
//       then cast( A.AccountingDocument as abap.char( 20 ) )
//       else A.DocumentReferenceID end           as DocumentReferenceID,


      //   case when A.CompanyCode = '1000'
      //    then '08AAKCS5788C1ZX'
      //    when A.CompanyCode = '2000'
      //    then '08ABJCS8323B1ZD' end as recipient_gstin ,
      //
      //    cast( 'SLF' as abap.char(7) ) as Documenttype ,

//      case 
//      when A.TransactionCurrency <> 'INR'
//      then cast( 'IMPORT'  as abap.char(20) )
//      when A.SUP_GST is initial
//      then cast( 'RCM_UR'  as abap.char(20) )
//      else A.REPORT end                         as REPORT,
      case 
      when A.SUP_GST is initial
      then cast( 'RCM'  as abap.char(20) )
      else A.REPORT end                         as REPORT,
      


      A.BaseUnit,
      A.TransactionCurrency,
      A.CompanyCodeCurrency,

      @DefaultAggregation: #SUM
      cast(A.Quantity as abap.dec( 20, 3 ) )    as Quantity,

      @DefaultAggregation: #SUM
      cast(A.INVOICE_AMT as abap.dec( 20, 2 ) ) as TAXABLE_AMT,

      @DefaultAggregation: #SUM
      cast(A.Cgst_amt as abap.dec( 20, 2 ) )    as Cgst_amt,

      @DefaultAggregation: #SUM
      cast(A.sgst_amt as abap.dec( 20, 2 ) )    as sgst_amt,

      @DefaultAggregation: #SUM
      cast(A.igst_amt as abap.dec( 20, 2 ) )    as igst_amt,

      A.AmountInCompanyCodeCurrency  ,

      A.cgst_rate,
      A.sgst_rate,
      A.igst_rate,


//      cast( ( coalesce( sum(A.AmountInCompanyCodeCurrency) , 0 ) + coalesce( A.Cgst_amt, 0 ) + coalesce( A.sgst_amt, 0 )
//      + coalesce( A.igst_amt, 0 )  )  as abap.dec( 20, 2 ) ) as INVOICE_AMT,
      
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
           A.AccountingDocumentType         =       'KR'
    or     A.AccountingDocumentType         =       'KG'
    or     A.AccountingDocumentType         =       'Y1'
    or(
      (
           A.AccountingDocumentType         =       'RE'
        or A.AccountingDocumentType         =       'VC'
        or A.AccountingDocumentType         =       'ZA'
        or A.AccountingDocumentType         =       'Y1'
      )
      and  A.ReverseDocument                =       '' //     C.IsInvoice = 'X' AND  D.IsSubsequentDebitCredit = ''
      and  A.SupplierInvoiceStatus          =       '5'
    ) // POST DOCUMENT ONLY
  )


group by
  A.REPORT,
  A.CompanyCode,
  A.AccountingDocument,
  A.TaxItemAcctgDocItemRef,
  k.ProfitCenter,
  A.ProfitCenter,
  A.FiscalYear,
  A.DocumentDate,
  A.PostingDate,
//  A.GLAccount,
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
  A.Quantity,
  A.INVOICE_AMT,
  A.Cgst_amt,
  A.sgst_amt,
  A.igst_amt,
  A.AmountInCompanyCodeCurrency ,
  A.cgst_rate,
  A.sgst_rate,
  A.igst_rate,
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
