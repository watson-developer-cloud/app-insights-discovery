#include -utf-8-
import settings as Settings
import grab_top_apps as Grab
import extract_reviews as Extract
import json, tempfile
import sys, os, time, datetime

# Grab only the top 10 apps (out of 100) to ingest.
num_apps_to_ingest = 10

# Store apps grabbed in textfile to use later.
fname = "ingested_apps.txt"

# Check the file currently doesn't exist. Remove otherwise.
try:
    os.remove(fname)
except OSError:
    pass

total_start = time.time()

envmt_id = Settings.ENVIRONMENT_ID
collection_name = Settings.COLLECTION_NAME
collection_id = Settings.COLLECTION_ID

# Create documents and upload
def upload_review(review, collection_id):
    reviewTemp = tempfile.NamedTemporaryFile(delete = False, suffix='.json')

    review_id = "{\n\t\"review_id\": %d,\n" %int(float((review.get("review_id"))))
    app_name = "\t\"app_name\": %s,\n" %json.dumps(review["app_name"])
    version = "\t\"version\": %s,\n" %json.dumps(review["version"])
    updated = "\t\"updated\": %s,\n" %json.dumps(review["updated"])
    title = "\t\"title\": %s,\n" %json.dumps(review["title"])
    rating = "\t\"rating\": %d,\n" %int(float((review.get("rating"))))
    review = "\t\"review\": %s\n}" %json.dumps(review["review"])

    doc_contents = review_id + app_name + version + updated + title + rating + review
    reviewTemp.write(doc_contents)
    reviewTemp.flush()
    reviewTemp.seek(0)
    try:
        Settings.discovery.add_document(envmt_id, collection_id, reviewTemp)
    except:
        time.sleep(5)
        print "adding document caused error"
    reviewTemp.close()
    return

def ingest_review():
    print "Grabbing top apps..."
    top_apps_dict = Grab.grab_top_apps()
    top_apps = top_apps_dict["result"]

    count = 0

    apps_grabbed = []

    # Initialize file with empty list.
    for app in top_apps:
        # Grab only the top 'x' apps that contain reviews information for us to use.
        if count >= num_apps_to_ingest - 1:
            break
        app_name = app["title"]
        app_id = int(float(app.get('id')))

        print "Extracting reviews for app %s" %app["title"]
        start = time.time()
        reviews = Extract.extract_reviews(app_name, app_id)
        end = time.time()
        total_num_reviews = len(reviews[app_name])

        # Ingest reviews only if reviews exist.
        if total_num_reviews != 0:
            print "extraction complete, extraction of %d number of reviews took: %d seconds" %(total_num_reviews, end-start)
            start_collection_creation = time.time()
            num_review = 0
            for review in reviews[app_name]:
                # Create a document
                print "Uploading review %d out of %d." %(num_review, total_num_reviews)
                upload_review(review, collection_id)
                num_review += 1
            end_collection_creation = time.time()
            total_collection_time = end_collection_creation - start_collection_creation
            converted_time = datetime.timedelta(seconds=(total_collection_time))
            print "Collection of %d documents for %s took: %d seconds, which is %s in hh:mm:ss form, to create." %(total_num_reviews, app_name, total_collection_time, str(converted_time))
            print "######################### Uploaded app %d: %s ############################." %(count, app_name)
            count += 1
            apps_grabbed.append(app)

            # Create file to write ingested apps to.
            with open(fname, "w+") as f:
                f.write(json.dumps(apps_grabbed, ensure_ascii=False))

        else:
            print "No reviews found. Skipping app: %s" %app_name

    total_end = time.time()
    total_time = total_end - total_start
    print "This script ran for %s. Wowza." % str(datetime.timedelta(seconds=total_time))
    print "created collection: %s with collection id = %s" %(collection_name, collection_id)

# Call on function to begin ingesting reviews.
ingest_review()
