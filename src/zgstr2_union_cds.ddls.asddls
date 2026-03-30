@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'GSTR2 REPORT'
@Metadata.ignorePropagatedAnnotations: true
@UI: { headerInfo: { typeName: 'Report', typeNamePlural: 'GSTR2 Report'  } }
define root view entity ZGSTR2_UNION_CDS
  as select distinct from ZGSTR2_B2B_CDS2 as A
  left outer join ZGSTR2_B2B_CDS2_NEW22 as b on A.AccountingDocument = b.AccountingDocument and A.CompanyCode = b.CompanyCode
  and A.FiscalYear = b.FiscalYear
  left outer join ZHSN_DES as c on c.ConsumptionTaxCtrlCode = A.ConsumptionTaxCtrlCode 
{
      @UI.lineItem      : [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @EndUserText.label: 'Company Code'
  key A.CompanyCode,
      @UI.lineItem      : [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @Consumption.valueHelpDefinition: [ { entity : { name: 'ZACCDOC_F4', element : 'accdoc' } }]
      @EndUserText.label: 'Accounting Document'
  key A.AccountingDocument,
      @UI.lineItem      : [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      @EndUserText.label: 'Fiscal Year'
  key A.FiscalYear,
  key A.doc_item,
  key case when A.CompanyCode = '2000' then '2100'
      else  max( A.ProfitCenter ) end as ProfitCenter,
  key case when A.SupplierInvoice <> '' then A.SupplierInvoice else A.AccountingDocument end as SupplierInvoice ,
  key A.ProductDescription,
  key A.ConsumptionTaxCtrlCode,
         @EndUserText.label: 'HSN Description'
  key c.ConsumptionTaxCtrlCodeText1 ,
  key A.DocumentDate,
  key A.PostingDate,
  key A.TaxCode,
  key A.Product,
  key A.Plant,
  key A.FiscalPeriod,
  key A.Supplier,
  key A.SupplierName,
  key A.AccountingDocumentType,
  key A.BusinessPlace,
  key A.DocumentReferenceID,
  key A.IN_GSTPlaceOfSupply,
  key A.SUP_GST,
  key A.BaseUnit,
  key A.TransactionCurrency,
  key A.CompanyCodeCurrency,
      @UI.lineItem      : [{ position: 35 }]
      @UI.identification: [{ position: 35 }]
      @EndUserText.label: 'Taxable Amount'
     @DefaultAggregation: #SUM
  key A.AmountInCompanyCodeCurrency,
     @DefaultAggregation: #SUM
  key A.Quantity,
     @UI.hidden: true
     @DefaultAggregation: #SUM
  key A.TAXABLE_AMT,
     @DefaultAggregation: #SUM
  key A.Cgst_amt,
     @DefaultAggregation: #SUM
  key A.sgst_amt,
     @DefaultAggregation: #SUM
  key A.igst_amt,
  key A.cgst_rate,
  key A.sgst_rate,
  key A.igst_rate,
   @EndUserText.label: 'HSN Total Amount'
   @DefaultAggregation: #SUM    
  key cast(coalesce(A.AmountInCompanyCodeCurrency,0) + coalesce(A.Cgst_amt,0) + coalesce(A.sgst_amt,0) + coalesce(A.igst_amt,0) as abap.dec( 20, 2 )) as hsn_tot_amt,
  
    @EndUserText.label: 'Tax Rate'
  key cast (coalesce(A.cgst_rate,0) + coalesce(A.sgst_rate,0) + coalesce(A.igst_rate,0) as abap.dec( 3, 0 )) as taxrate, 
  
          @EndUserText.label: 'Tax Amount'
      @DefaultAggregation: #SUM
  key cast (coalesce(A.Cgst_amt,0) + coalesce(A.sgst_amt,0) + coalesce(A.igst_amt,0) as abap.dec( 23, 3 )) as taxamt,
  
     @DefaultAggregation: #SUM
  key coalesce( A.INVOICE_AMT,0) + coalesce( b.nt_amt,0) as INVOICE_AMT,
  
      @UI.lineItem             : [{ position: 1000 }]
      @UI.selectionField       : [{position:  1000 }]
//      @Consumption.filter.multipleSelections: false
//      @Consumption.filter.mandatory: true
      @Consumption.defaultValue: 'ELG'
      @EndUserText.label       : 'Report'
      @Consumption.valueHelpDefinition: [ { entity : { name: 'ZGSTR2_F4', element : 'subrep_type' } }]
      A.REPORT,
    '' as  SupplierFullName,
    '' as  IN_HSNOrSACCode
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
group by
    A.CompanyCode,
    A.AccountingDocument,
    A.FiscalYear,
    A.doc_item,
    A.SupplierInvoice,
    A.ProductDescription,
    A.ConsumptionTaxCtrlCode,
    c.ConsumptionTaxCtrlCodeText1,
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
    A.DocumentReferenceID,
    A.IN_GSTPlaceOfSupply,
    A.SUP_GST,
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
    A.INVOICE_AMT,
    b.nt_amt,
    A.REPORT


union select distinct from ZGSTR2_CDNR_CDS2 as B
  left outer join ZHSN_DES as a on a.ConsumptionTaxCtrlCode = B.ConsumptionTaxCtrlCode 
   
{
  key B.CompanyCode,
  key B.AccountingDocument,
  key B.FiscalYear,
  key B.doc_item,
  key case when B.CompanyCode = '2000' then '2100'
      else max( B.ProfitCenter ) end as ProfitCenter,
  key case when B.SupplierInvoice <> '' then B.SupplierInvoice else B.AccountingDocument end as SupplierInvoice,
  key B.ProductDescription,
  key B.ConsumptionTaxCtrlCode,
  key a.ConsumptionTaxCtrlCodeText1 ,
  key B.DocumentDate,
  key B.PostingDate,
  key B.TaxCode,
  key B.Product,
  key B.Plant,
  key B.FiscalPeriod,
  key B.Supplier,
  key B.SupplierName,
  key B.AccountingDocumentType,
  key B.BusinessPlace,
  key B.DocumentReferenceID,
  key B.IN_GSTPlaceOfSupply,
  key B.SUP_GST,
  key B.BaseUnit,
  key B.TransactionCurrency,
  key B.CompanyCodeCurrency,
  key B.AmountInCompanyCodeCurrency,
  key B.Quantity,
  key B.TAXABLE_AMT,
  key B.Cgst_amt,
  key B.sgst_amt,
  key B.igst_amt,
  key B.cgst_rate,
  key B.sgst_rate,
  key B.igst_rate,
  key cast(coalesce(B.AmountInCompanyCodeCurrency,0) + coalesce(B.Cgst_amt,0) + coalesce(B.sgst_amt,0) + coalesce(B.igst_amt,0) as abap.dec( 20, 2 )) as hsn_tot_amt,
  key cast (coalesce(B.cgst_rate,0) + coalesce(B.sgst_rate,0) + coalesce(B.igst_rate,0) as abap.dec( 3, 0 )) as taxrate,  
  key cast (coalesce(B.Cgst_amt,0) + coalesce(B.sgst_amt,0) + coalesce(B.igst_amt,0) as abap.dec( 23, 3 )) as taxamt,
  key B.INVOICE_AMT,
      B.REPORT,
     '' as SupplierFullName,
    '' as  IN_HSNOrSACCode
//      B.YY1_Transporter_MIH,
//      B.YY1_GRRRNo_MIH,
//      B.YY1_BillofEntryDate_MIH,
//      B.YY1_BillofEntryNo_MIH,
//      B.YY1_BillofEntryValue_MIHC,
//      B.YY1_BillofEntryValue_MIH,
//      B.YY1_EWAYBILLNO_MIH,
//      B.YY1_GSTIN_MIH,
//      B.YY1_Import_MIH,
//      B.YY1_PortCode_MIH,
//      B.YY1_VehicleNo_MIH

}
group by
    B.CompanyCode,
    B.AccountingDocument,
    B.FiscalYear,
    B.doc_item,
    B.SupplierInvoice,
    B.ProductDescription,
    B.ConsumptionTaxCtrlCode,
    a.ConsumptionTaxCtrlCodeText1,
    B.DocumentDate,
    B.PostingDate,
    B.TaxCode,
    B.Product,
    B.Plant,
    B.FiscalPeriod,
    B.Supplier,
    B.SupplierName,
    B.AccountingDocumentType,
    B.BusinessPlace,
    B.DocumentReferenceID,
    B.IN_GSTPlaceOfSupply,
    B.SUP_GST,
    B.BaseUnit,
    B.TransactionCurrency,
    B.CompanyCodeCurrency,
    B.AmountInCompanyCodeCurrency,
    B.Quantity,
    B.TAXABLE_AMT,
    B.Cgst_amt,
    B.sgst_amt,
    B.igst_amt,
    B.cgst_rate,
    B.sgst_rate,
    B.igst_rate,
    B.INVOICE_AMT,
    B.REPORT


union select distinct from ZGSTR2_RCM_CDS2 as C
  left outer join ZHSN_DES as a on C.ConsumptionTaxCtrlCode = a.ConsumptionTaxCtrlCode 
   
{
  key C.CompanyCode,
  key C.AccountingDocument,
  key C.FiscalYear,
  key C.doc_item,
  key case when C.CompanyCode = '2000' then '2100'
      else max( C.ProfitCenter ) end as ProfitCenter,
  key case when C.SupplierInvoice <> '' then C.SupplierInvoice else C.AccountingDocument end as SupplierInvoice,
  key C.ProductDescription,
  key C.ConsumptionTaxCtrlCode,
  key a.ConsumptionTaxCtrlCodeText1 ,
  key C.DocumentDate,
  key C.PostingDate,
  key C.TaxCode,
  key C.Product,
  key C.Plant,
  key C.FiscalPeriod,
  key C.Supplier,
  key C.SupplierName,
  key C.AccountingDocumentType,
  key C.BusinessPlace,
  key C.DocumentReferenceID,
  key C.IN_GSTPlaceOfSupply,
  key C.SUP_GST,
  key C.BaseUnit,
  key C.TransactionCurrency,
  key C.CompanyCodeCurrency,
  key C.TAXABLE_AMT as AmountInCompanyCodeCurrency ,
  key C.Quantity,
  key C.TAXABLE_AMT,
  key C.Cgst_amt,
  key C.sgst_amt,
  key C.igst_amt,
  key C.cgst_rate,
  key C.sgst_rate,
  key C.igst_rate,
  key cast(coalesce(C.TAXABLE_AMT,0) + coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.igst_amt,0) as abap.dec( 20, 2 )) as hsn_tot_amt,  
  key cast (coalesce(C.cgst_rate,0) + coalesce(C.sgst_rate,0) + coalesce(C.igst_rate,0) as abap.dec( 3, 0 )) as taxrate,   
  key cast (coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.igst_amt,0) as abap.dec( 23, 3 )) as taxamt,
  key C.TAXABLE_AMT as INVOICE_AMT,
      C.REPORT,
      '' as SupplierFullName,
      '' as IN_HSNOrSACCode
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
}
group by
    C.CompanyCode,
    C.AccountingDocument,
    C.FiscalYear,
    C.doc_item,
    C.SupplierInvoice,
    C.ProductDescription,
    C.ConsumptionTaxCtrlCode,
    a.ConsumptionTaxCtrlCodeText1,
    C.DocumentDate,
    C.PostingDate,
    C.TaxCode,
    C.Product,
    C.Plant,
    C.FiscalPeriod,
    C.Supplier,
    C.SupplierName,
    C.AccountingDocumentType,
    C.BusinessPlace,
    C.DocumentReferenceID,
    C.IN_GSTPlaceOfSupply,
    C.SUP_GST,
    C.BaseUnit,
    C.TransactionCurrency,
    C.CompanyCodeCurrency,
    C.TAXABLE_AMT,
    C.Quantity,
    C.Cgst_amt,
    C.sgst_amt,
    C.igst_amt,
    C.cgst_rate,
    C.sgst_rate,
    C.igst_rate,
    C.REPORT



union select distinct from ZIN_ELIGABLE_CDS4 as C
  left outer join ZHSN_DES as a on C.ConsumptionTaxCtrlCode = a.ConsumptionTaxCtrlCode 
  

{
  key C.CompanyCode,
  key C.AccountingDocument,
  key C.FiscalYear,
  key C.doc_item,
  key case when C.CompanyCode = '2000' then '2100'
      else max( C.ProfitCenter ) end as ProfitCenter,
  key case when C.SupplierInvoice <> '' then C.SupplierInvoice else C.AccountingDocument end as SupplierInvoice,
  key C.ProductDescription,
  key C.ConsumptionTaxCtrlCode ,
  key a.ConsumptionTaxCtrlCodeText1 ,  
  key C.DocumentDate,
  key C.PostingDate,
  key C.TaxCode,
  key C.Product,
  key C.Plant,
  key C.FiscalPeriod,
  key C.Supplier,
  key C.SupplierName,
  key C.AccountingDocumentType,
  key C.BusinessPlace,
  key C.DocumentReferenceID,
  key C.IN_GSTPlaceOfSupply,
  key C.SUP_GST,
  key C.BaseUnit,
  key C.TransactionCurrency,
  key C.CompanyCodeCurrency,
  key C.AmountInCompanyCodeCurrency  ,
  key C.Quantity,
  key C.TAXABLE_AMT,
  key C.Cgst_amt,
  key C.sgst_amt,
  key C.IGST_AMT,
  key C.cgst_rate,
  key C.sgst_rate,
  key C.IGST_RATE,
  key cast(coalesce(C.AmountInCompanyCodeCurrency,0) + coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.IGST_AMT,0) as abap.dec( 20, 2 )) as hsn_tot_amt, 
  key cast (coalesce(C.cgst_rate,0) + coalesce(C.sgst_rate,0) + coalesce(C.IGST_RATE,0) as abap.dec( 3, 0 )) as taxrate,  
  key cast (coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.IGST_AMT,0) as abap.dec( 23, 3 )) as taxamt,
  key C.INVOICE_AMT,
      C.REPORT,
   '' as   SupplierFullName,
    '' as  IN_HSNOrSACCode 
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


}
group by
    C.CompanyCode,
    C.AccountingDocument,
    C.FiscalYear,
    C.doc_item,
    C.SupplierInvoice,
    C.ProductDescription,
    C.ConsumptionTaxCtrlCode,
    a.ConsumptionTaxCtrlCodeText1,
    C.DocumentDate,
    C.PostingDate,
    C.TaxCode,
    C.Product,
    C.Plant,
    C.FiscalPeriod,
    C.Supplier,
    C.SupplierName,
    C.AccountingDocumentType,
    C.BusinessPlace,
    C.DocumentReferenceID,
    C.IN_GSTPlaceOfSupply,
    C.SUP_GST,
    C.BaseUnit,
    C.TransactionCurrency,
    C.CompanyCodeCurrency,
    C.AmountInCompanyCodeCurrency,
    C.Quantity,
    C.TAXABLE_AMT,
    C.Cgst_amt,
    C.sgst_amt,
    C.IGST_AMT,
    C.cgst_rate,
    C.sgst_rate,
    C.IGST_RATE,
    C.INVOICE_AMT,
    C.REPORT




