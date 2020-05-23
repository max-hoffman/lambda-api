import json
import logging
import os
import psycopg2
import psycopg2.extras
import re
import random
import string

import api

DEFAULT_DB = os.getenv("DB_NAME", "test")
DEFAULT_SCHEMA = os.getenv("DB_SCHEMA", "schema_private")

def get_person(payload, person_id, context={}, schema=DEFAULT_SCHEMA, db=DEFAULT_DB):
    if len(person_id) < 1:
        raise api.BadRequestException("Missing id: {person_id}")

    select = ["id", "name", "email"]
    payload["id"] =  person_id

    query = f"""
        SELECT {", ".join(select)}
        FROM {schema}.person
        WHERE person.id = %(id)s
        """
    cursor = api.get_db_connection(db)
    cursor.execute(query, payload)
    res = [{r: getattr(row, r) for r in select} for row in cursor]

    if not res:
        raise api.BadRequestException("Id not found: {person_id}")

    return api.json_response(200, res)

def delete_person(payload, person_id, context={}, schema=DEFAULT_SCHEMA, db=DEFAULT_DB):
    if len(person_id) < 1:
        raise api.BadRequestException("Missing id: {person_id}")

    returning = ["id", "name", "email"]
    payload = {
        "id": person_id,
        "returning": ", ".join(returning),
        **payload
    }

    query = f"""
        DELETE FROM {schema}.person
        WHERE person.id = %(id)s
        RETURNING {", ".join(returning)}
        """
    cursor = api.get_db_connection(db)
    cursor.execute(query, payload)
    res = [{r: getattr(row, r) for r in returning} for row in cursor]

    if not res:
        raise api.BadRequestException("Id not found: {person_id}")

    return api.json_response(200, res)

def post_person(payload, context={}, schema=DEFAULT_SCHEMA, db=DEFAULT_DB):

    if not payload["email"] or not payload["name"]:
        raise api.BadRequestException("Missing fields: " + str(payload))

    if not api.is_email(payload["email"]):
        raise api.BadRequestException("bad email: " + payload["email"])

    query = f"""
        INSERT INTO {schema}.person (name, email)
        VALUES (%(name)s, %(email)s)
        ON CONFLICT (email) DO NOTHING
        RETURNING (id)
        """

    cursor = api.get_db_connection(db)
    cursor.execute(query, payload)
    res = [{r: getattr(row, r) for r in ["id"]} for row in cursor]

    if not res:
        raise api.DuplicateEmailException()
    else:
        # TODO: email person
        return api.json_response(200, res)
