open Sqldep
open Printf

let ctx = Hashtbl.create 50


let () =
  let lexbuf = Lexing.from_channel stdin in
  Lexing.set_filename lexbuf "<stdin>";
  let err f =
    let pos = lexbuf.lex_start_p in
    kfprintf
      (fun _ch -> exit 1)
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
        | Some x -> x
        | None ->
          err (fun ch () -> fprintf ch "undefined object '%s'" (show_name name))
      in
      match typ with
      | `View -> () (* it exists, that's all we need to know *)
      | `Table ->
        match typ' with
        | `Table -> () (* good! *)
        | `View -> err (fun ch () ->
          fprintf ch "a foreign key references '%s', a view" (show_name name)
        ))
    (fun typ name ->
      (* remember the view we may just have defined *)
      Hashtbl.replace ctx name typ)
    lexbuf
