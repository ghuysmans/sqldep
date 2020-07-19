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
