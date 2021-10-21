/* A. General Queries */

	/* CREATE INDEXES TO SPEED UP QUERIES */
	DROP INDEX IF EXISTS movies_index;
	DROP INDEX IF EXISTS ratings_index;
	
	CREATE INDEX movies_index ON Movies(id);
	CREATE INDEX ratings_index ON Ratings(rating, movie_id);
	
	/* 1. Finds the most reviewed movie */
	EXPLAIN ANALYZE
	SELECT movie_id, title, COUNT(movie_id) 
	FROM Movies 
	JOIN Ratings on Ratings.movie_id = Movies.id
	GROUP BY movie_id, title 
	ORDER BY COUNT(movie_id) DESC
	LIMIT 1;
	/*
	 This query was on the slower side, so I used an index for it to try to speed it up 
	 
	 --BEFORE INDEX-- 
	 Planning Time: 1.480 ms
	 Execution Time: 6912.396 ms
	(15 rows)
	
	--AFTER INDEX-- 
	 Planning Time: 2.214 ms
	 Execution Time: 6819.378 ms
	(15 rows)
	*/

	/* 2. Finds the highest reviewed movie */
	SELECT movie_id, title, COUNT(movie_id) 
	FROM Movies 
	JOIN Ratings on Ratings.movie_id = Movies.id
	WHERE Ratings.rating = 5
	GROUP BY movie_id, title 
	ORDER BY COUNT(movie_id) DESC
	LIMIT 1;

	/* 3. Finds the number of movies associated with at least 4 different genres */
	SELECT COUNT(*) 
	FROM (
		SELECT COUNT(DISTINCT movie_id)
		FROM Has_genre 
		GROUP BY movie_id
		HAVING COUNT(movie_id) >= 4
	) AS four_diff_genres;

	/* 4. Finds the most popular genre across all movies */
	SELECT title, COUNT(title) 
	FROM has_genre 
	GROUP BY title
	ORDER BY COUNT(title) DESC
	LIMIT 1;

	/* 5a. Finds the genres associated with the best reviews */
	EXPLAIN ANALYZE
	SELECT title1 as genre, high, low
	FROM 
	(
		(
			SELECT title as title1, SUM(high) as high 
			FROM
			(
				SELECT DISTINCT(title), COUNT(rating) as high
				FROM Ratings 
				JOIN has_genre ON Ratings.movie_id = has_genre.movie_id
				WHERE Ratings.rating >= 4.0 and title != ''
				GROUP BY title, rating
			) as count_high
			GROUP BY title
		) as high_ratings

		INNER JOIN 

		(
			SELECT title as title2, SUM(low) as low 
			FROM 
			(
				SELECT DISTINCT(title), COUNT(rating) as low
				FROM Ratings 
				JOIN has_genre ON Ratings.movie_id = has_genre.movie_id
				WHERE Ratings.rating < 4 and title != ''
				GROUP BY title, rating
			) as count_low
			GROUP BY title
		) as low_ratings
		
		ON high_ratings.title1 = low_ratings.title2
	) as high_low_ratings
	WHERE high > low;

	/*5b. Finds the genres associated with the most recent movies */
	EXPLAIN ANALYZE
	SELECT high.title as genre, high.cnt as high, low.cnt as low
			FROM 
			(
				SELECT DISTINCT(has_genre.title), COUNT(year) cnt
				FROM Movies
				JOIN has_genre ON Movies.id = has_genre.movie_id 
				WHERE year >= 2000 and has_genre.title != ''
				GROUP BY has_genre.title 
			) as high
	 
	INNER JOIN (
				SELECT DISTINCT(has_genre.title), COUNT(year) cnt
				FROM Movies
				JOIN has_genre ON Movies.id = has_genre.movie_id 
				WHERE year < 2000 and has_genre.title != ''
				GROUP BY has_genre.title 
			) as low
		
		ON high.title = low.title
		WHERE high > low;

	/* 5c Create indexes on Ratings(rating) and Movies(year) */
	CREATE INDEX index ON Ratings(rating);
	EXPLAIN ANALYZE
	SELECT title1 as genre, high, low
	FROM 
	(
		(
			SELECT title as title1, SUM(high) as high 
			FROM
			(
				SELECT DISTINCT(title), COUNT(rating) as high
				FROM Ratings 
				JOIN has_genre ON Ratings.movie_id = has_genre.movie_id
				WHERE Ratings.rating >= 4.0 and title != ''
				GROUP BY title, rating
			) as count_high
			GROUP BY title
		) as high_ratings

		INNER JOIN 

		(
			SELECT title as title2, SUM(low) as low 
			FROM 
			(
				SELECT DISTINCT(title), COUNT(rating) as low
				FROM Ratings 
				JOIN has_genre ON Ratings.movie_id = has_genre.movie_id
				WHERE Ratings.rating < 4 and title != ''
				GROUP BY title, rating
			) as count_low
			GROUP BY title
		) as low_ratings
		
		ON high_ratings.title1 = low_ratings.title2
	) as high_low_ratings
	WHERE high > low;
	DROP INDEX index;
	/*
		Query 5a WITHOUT index:
		
		 Planning Time: 0.667 ms
		 Execution Time: 7056.759 ms
		(73 rows)
		
		Query 5a WITH index:
		
		 Planning Time: 1.562 ms
		 Execution Time: 6967.075 ms
		(73 rows)
		
	*/
	CREATE INDEX index on Movies(year);
	EXPLAIN ANALYZE
	SELECT high.title as genre, high.cnt as high, low.cnt as low
			FROM 
			(
				SELECT DISTINCT(has_genre.title), COUNT(year) cnt
				FROM Movies
				JOIN has_genre ON Movies.id = has_genre.movie_id 
				WHERE year >= 2000 and has_genre.title != ''
				GROUP BY has_genre.title 
			) as high
	 
	INNER JOIN (
				SELECT DISTINCT(has_genre.title), COUNT(year) cnt
				FROM Movies
				JOIN has_genre ON Movies.id = has_genre.movie_id 
				WHERE year < 2000 and has_genre.title != ''
				GROUP BY has_genre.title 
			) as low
		
		ON high.title = low.title
		WHERE high > low;
	DROP INDEX index;
	/*
		Query 5b WITHOUT index:
		
		 Planning Time: 0.492 ms
		 Execution Time: 22.187 ms
		(44 rows)
		
		Query 5b WITH index:
		
		 Planning Time: 1.801 ms
		 Execution Time: 22.372 ms
		(46 rows)
		
	*/

