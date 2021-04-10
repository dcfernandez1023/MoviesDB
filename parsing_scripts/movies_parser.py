# tokenizes a line in movies.txt into an array of tokens
# @param entry - a line in the movies.txt file
# @return array with tokens representing a line in the movies.txt file
def tokenize_movie_entry(entry):
    # need to parse 3 separate fields: id, title+year, genres
    start_delim = entry.find(":")
    end_delim = entry.rfind(":")
    if start_delim == -1 or end_delim == -1:
        return ["", "", ""]
    # parse id
    movie_id = ""
    i = 0
    while i < start_delim:
        if entry[i].isdigit():
            movie_id += entry[i]
        i += 1
    # parse title+year
    title_year = ""
    t = start_delim + 1
    while t < end_delim:
        title_year += entry[t]
        t += 1
    # parse genres
    genres = ""
    g = end_delim + 1
    while g < len(entry):
        genres += entry[g]
        g += 1
    return [movie_id.strip(), title_year.strip(), genres.strip()]


# parses the title and year
# (e.g. Avengers (2013) becomes [Avengers, 2013]
# @param title_and_year - the title and year string
# @return an array with the tokenized title and year
def parse_title_and_year(title_and_year):
    year_start = title_and_year.rfind("(")
    if year_start == -1:
        return ["", ""]
    t = 0
    y = year_start + 1
    title = ""
    year = ""
    # parse title
    while t < year_start:
        if title_and_year[t] != ",":
            title += title_and_year[t]
        t += 1
    while y < len(title_and_year):
        if title_and_year[y].isdigit():
            year += title_and_year[y]
        y += 1
    return [title.strip(), year.strip()]


# modifies by current_genres dict by reference
# returns a an array representing CSV entries for the has_genres table
def parse_genres(movie_id, genres_string, current_genres):
    has_genre_data = []
    tokens = genres_string.split("|")
    for token in tokens:
        csv = ""
        if token != "(no genres listed)":
            csv = movie_id + ","
            csv += token
        else:
            csv = movie_id + "," + ""
        has_genre_data.append(csv)
        current_genres.update({token: True})
    return has_genre_data


# opens movies file and parses it into a CSV file
# @param data_dir - the path to the directory that movies.txt is in
def movies_to_csv(data_dir):
    # open files
    movies_file = open(data_dir + "/movies.txt", "r", encoding='utf-8')
    movies_parsed = open("./db_files/movies_parsed.csv", "a", encoding='utf-8')
    genres_parsed = open("./db_files/genres_parsed.csv", "a", encoding='utf-8')
    has_genre_parsed = open("./db_files/has_genre_parsed.csv", "a", encoding='utf-8')
    # truncate files that we are going to append to
    movies_parsed.truncate(0)
    genres_parsed.truncate(0)
    has_genre_parsed.truncate(0)
    # initialize dictionary to keep track of genres
    genres = {}
    for line in movies_file:
        entry = line.strip("\n")
        # tokenize entry
        tokens = tokenize_movie_entry(entry)
        movie_id = tokens[0]
        # parse title+year
        title_and_year = parse_title_and_year(tokens[1])
        title = title_and_year[0]
        year = title_and_year[1]
        has_genre_data = parse_genres(movie_id, tokens[2], genres)
        movie = movie_id + "," + title + "," + year
        # write movie to file
        movies_parsed.write(movie + "\n")
        # write has_genre_data to file
        for data in has_genre_data:
            has_genre_parsed.write(data + "\n")
    # write genres to file
    for genre in genres.keys():
        if genre != "(no genres listed)":
            genres_parsed.write(genre + "\n")
    # close all opened files
    print("    --> Movies Parsed ✔")
    print("    --> Genres Parsed ✔")
    movies_file.close()
    movies_parsed.close()
    genres_parsed.close()
