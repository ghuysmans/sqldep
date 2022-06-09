let id = ['A'-'Z' 'a'-'z' '0'-'9' '_']+
let name = ((id as db) '.')? (id as obj)
let indent = ['\t'' ']
let whatever = [^'\r''\n']*
let nl = '\r'?'\n'

(* FIXME case-insensitive match *)
rule traverse insert update delete = parse
| indent+ ".CommandText = \"INSERT " ("OR REPLACE " | "IGNORE ")? "INTO " name {
  insert (db, obj);
  eat insert update delete lexbuf
}
| indent+ ".CommandText = \"UPDATE " name {
  update (db, obj);
  eat insert update delete lexbuf
}
| indent+ ".CommandText = \"DELETE FROM " name {
  delete (db, obj);
  eat insert update delete lexbuf
}
(* TODO DELETE t FROM t INNER JOIN u... parse? improve sqlgg? *)
| indent+ ".CommandText = \"" {
  let pos = lexbuf.lex_start_p in
  Printf.eprintf "%s:%d: warning: unhandled query\n" pos.pos_fname pos.pos_lnum;
  eat insert update delete lexbuf
}
| nl {
  Lexing.new_line lexbuf;
  traverse insert update delete lexbuf
}
| _ { eat insert update delete lexbuf }
| eof { () }

and eat insert update delete = parse
| whatever nl {
  Lexing.new_line lexbuf;
  traverse insert update delete lexbuf
}
| eof { () }


{
let () =
  let f (db, obj) =
    match Sys.argv with
    | [| _ |] ->
      Printf.printf "%s\n" Sqldep.(show_name (db, obj))
    | [| _; prefix |] ->
      let db =
        match db with
        | None -> Some prefix
        | Some _ -> db
      in
      Sqldep.(quote (show_name (db, obj))) |>
      Printf.printf "%s [color=grey, fontcolor=grey]\n"
    | _ ->
      Printf.eprintf "usage: %s [prefix]\n" Sys.argv.(0);
      exit 1
  in
  let lexbuf = Lexing.from_channel stdin in
  Lexing.set_filename lexbuf "<stdin>";
  traverse f f f lexbuf
}
