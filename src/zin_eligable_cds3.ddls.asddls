@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IN ELIGABLE CDS 3'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZIN_ELIGABLE_CDS3
  as select from    I_JournalEntry            as A
    left outer join I_OperationalAcctgDocItem as B  on(
       B.AccountingDocument = A.AccountingDocument
       and B.CompanyCode    = A.CompanyCode
       and B.FiscalYear     = A.FiscalYear
     )
    left outer join ZIN_ELIGABLE_CDS2         as AB on(
      AB.AccountingDocument         = B.AccountingDocument
      and AB.CompanyCode            = B.CompanyCode
      and AB.FiscalYear             = B.FiscalYear
      and AB.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
    )
    left outer join I_SupplierInvoiceAPI01      as C  on(
       A.OriginalReferenceDocument = concat(
         C.SupplierInvoice, C.FiscalYear
       )
       and C.CompanyCode           = A.CompanyCode
       and C.FiscalYear            = A.FiscalYear
     )
    left outer join I_OperationalAcctgDocItem as K  on(
       K.AccountingDocument       = A.AccountingDocument
       and K.CompanyCode          = A.CompanyCode
       and K.FiscalYear           = A.FiscalYear
       and K.FinancialAccountType = 'K'
     )
    left outer join I_Supplier                as K2 on(
      K2.Supplier = K.Supplier
    )

    left outer join I_OperationalAcctgDocItem as F  on(
       F.AccountingDocument         = B.AccountingDocument
       and F.CompanyCode            = B.CompanyCode
       and F.FiscalYear             = B.FiscalYear
       and F.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
       and F.FixedAsset             is not initial
     )
    left outer join I_FixedAsset              as ft on(
      ft.CompanyCode          = B.CompanyCode
      and ft.MasterFixedAsset = B.MasterFixedAsset
    )

    left outer join I_ProductDescription      as p  on(
       p.Product      = B.Product
       and p.Language = 'E'
     )

    left outer join I_GLAccountText           as gt on(
      gt.GLAccount    = B.GLAccount
      and gt.Language = 'E'
    )



