open Sqldep
open Printf

let errors = ref 0

let check ctx inp =
  let lexbuf =
    let set_fn fn lexbuf =
      Lexing.set_filename lexbuf fn;
      lexbuf
    in
    match inp with
    | `Stdin ->
      Lexing.from_channel stdin |>
      set_fn "<stdin>"
    | `File fn ->
      try
        open_in fn |>
        Lexing.from_channel |>
        set_fn fn
      with Sys_error e ->
        eprintf "%s\n" e;
        exit 2
  in
  let err f =
    let pos = lexbuf.lex_start_p in
    kfprintf
      (fun _ch -> incr errors)
      stderr
      "%s:%d: error: %a\n" pos.pos_fname pos.pos_lnum
      f ()
  in
  traverse
    (fun typ name ->
      if Hashtbl.mem ctx name then
        err (fun ch () -> fprintf ch "redefinition of '%s'" (show_name name))
      else if typ = `Table then (* allow self-referencing FKs *)
        Hashtbl.replace ctx name typ
      else
        ())
    (fun typ _ name ->
      let typ' =
        match Hashtbl.find_opt ctx name with
        | Some _ as s -> s
        | None ->
          err (fun ch () -> fprintf ch "undefined object '%s'" (show_name name));
          None
      in
      match typ with
      | `View -> () (* it exists, that's all we need to know *)
      | `Table ->
        match typ' with
        | None -> () (* don't report twice *)
        | Some `Table -> () (* good! *)
        | Some `View -> err (fun ch () ->
          fprintf ch "a foreign key references '%s', a view" (show_name name)
        ))
    (fun typ name ->
      (* remember the view we may just have defined *)
      Hashtbl.replace ctx name typ)
    lexbuf


let () =
  let ctx = Hashtbl.create 50 in
  begin match Sys.argv with
  | [| _ |] -> check ctx `Stdin
  | [| _; "-h" |] | [| _; "--help" |]->
    eprintf "usage: %s sql.dep...\n" Sys.argv.(0);
    exit 1
  | _ ->
    Array.to_list Sys.argv |> List.tl |>
    List.iter (fun x -> check ctx (`File x))
  end;
  if !errors > 0 then exit 3
