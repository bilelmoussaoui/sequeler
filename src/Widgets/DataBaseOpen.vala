/*
* Copyright (c) 2011-2017 Alecaddd (http://alecaddd.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
*/

public class Sequeler.DataBaseOpen : Gtk.Box {

    public Gtk.Paned pane;
    public Gtk.Box toolbar;
    public Gtk.Button run_button;
    public Gtk.Spinner spinner;
    public Gtk.Label result_message;
    public Gtk.Label loading_msg;
    public Gtk.TreeView results_view;
    public Sequeler.QueryBuilder query_builder;

    public signal int execute_query (string query);
    public signal Gda.DataModel execute_select (string query);

    public DataBaseOpen () {
        orientation = Gtk.Orientation.VERTICAL;

        pane = new Gtk.Paned (Gtk.Orientation.VERTICAL);
        pane.wide_handle = true;
        this.pack_start (pane, true, true, 0);

        build_editor ();

        build_toolbar ();

        build_treeview ();

        connect_signals ();
    }

    public void build_editor () {
        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

        query_builder = new Sequeler.QueryBuilder ();
        query_builder.update_run_button.connect ((status) => {
            run_button.sensitive = status;
        });

        scroll.add (query_builder);

        var editor = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        editor.height_request = 100;

        editor.pack_start (scroll, true, true, 0);

        pane.pack1 (editor, true, false);
    }

    public void build_toolbar () {
        toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        toolbar.get_style_context ().add_class ("toolbar");
        toolbar.get_style_context ().add_class ("library-toolbar");

        var run_image = new Gtk.Image.from_icon_name ("application-x-executable-symbolic", Gtk.IconSize.BUTTON);
        run_button = new Gtk.Button.with_label (_("Run Query"));
        run_button.get_style_context ().add_class ("suggested-action");
        run_button.always_show_image = true;
        run_button.set_image (run_image);
        run_button.can_focus = false;
        run_button.margin = 10;
        run_button.sensitive = false;

        spinner = new Gtk.Spinner ();

        loading_msg = new Gtk.Label ("running query...");
        loading_msg.visible = false;
        loading_msg.no_show_all = true;

        toolbar.pack_start (spinner, false, false, 10);
        toolbar.pack_start (loading_msg, false, false, 10);
        toolbar.pack_end (run_button, false, false, 0);
    }

    public void build_treeview () {
        var results = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        results.height_request = 100;

        results.add (toolbar);

        var scroll = new Gtk.ScrolledWindow (null, null);
        scroll.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

        result_message = new Gtk.Label (_("No Results Available"));
        result_message.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        result_message.valign = Gtk.Align.CENTER;

        scroll.add (result_message);

        results_view = new Gtk.TreeView ();

        results.pack_start (scroll, true, true, 0);

        pane.pack2 (results, true, false);
    }

    public void connect_signals () {
        run_button.clicked.connect (() => {

            spinner.start ();
            loading_msg.visible = true;
            result_message.visible = false;
            result_message.no_show_all = true;

            GLib.Timeout.add_seconds(0, () => {                 
                var query = query_builder.get_text ();

                if ("select" in query.down ()) {
                    var response = execute_select (query);
                    spinner.stop ();
                    loading_msg.visible = false;
                    handle_select_response (response);
                } else {
                    var response = execute_query (query);
                    spinner.stop ();
                    loading_msg.visible = false;
                    handle_query_response (response);
                }
                return false; 
            });
        });
    }

    public void handle_query_response (int response) {
        if (response == 0) {
            result_message.visible = false;
            result_message.no_show_all = true;
        } else if (response == 1) {
            result_message.visible = true;
            result_message.no_show_all = false;
            result_message.label = _("Query Successfully Executed!");
        }
    }

    public void handle_select_response (Gda.DataModel response) {

    }
}