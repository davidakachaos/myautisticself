#!/usr/bin/env python3

import glob

post_dir = "_drafts/"

filenames = glob.glob(post_dir + "*md")


def ask(question):
    print(f"{question}")
    pass
