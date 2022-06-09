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
  let files, f =
    match Array.to_list Sys.argv |> List.tl with
    | [] ->
      [`Stdin],
      fun o -> Printf.printf "%s\n" Sqldep.(show_name o)
    | ["-h"] | ["--help"] ->
      Printf.eprintf "usage: %s [prefix [script.vbs...]]\n" Sys.argv.(0);
      exit 1
    | prefix :: l ->
      begin match l with
        | [] -> [`Stdin]
        | _ -> l |> List.map (function "-" -> `Stdin | f -> `File f)
      end,
      fun (db, obj) ->
        let db =
          match db with
          | None -> Some prefix
          | Some _ -> db
        in
        Sqldep.(quote (show_name (db, obj))) |>
        Printf.printf "%s [color=grey, fontcolor=grey]\n"
  in
  files |> List.iter (fun inp ->
    try
      let ch, fn =
        match inp with
        | `Stdin -> stdin, "<stdin>"
        | `File fn -> open_in fn, fn
      in
      let lexbuf = Lexing.from_channel ch in
      Lexing.set_filename lexbuf fn;
      traverse f f f lexbuf
    with Sys_error e ->
      Printf.eprintf "%s\n" e;
      exit 2
  )
}
