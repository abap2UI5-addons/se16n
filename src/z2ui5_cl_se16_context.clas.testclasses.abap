CLASS ltcl_filter_where DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS includes_or            FOR TESTING RAISING cx_static_check.
    METHODS excludes_and           FOR TESTING RAISING cx_static_check.
    METHODS include_and_exclude    FOR TESTING RAISING cx_static_check.
    METHODS fields_and             FOR TESTING RAISING cx_static_check.
    METHODS quote_doubled          FOR TESTING RAISING cx_static_check.
    METHODS pattern_escaped        FOR TESTING RAISING cx_static_check.
    METHODS name_not_a_field       FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_filter_where IMPLEMENTATION.

  METHOD includes_or.

    DATA temp1 TYPE z2ui5_cl_se16_context=>ty_t_filter_multi.
    DATA temp2 LIKE LINE OF temp1.
    DATA temp3 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp4 LIKE LINE OF temp3.
    DATA lv_where TYPE string.
    CLEAR temp1.

    temp2-name = `F`.

    CLEAR temp3.

    temp4-sign = `I`.
    temp4-option = `EQ`.
    temp4-low = `A`.
    INSERT temp4 INTO TABLE temp3.
    temp4-sign = `I`.
    temp4-option = `EQ`.
    temp4-low = `B`.
    INSERT temp4 INTO TABLE temp3.
    temp2-t_range = temp3.
    INSERT temp2 INTO TABLE temp1.

    lv_where = z2ui5_cl_se16_context=>filter_get_sql_where( temp1 ).

    cl_abap_unit_assert=>assert_equals( exp = `( F = 'A' OR F = 'B' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD excludes_and.

    " a row is kept only if it misses every excluded value
    DATA temp3 TYPE z2ui5_cl_se16_context=>ty_t_filter_multi.
    DATA temp4 LIKE LINE OF temp3.
    DATA temp5 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp6 LIKE LINE OF temp5.
    DATA lv_where TYPE string.
    CLEAR temp3.

    temp4-name = `F`.

    CLEAR temp5.

    temp6-sign = `E`.
    temp6-option = `EQ`.
    temp6-low = `X`.
    INSERT temp6 INTO TABLE temp5.
    temp6-sign = `E`.
    temp6-option = `EQ`.
    temp6-low = `Y`.
    INSERT temp6 INTO TABLE temp5.
    temp4-t_range = temp5.
    INSERT temp4 INTO TABLE temp3.

    lv_where = z2ui5_cl_se16_context=>filter_get_sql_where( temp3 ).

    cl_abap_unit_assert=>assert_equals( exp = `( F <> 'X' AND F <> 'Y' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD include_and_exclude.

    DATA temp5 TYPE z2ui5_cl_se16_context=>ty_t_filter_multi.
    DATA temp6 LIKE LINE OF temp5.
    DATA temp7 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp8 LIKE LINE OF temp7.
    DATA lv_where TYPE string.
    CLEAR temp5.

    temp6-name = `F`.

    CLEAR temp7.

    temp8-sign = `I`.
    temp8-option = `CP`.
    temp8-low = `A*`.
    INSERT temp8 INTO TABLE temp7.
    temp8-sign = `E`.
    temp8-option = `EQ`.
    temp8-low = `AB`.
    INSERT temp8 INTO TABLE temp7.
    temp6-t_range = temp7.
    INSERT temp6 INTO TABLE temp5.

    lv_where = z2ui5_cl_se16_context=>filter_get_sql_where( temp5 ).

    cl_abap_unit_assert=>assert_equals( exp = `( ( F LIKE 'A%' ESCAPE '#' ) AND F <> 'AB' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD fields_and.

    DATA temp7 TYPE z2ui5_cl_se16_context=>ty_t_filter_multi.
    DATA temp8 LIKE LINE OF temp7.
    DATA temp9 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp10 LIKE LINE OF temp9.
    DATA temp11 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp12 LIKE LINE OF temp11.
    DATA lv_where TYPE string.
    CLEAR temp7.

    CLEAR temp8.
    temp8-name = `F`.

    CLEAR temp9.

    temp10-sign = `I`.
    temp10-option = `EQ`.
    temp10-low = `A`.
    INSERT temp10 INTO TABLE temp9.
    temp8-t_range = temp9.
    INSERT temp8 INTO TABLE temp7.
    CLEAR temp8.
    temp8-name = `G`.

    CLEAR temp11.

    temp12-sign = `E`.
    temp12-option = `EQ`.
    temp12-low = `B`.
    INSERT temp12 INTO TABLE temp11.
    temp8-t_range = temp11.
    INSERT temp8 INTO TABLE temp7.
    CLEAR temp8.
    temp8-name = `H`.
    INSERT temp8 INTO TABLE temp7.

    lv_where = z2ui5_cl_se16_context=>filter_get_sql_where( temp7 ).

    cl_abap_unit_assert=>assert_equals( exp = `( F = 'A' ) AND ( G <> 'B' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD quote_doubled.

    DATA temp9 TYPE z2ui5_cl_se16_context=>ty_t_filter_multi.
    DATA temp10 LIKE LINE OF temp9.
    DATA temp13 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp14 LIKE LINE OF temp13.
    DATA lv_where TYPE string.
    CLEAR temp9.

    temp10-name = `F`.

    CLEAR temp13.

    temp14-sign = `I`.
    temp14-option = `EQ`.
    temp14-low = `O'Neil`.
    INSERT temp14 INTO TABLE temp13.
    temp10-t_range = temp13.
    INSERT temp10 INTO TABLE temp9.

    lv_where = z2ui5_cl_se16_context=>filter_get_sql_where( temp9 ).

    cl_abap_unit_assert=>assert_equals( exp = `( F = 'O''Neil' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD pattern_escaped.

    " * and + are the wildcards - a typed _ or % only matches itself
    DATA temp11 TYPE z2ui5_cl_se16_context=>ty_t_filter_multi.
    DATA temp12 LIKE LINE OF temp11.
    DATA temp15 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp16 LIKE LINE OF temp15.
    DATA lv_where TYPE string.
    CLEAR temp11.

    temp12-name = `F`.

    CLEAR temp15.

    temp16-sign = `I`.
    temp16-option = `CP`.
    temp16-low = `Z_T%#*+`.
    INSERT temp16 INTO TABLE temp15.
    temp12-t_range = temp15.
    INSERT temp12 INTO TABLE temp11.

    lv_where = z2ui5_cl_se16_context=>filter_get_sql_where( temp11 ).

    cl_abap_unit_assert=>assert_equals( exp = `( F LIKE 'Z#_T#%##%_' ESCAPE '#' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD name_not_a_field.

    " a name that is no plain field name never reaches the WHERE clause
    DATA temp13 TYPE z2ui5_cl_se16_context=>ty_t_filter_multi.
    DATA temp14 LIKE LINE OF temp13.
    DATA temp17 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp18 LIKE LINE OF temp17.
    DATA temp19 TYPE z2ui5_cl_se16_context=>ty_t_range.
    DATA temp20 LIKE LINE OF temp19.
    DATA lv_where TYPE string.
    CLEAR temp13.

    temp14-name = `F = 'A' OR EXISTS ( SELECT bname FROM usr02 ) OR F`.

    CLEAR temp17.

    temp18-sign = `I`.
    temp18-option = `EQ`.
    temp18-low = `A`.
    INSERT temp18 INTO TABLE temp17.
    temp14-t_range = temp17.
    INSERT temp14 INTO TABLE temp13.
    temp14-name = `G`.

    CLEAR temp19.

    temp20-sign = `I`.
    temp20-option = `EQ`.
    temp20-low = `B`.
    INSERT temp20 INTO TABLE temp19.
    temp14-t_range = temp19.
    INSERT temp14 INTO TABLE temp13.

    lv_where = z2ui5_cl_se16_context=>filter_get_sql_where( temp13 ).

    cl_abap_unit_assert=>assert_equals( exp = `( G = 'B' )`
                                        act = lv_where ).

  ENDMETHOD.

ENDCLASS.
