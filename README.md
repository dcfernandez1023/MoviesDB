# MoviesDB Project 
**Author**: Dominic Fernandez  
**Course**: CS 333 - Intro to Database Systems

# Overview
The goal of this project is to implement and load a relational database with a large data set coming from the 
online movie recommender, MovieLens. This project contains all the necessary scripts and SQL code to 
parse and load a Postgres database with the data supplied from MovieLens. 

# Installation
To get started running this project, follow the steps below:

- Clone this repository locally on your computer  
    `git clone https://github.com/dcfernandez1023/MoviesDB.git`


- Create python virtual environment (venv) in the root folder of the project  
    `python -m venv <path-to-venv>`
  

- Navigate to directory containing the `activate` file (usually in Scripts directory)  
    `cd /venv/<path-to-activate-file>`  
  

- Activate virtual environment  
    `activate`
  

- Navigate back to root folder and install required modules  
    `pip install -r requirements.txt`
  

- If you don't have Postgres installed, install it here: https://www.postgresql.org/download/
  

- Set environment variables `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`on your OS to connect to Postgres

# Usage

You have two options to run this project and load the database. You can either parse the .txt files independently and then 
load the resulting .csv files manually through the Postgres CLI, or you can parse and load the database all at once through python.

### Option 1: Parsing and Loading the Database Manually
- From the root folder of the project, run `python parser.py <path-to-db-files>`, where `<path-to-db-files>` is the _absolute path_ to the directory where your database .txt files are.


- If successful, the .csv files should appear in the `db_files` directory, and the prompt should display as follows below:

        # Parsing movie data...
        --> Movies Parsed ✔
        --> Genres Parsed ✔
        --> Ratings parsed ✔
        --> Tags parsed ✔
        Successfully parsed data ✔
        
        ----- Finished in 27 seconds -----

- Now, open up a terminal and `cd` to the `sql_code` directory in the root folder of the project. Open up `dcfernandez-code-phase2.sql`
and make sure the hard coded paths to the .csv files are correct. 


- Run `psql -U postgres -d moviesdb -a -f dcfernandez-code-phase2.sql`. 
  

- If you don't want the output to print to the terminal, you can redirect it to a file like so: 

    `psql -U postgres -d moviesdb -a -f dcfernandez-code-phase2.sql > <name-of-file>`

### Option 2: Parsing and Loading the Database with Python
- From the root folder of the project, run `python driver.py <path-to-db-files>`, where `<path-to-db-files>` is the _absolute path_ to the directory where your database .txt files are.

- If successful, the .csv files should appear in the `db_files` directory, and the database tables will be loaded 
with the expected data. The prompt below indicates a successful execution:

        # Parsing movie data...
            --> Movies Parsed ✔
            --> Genres Parsed ✔
            --> Ratings parsed ✔
            --> Tags parsed ✔
        # Loading data into Postgres...
        # Successfully loaded database ✔
        
        ----- Finished in 71 seconds -----

### Errors
If something goes wrong, the error should look something like this:  

    # Parsing movie data...
    --> Movies Parsed ✔
    --> Genres Parsed ✔
    --> Ratings parsed ✔
    --> Tags parsed ✔
    # Loading data into Postgres...
    
    --------------------------ERROR--------------------------
    Traceback (most recent call last):
    File "C:/Users/Dominic/DB-Project/MoviesDB/driver.py", line 26, in main
    "localhost", "5432"
    File "C:\Users\Dominic\DB-Project\MoviesDB\parsing_scripts\PostgresAccess.py", line 14, in establish_connection
    port=port
    File "C:\Users\Dominic\DB-Project\MoviesDB\venv\lib\site-packages\psycopg2\__init__.py", line 127, in connect
    conn = _connect(dsn, connection_factory=connection_factory, **kwasync)
    psycopg2.OperationalError: fe_sendauth: no password supplied
    ---------------------------------------------------------

