#!/usr/bin/env bash
sed -i 's/&gt;/>/g'  _site/2019/**/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/2019/**/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/2019/**/*.html

sed -i 's/&gt;/>/g'  _site/2020/**/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/2020/**/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/2020/**/*.html
# Also include index pages and so on
sed -i 's/%7B%7B%20/{{ /g'  _site/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/en/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/en/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/tag/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/tag/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/en/tag/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/en/tag/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/category/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/category/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/en/category/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/en/category/*.html
