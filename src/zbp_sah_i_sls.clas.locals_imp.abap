CLASS lsc_ZSAH_I_SLS DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZSAH_I_SLS IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  DATA(lo_util) = zcl_sah_sales_util=>get_instance( ).
  lo_util->get_hdr_value( IMPORTING ex_sales_hdr = DATA(ls_sales_hdr) ).
 lo_util->get_itm_value( IMPORTING ex_sales_itm = DATA(ls_sales_itm) ).
 lo_util->get_hdr_t_deletion( IMPORTING ex_sales_docs = DATA(lt_sales_header) ).
 lo_util->get_itm_t_deletion( IMPORTING ex_sales_info = DATA(lt_sales_items) ).
 lo_util->get_deletion_flags( IMPORTING ex_so_hdr_del = DATA(lv_so_hdr_del) ).
 " --- HEADER SAVE & TIMESTAMP FIX ---
 IF ls_sales_hdr IS NOT INITIAL.
 " Fill administrative fields before saving to DB
 GET TIME STAMP FIELD ls_sales_hdr-local_last_changed_at.
 GET TIME STAMP FIELD ls_sales_hdr-last_changed_at.
 " Fill creation fields only if it's a new record
 IF ls_sales_hdr-local_created_at IS INITIAL.
 GET TIME STAMP FIELD ls_sales_hdr-local_created_at.
 ls_sales_hdr-local_created_by = sy-uname.
 ENDIF.
 ls_sales_hdr-local_last_changed_by = sy-uname.
 MODIFY zsah_vbak FROM @ls_sales_hdr.
 ENDIF.
 " --- ITEM SAVE & TIMESTAMP FIX ---
 IF ls_sales_itm IS NOT INITIAL.
 GET TIME STAMP FIELD ls_sales_itm-local_last_changed_at.
 IF ls_sales_itm-local_created_at IS INITIAL.
 GET TIME STAMP FIELD ls_sales_itm-local_created_at.
 ls_sales_itm-local_created_by = sy-uname.
 ENDIF.
 MODIFY zsah_vbap FROM @ls_sales_itm.
 ENDIF.
 " --- DELETION LOGIC (Unchanged) ---
 IF lv_so_hdr_del = abap_true.
 LOOP AT lt_sales_header INTO DATA(ls_del_hdr).
 DELETE FROM zsah_vbak WHERE salesdocument = @ls_del_hdr-salesdocument.
 DELETE FROM zsah_vbap WHERE salesdocument = @ls_del_hdr-salesdocument.
 ENDLOOP.
 ELSE.
 LOOP AT lt_sales_header INTO ls_del_hdr.
 DELETE FROM zsah_vbak WHERE salesdocument = @ls_del_hdr-salesdocument.
 ENDLOOP.
 LOOP AT lt_sales_items INTO DATA(ls_del_itm).
 DELETE FROM zsah_vbap WHERE salesdocument = @ls_del_itm-salesdocument
 AND salesitemnumber = @ls_del_itm-salesitemnumber.
 ENDLOOP.
 ENDIF.
  ENDMETHOD.

  METHOD cleanup.
  zcl_sah_sales_util=>get_instance( )->cleanup_buffer( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
