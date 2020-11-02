open Sqlgg.Sql

let tables s =
  let rec aux {select = h, t; _} =
    h :: t |>
    List.map (function
      | {from = None; _} -> []
      | {from = Some p; _} ->
        let rec extract = function
          | `Select sf, _ -> aux sf
          | `Table t, _ -> [t]
          | `Nested (h, t), _ ->
            List.map extract (h :: List.map fst t) |>
            List.flatten
        in
        extract (`Nested p, None)
    ) |>
    List.flatten
  in
  match s with
  | Select sf -> None, aux sf
  | Create (name, `Select sf) -> Some name, aux sf
  | _ -> raise (Invalid_argument "tables")


let%test_module _ = (module struct
  let t sql =
    Sqlgg.Parser.parse_stmt sql |>
    tables |>
    snd |>
    List.map Sqlgg.Sql.show_table_name |>
    List.sort compare

  let%test "from_prod" = t "SELECT * FROM t, u" = ["t"; "u"]
  let%test "join" = t "SELECT * FROM t INNER JOIN u ON t.x = u.x" = ["t"; "u"]
  let%test "on_ex" = t "SELECT * FROM t INNER JOIN u ON EXISTS(SELECT * FROM v)" = ["t"; "u"; "v"]
  let%test "where_eq" = t "SELECT * FROM t WHERE x = (SELECT * FROM u)" = ["t"; "u"]
  let%test "where_in" = t "SELECT * FROM t WHERE x IN (SELECT * FROM u)" = ["t"; "u"]
  let%test "group_by_ex" = t "SELECT * FROM t GROUP BY EXISTS(SELECT * FROM u)" = ["t"; "u"]
  let%test "having_ex" = t "SELECT * FROM t GROUP BY x HAVING EXISTS(SELECT * FROM u)" = ["t"; "u"]
  let%test "order_by_ex" = t "SELECT * FROM t ORDER BY EXISTS(SELECT * FROM u)" = ["t"; "u"]
end)
