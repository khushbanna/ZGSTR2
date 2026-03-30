@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZGSTR2_B2B_CDS2'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGSTR2_B2B_CDS2_NEW as select from ZGSTR2_B2B_CDS2
{
   key AccountingDocument,
   key CompanyCode,
   key FiscalYear,
       count( * ) as line_item
}
group by
    AccountingDocument,
    CompanyCode,
    FiscalYear
