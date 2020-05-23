import datetime
import logging
import os
import re

import psycopg2
import psycopg2.extras

import api

cursor = None

def get_db_connection(db="quarantoned"):
    global cursor
    if not cursor:
        try:
            logging.info("connecting to {db}")
            conn = psycopg2.connect(
                dbname=os.getenv("DB_NAME", db),
                user=os.getenv("DB_USERNAME", "postgres"),
                password=os.getenv("DB_PASSWORD", "test"),
                host=os.getenv("DB_ENDPOINT", ""),
                port=os.getenv("DB_PORT", 5432))

            cursor = conn.cursor(cursor_factory=psycopg2.extras.NamedTupleCursor)
        except Exception as e:
            raise api.DatabaseConnectionException(e)
    return cursor

def gen_token(length=16):
    lettersAndDigits = string.ascii_lowercase + string.digits
    return ''.join(random.choice(lettersAndDigits) for i in range(length))

def is_name(val):
    return re.search("^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$", val)

def is_email(val):
    return re.search("^[\w!#$%&'*+/=?^_`{}~-]+@[\w\-]+(\.[\w\-]+)+$", val)

def is_token(val):
    return re.search("^[a-z0-9]*$", val)

def is_videocall_link(val):
    return re.search("^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$", val)

def is_fmt_ts(val, fmt):
    try:
        datetime.datetime.strptime(val, fmt)
    except:
        return False
    return True

def only_created(id, items):
    created_items = []
    for item in items:
        if item["created"]:
            created_items.append(items[id])
        else:
            created_items.remove(items[id])
    return created_items
