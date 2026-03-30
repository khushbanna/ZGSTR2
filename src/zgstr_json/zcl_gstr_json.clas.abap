class ZCL_GSTR_JSON definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .

TYPES: BEGIN OF ty_item_det,
         txval  TYPE decfloat34,
         rt     TYPE decfloat34,
         iamt   TYPE decfloat34,
         camt   TYPE decfloat34,
         samt   TYPE decfloat34,
         csamt  TYPE decfloat34,
       END OF ty_item_det.

TYPES: BEGIN OF ty_item,
         num     TYPE i,
         itm_det TYPE ty_item_det,
       END OF ty_item.

TYPES: BEGIN OF ty_invoice,
         inum     TYPE string,
         idt      TYPE string,
         val      TYPE decfloat34,
         pos      TYPE string,
         rchrg    TYPE string,
         inv_typ  TYPE string,
         itms     TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY,
       END OF ty_invoice.

 TYPES: BEGIN OF ty_b2b,
         ctin TYPE string,
         inv  TYPE STANDARD TABLE OF ty_invoice WITH EMPTY KEY,
       END OF ty_b2b.


  TYPES: BEGIN OF ty_b2cl,
         pos TYPE string,
         inv TYPE STANDARD TABLE OF ty_invoice WITH EMPTY KEY,
       END OF ty_b2cl.

  TYPES: BEGIN OF ty_b2cs,
         sply_ty TYPE string,
         rt      TYPE decfloat34,
         typ     TYPE string,
         pos     TYPE string,
         txval   TYPE decfloat34,
         camt    TYPE decfloat34,
         samt    TYPE decfloat34,
         csamt   TYPE decfloat34,
       END OF ty_b2cs.

  TYPES: BEGIN OF ty_nil_inv,
         sply_ty  TYPE string,
         expt_amt TYPE decfloat34,
         nil_amt  TYPE decfloat34,
         ngsup_amt TYPE decfloat34,
       END OF ty_nil_inv.

TYPES: BEGIN OF ty_nil,
         inv TYPE STANDARD TABLE OF ty_nil_inv WITH EMPTY KEY,
       END OF ty_nil.

  TYPES: BEGIN OF ty_exp,
         exp_typ TYPE string,
         inv     TYPE STANDARD TABLE OF ty_invoice WITH EMPTY KEY,
       END OF ty_exp.

       TYPES: BEGIN OF ty_cdn_note,
         nt_num  TYPE string,
         nt_dt   TYPE string,
         ntty    TYPE string,
         val     TYPE decfloat34,
         pos     TYPE string,
         rchrg   TYPE string,
         inv_typ TYPE string,
         itms    TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY,
       END OF ty_cdn_note.

TYPES: BEGIN OF ty_cdnr,
         ctin TYPE string,
         nt   TYPE STANDARD TABLE OF ty_cdn_note WITH EMPTY KEY,
       END OF ty_cdnr.

       TYPES: BEGIN OF ty_cdnur,
         nt_num TYPE string,
         nt_dt  TYPE string,
         ntty   TYPE string,
         val    TYPE decfloat34,
         typ    TYPE string,
         pos    TYPE string,
         itms   TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY,
       END OF ty_cdnur.

  TYPES: BEGIN OF ty_doc_range,
         num       TYPE i,
         from      TYPE string,
         to        TYPE string,
         totnum    TYPE i,
         cancel    TYPE i,
         net_issue TYPE i,
       END OF ty_doc_range.

TYPES: BEGIN OF ty_doc_det,
         doc_num TYPE i,
         doc_typ TYPE string,
         docs    TYPE STANDARD TABLE OF ty_doc_range WITH EMPTY KEY,
       END OF ty_doc_det.

TYPES: BEGIN OF ty_doc_issue,
         doc_det TYPE STANDARD TABLE OF ty_doc_det WITH EMPTY KEY,
       END OF ty_doc_issue.

       TYPES: BEGIN OF ty_hsn_item,
         num       TYPE i,
         hsn_sc    TYPE string,
         user_desc TYPE string,
         desc      TYPE string,
         uqc       TYPE string,
         qty       TYPE decfloat34,
         rt        TYPE decfloat34,
         txval     TYPE decfloat34,
         iamt      TYPE decfloat34,
         samt      TYPE decfloat34,
         camt      TYPE decfloat34,
         csamt     TYPE decfloat34,
       END OF ty_hsn_item.

