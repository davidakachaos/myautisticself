#!/usr/bin/env python3

import glob
import os
import subprocess
import shutil

post_dir = "_posts/"

filenames = glob.glob(post_dir + "*md")

seen_refs = dict()

for filename in filenames:
    f = open(filename, "r", encoding="utf8")
    crawl = False
    current_ref = ''
    current_lang = ''
    for line in f:
        if crawl:
            current_tags = line.strip().split()
            if current_tags[0] == "ref:":
                current_ref = "-".join(current_tags[1:])
            if current_tags[0] == "lang:":
                current_lang = "-".join(current_tags[1:])
                # crawl = False
                # break
        if line.strip() == "---":
            if not crawl:
                crawl = True
            else:
                if current_ref in seen_refs:
                    seen_refs[current_ref]['langs'].extend([current_lang])
                    seen_refs[current_ref]['documents'].extend([filename])
                else:
                    seen_refs[current_ref] = dict()
                    seen_refs[current_ref]['langs'] = [current_lang]
                    seen_refs[current_ref]['documents'] = [filename]
                crawl = False
                break
    f.close()
for (ref, values) in seen_refs.items():
    if len(values['langs']) == 1:
        print("Post needs a translated version!")
        print(values['documents'][0])
        to_trans = values['documents'][0].replace('.md', '').replace('_posts/','')
        result = subprocess.run(['trans', '-b', '-s', 'nl', '-t', 'en', to_trans], stdout=subprocess.PIPE)
        new_file_name = f"_posts/{result.stdout.decode('utf-8').strip(" \n")}.md"
        dest = shutil.copyfile(values['documents'][0], new_file_name)
        # Read in the file
        with open(new_file_name, 'r') as file :
          filedata = file.read()

        # Replace the target string
        filedata = filedata.replace('lang: nl', 'lang: en')

        # Write the file out again
        with open(new_file_name, 'w') as file:
          file.write(filedata)

        print(f"Generated a translated post: {new_file_name}")


# print(f"Current refs: {seen_refs}")
