import base64
import re
import subprocess
import time

import requests


def clean(word):
    return re.sub("[^0-9a-zA-Z]+", "", word).lower()


def run(cmd):
    print(f"Running: {cmd}\n")
    s = time.time()
    res = subprocess.run(cmd, shell=True, check=True)
    f = time.time()
    print(f"\n\tFinished in {f-s} seconds.\n")
    return res


def parse_owner_title(owner_title):
    if isinstance(owner_title, tuple) and len(owner_title) == 2:
        owner, title = owner_title
    else:
        owner, title = owner_title.split("/")
    return (owner, title)


def read_github_file(org, repo, branch, filename):
    """
    Read data from github api. Ht to @andersonfrailey for decoding the response
    """
    url = f"https://api.github.com/repos/{org}/{repo}/contents/{filename}?ref={branch}"
    response = requests.get(url)
    print(f"GET: {url} {response.status_code}")
    if response.status_code == 403:
        assert "hit rate limit" == 403
    assert response.status_code == 200
    sanatized_content = response.json()["content"].replace("\n", "")
    encoded_content = sanatized_content.encode()
    decoded_bytes = base64.decodebytes(encoded_content)
    text = decoded_bytes.decode()
    return text
