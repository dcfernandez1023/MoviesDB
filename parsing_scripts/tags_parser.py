# tokenizes a line in the tag file into an array of tokens
# @param entry - a line in the tag file
# @return array of tokens ( e.g. [user_id, movie_id, tag, timestamp] )
def tokenize_tag(entry):
    # need to parse 4 separate fields: user_id, movie_id, tag, timestamp
    # since there are 4 fields, we should be expecting 3 delimiters

    # index of the last delimiter
    last_delim = entry.rfind(":")
    if last_delim == -1:
        return ["", "", "", ""]
    # variable to keep track of current index
    curr = 0
    tokens = []
    # parse user_id
    user_id = ""
    while curr < len(entry) and entry[curr] != ":":
        if entry[curr].isdigit():
            user_id += entry[curr]
        curr += 1
    curr += 1
    tokens.append(user_id)
    # parse movie_id
    movie_id = ""
    while curr < len(entry) and entry[curr] != ":":
        if entry[curr].isdigit():
            movie_id += entry[curr]
        curr += 1
    curr += 1
    tokens.append(movie_id)
    # parse user-defined tag
    tag = ""
    while curr < last_delim:
        tag += entry[curr]
        curr += 1
    curr += 1
    tokens.append(tag)
    # parse timestamp
    timestamp = ""
    while curr < len(entry):
        timestamp += entry[curr]
        curr += 1
    tokens.append(timestamp)
    return [user_id, movie_id, tag, timestamp]


# opens and parses the tags file into a CSV file
# @param data_dir - the path to the directory the tags.txt file is in
def tags_to_csv(data_dir):
    tags_file = open(data_dir + "/tags.txt", "r", encoding='utf-8')
    tags_parsed = open("./db_files/tags_parsed.csv", "a", encoding='utf-8')
    tags_parsed.truncate(0)
    for line in tags_file:
        csv = ""
        entry = line.strip("\n")
        tokens = tokenize_tag(entry)
        for i in range(len(tokens)):
            if i == len(tokens) - 1:
                csv += tokens[i] + "\n"
            else:
                csv += tokens[i] + ","
        tags_parsed.write(csv)
    print("    --> Tags parsed ✔")
    tags_file.close()
    tags_parsed.close()
