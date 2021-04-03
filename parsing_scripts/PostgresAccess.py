import psycopg2


class PostgresAccess:
    def __init__(self):
        self.__connection = None

    def establish_connection(self, db, user, password, host, port):
        self.__connection = psycopg2.connect(
            database=db,
            user=user,
            password=password,
            host=host,
            port=port
        )

    def execute_sql_file(self, sql_path, params):
        if self.__connection is None:
            raise Exception("Unestablished Postgres Connection")
        sql = open(sql_path, "r").read()
        cursor = self.__connection.cursor()
        cursor.execute(sql, vars=params)
        self.__connection.commit()

    def close_connection(self):
        self.__connection.close()
