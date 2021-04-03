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
  

- Set environment variables `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`on your OS to connect to Postgres

# Usage
From the root folder of the project, run  

`python driver.py <path-to-db-files>`  

where `<path-to-db-files>` is the _absolute path_ to the directory where your database .txt files are.

If successful, this should be the result:

    # Parsing movie data...
    --> Movies Parsed ✔
    --> Genres Parsed ✔
    --> Ratings parsed ✔
    --> Tags parsed ✔
    # Loading data into Postgres...
    # Successfully loaded database ✔

    ----- Finished in 93 seconds -----

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

# In-depth Description
The default structure of this project from the root folder is as follows:
    
    - driver.py
    - db_files
    - parsing_scripts
        - movies_parser.py
        - ratings_parser.py
        - tags_parser.py
        - PostgresAccess.py
    - sql_code 
        - dcfernandez-code-phase2.sql
    - requirements.txt
    - venv

(NOTE: The `db_files` directory is initially empty since the .txt files are too large to push to Github. You have to supply the absolute path 
to the directory where those .txt files are as a command line argument)

This project loads the data into the database in two main steps: parsing and querying.  When `driver.py` 
is run, each script in the `parsing_scripts` directory is called to read their respective .txt files
and parse them into the .csv files that will be loaded into the database.  

After the .csv files are created, `driver.py` then instantiates a `PostgresAccess` object (which is a wrapper class to facilitate connecting to Postgres) and establishes a connection to Postgres using the `psycopg2` module.
The credentials it uses to connect to Postgres are received from the two environment variables, `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`, which were set up 
during the installation. 

Upon successfully connecting to the database, the instantiated PostgresAccess object executes the predefined SQL code from 
`dcfernandez-code-phase2.sql`, which contains all the queries necessary to create the tables and load them with the data from 
the .csv files. The paths to each of these .csv files are dynamically determined based on your cwd and passed in as parameters 
to `dcfernandez-code-phase2.sql` through the use of `psycopg2`.  

Inside of `dcfernandez-code-phase2.sql`, the first half of the file creates the tables for the database along with their primary keys.
In the second half of the file, the tables are populated with the data from the .csv files using the `COPY` command. Here's an example, where 
`%(movies_csv)s` is a parameter representing the path of the .csv file for the Movies table and is passed using `psycopg2`, which essentially reads 
the SQL file as a string and sends it as STDIN to Postgres to execute.

    COPY Movies(id, title, year)
    FROM %(movies_csv)s
    DELIMITER ',';

After the SQL code finishes its execution (takes around 60 sec.), then the connection to Postgres is closed and 
`driver.py` terminates.  