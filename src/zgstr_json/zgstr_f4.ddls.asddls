@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZGSTR_F4'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZGSTR_F4 as select from zgstreport_f4 as A
{
  key A.subrep_type
}
where
      A.rep_type =  'GSTR1'
  and A.zdelete  <> 'X'
