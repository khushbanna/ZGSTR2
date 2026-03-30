@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IN ELIGABLE CDS 1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZIN_ELIGABLE_CDS1 as select from  I_OperationalAcctgDocItem as A
left outer join I_OperationalAcctgDocItem as EIN on ( EIN.AccountingDocument = A.AccountingDocument and EIN.CompanyCode = A.CompanyCode
                                                      and EIN.FiscalYear = A.FiscalYear and EIN.TaxItemAcctgDocItemRef = A.TaxItemAcctgDocItemRef 
                                                      and ( ( EIN.TransactionTypeDetermination = 'PRD' ) or 
                                                      ( ( EIN.TransactionTypeDetermination = 'EIN' or EIN.TransactionTypeDetermination = 'FRE' or 
                                                             EIN.TransactionTypeDetermination = 'KBS' or EIN.TransactionTypeDetermination = 'ANL' ) and EIN.OriginalTaxBaseAmount = 0.00 ) ) )

  {
   key A.AccountingDocument ,
   key A.CompanyCode ,
   key A.FiscalYear ,
   key A.TaxItemAcctgDocItemRef ,
   key A.TaxCode ,
       A.TransactionTypeDetermination ,
      cast(A.OriginalTaxBaseAmount as abap.dec( 20, 2 ) ) as OriginalTaxBaseAmount ,
      cast(EIN.AmountInCompanyCodeCurrency as abap.dec( 20, 2 ) ) as einamt ,
//      cast(FRE.OriginalTaxBaseAmount as abap.dec( 16, 2 ) ) as FREAMT ,
      sum( cast(A.OriginalTaxBaseAmount   as abap.dec( 20, 2 ) ) 
         + coalesce(cast(EIN.AmountInCompanyCodeCurrency as abap.dec( 20, 2 ) ) , 0 )
//         + coalesce(cast(FRE.OriginalTaxBaseAmount as abap.dec( 16, 2 ) ) , 0 )
          ) as totalamt  
  
  
    
}
 where
     A.TaxItemAcctgDocItemRef <> '000000'
     and A.OriginalTaxBaseAmount is not null
     and A.OriginalTaxBaseAmount <> 0.00
    and A.TaxCode between 'N1' and 'N8'  
  
  group by 
A.AccountingDocument ,  
A.CompanyCode ,         
A.FiscalYear ,          
A.TaxItemAcctgDocItemRef ,
A.TaxCode ,
A.TransactionTypeDetermination ,
A.OriginalTaxBaseAmount ,
//FRE.OriginalTaxBaseAmount ,
EIN.AmountInCompanyCodeCurrency
