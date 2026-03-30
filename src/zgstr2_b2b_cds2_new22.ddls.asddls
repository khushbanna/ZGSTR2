@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZGSTR2_B2B_CDS2_NEW'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGSTR2_B2B_CDS2_NEW22 as select from ZGSTR2_B2B_CDS2_NEW as a left outer join ZNT_TAXCODE_DATA as b on
a.AccountingDocument = b.AccountingDocument and a.CompanyCode = b.CompanyCode and a.FiscalYear = b.FiscalYear 
{
    key a.AccountingDocument,
    key a.CompanyCode,
    key a.FiscalYear,
      case when b.AmountInCompanyCodeCurrency <> 0
      then div( cast( b.AmountInCompanyCodeCurrency as abap.dec( 16, 2 )) , a.line_item ) 
      else cast( b.AmountInCompanyCodeCurrency as abap.dec( 16, 2 )) end as nt_amt
}
