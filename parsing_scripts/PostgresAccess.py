import psycopg2


# provides access to postgres database
class PostgresAccess:
    def __init__(self):
        self.__connection = None

    # connects to postgres database given the database name, username, password, host, and port
    def establish_connection(self, db, user, password, host, port):
        self.__connection = psycopg2.connect(
            database=db,
            user=user,
            password=password,
            host=host,
            port=port
        )

    # executes a .sql file with params
    def execute_sql_file(self, sql_path, params):
        if self.__connection is None:
            raise Exception("Unestablished Postgres Connection")
        sql = open(sql_path, "r").read()
        cursor = self.__connection.cursor()
        cursor.execute(sql, vars=params)
        self.__connection.commit()

    # closes the connection to the database
    def close_connection(self):
        self.__connection.close()
