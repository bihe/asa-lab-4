import datetime
import json
import platform
import random
import string
import time
from getmac import get_mac_address as gma
from dapr.clients import DaprClient

PUBSUB_NAME = 'pubsub'
PUBSUB_TOPIC = 'notifications'
JSON_CTYPE = 'application/json'

# the message sent by our client
class Notification:
    def __init__(self, host, mac, value):
        self.host = host
        self.mac = mac
        tstmp = datetime.datetime.now(datetime.timezone.utc)
        self.timestamp = tstmp.isoformat()
        self.value = value

def get_random_string(length):
    res = ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))
    return str(res)


if __name__ == "__main__":
    msg = Notification(platform.node(), gma(), '')
    # we use the dapr client to "talk" with dapr
    # note: the client uses grpc for communication instead of the plain HTTP calls (@see agent-golang)
    d = DaprClient()

    while True:
        msg.value = get_random_string(16)
        tstmp = datetime.datetime.now(datetime.timezone.utc)
        msg.timestamp = tstmp.isoformat()

        # stringify our object
        payload = json.dumps(msg.__dict__)
        print(payload, flush=True)

        d.publish_event(pubsub_name=PUBSUB_NAME,
            topic_name=PUBSUB_TOPIC,
            data=payload,
            data_content_type=JSON_CTYPE # this is needed otherwise we end up with a string-representation which cannot be parsed by our dashboard
        )

        # wait randomly
        sleep_time = random.randint(1,10)
        print('sleep for %d seconds' % (sleep_time,), flush=True)
        time.sleep(sleep_time)
