#!/usr/bin/env python3

import glob
import os
import subprocess
import shutil

post_dir = "_posts/"

filenames = glob.glob(post_dir + "*md")

seen_refs = dict()


def translate(to_trans):
    return (
        subprocess.run(
            ["trans", "-b", "-s", "nl", "-t", "en", to_trans], stdout=subprocess.PIPE,
        )
        .stdout.decode("utf-8")
        .strip(" \n")
    )


for filename in filenames:
    f = open(filename, "r", encoding="utf8")
    crawl = False
    current_ref = ""
    current_lang = ""
    current_title = ""
    for line in f:
        if crawl:
            current_tags = line.strip().split()
            if current_tags[0] == "ref:":
                current_ref = "-".join(current_tags[1:])
            if current_tags[0] == "lang:":
                current_lang = "-".join(current_tags[1:])
            if current_tags[0] == "title:":
                current_title = " ".join(current_tags[1:])
                # crawl = False
                # break
        if line.strip() == "---":
            if not crawl:
                crawl = True
            else:
                if current_ref in seen_refs:
                    seen_refs[current_ref]["langs"].extend([current_lang])
                    seen_refs[current_ref]["documents"].extend([filename])
                    seen_refs[current_ref]["titles"].extend([current_title])
                else:
                    seen_refs[current_ref] = dict()
                    seen_refs[current_ref]["langs"] = [current_lang]
                    seen_refs[current_ref]["titles"] = [current_title]
                    seen_refs[current_ref]["documents"] = [filename]
                crawl = False
                break
    f.close()
for (ref, values) in seen_refs.items():
    if len(values["langs"]) == 1:
        print("Post needs a translated version!")
        print(values["documents"][0])
        translated_filename = translate(
            values["documents"][0].replace(".md", "").replace("_posts/", "")
        )
        org_title = values["titles"][0]
        translated_title = translate(org_title)
        new_file_name = f"_posts/{translated_filename}.md"
        dest = shutil.copyfile(values["documents"][0], new_file_name)
        # Read in the file
        with open(new_file_name, "r") as file:
            filedata = file.read()

        # Replace the target string
        filedata = filedata.replace("lang: nl", "lang: en")
        filedata = filedata.replace(f"title: {org_title}", f"title: {translated_title}")

        # Write the file out again
        with open(new_file_name, "w") as file:
            file.write(filedata)

        print(f"Generated a translated post: {new_file_name}")


# print(f"Current refs: {seen_refs}")