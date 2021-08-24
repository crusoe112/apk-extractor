#!/usr/bin/python3

import requests
import argparse
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
import sys
import json
import re
import time
import urllib.parse as urlparse
from urllib.parse import parse_qs

def extract_app_id(play_url):
    parsed = urlparse.urlparse(play_url)
    return parse_qs(parsed.query)['id'][0]

def get_evozi_token():
    token_url = 'https://apps.evozi.com/apk-downloader/'
    result = requests.get(token_url).text
    for line in result.split('\n'):
        if "$('#forceRefetch').is(':checked')}" in line:
            split_line = line.split(':')
            epoch_key = split_line[0].replace(' ', '').split('{')[1]
            epoch = split_line[1].replace(' ', '').split(',')[0]
            id_key = split_line[1].replace(' ', '').split(',')[1]
            token_key = split_line[2].replace(' ', '').split(',')[1]
            token_variable = split_line[3].replace(' ', '').split(',')[0]
            token = re.findall("{}  = '([^']+)".format(token_variable), result)[0]
            return id_key, {epoch_key: epoch, id_key: None, token_key: token}


def get_download_url(app_id, id_key, data):
    evozi_url = 'https://api-apk.evozi.com/download'
    data[id_key] = app_id
    params = data
    headers = {'Content-Type':'application/x-www-form-urlencoded'}
    result = json.loads(requests.post(evozi_url, data=params, headers=headers, verify=False).text)
    return 'https:{}'.format(result['url'].replace('\\', ''))

def main():
    # Parse arguments
    parser = argparse.ArgumentParser(description='A script to get the APK download link from api-apk.evozi.com')
    parser.add_argument('--mode', choices=['id','url'], help='Is input a Google Play url, or the app id?', default='url')
    parser.add_argument('query', type=str, help='The URL or ID of the app depending on mode parameter.')
    args = parser.parse_args()

    # URL or ID?
    #app_id = args.query
    if args.mode == 'url':
        try:
            app_id = extract_app_id(args.query)
        except Exception as e:
            print('Query parameter does not seem to be a proper Google play ID')
            sys.exit()
    else:
        app_id = args.query.strip().replace('"', '')

    # Get URL
    id_key, data = get_evozi_token()
    print(get_download_url(app_id, id_key, data))

if __name__ == '__main__':
    main()
