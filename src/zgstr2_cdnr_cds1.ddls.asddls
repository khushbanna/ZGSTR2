@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GSTR2 CDNR CDS1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGSTR2_CDNR_CDS1
  as select distinct from I_JournalEntry            as A
    left outer join       I_OperationalAcctgDocItem as B    on(
         B.AccountingDocument = A.AccountingDocument
         and B.CompanyCode    = A.CompanyCode
         and B.FiscalYear     = A.FiscalYear
       )

    left outer join       I_SupplierInvoiceAPI01      as C    on(
         A.OriginalReferenceDocument = concat(
           C.SupplierInvoice, C.FiscalYear
         )
         and C.CompanyCode           = A.CompanyCode
         and C.FiscalYear            = A.FiscalYear
       )
    left outer join       C_SupplierInvoiceItemDEX  as D    on(
         D.SupplierInvoice = C.SupplierInvoice
         and D.CompanyCode = C.CompanyCode
         and D.FiscalYear  = C.FiscalYear

       )

    left outer join       I_OperationalAcctgDocItem as K    on(
         K.AccountingDocument       = A.AccountingDocument
         and K.CompanyCode          = A.CompanyCode
         and K.FiscalYear           = A.FiscalYear
         and K.FinancialAccountType = 'K'
       )
    left outer join       I_Supplier                as K2   on(
        K2.Supplier = K.Supplier
      )

    left outer join       I_OperationalAcctgDocItem as CGST on(
      CGST.AccountingDocument         = A.AccountingDocument
      and CGST.CompanyCode            = A.CompanyCode
      and CGST.FiscalYear             = A.FiscalYear
      and CGST.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
      and CGST.TaxCode                = B.TaxCode
      and CGST.GLAccount              = '0002541000'
    )
    left outer join       I_OperationalAcctgDocItem as IGST on(
      IGST.AccountingDocument         = A.AccountingDocument
      and IGST.CompanyCode            = A.CompanyCode
      and IGST.FiscalYear             = A.FiscalYear
      and IGST.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
      and IGST.TaxCode                = B.TaxCode
      and IGST.GLAccount              = '0002541002'
    )
    left outer join       ZTAXCODE_SUMMARY          as CT   on(
        CT.taxcode         = B.TaxCode
        and CGST.GLAccount = '0002541000'
      )
    left outer join       ZTAXCODE_SUMMARY          as IT   on(
        IT.taxcode         = B.TaxCode
        and IGST.GLAccount = '0002541002'
      )
    left outer join       I_ProductDescription      as p    on(
         p.Product      = B.Product
         and p.Language = 'E'
       )
//    left outer join       zglcode                   as gl   on(
//        gl.AccountingDocument = A.AccountingDocument
//        and gl.CompanyCode    = A.CompanyCode
//        and gl.FiscalYear     = A.FiscalYear
//      )
//    left outer join       I_GLAccountText           as gt   on(
//        gt.GLAccount    = gl.GLAccount
//        and gt.Language = 'E'
//      )
    left outer join       I_GLAccountStdVH          as gla  on(
       gla.GLAccount       = B.GLAccount
       and gla.CompanyCode = A.CompanyCode
     )


{

  B.CompanyCode,
  B.AccountingDocument,
  B.ProfitCenter,
  B.TaxItemAcctgDocItemRef,
  A.OriginalReferenceDocument,
  C.SupplierInvoice,
  B.FiscalYear,
  B.DocumentDate,
  B.PostingDate,
  B.TaxCode,
  B.Plant,
  A.DocumentReferenceID,
  A.FiscalPeriod,
  K.Supplier,
  K2.SupplierName,
  B.AccountingDocumentType,
  B.BusinessPlace,
  K2.TaxNumber3                                                                                         as SUP_GST,
  K2.Region                                                                                             as IN_GSTPlaceOfSupply,

  B.BaseUnit,
  B.TransactionCurrency,
  B.CompanyCodeCurrency,

  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  cast(B.Quantity as abap.dec( 20, 3 ) )                                                                as Quantity,


  B.GLAccount ,
  cast(B.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                            as AmountInCompanyCodeCurrency,

  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'

  cast( coalesce( cast(CGST.TaxBaseAmountInCoCodeCrcy as abap.dec( 20 , 2 ) ) , 0 )
  + coalesce( cast(IGST.TaxBaseAmountInCoCodeCrcy as abap.dec( 20 , 2 ) ), 0 ) as abap.dec( 20 , 2 ) )  as TAXABLE_AMT,


  cast(CGST.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                         as Cgst_amt,
  cast(CGST.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                         as sgst_amt,
  cast(IGST.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                         as igst_amt,

  CT.gstrate                                                                                            as cgst_rate,
  CT.gstrate                                                                                            as sgst_rate,
  IT.gstrate                                                                                            as igst_rate,

  case when A.TransactionCurrency <> 'INR'
   then  cast( 'IMPORT'  as abap.char(20)  )
  else cast( 'ELG'  as abap.char(20)  )                                                            end as REPORT,


  p.ProductDescription                                                                                  as PT1,
  B.Product                                                                                             as P1,
//  gt.GLAccountName                                                                                      as PT2,
//  gl.GLAccount                                                                                          as P2,

//  case when p.ProductDescription is not initial
//      then p.ProductDescription
//      else
//        gt.GLAccountName end                                                                            as ProductDescription,
//
//  case when B.Product is not initial
//  then B.Product
//  else
//    gl.GLAccount end                                                                                    as Product,


  p.ProductDescription ,
  B.Product ,

  C.IsInvoice,
  C.ReverseDocument,
  C.SupplierInvoiceStatus,
  D.IsSubsequentDebitCredit,
  A.IsReversal,
  A.IsReversed,
  gla.GLAccountType,
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
       A.AccountingDocumentType =    'KG'
    //    or A.AccountingDocumentType =    'RE'
    or A.AccountingDocumentType =    'VC'
    or A.AccountingDocumentType =    'ZA'
  )

  //  and  B.ProfitLossAccountType  <> 'X'
  and  B.GLAccount              <>   '0002541000'
  and  B.GLAccount              <>   '0002541001'
  and  B.GLAccount              <>   '0002541002'
  and  B.TaxCode                like 'V%'
  and  B.TaxItemAcctgDocItemRef <>   '000000'
  and  gla.GLAccountType        <>   'N'