{

  B.CompanyCode,
  B.AccountingDocument,
  B.TaxItemAcctgDocItemRef                                       as doc_item,
  B.ProfitCenter,
  C.SupplierInvoice,
  B.FiscalYear,
  B.DocumentDate,
  B.PostingDate,
  //  B.GLAccount,
  B.TaxCode,
  //  B.Product ,
  B.Plant,
  A.DocumentReferenceID,
  A.FiscalPeriod,
  K.Supplier,
  K2.SupplierName,
  B.AccountingDocumentType,
  B.BusinessPlace,
  K2.TaxNumber3                                                  as SUP_GST,
  K2.Region                                                      as IN_GSTPlaceOfSupply,

  //  B.IN_GSTPlaceOfSupply ,

  B.BaseUnit,
  B.TransactionCurrency,
  B.CompanyCodeCurrency,
  cast( B.AmountInCompanyCodeCurrency as abap.dec( 16, 2 ) )     as AmountInCompanyCodeCurrency,

  cast(B.Quantity as abap.dec( 20, 3 ) )                         as Quantity,

  AB.TAXABLE_AMT                                                 as TAXABLE_AMT,
  sum(AB.TAXABLE_AMT)                                            as TESTINGONLY,

  case AB.TaxCode
  when 'N1' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  when 'N2' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  when 'N3' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  when 'N4' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  when 'NB' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  else cast('0.00' as abap.dec( 20, 2 ) )
  //   else 0.00
  end                                                            as CSGST_AMT,

  case AB.TaxCode
  when 'N5' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  when 'N6' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  when 'N7' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  when 'N8' then cast( AB.GSTAMOUNT  as abap.dec( 20, 2 ) )
  else cast('0.00' as abap.dec( 20, 2 ) )
  //   else 0.00
  end                                                            as IGST_AMT,

  case AB.TaxCode
  when 'N1' then AB.gstrate
  when 'N2' then AB.gstrate
  when 'N3' then AB.gstrate
  when 'N4' then AB.gstrate
  else cast('0.00' as abap.dec( 5, 2 ) )
  end                                                            as CSGST_RATE,

  case AB.TaxCode
  when 'N5' then AB.gstrate
  when 'N6' then AB.gstrate
  when 'N7' then AB.gstrate
  when 'N8' then AB.gstrate
  else cast('0.00' as abap.dec( 5, 2 ) )
  end                                                            as IGST_RATE,


  case when A.TransactionCurrency <> 'INR'
   then  cast( 'IMPORT'  as abap.char(20)  )
   else cast( 'IN_ELG'  as abap.char(20)  )                  end as REPORT,



  B.Product as p1 ,
  B.GLAccount as g1 ,
  
  case
  when B.Product is not initial     then p.ProductDescription
  else   gt.GLAccountName
          end                                                    as ProductDescription,

   B.Product                                                    as Product,

  F.MasterFixedAsset,
  ft.FixedAssetDescription,

  C.IsInvoice,
  C.SupplierInvoiceStatus,
  C.ReverseDocument,
  '' as SupplierFullName,
  '' as IN_HSNOrSACCode
//      C.YY1_Transporter_MIH,
//      C.YY1_GRRRNo_MIH,
//      C.YY1_BillofEntryDate_MIH,
//      C.YY1_BillofEntryNo_MIH,
//      C.YY1_BillofEntryValue_MIHC,
//      @Semantics.amount.currencyCode: 'YY1_BillofEntryValue_MIHC'
//      C.YY1_BillofEntryValue_MIH,
//      C.YY1_EWAYBILLNO_MIH,
//      C.YY1_GSTIN_MIH,
//      C.YY1_Import_MIH,
//      C.YY1_PortCode_MIH,
//      C.YY1_VehicleNo_MIH





}
where

  (
       A.AccountingDocumentType =       'KR'
    or A.AccountingDocumentType =       'KG'
    or A.AccountingDocumentType =       'RE'
    or A.AccountingDocumentType =       'VC'
    or A.AccountingDocumentType =       'ZA'
    or A.AccountingDocumentType =       'AA'
    or A.AccountingDocumentType =       'Y1'
  )
  and  B.TaxItemAcctgDocItemRef <>      '000000'
  and  B.OriginalTaxBaseAmount  <>      0.00
  and  A.IsReversal             <>      'X'
  and  A.IsReversed             <>      'X'
  and  B.TaxCode                between 'N1' and 'N8'



group by

  B.CompanyCode,
  B.AccountingDocument,
  B.TaxItemAcctgDocItemRef,
  B.ProfitCenter,
  C.SupplierInvoice,
  B.FiscalYear,
  B.DocumentDate,
  B.PostingDate,
  B.GLAccount,
  F.MasterFixedAsset,
  ft.FixedAssetDescription,
  K2.Region,
  B.TaxCode,
  B.Product,
  B.Plant,
  A.DocumentReferenceID,
  A.FiscalPeriod,
  K.Supplier,
  K2.SupplierName,
  B.AccountingDocumentType,
  B.BusinessPlace,
  K2.TaxNumber3,
  B.IN_GSTPlaceOfSupply,
  AB.GSTAMOUNT,
  AB.gstrate,
  AB.TaxCode,
  AB.TAXABLE_AMT,
  B.BaseUnit,
  B.TransactionCurrency,
  B.CompanyCodeCurrency,
  B.AmountInCompanyCodeCurrency,

  B.Quantity,
  p.ProductDescription,
  gt.GLAccountName,
  A.TransactionCurrency,
  C.IsInvoice,
  C.SupplierInvoiceStatus,
  C.ReverseDocument
//  C.YY1_Transporter_MIH,
//      C.YY1_GRRRNo_MIH,
//      C.YY1_BillofEntryDate_MIH,
//      C.YY1_BillofEntryNo_MIH,
//      C.YY1_BillofEntryValue_MIHC,
//      C.YY1_BillofEntryValue_MIH,
//      C.YY1_EWAYBILLNO_MIH,
//      C.YY1_GSTIN_MIH,
//      C.YY1_Import_MIH,
//      C.YY1_PortCode_MIH,
//      C.YY1_VehicleNo_MIH
