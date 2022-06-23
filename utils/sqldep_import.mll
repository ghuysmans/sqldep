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
let extend prefix (db, obj) =
  match db with
  | None -> Some prefix, obj
  | _ -> db, obj

let () =
  let files, f =
    let open Sqldep in
    match Array.to_list Sys.argv |> List.tl with
    | [] -> ["-"], fun _ ->
      ignore,
      fun o -> Printf.printf "%s\n" (show_name o)
    | ["-h"] | ["--help"] ->
      Printf.eprintf "usage: %s [[-b|-g] prefix script.vbs...]\n" Sys.argv.(0);
      exit 1
    | "-g" :: prefix :: l -> l, fun _ ->
      ignore,
      fun o ->
        Printf.printf "%s [color=grey, fontcolor=grey]\n"
          (quote (show_name (extend prefix o)))
    | "-b" :: prefix :: l ->
      Printf.printf "USE sqlbackup;\n";
      Printf.printf "DELETE FROM blacklist WHERE reason='sqldep';\n";
      l, fun fn ->
        ignore,
        fun (db, obj) ->
          Printf.printf
            "INSERT INTO blacklist VALUES ('%s', '%s', '%s', 1);\n"
            (Option.value ~default:prefix db)
            obj
            fn
    | prefix :: l -> l, fun _fn ->
      ignore,
      fun o ->
        Printf.printf "%s\n" (show_name (extend prefix o))
  in
  files |> List.iter (fun fn ->
    try
      let ch, fn =
        if fn = "-" then
          stdin, "<stdin>"
        else
          open_in fn, fn
      in
      let header, body = f fn in
      header ();
      let lexbuf = Lexing.from_channel ch in
      Lexing.set_filename lexbuf fn;
      traverse body body ignore lexbuf
    with Sys_error e ->
      Printf.eprintf "%s\n" e;
      exit 2
  )
}
