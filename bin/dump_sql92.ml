let tables = {sql|
  SELECT @string{TABLE_NAME}
  FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = %string{schema}
|sql}

let views = {sql|
  SELECT @string{TABLE_NAME}, @string{VIEW_DEFINITION}
  FROM information_schema.VIEWS
  WHERE TABLE_SCHEMA = %string{schema}
|sql}
