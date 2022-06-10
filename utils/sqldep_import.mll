let id = ['A'-'Z' 'a'-'z' '0'-'9' '_']+
let name = ((id as db) '.')? (id as obj)
let indent = ['\t'' ']
let command = indent* (".CommandText = \"" | id ".Execute \"")
let whatever = [^'\r''\n']*
let nl = '\r'?'\n'

(* FIXME case-insensitive match *)
rule traverse insert update delete = parse
| command "INSERT " ("OR REPLACE " | "IGNORE ")? "INTO " name {
  insert (db, obj);
  eat insert update delete lexbuf
}
| command "UPDATE " name {
  update (db, obj);
  eat insert update delete lexbuf
}
| command "DELETE FROM " name {
  delete (db, obj);
  eat insert update delete lexbuf
}
(* TODO DELETE t FROM t INNER JOIN u... parse? improve sqlgg? *)
| command {
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
| whatever { traverse insert update delete lexbuf }
| whatever nl {
  Lexing.new_line lexbuf;
  traverse insert update delete lexbuf
}
| eof { () }


{
let () =
  let files, f =
    let generic fmt prefix l =
      if fmt = `Backup then (
        Printf.printf "USE sqlbackup;\n";
        Printf.printf "DELETE FROM blacklist WHERE reason='sqldep';\n"
      );
      l |> List.map (function "-" -> `Stdin | f -> `File f),
      fun (db, obj) ->
        let db =
          match db with
          | None -> prefix
          | Some _ -> db
        in
        let open Sqldep in
        match fmt with
        | `Backup ->
          Printf.printf
            "INSERT INTO blacklist VALUES ('%s', '%s', 'sqldep', 1);\n"
            (match db with None -> "?" | Some x -> x)
            obj
        | `Raw ->
          Printf.printf "%s\n" (show_name (db, obj))
        | `Graph ->
          Printf.printf "%s [color=grey, fontcolor=grey]\n"
            (quote (show_name (db, obj)))
    in
    match Array.to_list Sys.argv |> List.tl with
    | [] ->
      [`Stdin],
      fun o -> Printf.printf "%s\n" Sqldep.(show_name o)
    | ["-h"] | ["--help"] ->
      Printf.eprintf "usage: %s [[-b|-g] prefix script.vbs...]\n" Sys.argv.(0);
      exit 1
    | "-g" :: prefix :: l ->
      generic `Graph (Some prefix) l
    | "-b" :: prefix :: l ->
      generic `Backup (Some prefix) l
    | prefix :: l ->
      generic `Raw (Some prefix) l
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
      traverse f f ignore lexbuf
    with Sys_error e ->
      Printf.eprintf "%s\n" e;
      exit 2
  )
}
