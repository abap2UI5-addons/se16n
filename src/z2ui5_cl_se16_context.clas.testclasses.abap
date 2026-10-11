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

    DATA(lv_where) = z2ui5_cl_se16_context=>filter_get_sql_where( VALUE #(
        ( name    = `F`
          t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` )
                             ( sign = `I` option = `EQ` low = `B` ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `( F = 'A' OR F = 'B' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD excludes_and.

    " a row is kept only if it misses every excluded value
    DATA(lv_where) = z2ui5_cl_se16_context=>filter_get_sql_where( VALUE #(
        ( name    = `F`
          t_range = VALUE #( ( sign = `E` option = `EQ` low = `X` )
                             ( sign = `E` option = `EQ` low = `Y` ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `( F <> 'X' AND F <> 'Y' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD include_and_exclude.

    DATA(lv_where) = z2ui5_cl_se16_context=>filter_get_sql_where( VALUE #(
        ( name    = `F`
          t_range = VALUE #( ( sign = `I` option = `CP` low = `A*` )
                             ( sign = `E` option = `EQ` low = `AB` ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `( ( F LIKE 'A%' ESCAPE '#' ) AND F <> 'AB' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD fields_and.

    DATA(lv_where) = z2ui5_cl_se16_context=>filter_get_sql_where( VALUE #(
        ( name    = `F`
          t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
        ( name    = `G`
          t_range = VALUE #( ( sign = `E` option = `EQ` low = `B` ) ) )
        ( name    = `H` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `( F = 'A' ) AND ( G <> 'B' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD quote_doubled.

    DATA(lv_where) = z2ui5_cl_se16_context=>filter_get_sql_where( VALUE #(
        ( name    = `F`
          t_range = VALUE #( ( sign = `I` option = `EQ` low = `O'Neil` ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `( F = 'O''Neil' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD pattern_escaped.

    " * and + are the wildcards - a typed _ or % only matches itself
    DATA(lv_where) = z2ui5_cl_se16_context=>filter_get_sql_where( VALUE #(
        ( name    = `F`
          t_range = VALUE #( ( sign = `I` option = `CP` low = `Z_T%#*+` ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `( F LIKE 'Z#_T#%##%_' ESCAPE '#' )`
                                        act = lv_where ).

  ENDMETHOD.

  METHOD name_not_a_field.

    " a name that is no plain field name never reaches the WHERE clause
    DATA(lv_where) = z2ui5_cl_se16_context=>filter_get_sql_where( VALUE #(
        ( name    = `F = 'A' OR EXISTS ( SELECT bname FROM usr02 ) OR F`
          t_range = VALUE #( ( sign = `I` option = `EQ` low = `A` ) ) )
        ( name    = `G`
          t_range = VALUE #( ( sign = `I` option = `EQ` low = `B` ) ) ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `( G = 'B' )`
                                        act = lv_where ).

  ENDMETHOD.

ENDCLASS.
