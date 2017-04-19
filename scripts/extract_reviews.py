import xml.etree.ElementTree as ET
import requests
import re

## Header needed to form URL to extract reviews from:
url_header = "https://itunes.apple.com/us/rss/customerreviews"

def elem_found(lst):
    return len(lst) > 0

# Take care of namespaces xml page contains.
nsmap = {'': 'http://www.w3.org/2005/Atom', 'im':'http://itunes.apple.com/rss', 'lang':'en'}
# URI also known as qualified name.
uri = "{http://www.w3.org/2005/Atom}"

# Add in app version.
def extract_reviews(app_name, app_id):
    """ Extract all reviews from the App Store's RSS feed per app, determined by
    app_id.

    Returns a list of reviews stored as dictionary objects.
    """
    page = 1
    reviews = {}
    while page <= 10:
        # Append to URL header to specify where to extract app reviews from.
        url = "%s/page=%d/id=%s/sortby=mostrecent/xml" %(url_header, page, app_id)
        response = requests.get(url)

        # Check if response is valid.
        if response.status_code != 200:
            return reviews
        # Encode reviews to parse with Element Tree.
        reviews_text = ET.fromstring(response.text.encode('utf-8'))
        entry_elems = reviews_text.findall(".//{http://www.w3.org/2005/Atom}entry")
        if app_name not in reviews:
            reviews.update({app_name: []})
        reviews[app_name] += [{"app_name": app_name,\
                                       "updated": review.find(uri + "updated").text,\
                                       "review_id": review.find(uri + "id").text,\
                                       "rating": review.findall(".//im:rating", namespaces=nsmap)[0].text,\
                                       "version": review.findall(".//im:version", namespaces=nsmap)[0].text,\
                                       "title": review.find(uri + "title").text, "review": review.find(uri + "content").text}
                                       for review in entry_elems
                                       if elem_found(review.findall(".//im:rating", namespaces=nsmap))]
        page += 1
    return reviews

def main(params):
    app_name = params["name"]
    app_id = params["id"]
    return extract_reviews(app_name, app_id)
