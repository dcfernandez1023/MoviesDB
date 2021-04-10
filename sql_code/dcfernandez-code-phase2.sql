/*
 * These queries initialize the database and load it with data from the parsed CSV files that are
 * located in the root folder of this project under the 'db_files' directory. This .sql script is intended
 * to be called directly from the command line using the Postgres CLI. If you run this script, be sure to change
 * the paths to the CSV files below, as they are hard coded.
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
FROM 'C:\\Users\\Dominic\\DB-Project\\MoviesDB\\db_files\\movies_parsed.csv'
DELIMITER ',';

COPY Genres(title)
FROM 'C:\\Users\\Dominic\\DB-Project\\MoviesDB\\db_files\\genres_parsed.csv'
DELIMITER ',';


COPY Ratings(user_id, movie_id, rating, time_stamp)
FROM 'C:\\Users\\Dominic\\DB-Project\\MoviesDB\\db_files\\ratings_parsed.csv'
DELIMITER ',';

COPY Tags(user_id, movie_id, tag, time_stamp)
FROM 'C:\\Users\\Dominic\\DB-Project\\MoviesDB\\db_files\\tags_parsed.csv'
DELIMITER ',';

COPY Has_genre(movie_id, title)
FROM 'C:\\Users\\Dominic\\DB-Project\\MoviesDB\\db_files\\has_genre_parsed.csv'
DELIMITER ',';

INSERT INTO Users
SELECT R.user_id
FROM Ratings R
UNION
SELECT T.user_id
FROM Tags T

