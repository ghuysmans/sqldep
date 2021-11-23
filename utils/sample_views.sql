CREATE VIEW movies_per_director AS SELECT fullname AS director, count(*) AS movies
FROM director LEFT JOIN movie ON movie.director=director.id
GROUP BY fullname;

