import logging
import os

import quarantoned as qt

logging.basicConfig(
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%m/%d/%Y %I:%M:%S %p",
    level=logging.DEBUG)

logger = logging.getLogger(__name__)

def main(event, context):
    path = event.get("path", None)
    method = event.get("httpMethod", None)

    logger.info(path, method)

    try:
        base, rest = os.path.split(path)
        payload = event.get("stageVariables", {})

        if not path:
            raise qt.NoPathSpecifiedException()
        elif base == "/person" and method == "POST":
            return post_person(event, context=context)
        elif base == "/person" and method == "DELETE":
            return delete_person(event, tail, context=context)
        elif base == "/person" and method == "GET":
            return get_person(event, tail, context=context)
        else:
            raise qt.NotFoundException(path, method)
    except qt.ClientException as e:
        logging.error(e)
        return qt.error_response(e)
    except Exception as e:
        logging.critical(e)
        return qt.error_response(qt.ServerException(e))
