#!/usr/bin/env python3

from multi_rake import Rake
from bs4 import BeautifulSoup
import markdown
import glob
import subprocess

post_dir = "_posts/"
filenames = glob.glob(post_dir + "*md")
print(f"Scanning...{len(filenames)}")
for filename in filenames:
    print(f"Processing {filename}")
    with open(filename, "r", encoding="utf8") as f:
        content = f.read().split("---")[-1]
        html = subprocess.run(["kramdown", content], capture_output=True).stdout
        soup = BeautifulSoup(html, features="html.parser")
        print(soup.get_text())
        break
