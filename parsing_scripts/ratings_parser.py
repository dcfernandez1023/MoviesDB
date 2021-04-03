def ratings_to_csv(data_dir):
    ratings_file = open(data_dir + "/ratings.txt", "r", encoding='utf-8')
    ratings_parsed = open("./db_files/ratings_parsed.csv", "a", encoding='utf-8')
    ratings_parsed.truncate(0)
    for line in ratings_file:
        csv = ""
        rating = line.strip("\n")
        tokens = rating.split(":")
        for i in range(len(tokens)):
            if i == len(tokens) - 1:
                csv += tokens[i] + "\n"
            else:
                csv += tokens[i] + ","
        ratings_parsed.write(csv)
    print("    --> Ratings parsed ✔")
    ratings_file.close()
    ratings_parsed.close()
