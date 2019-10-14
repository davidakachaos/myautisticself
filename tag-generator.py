#!/usr/bin/env python3

"""
tag_generator.py
Copyright 2017 Long Qian
Contact: lqian8@jhu.edu
This script creates tags for your Jekyll blog hosted by Github page.
No plugins required.
"""

import glob
import os

post_dir = "_posts/"
tag_dir = "tag/"
cat_dir = "category/"
default_lang = "nl"
extra_lang = ["en"]

filenames = glob.glob(post_dir + "*md")

total_tags = []
total_cats = []
for filename in filenames:
    f = open(filename, "r", encoding="utf8")
    crawl = False
    for line in f:
        if crawl:
            current_tags = line.strip().split()
            if current_tags[0] == "category:":
                total_cats.extend(["-".join(current_tags[1:])])
            if current_tags[0] == "tags:":
                total_tags.extend(current_tags[1:])
                # crawl = False
                # break
        if line.strip() == "---":
            if not crawl:
                crawl = True
            else:
                crawl = False
                break
    f.close()
total_tags = set(total_tags)
total_cats = set(total_cats)

old_tags = glob.glob(tag_dir + "*.md")
for lng in extra_lang:
    old_tags += glob.glob(lng + "/" + tag_dir + "*.md")
for tag in old_tags:
    os.remove(tag)

old_tags = glob.glob(cat_dir + "*.md")
for lng in extra_lang:
    old_tags += glob.glob(lng + "/" + cat_dir + "*.md")
for tag in old_tags:
    os.remove(tag)

if not os.path.exists(tag_dir):
    os.makedirs(tag_dir)

if not os.path.exists(cat_dir):
    os.makedirs(cat_dir)

for lng in extra_lang:
    if not os.path.exists(lng + "/" + tag_dir):
        os.makedirs(lng + "/" + tag_dir)
    if not os.path.exists(lng + "/" + cat_dir):
        os.makedirs(lng + "/" + cat_dir)

for tag in total_tags:
    tag_filename = tag_dir + tag + ".md"
    f = open(tag_filename, "a")
    write_str = (
        '---\nlayout: tagpage\ntitle: "Tag: '
        + tag
        + '"\ntag: '
        + tag
        + "\nref: tag_"
        + tag
        + "\nlang: "
        + default_lang
        + "\ndescription: "
        + "Tag pagina voor "
        + tag
        + "\nrobots: noindex\n---\n"
    )
    f.write(write_str)
    f.close()
    for lng in extra_lang:
        tag_filename = lng + "/" + tag_dir + tag + ".md"
        f = open(tag_filename, "a")
        f.write(
            write_str.replace("lang: " + default_lang, "lang: " + lng).replace(
                "pagina voor", "page for"
            )
        )
        f.close()

for cat in total_cats:
    cat_filename = cat_dir + cat + ".md"
    f = open(cat_filename, "a")
    write_str = (
        '---\nlayout: catpage\ntitle: "Categorie: '
        + " ".join(cat.split("-"))
        + '"\ncat: '
        + " ".join(cat.split("-"))
        + "\nref: cat_"
        + cat
        + "\nlang: "
        + default_lang
        + "\ndescription: "
        + "Categorie pagina voor "
        + " ".join(cat.split("-"))
        + "\nrobots: noindex\n---\n"
    )
    f.write(write_str)
    f.close()
    for lng in extra_lang:
        cat_filename = lng + "/" + cat_dir + cat + ".md"
        f = open(cat_filename, "a")
        f.write(
            write_str.replace("lang: " + default_lang, "lang: " + lng)
            .replace("title: Categorie", "title: Category")
            .replace("Categorie pagina voor", "Category page for")
        )
        f.close()

print("Tags generated, count", total_tags.__len__())
print("Cats generated, count", total_cats.__len__())