TYPES: BEGIN OF ty_hsn,
         hsn_b2b TYPE STANDARD TABLE OF ty_hsn_item WITH EMPTY KEY,
         hsn_b2c TYPE STANDARD TABLE OF ty_hsn_item WITH EMPTY KEY,
       END OF ty_hsn.

  TYPES: BEGIN OF ty_gst_payload,
         gstin     TYPE string,
         fp        TYPE string,
         b2b       TYPE STANDARD TABLE OF ty_b2b WITH EMPTY KEY,
         b2cl      TYPE STANDARD TABLE OF ty_b2cl WITH EMPTY KEY,
         b2cs      TYPE STANDARD TABLE OF ty_b2cs WITH EMPTY KEY,
         nil       TYPE ty_nil,
         exp       TYPE STANDARD TABLE OF ty_exp WITH EMPTY KEY,
         cdnr      TYPE STANDARD TABLE OF ty_cdnr WITH EMPTY KEY,
         cdnur     TYPE STANDARD TABLE OF ty_cdnur WITH EMPTY KEY,
         doc_issue TYPE ty_doc_issue,
         hsn       TYPE ty_hsn,
       END OF ty_gst_payload.

protected section.
private section.
ENDCLASS.



CLASS ZCL_GSTR_JSON IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

data(body) = request->get_text(  ) .

dATA(req) = request->get_form_fields(  ) .

data(fdate)  = valUE #( req[ name = 'fromdate' ]-value OPTIONAL ) .
data(todate)  = valUE #( req[ name = 'todate' ]-value OPTIONAL ) .
data(reporttype)  = valUE #( req[ name = 'reporttype' ]-value OPTIONAL ) .
data(BusinessPlace)  = valUE #( req[ name = 'businessplace' ]-value OPTIONAL ) .

data(from_date) = fdate+6(4) && fdate+3(2) && fdate+0(2) .
data(to_date)   = todate+6(4) && todate+3(2) && todate+0(2) .

condENSE reporttype NO-GAPS .

spLIT reporttype at ',' into table data(itreport).

DATA: rep type RANGE OF i_operationalacctgdocitem-DocumentItemText,
      wa_rep LIKE LINE OF rep .
if reporttype is not inITIAL .
loop at itreport into data(wa_report).
DATA(HS) = wa_report.
wa_rep-option = 'EQ' .
wa_rep-sign = 'I' .
wa_rep-low  = HS .
APPEND  wa_rep  TO rep  .
clear : wa_report,wa_rep.
endloop .

endiF.


read tABLE rep into data(hsnb2b) wiTH KEY low = 'HSNB2B'.  " with    customer_gst
read tABLE rep into data(hsnb2c) wiTH KEY low = 'HSNB2C'.  " without customer_gst

seLECT sINGLE * from I_KR_BusinessPlace whERE Branch = @businessplace into @data(business_place) .

DATA gs_payload TYPE ty_gst_payload.

data(dt)  = cl_abap_context_info=>get_system_date( ).

data(zdate)  = fdate+3(2) && fdate+6(4) .

gs_payload-gstin   = business_place-TaxNumber1.
gs_payload-fp      = zdate.

  selECT frOM ZGSTR1_UNION_CDS  as a  fIELDS
                                         a~BillingDocument,
                                         a~BillingDocument as BillingDocument2,
                                         a~BillingDocumentType,
                                         a~PostingDate as  BillingDocumentDate,
                                         sum( a~table_value ) as table_value ,
                                         sum( a~jocg_amt ) as jocg_amt,
                                         sum( a~josg_amt ) as josg_amt,
                                         sum( a~joig_amt ) as joig_amt,
                                         sum( a~invoice_amt ) as invoice_amt,
                                         a~report,
                                         ' ' AS ProductDescription,
                                         a~BaseUnit,
                                         a~customer_gst,
                                         case when a~customer_gst is iniTIAL then 'B2C'
                                         ELSE 'B2B' END AS CUST_GST,
                                         a~taxrate as rate,
                                         a~hsn_code,
                                         left( a~RegionName,2 ) as pos ,
                                         case when left( a~RegionName,2 ) = '08' then 'INTRA'
                                         ELSE 'INTR' END AS POS2,
                                         sum( a~Quantity ) as Quantity
                                         whERE a~PostingDate bETWEEN @from_date and @to_date and BusinessPlace = @BusinessPlace
                                         and report in @rep
                                         gROUP BY a~BillingDocument,
                                         a~BillingDocumentType,
                                         a~PostingDate,
                                         a~report,
                                         a~BaseUnit,
                                         a~customer_gst,
                                         a~taxrate ,
                                         a~RegionName,
                                         a~hsn_code
                                         into taBLE  @DATA(it).

