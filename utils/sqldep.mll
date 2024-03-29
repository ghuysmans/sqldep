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
| '\n' {
  Lexing.new_line lexbuf;
  traverse new_obj new_dep end_dep lexbuf
}
| ("TABLE" | "VIEW" as typ) ' ' name ':' {
  let typ = if typ = "TABLE" then `Table else `View in
  new_obj typ (db, obj);
  deps typ (db, obj) new_obj new_dep end_dep lexbuf
}

and deps typ name new_obj new_dep end_dep = parse
| "\n" {
  end_dep typ name;
  Lexing.new_line lexbuf;
  traverse new_obj new_dep end_dep lexbuf
}
| ' ' name {
  new_dep typ name (db, obj);
  deps typ name new_obj new_dep end_dep lexbuf
}


{
open Printf

let to_dot traverse ch =
  printf "digraph {\n";
  traverse
    (fun typ name ->
      printf "%s [label=\"%s\", shape=%s]\n%s -> {"
        (quote (show_name name))
        (show_name name)
        (shape_of_typ typ)
        (quote (show_name name)))
    (fun _ _ name -> printf "%s " (quote (show_name name)))
    (fun _ _ -> printf "}\n")
    ch;
  printf "}\n"
}
