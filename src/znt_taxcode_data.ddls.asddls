@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZNT_TAXCODE_DATA'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZNT_TAXCODE_DATA as select from I_OperationalAcctgDocItem
{

key  CompanyCode,
key  AccountingDocument,
key  FiscalYear ,
CompanyCodeCurrency,
@Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
sum( AmountInCompanyCodeCurrency ) as AmountInCompanyCodeCurrency

} where TaxCode = 'NT'

group by 
 CompanyCode,
 AccountingDocument, 
 FiscalYear,
 CompanyCodeCurrency
