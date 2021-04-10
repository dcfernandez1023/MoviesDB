/*
 * These queries initialize the database and load it with data from the parsed CSV files that are
 * located in the root folder of this project under the 'db_files' directory. This file is expecting
 * to be called by the cursor.execute() method of the psycopg2 library and is also expecting parameters
 * pointing to the path of the CSV files to be read. This .sql script is intended to be called within
 * this python project through the use of the psycopg2 module.
*/

/*** INITIALIZE TABLES ***/

DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Genres;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Ratings;
DROP TABLE IF EXISTS Tags;
DROP TABLE IF EXISTS Has_genre;

SET CLIENT_ENCODING TO 'utf8';

/* entity sets */
CREATE TABLE Movies(
    id Integer PRIMARY KEY,
    title varchar,
    year Integer
);

CREATE TABLE Genres(
    title varchar PRIMARY KEY
);
CREATE TABLE Users(
    id Integer PRIMARY KEY
);

/*relationship sets */
CREATE TABLE Ratings(
    user_id Integer,
    movie_id Integer,
    rating decimal,
    time_stamp bigint,
    PRIMARY KEY (user_id, movie_id)
);
CREATE TABLE Tags(
    user_id Integer,
    movie_id Integer,
    tag varchar,
    time_stamp bigint
);
CREATE TABLE Has_genre(
    movie_id Integer,
    title varchar,
    PRIMARY KEY (movie_id, title)
);

/*** LOAD DATA ***/

COPY Movies(id, title, year)
FROM %(movies_csv)s
DELIMITER ',';

COPY Genres(title)
FROM %(genres_csv)s
DELIMITER ',';


COPY Ratings(user_id, movie_id, rating, time_stamp)
FROM %(ratings_csv)s
DELIMITER ',';

COPY Tags(user_id, movie_id, tag, time_stamp)
FROM %(tags_csv)s
DELIMITER ',';

COPY Has_genre(movie_id, title)
FROM %(has_genre_csv)s
DELIMITER ',';

INSERT INTO Users
SELECT R.user_id
FROM Ratings R
UNION
SELECT T.user_id
FROM Tags T

