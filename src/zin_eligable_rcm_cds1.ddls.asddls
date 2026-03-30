@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IN ELIGABLE RCM CDS 4'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZIN_ELIGABLE_RCM_CDS1
  as select from    I_JournalEntry            as A
    left outer join I_OperationalAcctgDocItem as B    on(
         B.AccountingDocument = A.AccountingDocument
         and B.CompanyCode    = A.CompanyCode 
         and B.FiscalYear     = A.FiscalYear
       )

    left outer join I_SupplierInvoiceAPI01      as C    on(
         A.OriginalReferenceDocument = concat(
           C.SupplierInvoice, C.FiscalYear
         )
         and C.CompanyCode           = A.CompanyCode
         and C.FiscalYear            = A.FiscalYear
       )
    left outer join C_SupplierInvoiceItemDEX  as D    on(
         D.SupplierInvoice = C.SupplierInvoice
         and D.CompanyCode = C.CompanyCode
         and D.FiscalYear  = C.FiscalYear

       )

    left outer join I_OperationalAcctgDocItem as K    on(
         K.AccountingDocument       = A.AccountingDocument
         and K.CompanyCode          = A.CompanyCode
         and K.FiscalYear           = A.FiscalYear
         and K.FinancialAccountType = 'K'
       )
    left outer join I_Supplier                as K2   on(
        K2.Supplier = K.Supplier
      )

    left outer join I_OperationalAcctgDocItem as TAX  on(
       TAX.AccountingDocument         =  A.AccountingDocument
       and TAX.CompanyCode            =  A.CompanyCode
       and TAX.FiscalYear             =  A.FiscalYear
       and TAX.TaxItemAcctgDocItemRef =  B.TaxItemAcctgDocItemRef
       and TAX.OriginalTaxBaseAmount  <> 0.00
       and TAX.TaxCode                =  B.TaxCode
     )
    left outer join I_OperationalAcctgDocItem as CGST on(
      CGST.AccountingDocument         = A.AccountingDocument
      and CGST.CompanyCode            = A.CompanyCode
      and CGST.FiscalYear             = A.FiscalYear
      and CGST.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
      and CGST.TaxCode                = B.TaxCode
      and CGST.GLAccount              = '0001501007' // SGST 0001621017
    )
    left outer join I_OperationalAcctgDocItem as IGST on(
      IGST.AccountingDocument         = A.AccountingDocument
      and IGST.CompanyCode            = A.CompanyCode
      and IGST.FiscalYear             = A.FiscalYear
      and IGST.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
      and IGST.TaxCode                = B.TaxCode
      and IGST.GLAccount              = '0001501009'
    )

    left outer join ZTAXCODE_SUMMARY          as CT   on(
        CT.taxcode         = B.TaxCode
        and CGST.GLAccount = '0001501007'
      )
    left outer join ZTAXCODE_SUMMARY          as IT   on(
        IT.taxcode         = B.TaxCode
        and IGST.GLAccount = '0001501009'
      )

    left outer join I_ProductDescription      as p    on(
         p.Product      = B.Product
         and p.Language = 'E'
       )
//    left outer join zglcode                   as gl   on(
//        gl.AccountingDocument = A.AccountingDocument
//        and gl.CompanyCode    = A.CompanyCode
//        and gl.FiscalYear     = A.FiscalYear
//      )
//    left outer join I_GLAccountText           as gt   on(
//        gt.GLAccount    = gl.GLAccount
//        and gt.Language = 'E'
//      )

    left outer join I_OperationalAcctgDocItem as F    on(
         F.AccountingDocument         = B.AccountingDocument
         and F.CompanyCode            = B.CompanyCode
         and F.FiscalYear             = B.FiscalYear
         and F.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
         and F.FixedAsset             is not initial
       )
    left outer join I_FixedAsset              as ft   on(
        ft.CompanyCode          = B.CompanyCode
        and ft.MasterFixedAsset = B.MasterFixedAsset
      )


