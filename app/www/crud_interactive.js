function crud_interactive(ns_prefix) {
  $("#" + ns_prefix + "DT").on("click", ".edit_btn", function() {
    Shiny.setInputValue(ns_prefix + "id_to_edit", this.id, { priority: "event" });
  });
  $("#" + ns_prefix + "DT").on("click", ".clone_btn", function() {
    Shiny.setInputValue(ns_prefix + "id_to_clone", this.id, { priority: "event" });
  });
  $("#" + ns_prefix + "DT").on("click", ".delete_btn", function() {
    Shiny.setInputValue(ns_prefix + "id_to_delete", this.id, { priority: "event" });
  });
}