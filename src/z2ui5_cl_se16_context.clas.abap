CLASS z2ui5_cl_se16_context DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.
    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_s_range.
    TYPES ty_t_range TYPE STANDARD TABLE OF ty_s_range WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_filter_multi,
        name            TYPE string,
        t_range         TYPE ty_t_range,
        t_token         TYPE ty_t_token,
        t_token_added   TYPE ty_t_token,
        t_token_removed TYPE ty_t_token,
      END OF ty_s_filter_multi.
    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH EMPTY KEY.

    "! Vendored copy of the abap2UI5 utility methods this app uses, so the
    "! app carries its own context instead of depending on z2ui5_cl_util.
    CLASS-METHODS rtti_create_tab_by_name
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS filter_get_sql_where
      IMPORTING
        val           TYPE ty_t_filter_multi
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    CLASS-METHODS filter_get_sql_cond_by_range
      IMPORTING
        fieldname     TYPE clike
        range         TYPE ty_s_range
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_se16_context IMPLEMENTATION.

  METHOD rtti_create_tab_by_name.

    DATA(struct_desc) = cl_abap_structdescr=>describe_by_name( val ).
    DATA(data_desc) = CAST cl_abap_datadescr( struct_desc ).
    DATA(gr_dyntable_typ) = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.

  METHOD filter_get_sql_where.

    LOOP AT val INTO DATA(ls_filter).

      IF ls_filter-t_range IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_field_where) = ``.
      LOOP AT ls_filter-t_range INTO DATA(ls_range).
        DATA(lv_cond) = filter_get_sql_cond_by_range( fieldname = ls_filter-name
                                                      range     = ls_range ).
        IF lv_cond IS INITIAL.
          CONTINUE.
        ENDIF.
        IF lv_field_where IS INITIAL.
          lv_field_where = lv_cond.
        ELSE.
          lv_field_where = |{ lv_field_where } OR { lv_cond }|.
        ENDIF.
      ENDLOOP.

      IF lv_field_where IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS INITIAL.
        result = |( { lv_field_where } )|.
      ELSE.
        result = |{ result } AND ( { lv_field_where } )|.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD filter_get_sql_cond_by_range.

    DATA(lv_low) = replace( val  = range-low
                            sub  = `'`
                            with = `''`
                            occ  = 0 ).
    DATA(lv_high) = replace( val  = range-high
                             sub  = `'`
                             with = `''`
                             occ  = 0 ).
    DATA(lv_option) = range-option.

    IF range-sign = `E`.
      CASE lv_option.
        WHEN `EQ`. lv_option = `NE`.
        WHEN `NE`. lv_option = `EQ`.
        WHEN `LT`. lv_option = `GE`.
        WHEN `LE`. lv_option = `GT`.
        WHEN `GT`. lv_option = `LE`.
        WHEN `GE`. lv_option = `LT`.
        WHEN `CP`. lv_option = `NP`.
        WHEN `NP`. lv_option = `CP`.
        WHEN `BT`. lv_option = `NB`.
        WHEN `NB`. lv_option = `BT`.
      ENDCASE.
    ENDIF.

    DATA(lv_like) = ``.
    CASE lv_option.
      WHEN `EQ`.
        result = |{ fieldname } = '{ lv_low }'|.
      WHEN `NE`.
        result = |{ fieldname } <> '{ lv_low }'|.
      WHEN `LT`.
        result = |{ fieldname } < '{ lv_low }'|.
      WHEN `LE`.
        result = |{ fieldname } <= '{ lv_low }'|.
      WHEN `GT`.
        result = |{ fieldname } > '{ lv_low }'|.
      WHEN `GE`.
        result = |{ fieldname } >= '{ lv_low }'|.
      WHEN `CP`.
        lv_like = lv_low.
        REPLACE ALL OCCURRENCES OF `*` IN lv_like WITH `%`.
        REPLACE ALL OCCURRENCES OF `+` IN lv_like WITH `_`.
        result = |{ fieldname } LIKE '{ lv_like }'|.
      WHEN `NP`.
        lv_like = lv_low.
        REPLACE ALL OCCURRENCES OF `*` IN lv_like WITH `%`.
        REPLACE ALL OCCURRENCES OF `+` IN lv_like WITH `_`.
        result = |{ fieldname } NOT LIKE '{ lv_like }'|.
      WHEN `BT`.
        result = |{ fieldname } BETWEEN '{ lv_low }' AND '{ lv_high }'|.
      WHEN `NB`.
        result = |{ fieldname } NOT BETWEEN '{ lv_low }' AND '{ lv_high }'|.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