if hsnb2b is not iniTIAL.
  selECT frOM ZGSTR1_UNION_CDS  as a  fIELDS
                                         sum( a~table_value ) as table_value ,
                                         sum( a~jocg_amt ) as jocg_amt,
                                         sum( a~josg_amt ) as josg_amt,
                                         sum( a~joig_amt ) as joig_amt,
                                         'HSNB2B' as report,
                                         A~ProductDescription,
                                         a~BaseUnit,
                                         a~taxrate as rate,
                                         a~hsn_code,
                                         sum( a~Quantity ) as Quantity
                                         whERE a~PostingDate bETWEEN @from_date and @to_date and BusinessPlace = @BusinessPlace
                                         and report in @rep
                                         and customer_gst <> ''
                                         gROUP BY
                                         a~taxrate ,
                                         A~ProductDescription,
                                         a~BaseUnit,
                                         a~hsn_code
                                         APPENDING CORRESPONDING FIELDS OF TABLE @IT.
endiF.


if hsnb2c is not iniTIAL .
  selECT frOM ZGSTR1_UNION_CDS  as a  fIELDS
                                         sum( a~table_value ) as table_value ,
                                         sum( a~jocg_amt ) as jocg_amt,
                                         sum( a~josg_amt ) as josg_amt,
                                         sum( a~joig_amt ) as joig_amt,
                                         'HSNB2C' as report,
                                         A~ProductDescription,
                                         a~BaseUnit,
                                         a~taxrate as rate,
                                         a~hsn_code,
                                         sum( a~Quantity ) as Quantity
                                         whERE a~PostingDate bETWEEN @from_date and @to_date and BusinessPlace = @BusinessPlace
                                         and report in @rep
                                         and customer_gst = ''
                                         gROUP BY
                                         a~taxrate ,
                                         A~ProductDescription,
                                         a~BaseUnit,
                                         a~hsn_code
                                         APPENDING CORRESPONDING FIELDS OF TABLE @IT.
endiF.


DATA: ls_b2b TYPE ty_b2b,
      ls_inv TYPE ty_invoice,
      ls_item TYPE ty_item,
      ls_itm_det TYPE ty_item_det.

LOOP AT it INTO DATA(ls) WHERE report = 'B2B'.
data n type string.
n = n + 1 .
******************* CTIN
  READ TABLE gs_payload-b2b INTO ls_b2b WITH KEY ctin = ls-customer_gst.
  IF sy-subrc <> 0.
    CLEAR ls_b2b.
    ls_b2b-ctin = ls-customer_gst.
  ENDIF.

************* Invoice
  READ TABLE ls_b2b-inv INTO ls_inv WITH KEY inum = ls-BillingDocument.
  IF sy-subrc <> 0.
    CLEAR ls_inv.
    ls_inv-inum    = ls-BillingDocument.
    ls_inv-idt     =  ls-BillingDocumentDate .
    ls_inv-val     = ls-invoice_amt.
    ls_inv-pos     = ls-pos .
    ls_inv-rchrg   = 'N'.
    ls_inv-inv_typ = 'R'.
  ENDIF.

************************************ Item
  CLEAR ls_item.
  CLEAR ls_itm_det.

  ls_item-num = n.
  ls_itm_det-txval = ls-table_value.
  ls_itm_det-rt    = ls-rate.
  ls_itm_det-iamt  = ls-joig_amt.
  ls_itm_det-camt  = ls-jocg_amt.
  ls_itm_det-samt  = ls-josg_amt.
  ls_itm_det-csamt = 0.

  ls_item-itm_det = ls_itm_det.
  APPEND ls_item TO ls_inv-itms.


  DELETE ls_b2b-inv WHERE inum = ls_inv-inum.
  APPEND ls_inv TO ls_b2b-inv.

  DELETE gs_payload-b2b WHERE ctin = ls_b2b-ctin.
  APPEND ls_b2b TO gs_payload-b2b.

ENDLOOP.



DATA ls_b2cl TYPE ty_b2cl.

LOOP AT it INTO ls WHERE report = 'B2CL'.

