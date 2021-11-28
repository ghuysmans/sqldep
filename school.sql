CREATE TABLE class(
  class VARCHAR(5) NOT NULL,
  PRIMARY KEY (class),
);

CREATE TABLE student(
  lastname VARCHAR(32),
  firstname VARCHAR(32),
  class VARCHAR(5) NOT NULL,
  PRIMARY KEY (lastname, firstname),
  FOREIGN KEY (class) REFERENCES class(class)
);
