{
let show_name (db, name) =
  (match db with
   | None -> ""
   | Some x -> x ^ ".") ^
  name

let quote x =
  String.split_on_char '.' x |>
  String.concat "__"

let shape_of_typ = function
  | `Table -> "cylinder"
  | `View -> "house"
}


let id = ['A'-'Z' 'a'-'z' '0'-'9' '_']+
let name = ((id as db) '.')? (id as obj)

rule traverse new_obj new_dep end_dep = parse
| eof { () }
| ("TABLE" | "VIEW" as typ) ' ' name ':' {
  new_obj (if typ = "TABLE" then `Table else `View) (db, obj);
  deps new_obj new_dep end_dep lexbuf
}

and deps new_obj new_dep end_dep = parse
| "\n" {
  end_dep ();
  Lexing.new_line lexbuf;
  traverse new_obj new_dep end_dep lexbuf
}
| ' ' name {
  new_dep (db, obj);
  deps new_obj new_dep end_dep lexbuf
}


{
open Printf

let to_dot traverse ch =
  printf "digraph {\n";
  traverse
    (fun typ name ->
      printf "%s [shape=%s]\n%s -> {"
        (quote (show_name name))
        (shape_of_typ typ)
        (quote (show_name name)))
    (fun name -> printf "%s " (quote (show_name name)))
    (fun () -> printf "}\n")
    ch;
  printf "}\n"
}