union select distinct from ZIN_ELIGABLE_RCM_CDS2 as C
  left outer join ZHSN_DES as a on C.ConsumptionTaxCtrlCode = a.ConsumptionTaxCtrlCode 
 

{
  key C.CompanyCode,
  key C.AccountingDocument,
  key C.FiscalYear,
  key C.doc_item,
  key case when C.CompanyCode = '2000' then '2100'
      else max( C.ProfitCenter ) end as ProfitCenter, 
  key case when C.SupplierInvoice <> '' then C.SupplierInvoice else C.AccountingDocument end as SupplierInvoice,
  key C.ProductDescription,
  key C.ConsumptionTaxCtrlCode ,
  key a.ConsumptionTaxCtrlCodeText1,
  key C.DocumentDate,
  key C.PostingDate,
  key C.TaxCode,
  key C.Product,
  key C.Plant,
  key C.FiscalPeriod,
  key C.Supplier,
  key C.SupplierName,
  key C.AccountingDocumentType,
  key C.BusinessPlace,
  key C.DocumentReferenceID,
  key C.IN_GSTPlaceOfSupply,
  key C.SUP_GST,
  key C.BaseUnit,
  key C.TransactionCurrency,
  key C.CompanyCodeCurrency,
  key C.AmountInCompanyCodeCurrency  ,
  key C.Quantity,
  key C.TAXABLE_AMT,
  key C.Cgst_amt,
  key C.sgst_amt,
  key C.igst_amt,
  key C.cgst_rate,
  key C.sgst_rate,
  key C.igst_rate,
  key cast(coalesce(C.AmountInCompanyCodeCurrency,0) + coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.igst_amt,0) as abap.dec( 20, 2 )) as hsn_tot_amt, 
  key cast (coalesce(C.cgst_rate,0) + coalesce(C.sgst_rate,0) + coalesce(C.igst_rate,0) as abap.dec( 3, 0 )) as taxrate,  
  key cast (coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.igst_amt,0) as abap.dec( 23, 3 )) as taxamt, 
  key C.INVOICE_AMT,
      C.REPORT,
      '' as SupplierFullName,
      '' as IN_HSNOrSACCode 
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

}
group by
    C.CompanyCode,
    C.AccountingDocument,
    C.FiscalYear,
    C.doc_item,
    C.SupplierInvoice,
    C.ProductDescription,
    C.ConsumptionTaxCtrlCode,
    a.ConsumptionTaxCtrlCodeText1,
    C.DocumentDate,
    C.PostingDate,
    C.TaxCode,
    C.Product,
    C.Plant,
    C.FiscalPeriod,
    C.Supplier,
    C.SupplierName,
    C.AccountingDocumentType,
    C.BusinessPlace,
    C.DocumentReferenceID,
    C.IN_GSTPlaceOfSupply,
    C.SUP_GST,
    C.BaseUnit,
    C.TransactionCurrency,
    C.CompanyCodeCurrency,
    C.AmountInCompanyCodeCurrency,
    C.Quantity,
    C.TAXABLE_AMT,
    C.Cgst_amt,
    C.sgst_amt,
    C.igst_amt,
    C.cgst_rate,
    C.sgst_rate,
    C.igst_rate,
    C.INVOICE_AMT,
    C.REPORT



