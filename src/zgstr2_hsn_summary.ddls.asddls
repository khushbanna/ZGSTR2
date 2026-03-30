@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gstr2 hsn summary'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGSTR2_HSN_SUMMARY as select from ZGSTR2_B2B_CDS2 as b
{
  key b.CompanyCode,
  key '' as AccountingDocument,
  key '    ' as FiscalYear,
  key '      ' as doc_item,
  key ''as SupplierInvoice,
  key ''as ProductDescription,
  key b.ConsumptionTaxCtrlCode,
  key '' as DocumentDate,
  key '' as PostingDate,
  key '' as TaxCode,
  key '' as Product,
  key '' as Plant,
  key '   ' as FiscalPeriod,
  key '' as Supplier,
  key '' as SupplierName,
  key '' as AccountingDocumentType,
  key '' as BusinessPlace,
  key '' as DocumentReferenceID,
  key '' as IN_GSTPlaceOfSupply,
  key '' as SUP_GST,
  key b.BaseUnit,
  key b.TransactionCurrency,
  key cast( ' ' as abap.char( 3 )) as CompanyCodeCurrency,
  key sum(b.AmountInCompanyCodeCurrency)  as AmountInCompanyCodeCurrency,
  key sum(b.Quantity) as Quantity ,
  key sum(b.TAXABLE_AMT) as TAXABLE_AMT,
  key sum(b.Cgst_amt) as Cgst_amt, 
  key sum(b.sgst_amt) as sgst_amt,
  key sum(b.igst_amt) as igst_amt,
  key b.cgst_rate,
  key b.sgst_rate,
  key b.igst_rate,
  key sum(b.INVOICE_AMT) as INVOICE_AMT,
      'HSN' as REPORT,
     '' as SupplierFullName,
    '' as  IN_HSNOrSACCode
}
group by
  CompanyCode,
  ConsumptionTaxCtrlCode,
  BaseUnit,
  TransactionCurrency,
  cgst_rate,
  sgst_rate,
  igst_rate