data n2 type string.
n2 = n2 + 1 .
  READ TABLE gs_payload-b2cl INTO ls_b2cl WITH KEY pos = ls-pos.
  IF sy-subrc <> 0.
    CLEAR ls_b2cl.
    ls_b2cl-pos = ls-pos.
  ENDIF.

  CLEAR ls_inv.
  ls_inv-inum    = ls-BillingDocument.
  ls_inv-idt     = ls-BillingDocumentDate .
  ls_inv-val     = ls-invoice_amt.
  ls_inv-inv_typ = 'R'.

  CLEAR ls_item.
  CLEAR ls_itm_det.

  ls_item-num = n2.
  ls_itm_det-txval = ls-table_value.
  ls_itm_det-rt    = ls-rate.
  ls_itm_det-iamt  = ls-joig_amt.
  ls_itm_det-camt  = ls-jocg_amt.
  ls_itm_det-samt  = ls-josg_amt.

  ls_item-itm_det = ls_itm_det.
  APPEND ls_item TO ls_inv-itms.

  APPEND ls_inv TO ls_b2cl-inv.

  DELETE gs_payload-b2cl WHERE pos = ls_b2cl-pos.
  APPEND ls_b2cl TO gs_payload-b2cl.

ENDLOOP.


data(it2) = it[].
data(it3) = it[].
data(itnil) = it[].
DATA: ls2 LIKE LINE OF it.
DATA: ls3 LIKE LINE OF it.
DATA: lsnil LIKE LINE OF it.

SELECT FROM @it AS a FIELDS
' ' as BillingDocument,
' ' as BillingDocument2,
' ' as BillingDocumentType,
cast( '00000000' as DATS ) as  BillingDocumentDate,
sum( a~table_value ) as table_value ,
sum( a~jocg_amt ) as jocg_amt,
sum( a~josg_amt ) as josg_amt,
sum( a~joig_amt ) as joig_amt,
0 as invoice_amt,
report,
' ' as ProductDescription,
' ' as  BaseUnit,
' ' as customer_gst,
' ' AS CUST_GST,
a~rate as rate,
' ' as hsn_code,
pos ,
' ' AS POS2,
sum( a~Quantity ) as Quantity
where report = 'B2CS'
  GROUP BY
    a~rate,
    a~pos,
    a~report
  INTO TABLE @it2.

DATA ls_b2cs TYPE ty_b2cs.
LOOP AT it2 INTO ls2 WHERE report = 'B2CS'.

  CLEAR ls_b2cs.
  ls_b2cs-sply_ty = 'INTRA'.
  ls_b2cs-rt      = ls2-rate.
  ls_b2cs-typ     = 'OE'.
  ls_b2cs-pos     = ls2-pos.
  ls_b2cs-txval   = ls2-table_value.
  ls_b2cs-camt    = ls2-jocg_amt.
  ls_b2cs-samt    = ls2-josg_amt.
  ls_b2cs-csamt   = 0.

  APPEND ls_b2cs TO gs_payload-b2cs.

ENDLOOP.


DATA: ls_cdnr TYPE ty_cdnr,
      ls_nt   TYPE ty_cdn_note.

LOOP AT it INTO ls WHERE report = 'CDNR'.

data n3 type string.
n3 = n3 + 1 .

  READ TABLE gs_payload-cdnr INTO ls_cdnr WITH KEY ctin = ls-customer_gst.
  IF sy-subrc <> 0.
    CLEAR ls_cdnr.
    ls_cdnr-ctin = ls-customer_gst.
  ENDIF.

  CLEAR ls_nt.
  ls_nt-nt_num  = ls-BillingDocument.
  ls_nt-nt_dt   = ls-BillingDocumentDate .
  ls_nt-ntty    = 'C'.
  ls_nt-val     = ls-invoice_amt.
  ls_nt-pos     = ls-pos.
  ls_nt-rchrg   = 'N'.
  ls_nt-inv_typ = 'R'.

  CLEAR ls_item.
  CLEAR ls_itm_det.

  ls_item-num = n3.
  ls_itm_det-txval = ls-table_value.
  ls_itm_det-rt    = ls-rate.
  ls_itm_det-iamt  = ls-joig_amt.
  ls_itm_det-camt  = ls-jocg_amt.
  ls_itm_det-samt  = ls-josg_amt.

  ls_item-itm_det = ls_itm_det.
  APPEND ls_item TO ls_nt-itms.

  APPEND ls_nt TO ls_cdnr-nt.

  DELETE gs_payload-cdnr WHERE ctin = ls_cdnr-ctin.
  APPEND ls_cdnr TO gs_payload-cdnr.

