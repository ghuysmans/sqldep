CREATE TABLE paper(
  paper INT PRIMARY KEY,
  iso VARCHAR(2)
);

CREATE TABLE service(
  guid BINARY(16) PRIMARY KEY,
  type ENUM("print", "copy") NOT NULL,
  paper INT NOT NULL,
  color BOOLEAN NOT NULL,
  user VARCHAR(32),
  printer VARCHAR(32) NOT NULL,
  cost_center VARCHAR(64),
  n INT NOT NULL,
  start DATETIME NOT NULL,
  FOREIGN KEY (paper) REFERENCES paper(paper)
);

CREATE VIEW per_user AS
SELECT s.user, iso, COUNT(*)
FROM service s
INNER JOIN paper p ON p.paper=s.paper
GROUP BY s.user, s.paper;

CREATE VIEW per_class AS
SELECT s.cost_center, iso, COUNT(*)
FROM service s
INNER JOIN paper p ON p.paper=s.paper
INNER JOIN school.class c ON c.class=s.cost_center
GROUP BY s.cost_center, s.paper;
