class ClientException(Exception):
    def __init__(self, e):
        super().__init__()
        self.code = 400
        self.message = "Client exception {e}"

class ServerException(Exception):
    def __init__(self, e):
        super().__init__()
        self.message = "Server exception: {e}"
        self.code = 500

class InvalidPayLoadException(ServerException):
    def __init__(self, payload):
        super().__init__()
        self.message = f"Invalid payload: {payload}"

class DatabaseConnectionException(ServerException):
    def __init__(self, e):
        super().__init__(e)
        self.message = f"Failed to connect to database: {e}"
