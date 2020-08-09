let tables = {sql|
  SELECT @string{name}
  FROM sqlite_master
  WHERE type = 'table'
|sql}

let views = {sql|
  SELECT @string{name}, @string{sql}
  FROM sqlite_master
  WHERE type = 'view'
|sql}
