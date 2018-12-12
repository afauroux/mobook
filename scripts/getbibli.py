from requests import get
from requests.exceptions import RequestException
from contextlib import closing
from bs4 import BeautifulSoup


def simple_get(url):
    """
    Attempts to get the content at `url` by making an HTTP GET request.
    If the content-type of response is some kind of HTML/XML, return the
    text content, otherwise return None.
    """
    try:
        with closing(get(url, stream=True)) as resp:
            if is_good_response(resp):
                return resp.content
            else:
                return None

    except RequestException as e:
        log_error('Error during requests to {0} : {1}'.format(url, str(e)))
        return None


def is_good_response(resp):
    """
    Returns True if the response seems to be HTML, False otherwise.
    """
    content_type = resp.headers['Content-Type'].lower()
    return (resp.status_code == 200 and content_type is not None
            and content_type.find('html') > -1)


def log_error(e):
    """
    It is always a good idea to log errors. 
    This function just prints them, but you can
    make it do anything.
    """
    print(e)


pages = [
    f'http://www.litteratureaudio.com/notre-bibliotheque-de-livres-audio-gratuits?pg={i}'
    for i in range(1, 21)
]

raw_html = simple_get(pages[0])
html = BeautifulSoup(raw_html, 'html.parser')


def main():
    title_matcher = re.compile("(.+) [-–] (.+)")
    for p in html.select('ul'):
        if 'Catégorie' in p.select_one('li').text:
            break
    bibli = {}
    for li in p.findChildren("li", recursive=False):

        booklist = li.find('ul')
        category = booklist.previousSibling.text
        category = category if 'Catégorie' not in category else category.split(
            ':')[1].strip()
        print(category)
        bibli[category] = []
        c = 0
        for b in booklist.findChildren("li", recursive=False):
            link = b.select_one('a')
            m = title_matcher.match(link['title'])
            if m:
                author = m.group(1)
                title = m.group(2)

                bookpage = BeautifulSoup(
                    simple_get(link['href']), 'html.parser')
                files = bookpage.find_all(
                    "a", class_="link-mp3-file") + bookpage.find_all(
                        "a", class_="link-roman-mp3-file")
                files = [f['href'] for f in files]
                bibli[category].append({
                    "author": author,
                    "title": title,
                    "audiofile": files
                })
                c += 1
            if c > 10:
                break
    return bibli