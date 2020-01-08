#!/usr/bin/env bash
sed -i 's/&gt;/>/g'  _site/2019/**/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/2019/**/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/2019/**/*.html

sed -i 's/&gt;/>/g'  _site/2020/**/*.html
sed -i 's/%7B%7B%20/{{ /g'  _site/2020/**/*.html
sed -i 's/%20%7D%7D/ }}/g'  _site/2020/**/*.html