union select distinct from ZGSTR2_NIL_RATED_CDS2 as C
  left outer join ZHSN_DES as a on C.ConsumptionTaxCtrlCode = a.ConsumptionTaxCtrlCode 

{
  key C.CompanyCode,
  key C.AccountingDocument,
  key C.FiscalYear,
  key C.doc_item,
  key case when C.CompanyCode = '2000' then '2100'
      else max( C.ProfitCenter ) end as ProfitCenter,
  key case when C.SupplierInvoice <> '' then C.SupplierInvoice else C.AccountingDocument end as SupplierInvoice,
  key C.ProductDescription,
  key C.ConsumptionTaxCtrlCode ,
  key a.ConsumptionTaxCtrlCodeText1,
  key C.DocumentDate,
  key C.PostingDate,
  key C.TaxCode,
  key C.Product,
  key C.Plant,
  key C.FiscalPeriod,
  key C.Supplier,
  key C.SupplierName,
  key C.AccountingDocumentType,
  key C.BusinessPlace,
  key C.DocumentReferenceID,
  key C.IN_GSTPlaceOfSupply,
  key C.SUP_GST,
  key C.BaseUnit,
  key C.TransactionCurrency,
  key C.CompanyCodeCurrency,
  key C.AmountInCompanyCodeCurrency  ,
  key C.Quantity,
  key C.TAXABLE_AMT,
  key C.Cgst_amt,
  key C.sgst_amt,
  key C.igst_amt,
  key C.cgst_rate,
  key C.sgst_rate,
  key C.igst_rate,
  key cast(coalesce(C.AmountInCompanyCodeCurrency,0) + coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.igst_amt,0) as abap.dec( 20, 2 )) as hsn_tot_amt,   
  key cast (coalesce(C.cgst_rate,0) + coalesce(C.sgst_rate,0) + coalesce(C.igst_rate,0) as abap.dec( 3, 0 )) as taxrate,   
  key cast (coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.igst_amt,0) as abap.dec( 23, 3 )) as taxamt,  
  key C.INVOICE_AMT,
      C.REPORT,
      C.SupplierFullName as SupplierFullName,
      C.IN_HSNOrSACCode as IN_HSNOrSACCode

}
group by
    C.CompanyCode,
    C.AccountingDocument,
    C.FiscalYear,
    C.doc_item,
    C.SupplierInvoice,
    C.ProductDescription,
    C.ConsumptionTaxCtrlCode,
    a.ConsumptionTaxCtrlCodeText1,
    C.DocumentDate,
    C.PostingDate,
    C.TaxCode,
    C.Product,
    C.Plant,
    C.FiscalPeriod,
    C.Supplier,
    C.SupplierName,
    C.AccountingDocumentType,
    C.BusinessPlace,
    C.DocumentReferenceID,
    C.IN_GSTPlaceOfSupply,
    C.SUP_GST,
    C.BaseUnit,
    C.TransactionCurrency,
    C.CompanyCodeCurrency,
    C.AmountInCompanyCodeCurrency,
    C.Quantity,
    C.TAXABLE_AMT,
    C.Cgst_amt,
    C.sgst_amt,
    C.igst_amt,
    C.cgst_rate,
    C.sgst_rate,
    C.igst_rate,
    C.INVOICE_AMT,
    C.REPORT,
    C.SupplierFullName,
    C.IN_HSNOrSACCode


