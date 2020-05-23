import json
import os
import sys
import unittest

import quarantoned as qt

current_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)))

class TestLambda(unittest.TestCase):
    def setUp(self):
        with open(os.path.join(current_dir, "data", "proxy_event.json")) as f:
            self.test_event = json.load(f)
        with open(os.path.join(current_dir, "data", "person_event.json")) as f:
            self.person_event = json.load(f)
        with open(os.path.join(current_dir, "data", "event_event.json")) as f:
            self.event_event = json.load(f)
        self.test_schema = "quarantoned_private"

    def tearDown(self):
        pass

    def test_person(self):
        res = qt.post_person(self.person_event, {}, schema=self.test_schema)
        print("post", res["body"])
        person_id = res["body"][0]["id"]
        res = qt.get_person(self.person_event, person_id, {}, schema=self.test_schema)
        print("get", res["body"])
        res = qt.delete_person(self.person_event, person_id, {}, schema=self.test_schema)
        print("delete", res["body"])
        self.assertEqual(res["statusCode"], 200)

    def test_event(self):
        res = qt.post_event(self.event_event, {}, schema=self.test_schema)
        print("post", res["body"])
        event_id = res["body"][0]["id"]
        res = qt.get_event(self.event_event, event_id, {}, schema=self.test_schema)
        print("get", res["body"])
        res = qt.delete_event(self.event_event, event_id, {}, schema=self.test_schema)
        print("delete", res["body"])
        self.assertEqual(res["statusCode"], 200)
