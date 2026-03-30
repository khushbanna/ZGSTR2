@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IN ELIGABLE CDS 4'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZIN_ELIGABLE_CDS4
  as select from    ZIN_ELIGABLE_CDS3 as a
    left outer join ZPRODUST_HSN      as B on(
      B.Product = a.Product
    )
   left outer join ZJournalEntryItem as k on a.AccountingDocument = k.AccountingDocument and a.CompanyCode = k.CompanyCode and a.FiscalYear = k.FiscalYear
 and a.Product = k.Product      
{
      @UI.lineItem      : [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Company Code'
  key a.CompanyCode,

      @UI.lineItem      : [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @UI.selectionField: [{ position: 30 }]
  key a.AccountingDocument,
  key a.doc_item,
  key case when k.ProfitCenter <> '' then substring(k.ProfitCenter,7,10) else substring(a.ProfitCenter,7,10) end as ProfitCenter,

      @UI.lineItem      : [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      a.FiscalYear,
      a.SupplierInvoice,
      a.DocumentDate,
      a.PostingDate,
      a.TaxCode,
      a.Plant,
      a.DocumentReferenceID,
      a.FiscalPeriod,
      a.Supplier,
      a.SupplierName,
      a.AccountingDocumentType,
      a.BusinessPlace,
      a.SUP_GST,
      a.IN_GSTPlaceOfSupply,
      a.BaseUnit,
      a.TransactionCurrency,
      a.CompanyCodeCurrency,
//      a.AmountInCompanyCodeCurrency,
      cast(a.TAXABLE_AMT as abap.dec( 20, 2 ) ) as AmountInCompanyCodeCurrency,
      B.ConsumptionTaxCtrlCode,
      cast(a.Quantity as abap.dec( 20, 3 ) )                                as Quantity,

      cast(a.TAXABLE_AMT as abap.dec( 20, 2 ) )                             as TAXABLE_AMT,

      cast(( coalesce(cast(a.TAXABLE_AMT as abap.dec( 20, 2 ) ) , 0 )  + coalesce( a.CSGST_AMT , 0 ) + coalesce( a.CSGST_AMT , 0 )
                 + coalesce( a.IGST_AMT , 0  )   )  as abap.dec( 20, 2 )  ) as INVOICE_AMT,


      cast(a.CSGST_AMT as abap.dec( 20, 2 ) )                               as Cgst_amt,
      cast(a.CSGST_AMT as abap.dec( 20, 2 ) )                               as sgst_amt,
      a.CSGST_RATE                                                          as sgst_rate,
      a.CSGST_RATE                                                          as cgst_rate,
      cast(a.IGST_AMT as abap.dec( 20, 2 ) )                                as IGST_AMT,
      a.IGST_RATE,
      a.REPORT,
      a.ProductDescription,
      a.Product,
      a.IsInvoice,
      a.SupplierFullName,
      a.IN_HSNOrSACCode
//      a.YY1_Transporter_MIH,
//      a.YY1_GRRRNo_MIH,
//      a.YY1_BillofEntryDate_MIH,
//      a.YY1_BillofEntryNo_MIH,
//      a.YY1_BillofEntryValue_MIHC,
//      @Semantics.amount.currencyCode: 'YY1_BillofEntryValue_MIHC'
//      a.YY1_BillofEntryValue_MIH,
//      a.YY1_EWAYBILLNO_MIH,
//      a.YY1_GSTIN_MIH,
//      a.YY1_Import_MIH,
//      a.YY1_PortCode_MIH,
//      a.YY1_VehicleNo_MIH


}

where

  (
           a.AccountingDocumentType =       'KR'
    or     a.AccountingDocumentType =       'KG'
    or(
      (
           a.AccountingDocumentType =       'RE'
        or a.AccountingDocumentType =       'VC'
        or a.AccountingDocumentType =       'ZA'
        or a.AccountingDocumentType =       'AA'
        or a.AccountingDocumentType =       'Y1'
      )
      and  a.ReverseDocument        =       '' 
      and  a.SupplierInvoiceStatus   =       '5'
    ) // POST DOCUMENT ONLY
  )

group by
  a.CompanyCode,
  a.AccountingDocument,
  a.doc_item,
  a.ProfitCenter,
  k.ProfitCenter,
  a.FiscalYear,
  a.SupplierInvoice,
  a.DocumentDate,
  a.PostingDate,
  a.TaxCode,
  a.Plant,
  a.DocumentReferenceID,
  a.FiscalPeriod,
  a.Supplier,
  a.SupplierName,
  a.AccountingDocumentType,
  a.BusinessPlace,
  a.SUP_GST,
  a.IN_GSTPlaceOfSupply,
  a.BaseUnit,
  a.TransactionCurrency,
  a.CompanyCodeCurrency,
  a.AmountInCompanyCodeCurrency,
  B.ConsumptionTaxCtrlCode,
  a.Quantity,
  a.TAXABLE_AMT,
  a.CSGST_AMT,
  a.CSGST_AMT,
  a.CSGST_RATE,
  a.CSGST_RATE,
  a.IGST_AMT,
  a.IGST_RATE,
  a.REPORT,
  a.ProductDescription,
  a.Product,
  a.IsInvoice,
  a.ReverseDocument,
  a.SupplierFullName,
  a.IN_HSNOrSACCode
//      a.YY1_Transporter_MIH,
//      a.YY1_GRRRNo_MIH,
//      a.YY1_BillofEntryDate_MIH,
//      a.YY1_BillofEntryNo_MIH,
//      a.YY1_BillofEntryValue_MIHC,
//      a.YY1_BillofEntryValue_MIH,
//      a.YY1_EWAYBILLNO_MIH,
//      a.YY1_GSTIN_MIH,
//      a.YY1_Import_MIH,
//      a.YY1_PortCode_MIH,
//      a.YY1_VehicleNo_MIH
