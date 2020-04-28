#!/usr/bin/env python3

"""
tag_generator.py
Copyright 2017 Long Qian // Adjusted by David Westerink 2019
Contact: lqian8@jhu.edu
This script creates tags for your Jekyll blog hosted by Github page.
No plugins required.
"""

import glob
import os

post_dir = "_posts/**/"
tag_dir = "tag/"
cat_dir = "category/"
default_lang = "nl"
extra_lang = ["en"]

filenames = glob.glob(post_dir + "*md", recursive=True)

total_tags = []
total_cats = []
for filename in filenames:
    # print(f"proccessing {filename}")
    f = open(filename, "r", encoding="utf8")
    crawl = False
    for line in f:
        if crawl:
            current_tags = line.strip().split()
            # print(f"Testing: {current_tags}")
            if current_tags == []:
                # We have a special line, skip to the next line!
                continue
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

# print(f"Tags found: {total_tags}")

old_tag_files = glob.glob(tag_dir + "*.md")
old_tags = 0
# print(f"Old tag files: {old_tag_files}")
# exit(1)
for tag_file in old_tag_files:
    t = tag_file.split("/")[-1].replace(".md", "")
    # print(f"Found tag: {t}")
    if t not in total_tags:
        # print("-- Tag not in current tags, removing")
        os.remove(tag_file)
        for lng in extra_lang:
            for extra_tag_file in glob.glob(lng + "/" + tag_dir + t + ".md"):
                os.remove(extra_tag_file)
    else:
        # print('-- Tag is current, leaving there')
        old_tags += 1
        total_tags.remove(t)

# print(f"Tags to create: {total_tags}")

old_cat_files = glob.glob(cat_dir + "*.md")
old_cats = 0

for cat_file in old_cat_files:
    t = cat_file.split("/")[-1].replace(".md", "")
    # print(f"Found cat: {t}")
    if t not in total_cats:
        # print("-- cat not in current cats, removing")
        os.remove(cat_file)
        for lng in extra_lang:
            for extra_cat_file in glob.glob(lng + "/" + cat_dir + t + ".md"):
                os.remove(extra_cat_file)
    else:
        # print('-- cat is current, leaving there')
        old_cats += 1
        total_cats.remove(t)

# print(f"cats to create: {total_cats}")


# Creating paths and files
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
        + "\nsitemap: false\n"
        + "robots: noindex\n---\n"
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

print(
    f"New Tags: {total_tags.__len__()} New Cats: {total_cats.__len__()} Old Tags: {old_tags} Old Cats: {old_cats}"
)