ENDLOOP.


DATA ls_cdnur TYPE ty_cdnur.

LOOP AT it INTO ls WHERE report = 'CDNUR'.

data n4 type string.
n4 = n4 + 1 .

  CLEAR ls_cdnur.
  ls_cdnur-nt_num = ls-BillingDocument.
  ls_cdnur-nt_dt  = ls-BillingDocumentDate .
  ls_cdnur-ntty   = 'C'.
  ls_cdnur-val    = ls-invoice_amt.
  ls_cdnur-typ    = 'B2CL'.
  ls_cdnur-pos    = ls-pos.

  CLEAR ls_item.
  CLEAR ls_itm_det.

  ls_item-num = n4.
  ls_itm_det-txval = ls-table_value.
  ls_itm_det-rt    = ls-rate.
  ls_itm_det-iamt  = ls-joig_amt.
  ls_itm_det-camt  = ls-jocg_amt.
  ls_itm_det-samt  = ls-josg_amt.

  ls_item-itm_det = ls_itm_det.
  APPEND ls_item TO ls_cdnur-itms.

  APPEND ls_cdnur TO gs_payload-cdnur.

ENDLOOP.


DATA ls_exp TYPE ty_exp.

LOOP AT it INTO ls WHERE report = 'EXP'.

data n5 type string.
n5 = n5 + 1 .

  READ TABLE gs_payload-exp INTO ls_exp WITH KEY exp_typ = 'WOPAY'.
  IF sy-subrc <> 0.
    CLEAR ls_exp.
    ls_exp-exp_typ = 'WOPAY'.
  ENDIF.

  CLEAR ls_inv.
  ls_inv-inum = ls-BillingDocument.
  ls_inv-idt  = ls-BillingDocumentDate .
  ls_inv-val  = ls-invoice_amt.

  CLEAR ls_item.
  CLEAR ls_itm_det.

  ls_item-num = n5.
  ls_itm_det-txval = ls-table_value.
  ls_itm_det-rt    = ls-rate.

  ls_item-itm_det = ls_itm_det.
  APPEND ls_item TO ls_inv-itms.

  APPEND ls_inv TO ls_exp-inv.

  DELETE gs_payload-exp WHERE exp_typ = ls_exp-exp_typ.
  APPEND ls_exp TO gs_payload-exp.

ENDLOOP.

DATA ls_nil TYPE ty_nil_inv.

CLEAR gs_payload-nil.

SELECT FROM @it AS a FIELDS
' ' as BillingDocument,
' ' as BillingDocument2,
' ' as BillingDocumentType,
cast( '00000000' as DATS ) as  BillingDocumentDate,
sum( a~table_value ) as table_value ,
0 as jocg_amt,
0 as josg_amt,
0 as joig_amt,
sum( a~invoice_amt ) as invoice_amt,
' ' as report,
' ' as ProductDescription,
' ' as  BaseUnit,
' ' AS  customer_gst,
a~cust_gst AS CUST_GST,
0   as rate,
' ' as hsn_code,
' ' as pos ,
A~pos2 AS POS2,
0 as Quantity
WHERE A~report = 'NILRAT'
  GROUP BY
     a~pos2,
     a~cust_gst
  INTO TABLE @itnil.


LOOP AT itnil INTO ls .

  CLEAR ls_nil.
*  IF ls-pos = '08' and ls-cust_gst = 'B2C'.
  ls_nil-sply_ty   = | { LS-pos2 }{ LS-cust_gst } | .
*  ELSEIF ls-pos = '08' and ls-cust_gst = 'B2B'.
*  ls_nil-sply_ty   = 'INTRAB2B'.
*  ELSEIF ls-pos <> '08' and ls-cust_gst = 'B2C'.
*  ls_nil-sply_ty   = 'INTRB2C'.
*  ELSEIF ls-pos <> '08' and ls-cust_gst = 'B2B'.
*  ls_nil-sply_ty   = 'INTRB2B'.
*  ENDIF.

  ls_nil-expt_amt  = 0.
  ls_nil-nil_amt   = ls-invoice_amt.
  ls_nil-ngsup_amt = ls-table_value.

  APPEND ls_nil TO gs_payload-nil-inv.

ENDLOOP.



DATA: ls_hsn_item TYPE ty_hsn_item.

