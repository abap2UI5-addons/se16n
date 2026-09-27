CLASS z2ui5_cl_tm_se16_01 DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA mv_tabname     TYPE string.
    DATA mr_table       TYPE REF TO data.
    DATA mo_multiselect TYPE REF TO z2ui5_cl_sel_multisel.
    DATA ms_layout      TYPE z2ui5_t_11.

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

      WHEN `POPUP_LAYOUT`.
        client->nav_app_call( z2ui5_cl_layo_manager=>choose_layout(
            handle01 = `ZSE16`
            handle02 = mv_tabname ) ).

      WHEN `UPDATE_TABLE`.
        on_init( ).

      WHEN `GO`.
        client->nav_app_call( NEW z2ui5_cl_tm_se16_02( ) ).

      WHEN `BACK`.
        client->nav_app_leave( ).

    ENDCASE.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
                     )->ele( n = `View` ns = `mvc`
                     )->a( n = `xmlns` v = `sap.m`
                     )->a( n = `xmlns:mvc` v = `sap.ui.core.mvc`
                     )->a( n = `displayBlock` v = `true`
                     )->a( n = `height` v = `100%` ).
    DATA(page) = view->ele( `Shell`
                     )->ele( `Page`
                     )->a( n = `title` v = `abap2UI5 - SE16 CLOUD - Start`
                     )->a( n = `navButtonPress` v = client->_event( `BACK` )
                     )->a( n = `showNavButton` b = client->check_app_prev_stack( )
                     )->a( n = `floatingFooter` b = abap_true ).
    DATA(vbox) = page->ele( `VBox` ).

    vbox->ele( `HBox`
        )->tag( `Input`
        )->a( n = `value` v = client->_bind_edit( mv_tabname )
        )->a( n = `description` v = `Table`
        )->a( n = `submit` v = client->_event( `UPDATE_TABLE` )
        )->tag( `Button`
        )->a( n = `press` v = client->_event( `UPDATE_TABLE` )
        )->a( n = `text` v = `Load` ).
    vbox->ele( `HBox`
        )->tag( `Input`
        )->a( n = `value` v = client->_bind_edit( ms_layout-layout )
        )->a( n = `description` v = `Layout`
        )->a( n = `enabled` b = abap_false
        )->tag( `Button`
        )->a( n = `press` v = client->_event( `POPUP_LAYOUT` )
        )->a( n = `text` v = `Choose Layout` ).
    IF mv_tabname IS NOT INITIAL.
      mo_multiselect->set_output( client = client view = vbox ).
    ENDIF.
    page->ele( `footer`
        )->ele( `OverflowToolbar`
        )->tag( `ToolbarSpacer`
        )->tag( `Button`
        )->a( n = `text` v = `GO`
        )->a( n = `type` v = `Emphasized`
        )->a( n = `press` v = client->_event( `GO` ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    TRY.
        me->client = client.

        IF client->check_on_init( ).
          on_init( ).
        ELSEIF mo_multiselect->main( client ).
        ELSEIF client->check_on_navigated( ).
          on_navigated( ).
        ELSE.
          on_event( ).
        ENDIF.

      CATCH cx_root INTO DATA(x).
        client->message_box_display( x ).
    ENDTRY.
  ENDMETHOD.

  METHOD on_init.

    IF mv_tabname IS INITIAL.
      mv_tabname = `z2ui5_t_15`.
    ENDIF.

    mr_table = z2ui5_cl_se16_context=>rtti_create_tab_by_name( mv_tabname ).
    mo_multiselect = z2ui5_cl_sel_multisel=>factory_by_name(
                         val       = mv_tabname
                         s_variant = VALUE #( handle01 = `ZSE16` handle02 = mv_tabname ) ).

    view_display( ).

  ENDMETHOD.

  METHOD on_navigated.

    " which app handed control back decides what to do - asked with IS
    " INSTANCE OF instead of a CAST whose failure an empty CATCH swallowed,
    " so an error in the branch that does run reaches the message box in main
    DATA(lo_prev) = client->get_app_prev( ).

    IF lo_prev IS INSTANCE OF z2ui5_cl_layo_pop_w_sel.
      DATA(lo_layout) = CAST z2ui5_cl_layo_pop_w_sel( lo_prev )->result( ).

      IF lo_layout-check_confirmed = abap_true.
        FIELD-SYMBOLS <layout> TYPE z2ui5_t_11.
        ASSIGN lo_layout-row->* TO <layout>.
        ms_layout = <layout>.
        view_display( ).
      ENDIF.

    ELSEIF lo_prev IS INSTANCE OF z2ui5_cl_tm_se16_02.
      view_display( ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
