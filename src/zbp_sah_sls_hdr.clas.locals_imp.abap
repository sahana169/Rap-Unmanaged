CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Header.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Header.

    METHODS read FOR READ
      IMPORTING keys FOR READ Header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Header.

    METHODS rba_Salesitem FOR READ
      IMPORTING keys_rba FOR READ Header\_Salesitem FULL result_requested RESULT result LINK association_links.

    METHODS cba_Salesitem FOR MODIFY
      IMPORTING entities_cba FOR CREATE Header\_Salesitem.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  DATA : ls_sales_hdr TYPE zsah_vbak.
 LOOP AT entities INTO DATA(ls_entities).
 ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).
 IF ls_sales_hdr-salesdocument IS NOT INITIAL.
 SELECT * FROM zsah_vbak
 WHERE salesdocument = @ls_sales_hdr-salesdocument
 INTO TABLE @DATA(lt_sales_hdr).
 IF sy-subrc NE 0.
 DATA(lo_util) = zcl_sah_sales_util=>get_instance( ).
 lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr
 IMPORTING ex_created = DATA(lv_created) ).
 IF lv_created EQ abap_true.
 APPEND VALUE #( %cid = ls_entities-%cid
 salesdocument = ls_sales_hdr-salesdocument ) TO mapped-header.
 APPEND VALUE #( %cid = ls_entities-%cid
 salesdocument = ls_sales_hdr-salesdocument
 %msg = new_message( id = 'ZSAH_MSG'
 number = 001
v1 = 'Sales Order Created'
severity = if_abap_behv_message=>severity-success ) ) TO
reported-header.
 ENDIF.
 ELSE.
 APPEND VALUE #( %cid = ls_entities-%cid
 salesdocument = ls_sales_hdr-salesdocument ) TO failed-header.
 APPEND VALUE #( %cid = ls_entities-%cid
 salesdocument = ls_sales_hdr-salesdocument
 %msg = new_message( id = 'ZSAH_MSG'
 number = 001
v1 = 'Duplicate Sales Order'
severity = if_abap_behv_message=>severity-error ) ) TO
reported-header.
 ENDIF.
 ENDIF.
 ENDLOOP.
  ENDMETHOD.

  METHOD update.
  DATA : ls_sales_hdr TYPE zsah_vbak.
 LOOP AT entities INTO DATA(ls_entities).
 ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).
 IF ls_sales_hdr-salesdocument IS NOT INITIAL.
 SELECT * FROM zsah_vbak
 WHERE salesdocument = @ls_sales_hdr-salesdocument
 INTO TABLE @DATA(lt_sales_hdr).
 IF sy-subrc EQ 0.
 DATA(lo_util) = zcl_sah_sales_util=>get_instance( ).
 lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr
 IMPORTING ex_created = DATA(lv_created) ).
 IF lv_created EQ abap_true.
 APPEND VALUE #(
 %key = ls_entities-%key
 %msg = new_message(
 id = 'ZSAH_MSG'
 number = 001
 v1 = 'Sales Order Updation Successful'
 severity = if_abap_behv_message=>severity-success )
 ) TO reported-header.
 ENDIF.
 ELSE.
 APPEND VALUE #( %key = ls_entities-%cid_ref
 salesdocument = ls_sales_hdr-salesdocument ) TO failed-header.
 APPEND VALUE #( %key = ls_entities-%cid_ref
 salesdocument = ls_sales_hdr-salesdocument
 %msg = new_message( id = 'ZSAH_MSG'
 number = 001
 v1 = 'Sales Order Not Found !'
severity = if_abap_behv_message=>severity-error ) ) TO
reported-header.
 ENDIF.
 ENDIF.
 ENDLOOP.
  ENDMETHOD.

  METHOD delete.
  TYPES : BEGIN OF ty_sales_hdr,
 salesdocument TYPE zsah_de_sorder,
 END OF ty_sales_hdr,
 BEGIN OF ty_sales_item,
 salesdocument TYPE zsah_de_sorder,
 salesitemnumber TYPE int2,
 END OF ty_sales_item.
 DATA ls_sales_hdr TYPE ty_sales_hdr.
 DATA(lo_util) = zcl_sah_sales_util=>get_instance( ).
 LOOP AT keys INTO DATA(ls_key).
 CLEAR ls_sales_hdr.
 ls_sales_hdr-salesdocument = ls_key-salesdocument.
 lo_util->set_hdr_t_deletion( EXPORTING im_sales_doc = VALUE #( salesdocument
= ls_key-salesdocument ) ).
 lo_util->set_hdr_deletion_flag( EXPORTING im_so_delete = abap_true ).
 APPEND VALUE #( %key = ls_key-%key
 salesdocument = ls_key-salesdocument
 %msg = new_message( id = 'ZSAH_MSG'
 number = 001
 v1 = 'Sales Order Deletion Successful'
 severity = if_abap_behv_message=>severity-success ) ) TO