CLEAR gs_payload-hsn .

LOOP AT it INTO ls WHERE report = 'HSNB2B'.

data n11 type string.
n11 = n11 + 1 .

  CLEAR ls_hsn_item.

  ls_hsn_item-num       = n11.
  ls_hsn_item-hsn_sc    = ls-hsn_code.
  ls_hsn_item-user_desc = ls-productdescription.
  ls_hsn_item-desc      = ''.
  ls_hsn_item-uqc       = ls-BaseUnit.
  ls_hsn_item-qty       = ls-Quantity.
  ls_hsn_item-rt        = ls-rate.
  ls_hsn_item-txval     = ls-table_value.
  ls_hsn_item-iamt      = ls-joig_amt.
  ls_hsn_item-camt      = ls-jocg_amt.
  ls_hsn_item-samt      = ls-josg_amt.
  ls_hsn_item-csamt     = 0.

  APPEND ls_hsn_item TO gs_payload-hsn-hsn_b2b.

ENDLOOP.



LOOP AT it INTO ls WHERE report = 'HSNB2C'.

data n12 type string.
n12 = n12 + 1 .

  CLEAR ls_hsn_item.

  ls_hsn_item-num       = n12.
  ls_hsn_item-hsn_sc    = ls-hsn_code.
  ls_hsn_item-user_desc = ls-productdescription.
  ls_hsn_item-desc      = ''.
  ls_hsn_item-uqc       = ls-BaseUnit.
  ls_hsn_item-qty       = ls-Quantity.
  ls_hsn_item-rt        = ls-rate.
  ls_hsn_item-txval     = ls-table_value.
  ls_hsn_item-iamt      = ls-joig_amt.
  ls_hsn_item-camt      = ls-jocg_amt.
  ls_hsn_item-samt      = ls-josg_amt.
  ls_hsn_item-csamt     = 0.

  APPEND ls_hsn_item TO gs_payload-hsn-hsn_b2c.

ENDLOOP.

SELECT FROM @it AS a FIELDS
max( a~BillingDocument ) as BillingDocument,
min( a~BillingDocument ) as BillingDocument2,
a~BillingDocumentType,
cast( '00000000' as DATS ) as  BillingDocumentDate,
0 as table_value ,
0 as jocg_amt,
0 as josg_amt,
0 as joig_amt,
0 as invoice_amt,
' ' as report,
' ' as ProductDescription,
' ' as  BaseUnit,
' ' as customer_gst,
' ' AS CUST_GST,
0   as rate,
' ' as hsn_code,
' ' as pos ,
' ' AS POS2,
0 as Quantity
  GROUP BY
     a~BillingDocumentType
  INTO TABLE @it3.

DELETE IT3 WHERE BillingDocumentType = '' .

DATA: ls_doc_issue TYPE ty_doc_issue,
      ls_doc_det   TYPE ty_doc_det,
      ls_doc_range TYPE ty_doc_range.


loop at it3 asSIGNING fIELD-SYMBOL(<fs>).

data : n21 tyPE STRING.
N21 = N21 + 1.
CLEAR: ls_doc_det, ls_doc_range.

selECT sinGLE COUNT( * ) as count from I_BillingDocument whERE BillingDocument
betWEEN @<fs>-BillingDocument2 and @<fs>-billingdocument  into @data(tot).

selECT sinGLE COUNT( * ) as count from I_BillingDocument whERE BillingDocument
betWEEN @<fs>-BillingDocument2 and @<fs>-billingdocument and BillingDocumentIsCancelled <> '' into @data(can).

  ls_doc_range-num       = N21.
  ls_doc_range-from      = <fs>-BillingDocument2.
  ls_doc_range-to        = <fs>-BillingDocument.
  ls_doc_range-totnum    = tot.
  ls_doc_range-cancel    = can.
  ls_doc_range-net_issue = tot - can.

  APPEND ls_doc_range TO ls_doc_det-docs.


  ls_doc_det-doc_num = N21.
  ls_doc_det-doc_typ = <fs>-BillingDocumentType.


  APPEND ls_doc_det TO ls_doc_issue-doc_det.

clear : tot,can .
ENDLOOP.


gs_payload-doc_issue = ls_doc_issue.

DATA lv_json TYPE string.

lv_json = /ui2/cl_json=>serialize(
            data        = gs_payload
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
            compress    = abap_false ).

response->set_text( lv_json ) .


  endmethod.
ENDCLASS.