An error you may come across (especially if you are a Windows user) is invalid permissions for Postgres to read the .csv files, as
shown here:

    --------------------------ERROR--------------------------
    Traceback (most recent call last):
    File "driver.py", line 42, in main
    "tags_csv": os.getcwd() + "\\db_files\\ratings_parsed.csv"
    File "C:\Users\Dominic\db-test\MoviesDB\parsing_scripts\PostgresAccess.py", line 22, in execute_sql_file
    cursor.execute(sql, vars=params)
    psycopg2.errors.InsufficientPrivilege: could not open file "C:\Users\Dominic\db-test\MoviesDB\db_files\movies_parsed.csv" for reading: Permission denied
    HINT:  COPY FROM instructs the PostgreSQL server process to read a file. You may want a client-side facility such as psql's \copy.
    ---------------------------------------------------------

Postgres may have insufficient privileges to read files on your computer, so to get around this you must navigate
to the directory where these .csv files are located and change the permissions on the file to be readable/writable by everyone.
The path to the .csv files relative to the root folder of the project is `./db_files`.

# In-depth Description
### Project Structure
    
    - driver.py
    - parser.py
    - db_files
    - parsing_scripts
        - movies_parser.py
        - ratings_parser.py
        - tags_parser.py
        - PostgresAccess.py
    - sql_code 
        - init_db.sql
        - dcfernandez-code-phase2.sql
    - requirements.txt
    - venv

(NOTE: The `db_files` directory is initially empty since the .txt files are too large to push to Github. You have to supply the absolute path 
to the directory where those .txt files are as a command line argument)

### Description of Files

- `driver.py` is the driver code/entry point of the project. It runs the parsing scripts and loads the database. 


- `parser.py` is used if you want to parse and load the database manually (as described in the Usage section above).


- The python scripts in the `parsing_scripts` directory are used to parse their respective .txt files and parse them into .csv files, which will be later on 
loaded into the database.  


- The files in `db_files` will be where the .csv files are written to after parsing.  


- In the `sql_code` directory, `init_db.sql` are the SQL queries used by the `psycopg2` module to initialize and load the database. `init_db.sql` file is intended to be called by python only. If you want to initialize the database directly from the command line, 
then you can run the `dcfernandez-code-phase2.sql` file directly from the Postgres CLI, but be sure to change the paths to the .csv files, as they are hard coded in `dcfernandez-code-phase2.sql`.

### How the Project Works
_If you used python to both parse the .txt files and load the database, this describes how the code works for that._

This project loads the data into the database in two main steps: parsing and querying.  When `driver.py` 
is run, each script in the `parsing_scripts` directory is called to read their respective .txt files
and parse them into the .csv files that will be loaded into the database.  

After the .csv files are created, `driver.py` then instantiates a `PostgresAccess` object (which is a wrapper class to facilitate connecting to Postgres) and establishes a connection to Postgres using the `psycopg2` module.
The credentials it uses to connect to Postgres are received from the two environment variables, `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`, which were set up 
during the installation. 

Upon successfully connecting to the database, the instantiated `PostgresAccess` object executes the predefined SQL code from 
`init_db.sql`, which contains all the queries necessary to create the tables and load them with the data from 
the .csv files. The paths to each of these .csv files are dynamically determined based on your cwd and passed in as parameters 
to `init_db.sql` through the use of `psycopg2`.  

Inside of `init_db.sql`, the first half of the file creates the tables for the database along with their primary keys.
In the second half of the file, the tables are populated with the data from the .csv files using the `COPY` command. Here's an example, where 
`%(movies_csv)s` is a parameter representing the path of the .csv file for the Movies table and is passed using `psycopg2`, which essentially reads 
the SQL file as a string and sends it as STDIN to Postgres to execute:

    COPY Movies(id, title, year)
    FROM %(movies_csv)s
    DELIMITER ',';

After Postgres finishes its execution (takes around 50 sec.), then the connection to Postgres is closed and 
`driver.py` terminates.  