/* B. De-bias the Ratings of Users */

	/* 1. Find Difference Between User's Ratings and Average Rating of each Movie Rated by the User */
	CREATE TABLE IF NOT EXISTS ratings_with_diff (
		user_id Integer,
		movie_id Integer,
		rating decimal,
		time_stamp bigint,
		avg_rating decimal,
		difference decimal,
		PRIMARY KEY (user_id, movie_id)
	);
	DELETE FROM ratings_with_diff;
	INSERT INTO ratings_with_diff 
	SELECT ratings_diff.user_id, ratings_diff.movie_id, ratings_diff.rating, ratings_diff.time_stamp, ratings_diff.average, (ratings_diff.rating - ratings_diff.average) as diff 
	FROM 
	(
		(
			SELECT * 
			FROM Ratings 
		) as all_ratings 
		
		INNER JOIN 
		
		(
			SELECT movie_id as movie_id2, AVG(rating) as average
			FROM Ratings 
			GROUP BY movie_id2
		) as averages 
		
		ON all_ratings.movie_id = averages.movie_id2
		
	) as ratings_diff;

	/* 2. Update rating of users whose rating difference (absolute value) is greater than 3 */
	UPDATE ratings_with_diff rwd
	SET rating = rwd.avg_rating, time_stamp = (SELECT FLOOR(EXTRACT(epoch FROM NOW())*1000))
	WHERE ABS(rwd.difference) > 3;

	/* Personal query to see that all of the biased user ratings were actually updated */
	SELECT *
	FROM 
	(
		(
			SELECT user_id as user_rated, movie_id, rating as original_rating, time_stamp as original_time_stamp
			FROM Ratings 
		) as r
		
		INNER JOIN 
		
		(
			SELECT user_id, movie_id, rating as new_rating, time_stamp as new_time_stamp
			FROM ratings_with_diff
		) as rwd
		
		ON r.user_rated = rwd.user_id AND r.movie_id = rwd.movie_id AND r.original_rating != rwd.new_rating 
	) as results
	ORDER BY results.user_rated ASC
	LIMIT 20;

	/* 3. Find the new difference between a user's rating and the average rating of the movie he/she has rated */
	CREATE TABLE IF NOT EXISTS ratings_with_diff2 (
		user_id Integer,
		movie_id Integer,
		rating decimal,
		time_stamp bigint,
		avg_rating decimal,
		difference decimal,
		PRIMARY KEY (user_id, movie_id)
	);
	DELETE FROM ratings_with_diff2;
	INSERT INTO ratings_with_diff2
	SELECT ratings_diff.user_id, ratings_diff.movie_id, ratings_diff.rating, ratings_diff.time_stamp, ratings_diff.average, (ratings_diff.rating - ratings_diff.average) as diff 
	FROM 
	(
		(
			SELECT user_id, movie_id, rating, time_stamp 
			FROM ratings_with_diff  
		) as all_ratings 
		
		INNER JOIN 
		
		(
			SELECT movie_id as movie_id2, AVG(rating) as average
			FROM ratings_with_diff 
			GROUP BY movie_id2
		) as averages 
		
		ON all_ratings.movie_id = averages.movie_id2
		
	) as ratings_diff;

	/* 4. Update the rating of users whose ratin difference (absolute value) is greater than 3 for the new table, ratings_with_diff2 */
	UPDATE ratings_with_diff2 rwd2
	SET rating = rwd2.avg_rating, time_stamp = (SELECT FLOOR(EXTRACT(epoch FROM NOW())*1000))
	WHERE ABS(rwd2.difference) > 3;

	/* 
		* Repeating the process.  NOTE: I wanted to update the original table instead of creating new tables, but my update 
		* query took too long and would never finish, so  I just created new tables instead.
	*/

	CREATE TABLE IF NOT EXISTS ratings_with_diff3 (
		user_id Integer,
		movie_id Integer,
		rating decimal,
		time_stamp bigint,
		avg_rating decimal,
		difference decimal,
		PRIMARY KEY (user_id, movie_id)
	);
	DELETE FROM ratings_with_diff3;
	INSERT INTO ratings_with_diff3
	SELECT ratings_diff.user_id, ratings_diff.movie_id, ratings_diff.rating, ratings_diff.time_stamp, ratings_diff.average, (ratings_diff.rating - ratings_diff.average) as diff 
	FROM 
	(
		(
			SELECT user_id, movie_id, rating, time_stamp 
			FROM ratings_with_diff2
		) as all_ratings 
		
		INNER JOIN 
		
		(
			SELECT movie_id as movie_id2, AVG(rating) as average
			FROM ratings_with_diff2 
			GROUP BY movie_id2
		) as averages 
		
		ON all_ratings.movie_id = averages.movie_id2
		
	) as ratings_diff;

	UPDATE ratings_with_diff3 rwd3
	SET rating = rwd3.avg_rating, time_stamp = (SELECT FLOOR(EXTRACT(epoch FROM NOW())*1000))
	WHERE ABS(rwd3.difference) > 3;


	/* 5. List top 10 movies with biggest difference in ratings (pre-de-biasing vs. post-de-biasing) */

	SELECT top_ten_biased_movies.title, top_ten_biased_movies.movie_id, top_ten_biased_movies.original_avg_rating, top_ten_biased_movies.debiased_avg_rating, top_ten_biased_movies.bias
	FROM 
	(
		(
			SELECT final_results.movie_id1 as movie_id, final_results.original_avg_rating, final_results.debiased_avg_rating, (final_results.debiased_avg_rating - final_results.original_avg_rating) as bias 
			FROM 
			(
				(
					SELECT movie_id as movie_id1, AVG(rating) as original_avg_rating 
					FROM Ratings 
					GROUP BY movie_id1
				) as original_ratings
				
				INNER JOIN 
				
				(
					SELECT movie_id as movie_id2, avg_rating as debiased_avg_rating 
					FROM ratings_with_diff3
					GROUP BY movie_id2, avg_rating
				) as debiased_ratings 
				
				ON original_ratings.movie_id1 = debiased_ratings.movie_id2
				
			) as final_results
		) as bias_info
		
		INNER JOIN 
		
		(
			SELECT id as movie_id3, title 
			FROM Movies 
		) as movie_titles
		
		ON bias_info.movie_id = movie_titles.movie_id3
	) as top_ten_biased_movies

	ORDER BY bias DESC
	LIMIT 10;
















