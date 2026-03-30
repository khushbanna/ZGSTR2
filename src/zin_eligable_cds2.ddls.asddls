@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'IN ELIGABLE CDS 2'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZIN_ELIGABLE_CDS2 as  select from ZIN_ELIGABLE_CDS1 as A
left outer join ZTAXCODE_SUMMARY as GST on ( GST.taxcode = A.TaxCode  )
{
    key A.AccountingDocument,
    key A.CompanyCode,
    key A.FiscalYear,
    key A.TaxItemAcctgDocItemRef,
    key A.TaxCode,
        A.TransactionTypeDetermination,
        A.OriginalTaxBaseAmount,
        A.einamt,
        A.totalamt as TAXABLE_AMT  ,
        GST.gstrate ,
        
//        A.totalamt as GSTAMOUNT   
       round( cast( ( A.totalamt * GST.gstrate ) / 100  as abap.dec( 20, 3 ) ) , 2 )  as GSTAMOUNT 
        
        
        
        
}
group by
 
A.AccountingDocument,            
A.CompanyCode,                   
A.FiscalYear,                    
A.TaxItemAcctgDocItemRef,        
A.TaxCode,                       
A.TransactionTypeDetermination,  
A.OriginalTaxBaseAmount,         
A.einamt,                        
A.totalamt ,
 GST.gstrate                      

