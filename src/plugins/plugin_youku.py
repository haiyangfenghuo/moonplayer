﻿#!/usr/bin/python
# -*- encoding: utf-8 -*-

from moonplayer_utils import list_links, re2, parse_flvcd_page
import re
import json
import thread
import moonplayer

#hosts
hosts = ('v.youku.com',)
    
#search videos
def search(keyword, page):
    url = 'http://www.soku.com/search_video/q_' + keyword + '_orderby_1_page_' + str(page)
    moonplayer.get_url(url, search_cb, None)
    
def search_cb(content, data):
    #movies, TV series and details
    movies = list_links(content, 'http://www.youku.com/show_page/id_')
    details = list_links(content, '/detail/show/')
    n = (len(movies) + len(details)) >> 1
    #videos
    links = movies + details + list_links(content, 'http://v.youku.com/v_show/')
    moonplayer.show_list(links)
    for i in xrange(n):
        moonplayer.set_list_item_color(i, '#0000ff')
    
#search albums
def search_album(keyword, page):
    url = 'http://www.soku.com/search_playlist/q_' + keyword + '_orderby_1_page_' + str(page)
    moonplayer.get_url(url, search_album_cb, None)
    
def search_album_cb(content, data):
    links = list_links(content, 'http://www.youku.com/playlist_show/')
    moonplayer.show_list(links)
    
## Parse videos or albums
id_re = re.compile(r'http://v.youku.com/v_show/id_(.+)\.html')
def parse(url, options):
    #albums
    if url.startswith('http://www.youku.com/playlist_show/'):
        prefix = url[0:-5]
        moonplayer.get_url(url, parse_album_cb, (prefix, 1, []))
        return
    #details
    elif url.startswith('/detail/show/'):
        url = 'http://www.soku.com' + url
        moonplayer.get_url(url, parse_details_cb, None)
        return
    #movies or tv series
    elif url.startswith('http://www.youku.com/show_page/id_'):
        url2 = url.replace('/show_page/', '/show_episode/')
        moonplayer.get_url(url2, parse_series_cb, url)
        return
    #single video
    match = id_re.match(url)
    if not match:
        moonplayer.warn('Please input a valid youku url.')
        return
    url = 'http://www.flvcd.com/parse.php?kw=' + url
    if options & moonplayer.OPT_QL_SUPER:
        url += '&format=super'
    elif options & moonplayer.OPT_QL_HIGH:
        url += '&format=high'
    moonplayer.get_url(url, parse_cb, options)
    
## Parse videos
def parse_cb(page, options):
    result = parse_flvcd_page(page, None)
    if options & moonplayer.OPT_DOWNLOAD:
        moonplayer.download(result, result[0])
    else:
        moonplayer.play(result)
    
        
## Parse details
detail_re = re.compile(r'<a href="(http://v.youku.com/.+?)".+?>(\d+)</a>')
def parse_details_cb(content, data):
    links = []
    match = detail_re.search(content)
    while match:
        (url, name) = match.group(1, 2)
        links.append(name)
        links.append(url)
        match = detail_re.search(content, match.end(0))
    moonplayer.show_album(links)
        
## Parse TV series
def parse_series_cb(content, mov_url):
    links = []
    match = re2.search(content)
    if not match:
        moonplayer.get_url(mov_url, parse_movie_cb, None) #movie
        return
    while match:
        (name, url) = match.group(2, 1)
        links.append(name)
        links.append(url)
        match = re2.search(content, match.end(0))
    moonplayer.show_album(links)
    
## Parse movies
def parse_movie_cb(content, data):
    links = list_links(content, 'http://v.youku.com/v_show/')
    moonplayer.show_album(links)

## Parse albums
def parse_album_cb(content, data):
    prefix = data[0]
    now_page = data[1]
    items = data[2]
    new_items = list_links(content, 'http://v.youku.com/v_show/id_')
    items += new_items
    if len(new_items) > 0:
        url = prefix + '_ascending_1_mode_pic_page_' + str(now_page+1) + '.html'
        moonplayer.get_url(url, parse_album_cb, (prefix, now_page+1, items))
    else:
        moonplayer.show_album(items)