{

  B.CompanyCode,
  B.AccountingDocument,
  B.TaxItemAcctgDocItemRef,
  B.ProfitCenter,
  C.SupplierInvoice,
  B.FiscalYear,
  B.DocumentDate,
  B.PostingDate,
  B.TaxCode,
  //  B.Product ,
  B.Plant,
  A.DocumentReferenceID,
  A.FiscalPeriod,
  K.Supplier,
  K2.SupplierName,
  B.AccountingDocumentType,
  B.BusinessPlace,
  K2.TaxNumber3                                                             as SUP_GST,
  K2.Region                                                                 as IN_GSTPlaceOfSupply,

  //  B.IN_GSTPlaceOfSupply ,

  B.BaseUnit,
  B.TransactionCurrency,
  B.CompanyCodeCurrency,

  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  B.Quantity,
  B.GLAccount ,
  cast( B.AmountInCompanyCodeCurrency as abap.dec( 20, 2 ) ) * (-1)         as AmountInCompanyCodeCurrency,
  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'

  cast(TAX.OriginalTaxBaseAmount as abap.dec( 20, 2 )  )                    as TAXABLE_AMT,

  cast(CGST.AmountInCompanyCodeCurrency as abap.dec( 20, 2 ) ) * (-1)       as Cgst_amt,
  cast(CGST.AmountInCompanyCodeCurrency as abap.dec( 20, 2 ) ) * (-1)       as sgst_amt,
  cast(IGST.AmountInCompanyCodeCurrency as abap.dec( 20, 2 ) ) * (-1)       as igst_amt,


  CT.gstrate                                                                as cgst_rate,
  CT.gstrate                                                                as sgst_rate,
  IT.gstrate                                                                as igst_rate,
  sum(IT.gstrate)                                                           as TESTINGONLY,

  case when A.TransactionCurrency <> 'INR' then
   cast( 'IMPORT'  as abap.char(20)  )
   else cast( 'IN_ELG'  as abap.char(20)  )                         end as REPORT,


  p.ProductDescription ,
  B.Product ,
//  case when p.ProductDescription is not initial
//      then p.ProductDescription
//      else
//        gt.GLAccountName end                                                as ProductDescription,
//
//  case when B.Product is not initial
//   then B.Product
//   else
//     gl.GLAccount end                                                       as Product,

  F.MasterFixedAsset,
  ft.FixedAssetDescription,

  D.IsSubsequentDebitCredit,
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
       A.AccountingDocumentType         =       'KR'
    or A.AccountingDocumentType         =       'KG'
    or A.AccountingDocumentType         =       'RE'
    or A.AccountingDocumentType         =       'VC'
    or A.AccountingDocumentType         =       'ZA'
    or A.AccountingDocumentType         =       'AA'
    or A.AccountingDocumentType         =       'Y1'
  )
  and  B.TaxItemAcctgDocItemRef         <>      '000000'
//  and  B.GLAccount                      <>      '0001501007'
//  and  B.GLAccount                      <>      '0001501008'
//  and  B.GLAccount                      <>      '0001501009'
  and  A.IsReversal                     <>      'X'
  and  A.IsReversed                     <>      'X'
  and  B.TaxCode                        between 'M1' and 'M8'
  and(
       CGST.AmountInCompanyCodeCurrency is not null
    or IGST.AmountInCompanyCodeCurrency is not null
  )



group by

  B.CompanyCode,
  B.AccountingDocument,
  B.TaxItemAcctgDocItemRef,
  B.ProfitCenter,
  C.SupplierInvoice,
  B.FiscalYear,
  B.DocumentDate,
  B.PostingDate,
  //  B.GLAccount,
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

  B.BaseUnit,
  B.TransactionCurrency,
  B.CompanyCodeCurrency,

  B.Quantity,
  TAX.OriginalTaxBaseAmount,
  A.TransactionCurrency,
  CGST.AmountInCompanyCodeCurrency,
  IGST.AmountInCompanyCodeCurrency,
  B.GLAccount ,
  B.AmountInCompanyCodeCurrency,

  CT.gstrate,
  IT.gstrate,
  p.ProductDescription,
  F.MasterFixedAsset,
  ft.FixedAssetDescription,
  D.IsSubsequentDebitCredit,
  C.IsInvoice,
  C.SupplierInvoiceStatus,
  C.ReverseDocument
//      C.YY1_Transporter_MIH,
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