reported-header.
 ENDLOOP.
  ENDMETHOD.

  METHOD read.
  LOOP AT keys INTO DATA(ls_key).
 SELECT SINGLE * FROM zsah_vbak
 WHERE salesdocument = @ls_key-salesdocument
 INTO @DATA(ls_hdr).
 IF sy-subrc = 0.
 APPEND CORRESPONDING #( ls_hdr ) TO result.
 ENDIF.
 ENDLOOP.
 ENDMETHOD.

 METHOD lock.
  ENDMETHOD.

  METHOD rba_Salesitem.
  LOOP AT keys_rba INTO DATA(ls_key).
 SELECT * FROM zsah_vbap
 WHERE salesdocument = @ls_key-salesdocument
 INTO TABLE @DATA(lt_items).
 LOOP AT lt_items INTO DATA(ls_item).
 APPEND CORRESPONDING #( ls_item ) TO result.
 APPEND VALUE #( source-salesdocument = ls_key-salesdocument
 target-salesdocument = ls_item-salesdocument
 target-salesitemnumber = ls_item-salesitemnumber ) TO
association_links.
 ENDLOOP.
 ENDLOOP.
  ENDMETHOD.

  METHOD cba_Salesitem.
  DATA ls_sales_itm TYPE zsah_vbap.
 LOOP AT entities_cba INTO DATA(ls_entities_cba).
 LOOP AT ls_entities_cba-%target INTO DATA(ls_target).
 ls_sales_itm = CORRESPONDING #( ls_target MAPPING FROM ENTITY ).
 IF ls_sales_itm-salesdocument IS NOT INITIAL AND
 ls_sales_itm-salesitemnumber IS NOT INITIAL.
 SELECT * FROM zsah_vbap
 WHERE salesdocument = @ls_sales_itm-salesdocument
 AND salesitemnumber = @ls_sales_itm-salesitemnumber
 INTO TABLE @DATA(lt_sales_itm).
 IF sy-subrc NE 0.
 DATA(lo_util) = zcl_sah_sales_util=>get_instance( ).
 lo_util->set_itm_value( EXPORTING im_sales_itm = ls_sales_itm
 IMPORTING ex_created = DATA(lv_created) ).
 IF lv_created EQ abap_true.
 APPEND VALUE #( %cid = ls_target-%cid
 salesdocument = ls_sales_itm-salesdocument
 salesitemnumber = ls_sales_itm-salesitemnumber ) TO mapped-item.
 APPEND VALUE #( %cid = ls_target-%cid
 salesdocument = ls_sales_itm-salesdocument
 %msg = new_message( id = 'ZSAH_MSG'
 number = 001
v1 = 'Sales Item Creation Successful'
 severity = if_abap_behv_message=>severity-success ) ) TO
reported-item.
 ENDIF.
 ELSE.
 APPEND VALUE #( %cid = ls_target-%cid
 salesdocument = ls_sales_itm-salesdocument
 salesitemnumber = ls_sales_itm-salesitemnumber ) TO failed-item.
 APPEND VALUE #( %cid = ls_target-%cid
 salesdocument = ls_sales_itm-salesdocument
 salesitemnumber = ls_sales_itm-salesitemnumber
 %msg = new_message( id = 'ZSAH_MSG'
 number = 002
v1 = 'Duplicate Sales Item'
severity = if_abap_behv_message=>severity-error ) ) TO
reported-item.
 ENDIF.
 ENDIF.
 ENDLOOP.
 ENDLOOP.
  ENDMETHOD.

ENDCLASS.
