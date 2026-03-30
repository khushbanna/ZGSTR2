@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GSTR2 CDNR CDS2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGSTR2_CDNR_CDS2
  as select from    ZGSTR2_CDNR_CDS1 as A
    left outer join ZPRODUST_HSN     as B on(
      B.Product = A.Product
    )
   left outer join ZJournalEntryItem as k on A.AccountingDocument = k.AccountingDocument and A.CompanyCode = k.CompanyCode and A.FiscalYear = k.FiscalYear
 and A.Product = k.Product     
{
  key A.CompanyCode,
  key A.AccountingDocument,
  key A.TaxItemAcctgDocItemRef  as doc_item,
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
      A.BaseUnit,
      A.TransactionCurrency,
      A.CompanyCodeCurrency,
      A.DocumentReferenceID,

      //    case when A.SupplierInvoice is not initial
      //    then cast( A.SupplierInvoice as abap.char( 20 ) )
      //    else cast(A.AccountingDocument as abap.char( 20 ) ) end as DocumentReferenceID ,


      //   case when A.TAXABLE_AMT < 0
      //      then cast( 'CR' as abap.char(7) )
      //      else cast( 'DR' as abap.char(7) )
      //       end as Documenttype ,

      sum(A.AmountInCompanyCodeCurrency)                     as AmountInCompanyCodeCurrency,
      A.Quantity                                             as Quantity,
      A.TAXABLE_AMT                                          as TAXABLE_AMT,
      A.Cgst_amt                                             as Cgst_amt,
      A.sgst_amt                                             as sgst_amt,
      A.igst_amt                                             as igst_amt,


      A.cgst_rate,
      A.sgst_rate,
      A.igst_rate,

      cast( ( coalesce( sum(A.AmountInCompanyCodeCurrency ) , 0 ) + coalesce( A.Cgst_amt, 0 ) + coalesce( A.sgst_amt, 0 )
      + coalesce( A.igst_amt, 0 )  )  as abap.dec( 20, 2 ) ) as INVOICE_AMT,

      A.REPORT,
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
       A.IsReversal <> 'X'
  and  A.IsReversed <> 'X'
  and(
       A.Cgst_amt   is not initial
    or A.igst_amt   is not initial
  )



group by

  A.CompanyCode,
  A.AccountingDocument,
  A.TaxItemAcctgDocItemRef,
  k.ProfitCenter,
  A.ProfitCenter,
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
  A.BaseUnit,
  A.TransactionCurrency,
  A.CompanyCodeCurrency,
  A.DocumentReferenceID,
  A.cgst_rate,
  A.sgst_rate,
  A.igst_rate,
  A.Quantity,
  A.TAXABLE_AMT,
  A.Cgst_amt,
  A.sgst_amt,
  A.igst_amt,
  A.REPORT,
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
