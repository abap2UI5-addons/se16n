CLASS z2ui5_cl_tm_se16_01 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mv_tabname     TYPE string VALUE `USR01`.
    DATA mr_table       TYPE REF TO data.
    DATA mo_multiselect TYPE REF TO z2ui5_cl_sel_multisel.
    DATA ms_layout TYPE z2ui5_t_11.
    METHODS on_navigated.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.

    METHODS on_event.
    METHODS view_display.
    METHODS on_init.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_tm_se16_01 IMPLEMENTATION.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'POPUP_LAYOUT'.
        client->nav_app_call( z2ui5_cl_layo_manager=>choose_layout(
            handle01 = 'ZSE16'
            handle02 = mv_tabname ) ).

      WHEN 'UPDATE_TABLE'.
        on_init( ).

      WHEN 'GO'.
        client->nav_app_call( NEW z2ui5_cl_tm_se16_02( ) ).

      WHEN 'BACK'.
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).

    DATA(page) = view->shell( )->page( title          = 'abap2UI5 - SE16 CLOUD - Start'
                                       navbuttonpress = client->_event( 'BACK' )
                                       shownavbutton  = client->check_app_prev_stack( )
                                        floatingfooter = abap_true
                                        ).
    DATA(vbox) = page->vbox( ).

    vbox->hbox(
        )->input(  value = client->_bind_edit( mv_tabname ) description = `Table` submit = client->_event( `UPDATE_TABLE` )
        )->button( press = client->_event( `UPDATE_TABLE` ) text = `Post`
        ).
    vbox->hbox(
        )->input(  value = client->_bind_edit( ms_layout-layout ) description = `Layout` enabled = abap_false
        )->button( press = client->_event( `POPUP_LAYOUT` ) text = `Post`
      ).
    IF mv_tabname IS NOT INITIAL.
      mo_multiselect->set_output( client = client view = vbox ).
    ENDIF.


    page->footer( )->overflow_toolbar(
        )->toolbar_spacer(
        )->button( text  = `GO`
                   type  = `Emphasized`
                   press = client->_event( `GO` ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    TRY.
        me->client = client.

        IF client->check_on_init( ).
          on_init( ).
          RETURN.
        ENDIF.

        IF mo_multiselect->main( client ).
          RETURN.
        ENDIF.

        IF client->check_on_navigated( ).
          on_navigated( ).
          RETURN.
        ENDIF.
        on_event( ).

      CATCH cx_root INTO DATA(x).
        client->message_box_display( x ).
    ENDTRY.
  ENDMETHOD.

  METHOD on_init.

    mr_table = z2ui5_cl_util=>rtti_create_tab_by_name( mv_tabname ).
    mo_multiselect = z2ui5_cl_sel_multisel=>factory_by_name(
                       val       = mv_tabname
                      s_variant =  VALUE #( handle01 = 'ZSE16' handle02 = mv_tabname )
             ).

*    mo_layout = z2ui5_cl_layo_manager=>factory( control  = z2ui5_cl_layo_manager=>m_table
*                                          data     = mr_table
*                                          handle01 = 'ZSE16'
*                                          handle02 = mv_tabname ).



    view_display( ).

  ENDMETHOD.


  METHOD on_navigated.

    TRY.
        DATA(lo_popup) = CAST z2ui5_cl_layo_pop_w_sel( client->get_app_prev( ) ).
        DATA(lo_layout) = lo_popup->result( ).

        IF lo_layout-check_confirmed = abap_true.
          FIELD-SYMBOLS <layout> TYPE z2ui5_t_11.
          ASSIGN lo_layout-row->* TO <layout>.
          ms_layout = <layout>.
        ENDIF.
        RETURN.
      CATCH cx_root.
    ENDTRY.
    TRY.
        DATA(lo_app) = CAST z2ui5_cl_tm_se16_02( client->get_app_prev( ) ).
        view_display( ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
