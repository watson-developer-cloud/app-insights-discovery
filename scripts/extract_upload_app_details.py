from bs4 import BeautifulSoup
import string, os, json, time, requests
import settings as Settings
from cloudant import cloudant
from cloudant.document import Document

# Grab environment and collection IDs from ingest_reviews file
environment_id = Settings.ENVIRONMENT_ID
collection_id = Settings.COLLECTION_ID
filename = "ingested_apps.txt"

def to_ascii(text):
    printable = set(string.printable)
    return filter(lambda x: x in printable, text)

def clean_description(text):
    """ Remove all non printable, non-ascii characters from description. Returns
    unicode to remove NavigableString reference to parse tree.
    """
    printable = set(string.printable)
    t = filter(lambda x: x in printable, text)

    # If no text is in ascii, return.
    if not t:
        return t
    # Remove extra spaces at the beginning
    t.lstrip()

    # Add punctuation at the end.
    if t[-1] not in string.punctuation:
        t += ". "
    return t

def find_description(soup):
    """ Find the description item property within the given html using soup. Returns
    unicode to remove NavigableString reference to parse tree.
    """
    description = ""
    for p in soup.find_all("p"):
        if p.get('itemprop') == "description":
            description_contents = [clean_description(content) for content in p.contents if content.find("br")]
            description += "".join(description_contents)
    return unicode(description)

def find_image(soup):
    """ Find the image URL of the app with Beautiful Soup. Returns
    unicode to remove NavigableString reference to parse tree.
    """
    for meta in soup.find_all("meta"):
        if meta.get('name') == "twitter:image":
            return unicode(meta.get('content'))

def extract_rating(text):
    """ Extract rating and number of reviews from the text grabbed. Converts
    rating into a double and number of reviews into an int. No error messages are
    added. This probably needs to be changed to include error checking.
    Returns (float, int)
    """
    # Split the text into an array where first elem is rating, second elem is
    # number of reviews.
    info = text.split(",")
    rating, num_reviews = None, None
    for i in info:
        # Get rid of white space at beginning and split text into array of words
        # contained in the sentence.
        x = i.lstrip().split()
        if "stars" in i:
            rating = x[0]
            # Replace 'and a half' with .5
            if "and a half" in i:
                rating += ".5"
            rating = float(rating)
        elif "Ratings" in i:
            num_reviews = int(x[0])
    return (rating, num_reviews)

def find_rating_and_num_reviews(soup):
    """ Find overall rating for the app and number of reviews. Returns
    extract_rating
    """
    grab_rating = False
    for div in soup.find_all("div", class_="extra-list customer-ratings"):
        for content in div.contents:
            # Find All Versions div.
            if "All Versions:" in unicode(content):
                # print content
                grab_rating = True
            if grab_rating and "Ratings" in unicode(content):
                # Make into tree again once we grab the html bit containing reviews.
                rating_soup = BeautifulSoup(unicode(content), 'html.parser')
                for div in rating_soup.find_all("div"):
                    rating_label = div.get('aria-label')
                    return extract_rating(unicode(rating_label))
                grab_rating = False
    return "Shouldn't be reached."

def find_category(soup):
    """ Find category app falls under. Returns unicode to remove NavigableString
    reference to parse tree.
    """
    for span in soup.find_all("span"):
        if span.get('itemprop') == "applicationCategory":
            return unicode(span.text)

def upload_to_db(app_id, name, category, description, image, rating, total_reviews, raw_name):
    """ Uploads app details to cloudant database where id is the key to
    the document in cloudant. The document includes the app name, description,
    url, rating and the total number of reviews.
    """

    # Connect to cloudant. Exits cloudant when block is exited.
    with cloudant(Settings.CLOUDANT_USERNAME, Settings.CLOUDANT_PASSWORD, url=Settings.CLOUDANT_URL) as client:
        session = client.session()
        # Create or check for db:
        try:
            # Create database.
            app_db = client.create_database(Settings.DATABASE_NAME)
        except:
            # Database already exists.
            app_db = client[Settings.DATABASE_NAME]

        # Check database exists
        if not app_db.exists():
            raise NonexistentDatabase("The database %s does not exist." %Settings.DATABASE_NAME)

        # Create or update document and perform fetch/save after exiting this block
        with Document(app_db, app_id) as doc:
            doc['name'] = name.encode('utf-8')
            doc['description'] = description.encode('utf-8')
            doc['image'] = image
            doc['category'] = category
            doc['rating'] = rating
            doc['total_reviews'] = total_reviews
            doc['keyword'] = query_for_top_keywords(raw_name, category)
            doc['turnarounds'] = int(query_num_turnarounds(raw_name))
            doc['sentiment'] = float(query_average_app_sentiment(raw_name))

        # Display document for error checking
        print app_db[app_id]
    return

