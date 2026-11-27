CLASS z2ui5_cl_se16_context DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Environment-abstracted newline. Callers must read it from
    " z2ui5_cl_se16_context instead of referencing cl_abap_char_utilities
    " directly, so the dependency on that SAP standard class lives in exactly
    " one place (this class' class_constructor) and can be ported once for
    " non-ABAP runtimes (e.g. transpiled JS).
    CLASS-DATA cv_char_util_newline        TYPE c LENGTH 1 READ-ONLY.
    CLASS-DATA cv_char_util_horizontal_tab TYPE c LENGTH 1 READ-ONLY.

    " the visibility constant error_get_attributes filters on, so callers do
    " not reference cl_abap_objectdescr directly
    CLASS-DATA cv_objectdescr_public       TYPE c LENGTH 1 READ-ONLY.

    CLASS-METHODS class_constructor.

    TYPES:
      BEGIN OF ty_s_token,
        key      TYPE string,
        text     TYPE string,
        visible  TYPE abap_bool,
        selkz    TYPE abap_bool,
        editable TYPE abap_bool,
      END OF ty_s_token.

    TYPES ty_t_token TYPE STANDARD TABLE OF ty_s_token WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_range,
        sign   TYPE c LENGTH 1,
        option TYPE c LENGTH 2,
        low    TYPE string,
        high   TYPE string,
      END OF ty_s_range.

    TYPES ty_t_range TYPE STANDARD TABLE OF ty_s_range WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_filter_multi,
        name            TYPE string,
        t_range         TYPE ty_t_range,
        t_token         TYPE ty_t_token,
        t_token_added   TYPE ty_t_token,
        t_token_removed TYPE ty_t_token,
      END OF ty_s_filter_multi.

    TYPES ty_t_filter_multi TYPE STANDARD TABLE OF ty_s_filter_multi WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_msg,
        text       TYPE string,
        id         TYPE string,
        no         TYPE string,
        type       TYPE string,
        v1         TYPE string,
        v2         TYPE string,
        v3         TYPE string,
        v4         TYPE string,
        timestampl TYPE timestampl,
        t_meta     TYPE ty_t_name_value,
      END OF ty_s_msg,
      ty_t_msg TYPE STANDARD TABLE OF ty_s_msg WITH DEFAULT KEY.

    TYPES:
      BEGIN OF ty_s_sy,
        datum TYPE d,
        uzeit TYPE t,
        uname TYPE c LENGTH 12,
        sysid TYPE c LENGTH 8,
        saprl TYPE c LENGTH 4,
      END OF ty_s_sy.

    CLASS-METHODS filter_get_sql_where
      IMPORTING
        val           TYPE ty_t_filter_multi
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_create_tab_by_name
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO data.

    CLASS-METHODS uuid_get_c32
      RETURNING
        VALUE(result) TYPE string.

    " THE one place that reads a system field for its VALUE - date, time,
    " user, system id, release. Every other class asks here
    " (sy_get( )-uname), for two reasons: ABAP for Cloud Development reports
    " the old system fields on every statement that names one ("The old
    " variant of SY-DATUM should not be used ..."), so one reader is one
    " finding per field instead of one per use; and the day one of them
    " has to come from another API, it changes here and nowhere else.
    " Not meant: sy-subrc, sy-tabix and sy-index - those are the result of
    " the statement before them and have to be read where it stands
    CLASS-METHODS sy_get
      RETURNING
        VALUE(result) TYPE ty_s_sy.

    CLASS-METHODS c_trim
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_type_kind
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_check_clike
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    " abap_true for values that can be rendered into a text without a
    " conversion dump - the elementary types. Anything structured (struct,
    " table, reference) must be excluded before a generic `|{ val }|`.
    CLASS-METHODS rtti_check_printable
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS rtti_get_classname_by_ref
      IMPORTING
        val           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS rtti_get_t_attri_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_attrdescr_tab.

    " The source-code position an exception was raised at, as
    " `<program> / <include> / line <n>`; empty when the runtime supplies
    " none. Wraps cx_root->get_source_position so the dependency on the SAP
    " standard exception API stays inside this class. This is what identifies
    " the failing method for exceptions that carry no text of their own -
    " a CX_SY_MOVE_CAST_ERROR only says which types did not match, the
    " position says where.
    CLASS-METHODS error_get_source_position
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE string.

    " Every public, non-static, non-constant attribute of an exception that
    " has a printable value - the class-specific payload the text alone does
    " not carry (source/target type of a cast error, the offending value of a
    " conversion error, DB object of an SQL error, ...). The general cx_root
    " attributes (PREVIOUS, TEXTID, IS_RESUMABLE, KERNEL_ERRID) are skipped -
    " the caller renders them itself or they carry no information.
    CLASS-METHODS error_get_attributes
      IMPORTING
        val           TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS rtti_get_t_attri_by_include
      IMPORTING
        !type         TYPE REF TO cl_abap_datadescr
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS expand_components
      IMPORTING
        val           TYPE abap_component_tab
        depth         TYPE i DEFAULT 0
      RETURNING
        VALUE(result) TYPE abap_component_tab.

    CLASS-METHODS rtti_get_t_attri_by_any
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE cl_abap_structdescr=>component_table.

    CLASS-METHODS msg_get_t
      IMPORTING
        !val          TYPE any
        !val2         TYPE any OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_map
      IMPORTING
        name          TYPE clike
        val           TYPE data
        msg           TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

  PROTECTED SECTION.
    CLASS-METHODS msg_get_internal
      IMPORTING
        val           TYPE any
        " the RAP-shape check of a structure is a property of its TYPE - a
        " table decides it once for its rows (msg_get_internal_tab) and hands
        " the answer down, instead of asking for every row
        iv_check_rap  TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_by_oref
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS check_is_rap_struct
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS msg_get_rap
      IMPORTING
        val           TYPE any
        entity_name   TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_t_msg.

    CLASS-METHODS msg_get_rap_row
      IMPORTING
        val         TYPE any
        entity_name TYPE string OPTIONAL
      EXPORTING
        messages    TYPE ty_t_msg
        is_row      TYPE abap_bool.

    CLASS-METHODS get_comp_str
      IMPORTING
        val           TYPE any
        comp          TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS scan_flag_prefix
      IMPORTING
        val           TYPE any
        prefix        TYPE clike
      RETURNING
        VALUE(result) TYPE string_table.

    CLASS-METHODS msg_get_rap_element
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_state_area
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_action
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_pid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_cid
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_tky
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_flatten
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_meta
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE ty_t_name_value.

    CLASS-METHODS msg_get_rap_fail_text
      IMPORTING
        cause         TYPE i
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS msg_get_rap_cause_value
      IMPORTING
        name          TYPE clike
      RETURNING
        VALUE(result) TYPE i.

  PRIVATE SECTION.

    CLASS-METHODS filter_get_sql_cond_by_range
      IMPORTING
        fieldname     TYPE clike
        range         TYPE ty_s_range
      RETURNING
        VALUE(result) TYPE string.

    " The option that selects the complement: EQ <-> NE, LT <-> GE, LE <-> GT,
    " CP <-> NP, BT <-> NB. Any other option comes back as it is.
    CLASS-METHODS filter_option_negate
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    " whether a type kind is a number: i, int1, int2, int8, p, f,
    " decfloat16, decfloat34 - the one list the number checks share. int8
    " by its value `8`, a constant lower releases do not have
    CLASS-METHODS rtti_check_typekind_number
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE abap_bool.

    " Guards uuid_get_c32 against re-entering itself through the exception it
    " raises (z2ui5_cx_se16_error reads a uuid for its full report).
    CLASS-DATA gv_uuid_failed TYPE abap_bool.

    TYPES:
      BEGIN OF ty_s_attri_cache,
        absolute_name TYPE string,
        o_struct      TYPE REF TO cl_abap_structdescr,
        t_attri       TYPE cl_abap_structdescr=>component_table,
      END OF ty_s_attri_cache.

    CLASS-DATA mt_attri_cache TYPE HASHED TABLE OF ty_s_attri_cache WITH UNIQUE KEY absolute_name.

    CLASS-METHODS check_msg_container
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! the public attributes of an object that carry a message part (TEXT,
    "! TYPE, MSGV1 ...), mapped over is_msg - see msg_map
    CLASS-METHODS msg_get_by_oref_attri
      IMPORTING
        io_obj        TYPE REF TO object
        is_msg        TYPE ty_s_msg
      RETURNING
        VALUE(result) TYPE ty_s_msg.

    "! the rows of a table, the RAP shape decided on the first structured row
    CLASS-METHODS msg_get_internal_tab
      IMPORTING
        it_tab        TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE ty_t_msg.
ENDCLASS.


CLASS z2ui5_cl_se16_context IMPLEMENTATION.

  METHOD class_constructor.

    cv_char_util_newline        = cl_abap_char_utilities=>newline.
    cv_char_util_horizontal_tab = cl_abap_char_utilities=>horizontal_tab.

    cv_objectdescr_public            = cl_abap_objectdescr=>public.

  ENDMETHOD.

  METHOD filter_get_sql_where.

    DATA ls_filter LIKE LINE OF val.
      DATA lv_include TYPE string.
      DATA lv_exclude TYPE string.
      DATA ls_range LIKE LINE OF ls_filter-t_range.
        DATA lv_cond TYPE string.
          DATA temp15 TYPE string.
          DATA temp16 TYPE string.
      DATA temp17 TYPE string.
      DATA lv_field_where LIKE temp17.
    LOOP AT val INTO ls_filter.

      IF ls_filter-t_range IS INITIAL.
        CONTINUE.
      ENDIF.

      " the select-options are bound to the view, so the name comes back from
      " the browser - only a plain field name goes into the WHERE clause, never
      " a condition or a subquery on another table
      " a character set instead of a regex: PCRE is not on 7.02, POSIX not
      " on ABAP Cloud
      IF ls_filter-name IS INITIAL
          OR ls_filter-name CN `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/`.
        CONTINUE.
      ENDIF.

      " select-option semantics: a row matches one of the including ranges
      " and none of the excluding ones. An excluding range arrives here
      " already negated (filter_get_sql_cond_by_range), so the includes are
      " joined with OR and the excludes with AND - OR-ing them too let
      " every row through that missed a single exclude

      lv_include = ``.

      lv_exclude = ``.

      LOOP AT ls_filter-t_range INTO ls_range.

        lv_cond = filter_get_sql_cond_by_range( fieldname = ls_filter-name
                                                      range     = ls_range ).
        IF lv_cond IS INITIAL.
          CONTINUE.
        ENDIF.
        IF ls_range-sign = `E`.

          IF lv_exclude IS INITIAL.
            temp15 = lv_cond.
          ELSE.
            temp15 = |{ lv_exclude } AND { lv_cond }|.
          ENDIF.
          lv_exclude = temp15.
        ELSE.

          IF lv_include IS INITIAL.
            temp16 = lv_cond.
          ELSE.
            temp16 = |{ lv_include } OR { lv_cond }|.
          ENDIF.
          lv_include = temp16.
        ENDIF.
      ENDLOOP.


      IF lv_include IS NOT INITIAL AND lv_exclude IS NOT INITIAL.
        temp17 = |( { lv_include } ) AND { lv_exclude }|.
      ELSEIF lv_include IS NOT INITIAL.
        temp17 = lv_include.
      ELSE.
        temp17 = lv_exclude.
      ENDIF.

      lv_field_where = temp17.

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

    DATA lv_low TYPE string.
    DATA lv_high TYPE string.
    DATA lv_option LIKE range-option.
    DATA lv_like TYPE string.
    DATA lv_pos TYPE i.
    DATA lv_len TYPE i.
      DATA lv_char TYPE string.
    lv_low = replace( val  = range-low
                            sub  = `'`
                            with = `''`
                            occ  = 0 ).

    lv_high = replace( val  = range-high
                             sub  = `'`
                             with = `''`
                             occ  = 0 ).

    lv_option = range-option.

    IF range-sign = `E`.
      lv_option = filter_option_negate( lv_option ).
    ENDIF.

    " CP: * and + are the wildcards and # makes the next character a plain
    " one (`#*` is a star), as in an IN range. A _ or % the user typed is a
    " plain character, so it is escaped for LIKE

    lv_like = ``.

    lv_pos = 0.

    lv_len = strlen( lv_low ).
    WHILE lv_pos < lv_len.

      lv_char = substring( val = lv_low
                                 off = lv_pos
                                 len = 1 ).
      IF lv_char = `#` AND lv_pos + 1 < lv_len.
        lv_pos = lv_pos + 1.
        lv_char = substring( val = lv_low
                             off = lv_pos
                             len = 1 ).
        IF lv_char CA `#%_`.
          lv_like = lv_like && `#` && lv_char.
        ELSE.
          lv_like = lv_like && lv_char.
        ENDIF.
      ELSEIF lv_char = `*`.
        lv_like = lv_like && `%`.
      ELSEIF lv_char = `+`.
        lv_like = lv_like && `_`.
      ELSEIF lv_char CA `#%_`.
        lv_like = lv_like && `#` && lv_char.
      ELSE.
        lv_like = lv_like && lv_char.
      ENDIF.
      lv_pos = lv_pos + 1.
    ENDWHILE.

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
        result = |{ fieldname } LIKE '{ lv_like }' ESCAPE '#'|.
      WHEN `NP`.
        result = |{ fieldname } NOT LIKE '{ lv_like }' ESCAPE '#'|.
      WHEN `BT`.
        result = |{ fieldname } BETWEEN '{ lv_low }' AND '{ lv_high }'|.
      WHEN `NB`.
        result = |{ fieldname } NOT BETWEEN '{ lv_low }' AND '{ lv_high }'|.
    ENDCASE.

  ENDMETHOD.

  METHOD filter_option_negate.

    result = val.
    CASE result.
      WHEN `EQ`. result = `NE`.
      WHEN `NE`. result = `EQ`.
      WHEN `LT`. result = `GE`.
      WHEN `LE`. result = `GT`.
      WHEN `GT`. result = `LE`.
      WHEN `GE`. result = `LT`.
      WHEN `CP`. result = `NP`.
      WHEN `NP`. result = `CP`.
      WHEN `BT`. result = `NB`.
      WHEN `NB`. result = `BT`.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_check_typekind_number.

    CASE val.
      WHEN cl_abap_typedescr=>typekind_int
          OR cl_abap_typedescr=>typekind_int1
          OR cl_abap_typedescr=>typekind_int2
          OR cl_abap_typedescr=>typekind_packed
          OR cl_abap_typedescr=>typekind_float
          OR cl_abap_typedescr=>typekind_decfloat16
          OR cl_abap_typedescr=>typekind_decfloat34
          OR `8`.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_create_tab_by_name.

    " type_not_found is a classic exception: called functionally, an unknown
    " name ends in a short dump no CATCH stops - so it is handled here and
    " the caller gets an unbound reference instead
    DATA lo_type TYPE REF TO cl_abap_typedescr.
    DATA temp18 TYPE REF TO cl_abap_datadescr.
    DATA data_desc LIKE temp18.
    DATA gr_dyntable_typ TYPE REF TO cl_abap_tabledescr.
    cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = val
                                         RECEIVING  p_descr_ref    = lo_type
                                         EXCEPTIONS type_not_found = 1
                                                    OTHERS         = 2 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    " a class or an interface of that name is no data type - the kind, not
    " IS INSTANCE OF, which the 7.02 downport cannot express
    IF lo_type->kind = cl_abap_typedescr=>kind_class OR lo_type->kind = cl_abap_typedescr=>kind_intf.
      RETURN.
    ENDIF.

    temp18 ?= lo_type.

    data_desc = temp18.

    gr_dyntable_typ = cl_abap_tabledescr=>create( data_desc ).
    CREATE DATA result TYPE HANDLE gr_dyntable_typ.

  ENDMETHOD.

  METHOD uuid_get_c32.
    DATA lv_uuid      TYPE c LENGTH 32.
    DATA lv_classname TYPE string.
    DATA lv_fm        TYPE string.
        DATA lx_uuid TYPE REF TO cx_root.

    TRY.

        TRY.

            lv_classname = `CL_SYSTEM_UUID`.
            CALL METHOD (lv_classname)=>if_system_uuid_static~create_uuid_c32
              RECEIVING
                uuid = lv_uuid.

          CATCH cx_root.

            lv_fm = `GUID_CREATE`.
            " error_message: a message the module sends would otherwise end
            " the request, which no CATCH reaches
            CALL FUNCTION lv_fm
              IMPORTING
                ev_guid_32    = lv_uuid
              EXCEPTIONS
                error_message = 1
                OTHERS        = 2.
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE z2ui5_cx_se16_error
                EXPORTING
                  val = `GUID_CREATE_FAILED`.
            ENDIF.

        ENDTRY.

        result = lv_uuid.


      CATCH cx_root INTO lx_uuid.
        " both UUID mechanisms failed - raise the framework exception so the
        " consumer's single top-level catch can turn it into a handled error.
        " ASSERT would raise the uncatchable ASSERTION_FAILED and bypass that
        " catch (short dump instead of a handled error response).
        " z2ui5_cx_se16_error reads a uuid when it renders its full report,
        " so a renderer running while the raise below is on its way would
        " re-enter this method. gv_uuid_failed makes that nested call return an
        " empty UUID instead of raising again.
        IF gv_uuid_failed = abap_true.
          RETURN.
        ENDIF.
        gv_uuid_failed = abap_true.
        TRY.
            RAISE EXCEPTION TYPE z2ui5_cx_se16_error
              EXPORTING
                val = lx_uuid.
          CLEANUP.
            CLEAR gv_uuid_failed.
        ENDTRY.
    ENDTRY.
  ENDMETHOD.

  METHOD sy_get.

    result-datum = sy-datum.
    result-uzeit = sy-uzeit.
    result-uname = sy-uname.
    result-sysid = sy-sysid.
    result-saprl = sy-saprl.

  ENDMETHOD.

  METHOD c_trim.
      DATA lv_before LIKE result.

    result = val.
    " spaces and tabs alternate at either end (`\t \tx`) - one pass of each
    " leaves the inner layer standing, so strip until nothing changes. No
    " fixed number of passes: ten left the eleventh layer of a padded value
    " standing. Every pass that changes something shortens the string, so
    " the loop ends
    DO.

      lv_before = result.
      result = shift_left( shift_right( result ) ).
      result = shift_right( val = result
                            sub = cv_char_util_horizontal_tab ).
      result = shift_left( val = result
                           sub = cv_char_util_horizontal_tab ).
      IF result = lv_before.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.

  METHOD rtti_get_type_kind.

    result = cl_abap_datadescr=>get_data_type_kind( val ).

  ENDMETHOD.

  METHOD rtti_check_clike.

    CASE rtti_get_type_kind( val ).
      " typekind_clike/_csequence are generic kinds of formal parameters and
      " can never be returned for a concrete data object - list the concrete
      " character-like kinds (c, string, n, d, t) instead
      WHEN cl_abap_datadescr=>typekind_char OR
          cl_abap_datadescr=>typekind_string OR
          cl_abap_datadescr=>typekind_num OR
          cl_abap_datadescr=>typekind_date OR
          cl_abap_datadescr=>typekind_time.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.

  METHOD rtti_check_printable.
    DATA lv_type_kind TYPE string.
    DATA temp1 TYPE xsdboolean.

    IF rtti_check_clike( val ) = abap_true.
      result = abap_true.
      RETURN.
    ENDIF.


    lv_type_kind = rtti_get_type_kind( val ).

    temp1 = boolc( lv_type_kind = cl_abap_datadescr=>typekind_hex OR rtti_check_typekind_number( lv_type_kind ) = abap_true ).
    result = temp1.

  ENDMETHOD.

  METHOD rtti_get_classname_by_ref.

    " an unbound reference has no class - answer with an empty name instead
    " of letting the RTTI call fail. Callers ask this while rendering (error
    " context, response header), where a half-built object graph is normal
    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    result = substring_after( val = cl_abap_classdescr=>get_class_name( val )
                              sub = `\CLASS=` ).

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_oref.

    DATA lo_descr TYPE REF TO cl_abap_typedescr.
    DATA temp19 TYPE REF TO cl_abap_classdescr.

    " describe_by_object_ref raises the classic exception REFERENCE_IS_INITIAL
    " for an initial reference - called functionally that is a runtime error no
    " CATCH reaches
    cl_abap_objectdescr=>describe_by_object_ref( EXPORTING  p_object_ref         = val
                                                 RECEIVING p_descr_ref           = lo_descr
                                                 EXCEPTIONS reference_is_initial = 1
                                                            OTHERS               = 2 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z2ui5_cx_se16_error
        EXPORTING
          val = `RTTI_REFERENCE_IS_INITIAL`.
    ENDIF.

    temp19 ?= lo_descr.
    result = temp19->attributes.

  ENDMETHOD.

  METHOD error_get_source_position.

    " typed like the EXPORTING parameters of get_source_position (syrepid is
    " CHAR40) - they are passed by reference, so a string would not be
    " type-compatible here
    DATA lv_program TYPE c LENGTH 40.
    DATA lv_include TYPE c LENGTH 40.
    DATA lv_line    TYPE i.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    " open-abap - the transpiled JS runtime behind the node tests - implements
    " get_source_position by reading a field that only the RAISE statement
    " writes, and fails with a JS TypeError for every other exception (a
    " runtime-thrown one, or one built with NEW). That error is not an ABAP
    " exception, so the TRY below cannot intercept it and the caller would go
    " down instead of reporting the error it was diagnosing. sy-saprl is
    " `OPEN` on that runtime and a real release everywhere else.
    IF sy_get( )-saprl = `OPEN`.
      RETURN.
    ENDIF.

    TRY.
        val->get_source_position( IMPORTING program_name = lv_program
                                            include_name = lv_include
                                            source_line  = lv_line ).
      CATCH cx_root ##NO_HANDLER.
        " never let the diagnostic be the reason a caller fails
    ENDTRY.

    IF lv_program IS INITIAL AND lv_line IS INITIAL.
      RETURN.
    ENDIF.

    result = c_trim( lv_program ).
    " the include is the interesting part for a class (...CM001 = the method
    " that raised); repeating it when it equals the program adds nothing
    IF lv_include IS NOT INITIAL AND lv_include <> lv_program.
      result = |{ result } / { c_trim( lv_include ) }|.
    ENDIF.
    IF lv_line IS NOT INITIAL.
      result = |{ result } / line { lv_line }|.
    ENDIF.

  ENDMETHOD.

  METHOD error_get_attributes.

    " declared, NOT `DATA(lv_name) = CONV string( lr_attri->name )`: a CONV
    " that is the whole right-hand side of an assignment is "Redundant
    " conversion for type STRING" in SLIN - the assignment converts by
    " itself. The variable stays a string on purpose: the RTTI name is a
    " CHAR field whose trailing blanks have no business in the rendered name
    DATA lv_name TYPE string.

    FIELD-SYMBOLS <comp> TYPE any.
        DATA lt_attri TYPE abap_attrdescr_tab.
    DATA temp20 LIKE LINE OF lt_attri.
    DATA lr_attri LIKE REF TO temp20.
      DATA temp21 TYPE z2ui5_cl_se16_context=>ty_s_name_value.

    IF val IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.

        lt_attri = rtti_get_t_attri_by_oref( val ).
      CATCH cx_root.
        RETURN.
    ENDTRY.



    LOOP AT lt_attri REFERENCE INTO lr_attri "#EC CI_SORTSEQ
         WHERE visibility  = cv_objectdescr_public
           AND is_constant = abap_false
           AND is_class    = abap_false.

      CASE lr_attri->name.
          " rendered by the caller (PREVIOUS as the next chain entry,
          " KERNEL_ERRID as its own line) or without information value
        WHEN `PREVIOUS` OR `TEXTID` OR `IS_RESUMABLE` OR `KERNEL_ERRID`.
          CONTINUE.
      ENDCASE.

      lv_name = lr_attri->name.
      " UNASSIGN + IS ASSIGNED, not sy-subrc - see unassign_data for the
      " release behaviour (#1937). INSIDE A LOOP the stale-subrc reading is
      " not just "skipped one attribute": a failed ASSIGN leaves the symbol
      " on the PREVIOUS iteration's attribute, so a stale 0 renders that
      " value under this attribute's name - a wrong value in the error dump,
      " which is the one place a reader has nothing else to go by
      UNASSIGN <comp>.
      ASSIGN val->(lv_name) TO <comp>.
      IF <comp> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF rtti_check_printable( <comp> ) = abap_false OR <comp> IS INITIAL.
        CONTINUE.
      ENDIF.


      CLEAR temp21.
      temp21-n = lv_name.
      temp21-v = c_trim( |{ <comp> }| ).
      INSERT temp21 INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_include.

    " `type` IS the include's descriptor - the component the caller took it
    " from (as_include = abap_true) carries the structure descriptor, and
    " RTTI descriptors are singletons. It used to be re-described by name,
    " an RTTI lookup per include on the binding path that could only hand
    " back the object already in hand - or fail for a local include type
    " whose absolute name does not resolve, where the direct cast cannot
    DATA sdescr TYPE REF TO cl_abap_structdescr.
        DATA lx_cast TYPE REF TO cx_sy_move_cast_error.
    TRY.
        sdescr ?= type.

      CATCH cx_sy_move_cast_error INTO lx_cast.
        RAISE EXCEPTION TYPE z2ui5_cx_se16_error
          EXPORTING
            val      = |Include type '{ type->absolute_name }' is not a structure|
            previous = lx_cast.
    ENDTRY.
    result = expand_components( val   = sdescr->get_components( )
                                depth = depth ).

  ENDMETHOD.

  METHOD expand_components.
    DATA temp22 LIKE LINE OF val.
    DATA lr_comp LIKE REF TO temp22.
        DATA lt_include TYPE abap_component_tab.
          DATA temp23 LIKE LINE OF lt_include.
          DATA lr_include LIKE REF TO temp23.

    " see the declaration: bounded so a cyclic include chain surfaces as a
    " readable error instead of a stack-overflow dump. 16 nested include
    " levels is far beyond any real DDIC structure
    IF depth > 16.
      RAISE EXCEPTION TYPE z2ui5_cx_se16_error
        EXPORTING
          val = `RTTI_INCLUDE_RECURSION - include expansion exceeded 16 levels (cyclic include?)`.
    ENDIF.



    LOOP AT val REFERENCE INTO lr_comp.
      IF lr_comp->as_include = abap_true.
        " INCLUDE ... RENAMING WITH SUFFIX: the structure's components are
        " named <component><suffix>, and every nested level adds its own -
        " the bare include names do not exist on the structure, so a
        " binding path or ASSIGN COMPONENT built from them fails

        lt_include = rtti_get_t_attri_by_include( type  = lr_comp->type
                                                        depth = depth + 1 ).
        IF lr_comp->suffix IS NOT INITIAL.


          LOOP AT lt_include REFERENCE INTO lr_include.
            lr_include->name = lr_include->name && lr_comp->suffix.
          ENDLOOP.
        ENDIF.
        INSERT LINES OF lt_include INTO TABLE result.
      ELSE.
        INSERT lr_comp->* INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD rtti_get_t_attri_by_any.

    DATA lo_struct        TYPE REF TO cl_abap_structdescr.
    DATA lo_type          TYPE REF TO cl_abap_typedescr.
    " declared, not CONV string( ) - see error_get_attributes
    DATA lv_absolute_name TYPE string.
        DATA temp24 TYPE REF TO cl_abap_structdescr.
        DATA temp25 TYPE REF TO cl_abap_structdescr.
        DATA temp21 TYPE REF TO cl_abap_tabledescr.
    FIELD-SYMBOLS <ls_attri_cache> TYPE z2ui5_cl_se16_context=>ty_s_attri_cache.
      DATA temp26 TYPE z2ui5_cl_se16_context=>ty_s_attri_cache.

    " describe_by_data never fails for a data object, and the reference case
    " is the one branch. The fallback chain that used to sit here - a second
    " describe_by_data_ref, then describe_by_name( val ) - could rescue no
    " input: the first only re-raised what the branch above had raised, and
    " a data object is no type name
    lo_type = cl_abap_typedescr=>describe_by_data( val ).
    IF lo_type->kind = cl_abap_typedescr=>kind_ref.
      " REFERENCE_IS_INITIAL - see rtti_get_t_attri_by_oref
      cl_abap_typedescr=>describe_by_data_ref( EXPORTING  p_data_ref           = val
                                               RECEIVING p_descr_ref           = lo_type
                                               EXCEPTIONS reference_is_initial = 1
                                                          OTHERS               = 2 ).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE z2ui5_cx_se16_error
          EXPORTING
            val = `RTTI_REFERENCE_IS_INITIAL`.
      ENDIF.
    ENDIF.

    CASE lo_type->kind.
      WHEN cl_abap_typedescr=>kind_struct.

        temp24 ?= lo_type.
        lo_struct = temp24.
      WHEN cl_abap_typedescr=>kind_table.


        temp21 ?= lo_type.
        temp25 ?= temp21->get_table_line_type( ).
        lo_struct = temp25.
      WHEN OTHERS.
        lo_struct ?= lo_type.
    ENDCASE.

    " descriptor instances are singletons per type, so the identity check
    " guards against absolute names reused by other (local/anonymous) types
    lv_absolute_name = lo_struct->absolute_name.

    READ TABLE mt_attri_cache WITH KEY absolute_name = lv_absolute_name ASSIGNING <ls_attri_cache>.
    IF <ls_attri_cache> IS ASSIGNED AND <ls_attri_cache>-o_struct = lo_struct.
      result = <ls_attri_cache>-t_attri.
      RETURN.
    ENDIF.

    result = expand_components( lo_struct->get_components( ) ).

    IF <ls_attri_cache> IS ASSIGNED.
      <ls_attri_cache>-o_struct = lo_struct.
      <ls_attri_cache>-t_attri  = result.
    ELSE.

      CLEAR temp26.
      temp26-absolute_name = lv_absolute_name.
      temp26-o_struct = lo_struct.
      temp26-t_attri = result.
      INSERT temp26 INTO TABLE mt_attri_cache.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_t.

    result = msg_get_internal( val ).
    IF result IS INITIAL AND val2 IS NOT INITIAL.
      result = msg_get_internal( val2 ).
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_internal.
        FIELD-SYMBOLS <tab> TYPE ANY TABLE.
        DATA lt_attri TYPE abap_component_tab.
        DATA temp27 TYPE ty_s_msg.
        DATA ls_result LIKE temp27.
        DATA temp28 LIKE LINE OF lt_attri.
        DATA ls_attri LIKE REF TO temp28.
          FIELD-SYMBOLS <comp> TYPE any.
          DATA temp29 TYPE z2ui5_cl_se16_context=>ty_s_msg.

    CASE rtti_get_type_kind( val ).

      WHEN cl_abap_datadescr=>typekind_table.

        " guarded like data_render_tab and data_get_headline - handing an
        " UNASSIGNED symbol to the method below is a GETWA_NOT_ASSIGNED
        " dump. No messages then, which is what "nothing in here is a
        " message" means to the caller: it falls back to the data renderer
        ASSIGN val TO <tab>.
        IF <tab> IS NOT ASSIGNED.
          RETURN.
        ENDIF.
        result = msg_get_internal_tab( <tab> ).

      WHEN cl_abap_datadescr=>typekind_struct1 OR cl_abap_datadescr=>typekind_struct2.

        IF val IS INITIAL.
          RETURN.
        ENDIF.

        IF iv_check_rap = abap_true AND check_is_rap_struct( val ) = abap_true.
          result = msg_get_rap( val ).
          RETURN.
        ENDIF.


        lt_attri = rtti_get_t_attri_by_any( val ).


        CLEAR temp27.

        ls_result = temp27.


        LOOP AT lt_attri REFERENCE INTO ls_attri.

          ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          " only an ITEM that can HOLD messages is the envelope's payload -
          " a table, a structure or an object (the BALI item). A plain
          " ITEM field (a position number) became the whole message and
          " dropped the structure's other fields
          IF ls_attri->name = `ITEM` AND check_msg_container( <comp> ) = abap_true.
            result = msg_get_internal( <comp> ).
            RETURN.
          ENDIF.
          ls_result = msg_map( name = ls_attri->name
                               val  = <comp>
                               msg  = ls_result ).

        ENDLOOP.
        " a T100 message is a class AND a number. A component called ID
        " alone is the key column of any business row - built into a
        " message, it gave `I:0001:` (a missing class still answers a text)
        " and the data never reached the data renderer it was meant for
        IF ls_result-text IS INITIAL AND ls_result-id IS NOT INITIAL AND ls_result-no IS NOT INITIAL.
          ls_result-id = to_upper( ls_result-id ).
          MESSAGE ID ls_result-id TYPE `I` NUMBER ls_result-no
                  WITH ls_result-v1 ls_result-v2 ls_result-v3 ls_result-v4
                  INTO ls_result-text.
        ENDIF.
        INSERT ls_result INTO TABLE result.

      WHEN cl_abap_datadescr=>typekind_oref.
        " an unbound reference carries no message - guarded like the struct
        " and table branches guard theirs. Unguarded it fell through the
        " three handlers of msg_get_by_oref into a describe on the null
        " reference, and message_box_display( unbound ) ended in a 500
        " instead of the documented silence
        IF val IS NOT INITIAL.
          result = msg_get_by_oref( val ).
        ENDIF.

      WHEN OTHERS.

        " skip an empty character value like the struct branch does -
        " otherwise msg_get_t's val2 fallback can never take over and the
        " caller renders a message box with blank text
        IF rtti_check_clike( val ) IS NOT INITIAL AND val IS NOT INITIAL.

          CLEAR temp29.
          temp29-text = val.
          INSERT temp29 INTO TABLE result.
        ENDIF.
    ENDCASE.

  ENDMETHOD.

  METHOD msg_get_by_oref.
        DATA temp30 TYPE REF TO cx_root.
        DATA lx LIKE temp30.
        DATA temp31 TYPE z2ui5_cl_se16_context=>ty_s_msg.
    DATA obj TYPE REF TO object.
    DATA lr_tab TYPE REF TO data.
    FIELD-SYMBOLS <tab> TYPE any.
    DATA temp32 TYPE z2ui5_cl_se16_context=>ty_s_msg.

    " four shapes, tried in turn and each on its own level - the nested
    " TRY/CATCH pyramid this used to be carried the attribute mapping twice,
    " three CATCH blocks deep, one fix away from drifting. Every attempt
    " that fails falls through to the next; the last one cannot fail
    " quietly, it maps whatever public attributes the object has

    " 1. an exception: its text, and its public attributes over it
    TRY.

        temp30 ?= val.

        lx = temp30.

        CLEAR temp31.
        temp31-type = `E`.
        temp31-text = lx->get_text( ).
        INSERT msg_get_by_oref_attri( io_obj = lx
                                      is_msg = temp31 ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.


    obj = val.



    " 2. an application log (IF_BALI_LOG)
    TRY.
        CREATE DATA lr_tab TYPE (`if_bali_log=>ty_item_table`).
        ASSIGN lr_tab->* TO <tab>.
        CALL METHOD obj->(`IF_BALI_LOG~GET_ALL_ITEMS`)
          RECEIVING
            item_table = <tab>.
        INSERT LINES OF msg_get_internal( <tab> ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " 3. a logger (ZIF_LOGGER)
    TRY.
        CREATE DATA lr_tab TYPE (`BAPIRETTAB`).
        ASSIGN lr_tab->* TO <tab>.
        CALL METHOD obj->(`ZIF_LOGGER~EXPORT_TO_TABLE`)
          RECEIVING
            rt_bapiret = <tab>.
        INSERT LINES OF msg_get_internal( <tab> ) INTO TABLE result.
        RETURN.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.

    " 4. any object: whatever public attributes carry a message part

    CLEAR temp32.
    INSERT msg_get_by_oref_attri( io_obj = obj
                                  is_msg = temp32 ) INTO TABLE result.

  ENDMETHOD.

  METHOD msg_map.

    result = msg.

    " The value is a component of an ARBITRARY structure: msg_get_internal
    " walks whatever an app hands to message_box_display( ) and maps every
    " component BY NAME. A business structure with a component that happens
    " to be called TEXT, ID, TYPE or V1 and is a TABLE, a nested structure
    " or a reference is not a message part - and the assignments below are
    " no class-based exception for it, they are a MOVE type conflict
    " (OBJECTS_MOVE_NOT_SUPPORTED on a system, "table, no header line" in
    " the transpiled runtime). So the box that was supposed to REPORT a
    " problem was the crash: nothing between here and the app's own main( )
    " catches it, and the roundtrip ended as a 500.
    " Decided BEFORE anything is assigned, which is the same rule
    " z2ui5_cl_ui5_srv_model=>delta_apply_field follows for the same reason
    " - a runtime error cannot be caught after the fact. A skipped component
    " simply is not a message part: the entry ends up without a text,
    " ui5_msg_box_format drops it, and the caller falls back to the DATA
    " renderer, which shows the whole structure including that component
    IF rtti_check_printable( val ) = abap_false.
      RETURN.
    ENDIF.

    CASE name.
      WHEN `ID` OR `MSGID` OR `ARBGB`.
        result-id = val.
      WHEN `NO` OR `NUMBER` OR `MSGNO` OR `TXTNR`.
        result-no = val.
      WHEN `MESSAGE` OR `TEXT`.
        result-text = val.
      WHEN `TYPE` OR `MSGTY` OR `M_SEVERITY`.
        result-type = val.
      WHEN `MESSAGE_V1` OR `MSGV1` OR `V1`.
        result-v1 = val.
      WHEN `MESSAGE_V2` OR `MSGV2` OR `V2`.
        result-v2 = val.
      WHEN `MESSAGE_V3` OR `MSGV3` OR `V3`.
        result-v3 = val.
      WHEN `MESSAGE_V4` OR `MSGV4` OR `V4`.
        result-v4 = val.
      WHEN `TIME_STMP`.
        " the one target that is not a string: a printable but non-numeric
        " value (`2026-09-16 10:00` in a char field of that name) converts
        " into the packed timestamp with CX_SY_CONVERSION_NO_NUMBER, which
        " is catchable where the MOVE conflict above is not - caught, and
        " the entry keeps no timestamp rather than costing the whole box
        TRY.
            result-timestampl = val.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
    ENDCASE.

  ENDMETHOD.

  METHOD check_is_rap_struct.

    DATA lt_attri TYPE abap_component_tab.
    DATA temp33 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp33.
          DATA temp34 TYPE REF TO cl_abap_tabledescr.
          DATA lo_line TYPE REF TO cl_abap_datadescr.
          DATA temp35 TYPE REF TO cl_abap_structdescr.
          DATA lt_comps TYPE abap_component_tab.
          DATA temp36 LIKE LINE OF lt_comps.
          DATA ls_comp LIKE REF TO temp36.
    lt_attri = rtti_get_t_attri_by_any( val ).



    LOOP AT lt_attri REFERENCE INTO ls_attri.
      CASE ls_attri->name.
        WHEN `%MSG` OR `%FAIL` OR `%OTHER`.
          result = abap_true.
          RETURN.
      ENDCASE.
    ENDLOOP.

    LOOP AT lt_attri REFERENCE INTO ls_attri.
      " the component's descriptor is already in the attribute table - no
      " ASSIGN and no describe_by_data per component
      IF ls_attri->type->kind <> cl_abap_typedescr=>kind_table.
        CONTINUE.
      ENDIF.

      TRY.

          temp34 ?= ls_attri->type.

          lo_line = temp34->get_table_line_type( ).
          IF lo_line->kind <> cl_abap_typedescr=>kind_struct.
            CONTINUE.
          ENDIF.

          temp35 ?= lo_line.

          lt_comps = temp35->get_components( ).


          LOOP AT lt_comps REFERENCE INTO ls_comp.
            IF ls_comp->name = `%MSG` OR ls_comp->name = `%FAIL`.
              result = abap_true.
              RETURN.
            ENDIF.
          ENDLOOP.
        CATCH cx_root ##NO_HANDLER.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap.

    DATA lv_kind TYPE string.
    DATA lv_is_row TYPE abap_bool.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp37 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp37.
      FIELD-SYMBOLS <tab> TYPE any.
      FIELD-SYMBOLS <ftab> TYPE ANY TABLE.
      DATA temp38 TYPE REF TO cl_abap_tabledescr.
      DATA lo_line TYPE REF TO cl_abap_datadescr.
      FIELD-SYMBOLS <row> TYPE ANY.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    msg_get_rap_row( EXPORTING val         = val
                               entity_name = entity_name
                     IMPORTING messages    = result
                               is_row      = lv_is_row ).
    IF lv_is_row = abap_true.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <tab>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      IF rtti_get_type_kind( <tab> ) <> cl_abap_datadescr=>typekind_table.
        CONTINUE.
      ENDIF.

      " guarded like data_render_tab, msg_get_internal and
      " data_get_headline - and here the symbol is LOOP-CARRIED, so an
      " ASSIGN that fails leaves it on the PREVIOUS component's table and
      " the rows below would be read out of that one

      UNASSIGN <ftab>.
      ASSIGN <tab> TO <ftab>.
      IF <ftab> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      " the row kind is a property of the table TYPE - decided once per
      " table, not asked of every row (same idea as msg_get_internal_tab)

      temp38 ?= ls_attri->type.

      lo_line = temp38->get_table_line_type( ).

      LOOP AT <ftab> ASSIGNING <row>.
        IF lo_line->type_kind = cl_abap_datadescr=>typekind_oref.
          IF <row> IS NOT INITIAL.
            TRY.
                INSERT LINES OF msg_get_t( <row> ) INTO TABLE result.
              CATCH cx_root ##NO_HANDLER.
            ENDTRY.
          ENDIF.
        ELSE.
          INSERT LINES OF msg_get_rap( val         = <row>
                                       entity_name = ls_attri->name ) INTO TABLE result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_row.
    DATA lv_meta_built TYPE abap_bool.
    DATA lt_meta TYPE ty_t_name_value.
    FIELD-SYMBOLS <msg> TYPE any.
            DATA lt_one TYPE z2ui5_cl_se16_context=>ty_t_msg.
            FIELD-SYMBOLS <m> LIKE LINE OF lt_one.
    FIELD-SYMBOLS <fail> TYPE any.
      FIELD-SYMBOLS <cause> TYPE any.
        DATA lv_cause TYPE i.
        DATA lv_text TYPE string.
        DATA temp39 TYPE z2ui5_cl_se16_context=>ty_s_msg.
    CLEAR messages.
    is_row = abap_false.

    " the meta block is built LAZILY: msg_get_rap_meta walks the row's
    " components three times over (element/action/tky scans), and the
    " common row in a RAP response table carries neither a filled %MSG nor
    " a %FAIL - building the block up front threw that work away per row




    ASSIGN COMPONENT `%MSG` OF STRUCTURE val TO <msg>.
    IF sy-subrc = 0.
      is_row = abap_true.
      IF <msg> IS NOT INITIAL.
        lt_meta = msg_get_rap_meta( val ).
        lv_meta_built = abap_true.
        TRY.

            lt_one = msg_get_t( <msg> ).

            LOOP AT lt_one ASSIGNING <m>.
              <m>-t_meta = lt_meta.
            ENDLOOP.
            INSERT LINES OF lt_one INTO TABLE messages.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDIF.


    ASSIGN COMPONENT `%FAIL` OF STRUCTURE val TO <fail>.
    IF sy-subrc = 0.
      is_row = abap_true.

      ASSIGN COMPONENT `CAUSE` OF STRUCTURE <fail> TO <cause>.
      IF sy-subrc = 0.
        IF lv_meta_built = abap_false.
          lt_meta = msg_get_rap_meta( val ).
        ENDIF.
        " %FAIL-CAUSE is the enumeration IF_ABAP_BEHV=>T_FAIL_CAUSE (base
        " type i). An enumerated value does not convert to i - a plain MOVE
        " is the runtime error UC_OBJECTS_NOT_CONVERTIBLE - so it is read by
        " its name (a string template writes the name) and mapped to the
        " base value. Type kind `k` is the enumeration (literal: the
        " constant typekind_enum does not exist on 7.02).

        IF cl_abap_typedescr=>describe_by_data( <cause> )->type_kind = `k`.
          lv_cause = msg_get_rap_cause_value( |{ <cause> }| ).
        ELSE.
          lv_cause = <cause>.
        ENDIF.

        lv_text = msg_get_rap_fail_text( lv_cause ).
        IF entity_name IS NOT INITIAL.
          lv_text = |{ entity_name }: { lv_text }|.
        ENDIF.

        CLEAR temp39.
        temp39-type = `E`.
        temp39-text = lv_text.
        temp39-t_meta = lt_meta.
        INSERT temp39 INTO TABLE messages.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_comp_str.

    " printable first, then the assignment: the component comes out of a
    " structure this class did not declare, and a table or a nested
    " structure into a string is a MOVE type conflict, not an exception -
    " see msg_map, which learnt it the expensive way.
    " One chained AND and not the nested IFs z2ui5_cl_ui5_handler=>
    " request_context_info argues for: abaplint's if_in_if refuses the
    " nesting here (nothing sits between the two tests), and the second
    " operand is safe on a failed ASSIGN either way - ABAP evaluates a
    " logical expression left to right and stops once the result is decided
    FIELD-SYMBOLS <comp> TYPE any.
    ASSIGN COMPONENT comp OF STRUCTURE val TO <comp>.
    IF sy-subrc = 0 AND rtti_check_printable( <comp> ) = abap_true.
      result = <comp>.
    ENDIF.

  ENDMETHOD.

  METHOD scan_flag_prefix.

    DATA lv_kind TYPE string.
    DATA temp40 TYPE string.
    DATA lv_prefix LIKE temp40.
    DATA lv_off TYPE i.
      FIELD-SYMBOLS <sub> TYPE any.
    DATA lv_len TYPE i.
    DATA lt_attri TYPE abap_component_tab.
    DATA temp41 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp41.
      FIELD-SYMBOLS <flag> TYPE any.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.

    " a `-` in the prefix is a path, not part of a component name - no
    " component name can contain one: %ELEMENT-<field> and
    " %OP-%ACTION-<name> are components of the NESTED structures %ELEMENT
    " and %OP-%ACTION. Compared against the row's own component names, the
    " two RAP prefixes never matched, and no message ever carried its
    " element or action

    temp40 = prefix.

    lv_prefix = temp40.

    lv_off = find( val = lv_prefix
                         sub = `-` ).
    IF lv_off >= 0.

      ASSIGN COMPONENT lv_prefix(lv_off) OF STRUCTURE val TO <sub>.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
      result = scan_flag_prefix( val    = <sub>
                                 prefix = substring( val = lv_prefix
                                                     off = lv_off + 1 ) ).
      RETURN.
    ENDIF.


    lv_len = strlen( lv_prefix ).

    lt_attri = rtti_get_t_attri_by_any( val ).


    LOOP AT lt_attri REFERENCE INTO ls_attri.
      IF strlen( ls_attri->name ) <= lv_len.
        CONTINUE.
      ENDIF.
      IF NOT ( lv_len = 0 OR ls_attri->name(lv_len) = lv_prefix ).
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <flag>.
      IF sy-subrc <> 0 OR <flag> IS INITIAL.
        CONTINUE.
      ENDIF.
      INSERT ls_attri->name+lv_len INTO TABLE result.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_element.

    DATA lt_suffix TYPE string_table.
    lt_suffix = scan_flag_prefix( val       = val
                                        prefix = `%ELEMENT-` ).
    result = concat_lines_of( table = lt_suffix
                              sep   = `, ` ).

  ENDMETHOD.

  METHOD msg_get_rap_state_area.

    result = get_comp_str( val     = val
                           comp = `%STATE_AREA` ).

  ENDMETHOD.

  METHOD msg_get_rap_action.

    DATA lt_suffix TYPE string_table.
    DATA temp42 TYPE string.
    DATA temp43 TYPE string.
    lt_suffix = scan_flag_prefix( val       = val
                                        prefix = `%OP-%ACTION-` ).

    CLEAR temp42.

    READ TABLE lt_suffix INTO temp43 INDEX 1.
    IF sy-subrc = 0.
      temp42 = temp43.
    ENDIF.
    result = temp42.

  ENDMETHOD.

  METHOD msg_get_rap_pid.

    result = get_comp_str( val     = val
                           comp = `%PID` ).

  ENDMETHOD.

  METHOD msg_get_rap_cid.

    result = get_comp_str( val     = val
                           comp = `%CID` ).

  ENDMETHOD.

  METHOD msg_get_rap_tky.

    FIELD-SYMBOLS <tky> TYPE any.
    ASSIGN COMPONENT `%TKY` OF STRUCTURE val TO <tky>.
    IF sy-subrc <> 0 OR <tky> IS INITIAL.
      RETURN.
    ENDIF.
    result = msg_get_rap_flatten( <tky> ).

  ENDMETHOD.

  METHOD msg_get_rap_flatten.

    DATA lv_kind TYPE string.
    DATA lt_attri TYPE abap_component_tab.
    DATA lt_part TYPE string_table.
    DATA temp44 LIKE LINE OF lt_attri.
    DATA ls_attri LIKE REF TO temp44.
      FIELD-SYMBOLS <comp> TYPE any.
      DATA lv_sub_kind TYPE string.
        DATA lv_sub TYPE string.
            DATA lv_str TYPE string.
            DATA temp45 LIKE LINE OF lt_part.
    lv_kind = rtti_get_type_kind( val ).
    IF lv_kind <> cl_abap_datadescr=>typekind_struct1
        AND lv_kind <> cl_abap_datadescr=>typekind_struct2.
      RETURN.
    ENDIF.


    lt_attri = rtti_get_t_attri_by_any( val ).




    LOOP AT lt_attri REFERENCE INTO ls_attri.

      ASSIGN COMPONENT ls_attri->name OF STRUCTURE val TO <comp>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      lv_sub_kind = rtti_get_type_kind( <comp> ).
      IF lv_sub_kind = cl_abap_datadescr=>typekind_struct1
          OR lv_sub_kind = cl_abap_datadescr=>typekind_struct2.

        lv_sub = msg_get_rap_flatten( <comp> ).
        IF lv_sub IS NOT INITIAL.
          INSERT lv_sub INTO TABLE lt_part.
        ENDIF.
      ELSEIF <comp> IS NOT INITIAL AND rtti_check_printable( <comp> ) = abap_true.
        " the printable test does what the TRY around this could not: a
        " TABLE component into the string below is a MOVE type conflict and
        " therefore a runtime error, which no CATCH takes (see msg_map). The
        " TRY stays for the conversions that ARE class-based - a character
        " value the packed/numeric target refuses
        TRY.

            lv_str = <comp>.

            temp45 = |{ ls_attri->name }={ lv_str }|.
            INSERT temp45 INTO TABLE lt_part.
          CATCH cx_root ##NO_HANDLER.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    result = concat_lines_of( table = lt_part
                              sep   = `, ` ).

  ENDMETHOD.

  METHOD msg_get_rap_meta.

    DATA lv TYPE string.
      DATA temp46 TYPE z2ui5_cl_se16_context=>ty_s_name_value.
      DATA temp47 TYPE z2ui5_cl_se16_context=>ty_s_name_value.
      DATA temp48 TYPE z2ui5_cl_se16_context=>ty_s_name_value.
      DATA temp49 TYPE z2ui5_cl_se16_context=>ty_s_name_value.
      DATA temp50 TYPE z2ui5_cl_se16_context=>ty_s_name_value.
      DATA temp51 TYPE z2ui5_cl_se16_context=>ty_s_name_value.

    lv = msg_get_rap_element( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp46.
      temp46-n = `element`.
      temp46-v = lv.
      INSERT temp46 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_state_area( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp47.
      temp47-n = `state_area`.
      temp47-v = lv.
      INSERT temp47 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_action( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp48.
      temp48-n = `action`.
      temp48-v = lv.
      INSERT temp48 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_pid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp49.
      temp49-n = `pid`.
      temp49-v = lv.
      INSERT temp49 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_cid( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp50.
      temp50-n = `cid`.
      temp50-v = lv.
      INSERT temp50 INTO TABLE result.
    ENDIF.

    lv = msg_get_rap_tky( val ).
    IF lv IS NOT INITIAL.

      CLEAR temp51.
      temp51-n = `tky`.
      temp51-v = lv.
      INSERT temp51 INTO TABLE result.
    ENDIF.

  ENDMETHOD.

  METHOD msg_get_rap_fail_text.
    " the base values of IF_ABAP_BEHV=>T_FAIL_CAUSE, read on an S/4HANA
    " system (2026-11-13) - HTTP-like codes, not a running number
    DATA temp52 TYPE string.
    CASE cause.
      WHEN 0.
        temp52 = `Operation failed`.
      WHEN 401.
        temp52 = `Authorization failure`.
      WHEN 404.
        temp52 = `Entity not found`.
      WHEN 409.
        temp52 = `Concurrent modification`.
      WHEN 423.
        temp52 = `Entity is locked`.
      WHEN 424.
        temp52 = `Dependent operation failed`.
      WHEN 501.
        temp52 = `Operation not implemented`.
      WHEN 4221.
        temp52 = `Operation disabled`.
      WHEN 4222.
        temp52 = `Entity is read-only`.
      WHEN OTHERS.
        temp52 = |Operation failed (cause code { cause })|.
    ENDCASE.
    result = temp52.
  ENDMETHOD.

  METHOD check_msg_container.

    DATA lv_kind TYPE string.
    DATA temp2 TYPE xsdboolean.
    lv_kind = rtti_get_type_kind( val ).

    temp2 = boolc( lv_kind = cl_abap_datadescr=>typekind_table OR lv_kind = cl_abap_datadescr=>typekind_struct1 OR lv_kind = cl_abap_datadescr=>typekind_struct2 OR lv_kind = cl_abap_datadescr=>typekind_oref ).
    result = temp2.

  ENDMETHOD.

  METHOD msg_get_by_oref_attri.

    FIELD-SYMBOLS <comp> TYPE any.
    DATA lt_attri_o TYPE abap_attrdescr_tab.
    DATA temp53 LIKE LINE OF lt_attri_o.
    DATA ls_attri_o LIKE REF TO temp53.

    result = is_msg.

    lt_attri_o = rtti_get_t_attri_by_oref( io_obj ).


    LOOP AT lt_attri_o REFERENCE INTO ls_attri_o "#EC CI_SORTSEQ
         WHERE visibility = cv_objectdescr_public.
      " UNASSIGN + IS ASSIGNED, not sy-subrc - the loop-carried case (see
      " error_get_attributes). Here a stale 0 maps the PREVIOUS attribute's
      " value onto this one's name, i.e. a message id, number or placeholder
      " taken from the wrong attribute
      UNASSIGN <comp>.
      ASSIGN io_obj->(ls_attri_o->name) TO <comp>.
      IF <comp> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      result = msg_map( name = ls_attri_o->name
                        val  = <comp>
                        msg  = result ).
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_internal_tab.

    " the RAP shape is a property of the ROW TYPE: decided on the first
    " structured row and handed down, not asked of every row - the check
    " describes every table component of a row, which a business table of a
    " few thousand rows paid a few thousand times before the box even
    " decided it carries no message at all
    DATA lv_rap LIKE abap_false.
    DATA lv_first LIKE abap_true.
    FIELD-SYMBOLS <row> TYPE ANY.
        DATA lv_row_kind TYPE string.
    lv_rap = abap_false.

    lv_first = abap_true.

    LOOP AT it_tab ASSIGNING <row>.
      IF lv_first = abap_true.
        lv_first = abap_false.

        lv_row_kind = rtti_get_type_kind( <row> ).
        IF lv_row_kind = cl_abap_datadescr=>typekind_struct1
            OR lv_row_kind = cl_abap_datadescr=>typekind_struct2.
          lv_rap = check_is_rap_struct( <row> ).
        ENDIF.
      ENDIF.
      IF lv_rap = abap_true AND <row> IS NOT INITIAL.
        INSERT LINES OF msg_get_rap( <row> ) INTO TABLE result.
      ELSE.
        INSERT LINES OF msg_get_internal( val          = <row>
                                          iv_check_rap = abap_false ) INTO TABLE result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD msg_get_rap_cause_value.

    " the name of an IF_ABAP_BEHV=>T_FAIL_CAUSE value to its base value;
    " -1 for a name this release does not know, which the text keeps
    " (the upper-case name in a variable first: the downport turns the
    " SWITCH into a CASE, whose operand takes no built-in function on 7.02)
    DATA lv_name TYPE string.
    DATA temp54 TYPE i.
    lv_name = to_upper( name ).

    CASE lv_name.
      WHEN `UNSPECIFIC`.
        temp54 = 0.
      WHEN `UNAUTHORIZED`.
        temp54 = 401.
      WHEN `NOT_FOUND`.
        temp54 = 404.
      WHEN `CONFLICT`.
        temp54 = 409.
      WHEN `LOCKED`.
        temp54 = 423.
      WHEN `DEPENDENCY`.
        temp54 = 424.
      WHEN `NOT_IMPLEMENTED`.
        temp54 = 501.
      WHEN `DISABLED`.
        temp54 = 4221.
      WHEN `READONLY`.
        temp54 = 4222.
      WHEN OTHERS.
        temp54 = -1.
    ENDCASE.
    result = temp54.

  ENDMETHOD.
ENDCLASS.
