from parsing_scripts import tags_parser, movies_parser, ratings_parser, PostgresAccess
import time
import traceback
import os
import sys


# driver code to parse csv files that will be loaded into the database
# and then load it into the database
def main():
    try:
        if len(sys.argv) != 2:
            print("Usage: python driver.py <absolute-path-to-db-file-directory>")
            exit(1)

        data_dir = sys.argv[1]
        start = time.time()

        print("# Parsing movie data...")
        # parse the .txt files into .csv files
        movies_parser.movies_to_csv(data_dir)
        ratings_parser.ratings_to_csv(data_dir)
        tags_parser.tags_to_csv(data_dir)

        print("# Loading data into Postgres...")
        # load .csv files into postgres
        postgres = PostgresAccess.PostgresAccess()
        postgres.establish_connection(
            "moviesdb",
            os.getenv("POSTGRES_USERNAME"),
            os.getenv("POSTGRES_PASSWORD"),
            "localhost", "5432"
        )
        # execute sql code
        postgres.execute_sql_file(
            "./sql_code/init_db.sql",
            {
                "genres_csv": os.getcwd() + "\\db_files\\genres_parsed.csv",
                "has_genre_csv": os.getcwd() + "\\db_files\\has_genre_parsed.csv",
                "movies_csv": os.getcwd() + "\\db_files\\movies_parsed.csv",
                "ratings_csv": os.getcwd() + "\\db_files\\ratings_parsed.csv",
                "tags_csv": os.getcwd() + "\\db_files\\tags_parsed.csv"
            }
        )
        postgres.close_connection()
        print("# Successfully loaded database ✔")

        duration = round(time.time() - start)
        print("\n----- Finished in " + str(duration) + " seconds -----")
    except Exception:
        tb = traceback.format_exc()
        print("\n--------------------------ERROR--------------------------")
        print(tb.strip("\n"))
        print("---------------------------------------------------------")


main()
