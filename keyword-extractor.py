#!/usr/bin/env python3

from multi_rake import Rake
from bs4 import BeautifulSoup
import glob
import subprocess
import os
import re
from monkeylearn import MonkeyLearn

ML_KEY = "e9b0b37c5aa9abc62087f453820cc56f7fb7c39c"

dutch_stop_words = {
    "alt",
    "jpg",
    "png",
    "jpeg",
    "de",
    "en",
    "van",
    "ik",
    "te",
    "dat",
    "die",
    "in",
    "een",
    "hij",
    "het",
    "niet",
    "zijn",
    "is",
    "was",
    "op",
    "aan",
    "met",
    "als",
    "voor",
    "had",
    "er",
    "maar",
    "om",
    "hem",
    "dan",
    "zou",
    "of",
    "wat",
    "mijn",
    "men",
    "dit",
    "zo",
    "door",
    "over",
    "ze",
    "zich",
    "bij",
    "ook",
    "tot",
    "je",
    "mij",
    "uit",
    "der",
    "daar",
    "haar",
    "naar",
    "heb",
    "hoe",
    "heeft",
    "hebben",
    "deze",
    "u",
    "want",
    "nog",
    "zal",
    "me",
    "zij",
    "nu",
    "ge",
    "geen",
    "omdat",
    "iets",
    "worden",
    "toch",
    "al",
    "waren",
    "veel",
    "meer",
    "doen",
    "toen",
    "moet",
    "ben",
    "zonder",
    "kan",
    "hun",
    "dus",
    "alles",
    "onder",
    "ja",
    "eens",
    "hier",
    "wie",
    "werd",
    "altijd",
    "doch",
    "wordt",
    "wezen",
    "kunnen",
    "ons",
    "zelf",
    "tegen",
    "na",
    "reeds",
    "wil",
    "kon",
    "niets",
    "uw",
    "iemand",
    "geweest",
    "andere",
}
english_stop_words = {
    "i",
    "alt",
    "jpg",
    "png",
    "jpeg",
    "me",
    "my",
    "myself",
    "we",
    "our",
    "ours",
    "ourselves",
    "you",
    "your",
    "yours",
    "yourself",
    "yourselves",
    "he",
    "him",
    "his",
    "himself",
    "she",
    "her",
    "hers",
    "herself",
    "it",
    "its",
    "itself",
    "they",
    "them",
    "their",
    "theirs",
    "themselves",
    "what",
    "which",
    "who",
    "whom",
    "this",
    "that",
    "these",
    "those",
    "am",
    "is",
    "are",
    "was",
    "were",
    "be",
    "been",
    "being",
    "have",
    "has",
    "had",
    "having",
    "do",
    "does",
    "did",
    "doing",
    "a",
    "an",
    "the",
    "and",
    "but",
    "if",
    "or",
    "because",
    "as",
    "until",
    "while",
    "of",
    "at",
    "by",
    "for",
    "with",
    "about",
    "against",
    "between",
    "into",
    "through",
    "during",
    "before",
    "after",
    "above",
    "below",
    "to",
    "from",
    "up",
    "down",
    "in",
    "out",
    "on",
    "off",
    "over",
    "under",
    "again",
    "further",
    "then",
    "once",
    "here",
    "there",
    "when",
    "where",
    "why",
    "how",
    "all",
    "any",
    "both",
    "each",
    "few",
    "more",
    "most",
    "other",
    "some",
    "such",
    "no",
    "nor",
    "not",
    "only",
    "own",
    "same",
    "so",
    "than",
    "too",
    "very",
    "s",
    "t",
    "can",
    "will",
    "just",
    "don",
    "should",
    "now",
    "d",
    "ll",
    "m",
    "o",
    "re",
    "ve",
    "y",
    "ain",
    "aren",
    "couldn",
    "didn",
    "doesn",
    "hadn",
    "hasn",
    "haven",
    "isn",
    "ma",
    "mightn",
    "mustn",
    "needn",
    "shan",
    "shouldn",
    "wasn",
    "weren",
    "won",
    "wouldn",
}

post_dir = "_posts/"
filenames = glob.glob(post_dir + "**/*md")
print(f"Scanning...{len(filenames)}")
rake = Rake(max_words=2, min_chars=5)
for filename in filenames:
    print(f"Processing {filename}")
    with open(filename, "r+", encoding="utf8") as f:
        crawl = False
        found_keywords = False
        for line in f:
            if crawl:
                current_tags = line.strip().split()
                if current_tags == []:
                    continue
                if current_tags[0] == "keywords:":
                    found_keywords = True
                    break
                if current_tags[0] == "lang:":
                    lang_found = current_tags[1]
            if line.strip() == "---":
                if not crawl:
                    crawl = True
                else:
                    crawl = False
                    break
        if found_keywords:
            print(f"{filename} already has keywords, skipping...")
            continue
        if lang_found == "nl":
            rake.stopwords = dutch_stop_words
            rake.language_code = "nl"
        if lang_found == "en":
            rake.stopwords = english_stop_words
            rake.language_code = "en"

        rake.stopwords.update(set(["assets", "img", "responsive"]))
        # Read the file minus the header
        f.seek(0)
        content = f.read().split("---")[-1]
        ftmp = open("temp.md", "w+")
        ftmp.write(content)
        ftmp.close()
        # Convert the markdown to html and get the text
        html = subprocess.getoutput(
            "kramdown temp.md"
        )  # subprocess.run(["kramdown", "temp.md"], capture_output=True).stdout
        os.remove("temp.md")
        soup = BeautifulSoup(html, features="html5lib")
        # Get keywords
        the_text = re.sub(r"\{\%.+\%\}", "", soup.get_text())
        # print(f"{the_text}")
        ml = MonkeyLearn(ML_KEY)
        model_id = "ex_YCya9nrn"
        keywords = ml.extractors.extract(
            model_id, [{"text": the_text, "external_id": "ANY_ID"}]
        ).body
        # print(f"{[ item for item in keywords[0]['extractions'] ]}")
        # print(f"{[ item['parsed_value'] for item in keywords[0]['extractions'] ]}")
        # exit()
        # print(f"{the_text}")
        # keywords = [word for word, value in rake.apply(the_text)]
        the_keywords = [item["parsed_value"] for item in keywords[0]["extractions"]]
        print(f"Adding keywords: '{', '.join(the_keywords[:5])}'\n")
        # Rewind, and add the keywords
        f.seek(0)
        lines = f.readlines()
        lines.insert(1, f"keywords: '{','.join(the_keywords[:5])}'\n")
        f.seek(0)
        f.writelines(lines)
