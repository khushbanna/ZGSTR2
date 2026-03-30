@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GSTR2 B2B CDS1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGSTR2_NIL_RATED_CDS1
  as select distinct from I_JournalEntry            as A
    left outer join       I_OperationalAcctgDocItem as B      on(
           B.AccountingDocument = A.AccountingDocument
           and B.CompanyCode    = A.CompanyCode
           and B.FiscalYear     = A.FiscalYear
         )

    left outer join       I_SupplierInvoiceAPI01    as C      on(
           A.OriginalReferenceDocument = concat(
             C.SupplierInvoice, C.FiscalYear
           )
           and C.CompanyCode           = A.CompanyCode
           and C.FiscalYear            = A.FiscalYear
         )
    left outer join       C_SupplierInvoiceItemDEX  as D      on(
           D.SupplierInvoice = C.SupplierInvoice
           and D.CompanyCode = C.CompanyCode
           and D.FiscalYear  = C.FiscalYear
         )

    left outer join       I_OperationalAcctgDocItem as K      on(
           K.AccountingDocument       = A.AccountingDocument
           and K.CompanyCode          = A.CompanyCode
           and K.FiscalYear           = A.FiscalYear
           and K.FinancialAccountType = 'K'
         )
    left outer join       I_Supplier                as K2     on(
          K2.Supplier = K.Supplier
        )

    left outer join       I_OperationalAcctgDocItem as CGST   on(
        CGST.AccountingDocument         = A.AccountingDocument
        and CGST.CompanyCode            = A.CompanyCode
        and CGST.FiscalYear             = A.FiscalYear
        and CGST.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
        and CGST.TaxCode                = B.TaxCode
        and CGST.GLAccount              = '0002541000' // 0002541001SGST
      )
    left outer join       I_OperationalAcctgDocItem as IGST   on(
        IGST.AccountingDocument         = A.AccountingDocument
        and IGST.CompanyCode            = A.CompanyCode
        and IGST.FiscalYear             = A.FiscalYear
        and IGST.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
        and IGST.TaxCode                = B.TaxCode
        and IGST.GLAccount              = '0002541002'
      )
    left outer join       I_OperationalAcctgDocItem as IGST_I on(
      IGST_I.AccountingDocument         = A.AccountingDocument
      and IGST_I.CompanyCode            = A.CompanyCode
      and IGST_I.FiscalYear             = A.FiscalYear
//      and IGST_I.TaxItemAcctgDocItemRef = B.TaxItemAcctgDocItemRef
//      and IGST_I.TaxCode  is initial               
      and IGST_I.GLAccount              = '0002541021'
    )

    left outer join       ZTAXCODE_SUMMARY          as CT     on(
          CT.taxcode         = B.TaxCode
          and CGST.GLAccount = '0002541000'
        )
    left outer join       ZTAXCODE_SUMMARY          as IT     on(
          IT.taxcode         = B.TaxCode
          and IGST.GLAccount = '0002541002'
        )
    left outer join       ZTAXCODE_SUMMARY          as IT_I   on(
        IT_I.taxcode         = B.TaxCode
        and IGST_I.GLAccount = '0002541021'
      )

    left outer join       I_ProductDescription      as p      on(
           p.Product      = B.Product
           and p.Language = 'E'
         )
  //    left outer join zglcode                   as gl   on(
  //        gl.AccountingDocument = A.AccountingDocument
  //        //        and gl.TaxItemAcctgDocItemRef    = B.TaxItemAcctgDocItemRef
  //        and gl.CompanyCode    = A.CompanyCode
  //        and gl.FiscalYear     = A.FiscalYear
  //      )
  //    left outer join I_GLAccountText           as gt   on(
  //        gt.GLAccount    = gl.GLAccount
  //        and gt.Language = 'E'
  //      )
    left outer join       I_GLAccountStdVH          as gla    on(
         gla.GLAccount       = B.GLAccount
         and gla.CompanyCode = A.CompanyCode
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
  B.Plant,
  A.DocumentReferenceID,
  A.FiscalPeriod,
  K.Supplier,
  K2.SupplierName,
  B.AccountingDocumentType,
  B.BusinessPlace,
  K2.TaxNumber3                                                                                        as SUP_GST,
  K2.Region                                                                                            as IN_GSTPlaceOfSupply,

  B.BaseUnit,
  B.TransactionCurrency,
  B.CompanyCodeCurrency,

  @Semantics.quantity.unitOfMeasure: 'BaseUnit'
  cast(B.Quantity as abap.dec( 20, 3 ) )                                                               as Quantity,
  B.GLAccount,
  cast(B.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                           as AmountInCompanyCodeCurrency,

  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
  cast( coalesce( cast(CGST.TaxBaseAmountInCoCodeCrcy as abap.dec( 20 , 2 ) ) , 0 )
  + coalesce( cast(IGST.TaxBaseAmountInCoCodeCrcy as abap.dec( 20 , 2 ) ), 0 ) as abap.dec( 20 , 2 ) ) as TAXABLE_AMT,

  cast(CGST.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                        as Cgst_amt,
  cast(CGST.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                        as sgst_amt,
  
  case when IGST.AmountInCompanyCodeCurrency is null and CGST.AmountInCompanyCodeCurrency is null
  then cast(IGST_I.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )
  else cast(IGST.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) ) end as igst_amt ,
  
//  coalesce( cast(IGST.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) ) , 0) +
//  coalesce( cast(IGST_I.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) ) , 0)                       as igst_amt, 
  
  
  cast(IGST_I.AmountInCompanyCodeCurrency as abap.dec( 20 , 2 ) )                                      as igst_amt_I,

  CT.gstrate                                                                                           as cgst_rate,
  CT.gstrate                                                                                           as sgst_rate,
  IT.gstrate                                                                                           as igst_rate,
  IT_I.gstrate                                                                                         as igst_rate_I,

  cast( 'NILRAT'  as abap.char(20)  )                                                                     as REPORT,

  p.ProductDescription                                                                                 as p1,
  p.ProductDescription                                                                                 as ProductDescription,
  B.Product,

  C.IsInvoice,
  C.ReverseDocument,
  C.SupplierInvoiceStatus,
  D.IsSubsequentDebitCredit,
  A.IsReversal,
  A.IsReversed
  //  K2.SupplierFullName,
  //  B.IN_HSNOrSACCode

//  C.YY1_Transporter_MIH,
//  C.YY1_GRRRNo_MIH,
//  C.YY1_BillofEntryDate_MIH,
//  C.YY1_BillofEntryNo_MIH,
//  C.YY1_BillofEntryValue_MIHC,
//  @Semantics.amount.currencyCode: 'YY1_BillofEntryValue_MIHC'
//  C.YY1_BillofEntryValue_MIH,
//  C.YY1_EWAYBILLNO_MIH,
//  C.YY1_GSTIN_MIH,
//  C.YY1_Import_MIH,
//  C.YY1_PortCode_MIH,
//  C.YY1_VehicleNo_MIH




}
where
  (
       A.AccountingDocumentType =    'KR'
    or A.AccountingDocumentType =    'RE'
     or A.AccountingDocumentType =    'KG'
        or A.AccountingDocumentType =    'VC'
) 
  and  B.GLAccount              <>   '0002541000'
  and  B.GLAccount              <>   '0002541001'
  and  B.GLAccount              <>   '0002541002'
  and  B.GLAccount              <>   '0002541021'
  and      B.GLAccount                      <> '0004651011'

  //    and      B.GLAccount              <>   '0004002033'  // Price Difference
  //    and      B.GLAccount              <>   '0002402030'  // INV-RM TUBE DOM
  //    and      B.GLAccount              <>   '0004006070'
  //    and      B.GLAccount              <>   '0004002053'
  //    and      B.GLAccount              <>   '0002402050'
  //    and      B.GLAccount              <>   '0004054037'
  //    and      B.GLAccount              <>   '0004054033'
  //    and      B.GLAccount              <>   '0004601000'
  //    and      B.GLAccount              <>   '0002406080'
  //    and      B.GLAccount              <>   '0004006083'
  //    and      B.GLAccount              <>   '0002406070'

  and(
       B.TaxCode                like 'V0%'
    or B.TaxCode                like ''
  )
  and  B.TaxItemAcctgDocItemRef <>   '000000'
  and  gla.GLAccountType        <>   'N'
