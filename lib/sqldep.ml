open Sqlgg.Sql

let tables =
  let rec expr = function
    | Value _ -> []
    | Param _ -> []
    | Choices (_, l) ->
      List.map (fun (_, o) ->
        match o with
        | None -> []
        | Some e -> expr e
      ) l |>
      List.flatten
    | Fun (_, l) -> List.map expr l |> List.flatten
    | Select (s, _) -> select_full s
    | Column _ -> []
    | Inserted _ -> []
  and column = function
    | All -> []
    | AllOf _ -> []
    | Expr (e, _) -> expr e
  and nested (h, t) =
    let source (s, _alias) =
      match s with
      | `Select s -> select_full s
      | `Table t -> [t]
      | `Nested n -> nested n
    in
    source h @ (
      List.map (fun (s, c) ->
        source s @
        match c with
        | `Cross -> []
        | `Search e -> expr e
        | `Default -> []
        | `Natural -> []
        | `Using _ -> []
      ) t |>
      List.flatten
    )
  and select {columns; from; where; group; having} =
    List.flatten [
      List.map column columns;
      (match from with None -> [] | Some n -> [nested n]);
      (match where with None -> [] | Some e -> [expr e]);
      List.map expr group;
      (match having with None -> [] | Some e -> [expr e]);
    ] |>
    List.flatten
  and select_full {select = h, t; order; _} =
    List.flatten [
      h :: t |> List.map select;
      List.map (fun (e, _) -> expr e) order;
    ] |>
    List.flatten
  in
  select_full

let fks _schema =
  failwith "FIXME extend sqlgg"


let%test_module _ = (module struct
  let t sql =
    match Sqlgg.Parser.parse_stmt sql with
    | Select sf ->
      tables sf |>
      List.map Sqlgg.Sql.show_table_name |>
      List.sort compare
    | _ -> failwith "expected a Select"

  let%test "from_prod" = t "SELECT * FROM t, u" = ["t"; "u"]
  let%test "join" = t "SELECT * FROM t INNER JOIN u ON t.x = u.x" = ["t"; "u"]
  let%test "on_ex" = t "SELECT * FROM t INNER JOIN u ON EXISTS(SELECT * FROM v)" = ["t"; "u"; "v"]
  let%test "where_eq" = t "SELECT * FROM t WHERE x = (SELECT * FROM u)" = ["t"; "u"]
  let%test "where_in" = t "SELECT * FROM t WHERE x IN (SELECT * FROM u)" = ["t"; "u"]
  let%test "group_by_ex" = t "SELECT * FROM t GROUP BY EXISTS(SELECT * FROM u)" = ["t"; "u"]
  let%test "having_ex" = t "SELECT * FROM t GROUP BY x HAVING EXISTS(SELECT * FROM u)" = ["t"; "u"]
  let%test "order_by_ex" = t "SELECT * FROM t ORDER BY EXISTS(SELECT * FROM u)" = ["t"; "u"]
  let%test "sel_ex" = t "SELECT EXISTS(SELECT * FROM u) FROM t" = ["t"; "u"]
end)
