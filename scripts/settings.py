from __future__ import print_function
# settings.py
import os
from os.path import join, dirname
from dotenv import load_dotenv
from watson_developer_cloud import DiscoveryV1

dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

DISCOVERY_VERSION = os.environ.get("DISCOVERY_VERSION")
DISCOVERY_USERNAME = os.environ.get("DISCOVERY_USERNAME")
DISCOVERY_PASSWORD = os.environ.get("DISCOVERY_PASSWORD")
COLLECTION_NAME = os.environ.get("COLLECTION_NAME")

CLOUDANT_USERNAME = os.environ.get("CLOUDANT_USERNAME")
CLOUDANT_PASSWORD = os.environ.get("CLOUDANT_PASSWORD")
DATABASE_NAME=os.environ.get("DATABASE_NAME")

discovery = DiscoveryV1(DISCOVERY_VERSION,
                        username=DISCOVERY_USERNAME,
                        password=DISCOVERY_PASSWORD)

# instantiate discovery service inside the ingest_reviews
def get_envmt_id():
    """ Grab the environment ID of the Discovery service
    """
    envmts = discovery.get_environments()
    reviews_envmt = [x for x in envmts['environments'] if
                     x['name'] == 'byod']
    envmt_id = reviews_envmt[0]['environment_id']
    return envmt_id

# Set the environment ID as global var to reuse.
ENVIRONMENT_ID = get_envmt_id()

def get_configuration_id():
    print("getting config id")
    configs = discovery.list_configurations(ENVIRONMENT_ID)
    review_config = [x for x in configs['configurations'] if
                     x['name'] == 'json_config']
    return review_config[0]['configuration_id']

def get_collection_id(name):
    print("getting collection id")
    config_id = get_configuration_id()
    collections = discovery.list_collections(ENVIRONMENT_ID)
    collection = [c for c in collections["collections"] if
                  c['name'] == name]
    if len(collection) == 0:
        print("creating collection")
        discovery.create_collection(ENVIRONMENT_ID, name, configuration_id=config_id)
        return get_collection_id(name)
    return collection[0]['collection_id']

COLLECTION_ID = get_collection_id(COLLECTION_NAME)
