open Sqldep

let () =
  to_dot traverse (Lexing.from_channel stdin)
