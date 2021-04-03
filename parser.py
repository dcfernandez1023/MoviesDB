from parsing_scripts import tags_parser, movies_parser, ratings_parser, PostgresAccess
import time
import traceback
import sys


# driver code to prepare csv files that will be
# loaded into the database
def main():
    try:
        if len(sys.argv) != 2:
            print("\nUsage: python driver.py <absolute-path-to-db-file-directory>")
            exit(1)

        data_dir = sys.argv[1]
        start = time.time()

        print("# Parsing movie data...")
        # parse the .txt files into .csv files
        movies_parser.movies_to_csv(data_dir)
        ratings_parser.ratings_to_csv(data_dir)
        tags_parser.tags_to_csv(data_dir)
        print("Successfully parsed data ✔")

        duration = round(time.time() - start)
        print("\n----- Finished in " + str(duration) + " seconds -----")
    except Exception:
        tb = traceback.format_exc()
        print("\n--------------------------ERROR--------------------------")
        print(tb.strip("\n"))
        print("---------------------------------------------------------")


main()