# Rename to extract and upload app details.
def extract_app_details(top_apps):
    """ Grab all desired content from each specific app page within top 100 free
    apps: id, name, description, image, rating, total_reviews
    """
    for app in top_apps:
        app_id = app["id"]
        name = to_ascii(app["title"])

        # Go to app's iTunes page.
        app_url = app["url"]
        r = requests.get(app_url)
        # Extract information App Insights requires.
        soup = BeautifulSoup(r.text, 'html.parser')
        description = find_description(soup)
        image = find_image(soup)
        category = find_category(soup)
        (rating, total_reviews) = find_rating_and_num_reviews(soup)
        upload_to_db(app_id, name, category, description, image, rating, total_reviews, app["title"])

    # Check all documents uploaded into cloudant.
    with cloudant(Settings.CLOUDANT_USERNAME, Settings.CLOUDANT_PASSWORD, url=Settings.CLOUDANT_URL) as client:
        session = client.session()
        documents = []
        for document in client[Settings.DATABASE_NAME]:
            documents.append(document)
            # Don't overload cloudant
            time.sleep(.300)
    return {'results': documents}

def clean_keywords(app_info, keywords):
    """ Compares keywords list to list of strings detailing the app info to make
    sure the displayed keyword does not contain any words already found within
    the app name, app category, or other common, unhelpful keywords.
    """
    title_words = [words.lower() for phrases in app_info for words in phrases.split()]
    for phrase in keywords:
        contains_keyword = False
        for word in title_words:
            if word in phrase.lower() or phrase.lower() in word:
                contains_keyword = True
        if not contains_keyword:
            # Return the first keyword that doesn't contain duplicates.
            return phrase.lower()

def query_for_top_keywords(app_name, app_category):
    """ Use the discovery service to query for the top keywords mentioned within reviews.
    """
    entities = ["filter(app_name:%s).term(review_enriched.keywords.text).term(review_enriched.keywords.sentiment.type)" %app_name]
    qopts = {
        'aggregation': entities
        }
    results = Settings.discovery.query(environment_id, collection_id, qopts)
    # Add error checking. probably seperate into a function that takes in the result
    jsonResults = json.loads(json.dumps(results["aggregations"][0]["aggregations"][0]["results"][0]))

    keywords_json = json.loads(json.dumps(results["aggregations"][0]["aggregations"]))
    keywords = []
    for keyword in keywords_json[0]["results"]:
        keywords.append(keyword["key"])
    app_info = app_name.split(" ") + app_category.split(" ")
    app_info.append("app")
    return clean_keywords(app_info, keywords)

def query_num_turnarounds(app_name):
    """ Query the discovery service for all review that contain positive sentiment
    but rated with 3 or lower stars. Returns only the number of reviews that match this query.
    """
    qopts = {
        'filter': "app_name:%s,review_enriched.docSentiment.type:positive,rating<3" %app_name,
        'return': "rating,review,version,app_name,title,updated"
    }
    results = Settings.discovery.query(environment_id, collection_id, qopts)
    return json.dumps(results["matching_results"])

def query_average_app_sentiment(app_name):
    """ Find the average review sentiment for the app specified.
    """
    qopts = {
        "aggregation": "filter(app_name:%s).average(review_enriched.docSentiment.score)" %app_name
    }
    results = Settings.discovery.query(environment_id, collection_id, qopts)
    return json.dumps(results["aggregations"][0]["aggregations"][0]["value"])

def delete_database():
    """ Delete the cloudant database created.
    """
    with cloudant(Settings.CLOUDANT_USERNAME, Settings.CLOUDANT_PASSWORD, url=Settings.CLOUDANT_URL) as client:
        session = client.session()
        client.delete_database(Settings.DATABASE_NAME)
    return

# Main script running.
if not os.path.exists(filename):
    print ("please run `python ingest_reviews.py` first in order to create the needed ingested_apps.txt file.")
else:
    # Gathered info needed returned by ingest_reviews.py
    with open(filename) as apps:
        test_app = json.loads(apps.read())
    # delete_database()
    print extract_app_details(test_app)
