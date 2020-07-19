open Sqlgg
open Format

let () =
  let name, l = Sqldep.tables @@ Parser.parse_stmt (read_line ()) in
  let show = Sql.show_table_name in
  printf "@[<hov>";
  (match name with None -> () | Some n -> printf "%s: " (show n));
  let pp_sep ppf () = fprintf ppf ",@ " in
  List.map show l |>
  printf "%a@]@." (pp_print_list ~pp_sep pp_print_string)
