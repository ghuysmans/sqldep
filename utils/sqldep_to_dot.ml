open Sqldep
open Printf

let quote x =
  String.split_on_char '.' x |>
  String.concat "__"

let shape_of_typ = function
  | `Table -> "cylinder"
  | `View -> "house"


let () =
  printf "digraph {\n";
  traverse
    (fun typ name ->
      printf "%s [shape=%s]\n%s -> {"
        (quote (show_name name))
        (shape_of_typ typ)
        (quote (show_name name)))
    (fun name -> printf "%s " (quote (show_name name)))
    (fun () -> printf "}\n")
    (Lexing.from_channel stdin);
  printf "}\n"
