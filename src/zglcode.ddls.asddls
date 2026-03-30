@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zglcode'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zglcode as select from I_OperationalAcctgDocItem as a
{
    key a.AccountingDocument ,
//    key a.TaxItemAcctgDocItemRef ,
    key a.CompanyCode ,
        a.FiscalYear ,
       max( a.GLAccount) as GLAccount
} group by
 a.AccountingDocument ,
// a.TaxItemAcctgDocItemRef ,
 a.CompanyCode ,
 a.FiscalYear 
