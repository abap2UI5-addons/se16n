CLASS z2ui5_cl_tm_se16_02 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mo_layout TYPE REF TO z2ui5_cl_layo_manager.
    DATA mo_prev   TYPE REF TO z2ui5_cl_tm_se16_01.
    DATA mr_table  TYPE REF TO data.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS set_data.

    METHODS on_event.
    METHODS view_display.
    METHODS on_navigated.
    METHODS on_init.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_tm_se16_02 IMPLEMENTATION.

  METHOD set_data.

    DATA(lv_where) = z2ui5_cl_util=>filter_get_sql_where( mo_prev->mo_multiselect->ms_result-t_filter ).
    CLEAR mr_table->*.
    TRY.

        SELECT FROM (mo_prev->mv_tabname)
         FIELDS
           *
          WHERE (lv_where)
         INTO CORRESPONDING FIELDS OF TABLE @mr_table->*
         UP TO 100 ROWS.

      CATCH cx_root INTO DATA(x).
    ENDTRY.

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.
      WHEN `REFRESH`.
        set_data( ).
      WHEN `BUTTON_START`.
        set_data( ).
        view_display( ).
      WHEN 'BACK'.
        client->nav_app_leave( ).
      WHEN OTHERS.
        z2ui5_cl_layo_pop=>on_event_layout( client = client
                                            layout = mo_layout ).
    ENDCASE.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).

    DATA(page) = view->shell( )->page(
                     id             = `page_main`
                     title          = |abap2UI5 - SE16-CLOUD -{ mo_prev->mv_tabname }|
                     navbuttonpress = client->_event( 'BACK' )
                     floatingfooter = abap_true
                     shownavbutton  = xsdbool( client->get( )-s_draft-id_prev_app_stack IS NOT INITIAL ) ).

    z2ui5_cl_layo_xml_builder=>xml_build_table( i_data   = mr_table
                                                i_xml    = page
                                                i_client = client
                                                i_layout = mo_layout ).

    page->footer( )->overflow_toolbar(
        )->button( text  = `Back`
                   press = client->_event( `BACK` )
        )->toolbar_spacer(
        )->button( text  = `Refresh`
                   press = client->_event( `REFRESH` ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    TRY.

        me->client = client.

        IF client->check_on_init( ).
          on_init( ).
        ELSEIF client->check_on_navigated( ).
          on_navigated( ).
        ELSEIF client->get( )-event IS NOT INITIAL.
          on_event( ).
        ENDIF.

      CATCH cx_root INTO DATA(x).
        client->message_box_display( x ).
    ENDTRY.
  ENDMETHOD.

  METHOD on_navigated.

    TRY.
        DATA(app) = CAST z2ui5_cl_layo_pop( client->get_app( client->get( )-s_draft-id_prev_app ) ).
        mo_layout = app->mo_layout.

        IF app->mv_rerender = abap_true.
          " subcolumns need rerendering to work ..
          view_display( ).
        ELSE.
          "  for all other changes in Layout View Model Update is enough.
          client->view_model_update( ).
        ENDIF.
      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD on_init.

    mo_prev = CAST #( client->get_app_prev( ) ).
    mr_table = z2ui5_cl_util=>rtti_create_tab_by_name( mo_prev->mv_tabname ).
    set_data( ).

    IF mo_layout IS NOT BOUND.

      IF mo_prev->ms_layout-guid IS INITIAL.

        mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                    data     = mr_table
                                                    handle01 = 'ZSE16'
                                                    handle02 = mo_prev->mv_tabname ).
      ELSE.

        mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
                                                    data     = mr_table
                                                    handle01 = 'ZSE16'
                                                    handle02 = mo_prev->mv_tabname ).

        mo_layout = z2ui5_cl_layo_manager=>factory_by_guid( layout_guid = mo_prev->ms_layout-guid
                                                            t_comps     = mo_layout->ms_layout-t_layout ).
      ENDIF.

    ENDIF.

    view_display( ).

  ENDMETHOD.

ENDCLASS.