//union select distinct from ZGSTR2_HSN_SUMMARY as C
//  left outer join ZHSN_DES as a on C.ConsumptionTaxCtrlCode = a.ConsumptionTaxCtrlCode 
//{
//  key C.CompanyCode,
//  key C.AccountingDocument,
//  key C.FiscalYear, 
//  key C.doc_item, 
//  key C.SupplierInvoice,
//  key C.ProductDescription,
//  key C.ConsumptionTaxCtrlCode ,
//  key a.ConsumptionTaxCtrlCodeText1,
//  key C.DocumentDate,
//  key C.PostingDate,
//  key C.TaxCode,
//  key C.Product,
//  key C.Plant,
//  key C.FiscalPeriod, 
//  key C.Supplier,
//  key C.SupplierName,
//  key C.AccountingDocumentType,
//  key C.BusinessPlace,
//  key C.DocumentReferenceID,
//  key C.IN_GSTPlaceOfSupply,
//  key C.SUP_GST,
//  key C.BaseUnit,
//  key C.TransactionCurrency,
//  key cast( ' ' as abap.cuky(5)) as CompanyCodeCurrency, 
//  key C.AmountInCompanyCodeCurrency  ,
//  key C.Quantity,
//  key C.TAXABLE_AMT,
//  key C.Cgst_amt,
//  key C.sgst_amt,
//  key C.igst_amt,
//  key C.cgst_rate,
//  key C.sgst_rate,
//  key C.igst_rate,
//  key cast (coalesce(C.cgst_rate,0) + coalesce(C.sgst_rate,0) + coalesce(C.igst_rate,0) as abap.dec( 3, 0 )) as taxrate,   
//  key cast (coalesce(C.Cgst_amt,0) + coalesce(C.sgst_amt,0) + coalesce(C.igst_amt,0) as abap.dec( 23, 3 )) as taxamt,  
//  key C.INVOICE_AMT,
//      C.REPORT,
//      C.SupplierFullName as SupplierFullName,
//      C.IN_HSNOrSACCode as IN_HSNOrSACCode
//
//}    
