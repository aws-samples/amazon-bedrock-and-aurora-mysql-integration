# -*- coding: utf-8 -*-

import pymysql
import feedparser
import re

# if module is not installed, please install it. ex: pip install -r requirements.txt

myfeed = feedparser.parse("https://aws.amazon.com/about-aws/whats-new/recent/feed/")
db = pymysql.connect(
        host='<Aurora MySQL Writer Endpoint>',
        user='<user name>',
        password='<password>',
        database='<sample schema (ex: bedrockdb)>',
        charset="utf8",
        cursorclass=pymysql.cursors.DictCursor)

with db:
  with db.cursor() as cur:
    for item in myfeed['items']:
        title = item.title
        link = item.link 
        description =  re.sub(r'<[^>]+>', '', item.description).replace("'", "\\'").replace('"', '\\"').replace('\n', ' ')
        print (title)
        print (link)
        print (description)

        cur.execute("INSERT INTO t_feed (title, link, description) VALUES (%s, %s, %s)", (title, link, description))
  db.commit()
  print ('Import rss Succesfull!')
