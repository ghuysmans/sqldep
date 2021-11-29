open Sqldep

let hack = function
  | None, _ -> failwith "unqualified object name"
  | Some db, _ -> None, db


let () =
  Printf.printf "strict ";
  Lexing.from_channel stdin |>
  to_dot (fun new_obj new_dep end_dep ch ->
    traverse
      (fun _ name -> new_obj `Table (hack name))
      (fun name -> new_dep (hack name))
      end_dep
      ch
  )
