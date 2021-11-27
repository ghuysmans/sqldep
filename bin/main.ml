open Sqlgg

let show_name typ = function
  | `Table_name tn -> Printf.printf "%s %s:" typ (Sql.show_table_name tn)
  | `Anonymous -> Printf.printf "%s ?:" typ

let show_view name sf =
  show_name "VIEW" name;
  Sqldep.tables sf |> List.iter (fun x ->
    Printf.printf " %s" (Sql.show_table_name x)
  );
  Printf.printf "\n"

let show_fks name sch =
  show_name "TABLE" name;
  Sqldep.fks sch |> List.iter (fun {table; _} ->
    Printf.printf " %s" (Sql.show_table_name (`Table_name table))
  );
  Printf.printf "\n"


type token = [`Comment of string | `Token of string | `Char of char |
              `Space of string | `Prop of string * string | `Semicolon ]

let () =
  let lexbuf = Lexing.from_channel stdin in
  let tokens = Enum.from (fun () ->
    if lexbuf.Lexing.lex_eof_reached then raise Enum.No_more_elements else
    match Sql_lexer.ruleStatement lexbuf with
    | `Eof -> raise Enum.No_more_elements
    | #token as x -> x)
  in
  let extract () =
    let b = Buffer.create 1024 in
    let answer () = Buffer.contents b in
    let rec loop smth =
      match Enum.get tokens with
      | None -> if smth then Some (answer ()) else None
      | Some x ->
        match x with
        | `Comment s -> ignore s; loop smth (* do not include comments (option?) *)
        | `Char c -> Buffer.add_char b c; loop true
        | `Space _ when smth = false -> loop smth (* drop leading whitespaces *)
        | `Token s | `Space s -> Buffer.add_string b s; loop true
        | `Prop _ -> loop smth
        | `Semicolon -> Some (answer ())
    in
    loop false
  in
  let rec f () =
    match extract () with
    | None -> raise Enum.No_more_elements
    | Some x -> x
    | exception e ->
      Printf.eprintf "lexer failed (%s)\n" (Printexc.to_string e);
      f ()
  in
  Enum.from f |> Enum.iter (fun sql ->
    match Parser.T.parse_string sql with
    | Some (Select sf) -> show_view `Anonymous sf (* FIXME recover pos_lnum *)
    | Some (Create (name, `Select sf)) -> show_view (`Table_name name) sf
    | Some (Create (name, `Schema sch)) -> show_fks (`Table_name name) sch
    | _ -> ()
  )
