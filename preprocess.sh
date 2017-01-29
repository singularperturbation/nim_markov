#!/bin/sh

# Reads JSON from Slack dump in stdin, normalized messages go to stdout

jq -r '.[] | select(.type == "message") | select(has("subtype")==false) | .text | gsub("\n"; " ") | gsub("&gt;";" ") | gsub("&lt;";"") | gsub("&amp;";" ")' \
  | sed -e 's/<.*>/ /g' \
  | sed -e 's/`.*`/ /g' \
  | sed -E 's/[[:space:]]+/ /g' \
  | ruby -pe '$_ = if $_ =~ /[[:alpha:]]/ then $_ else "" end' \
  | sed -e 's/[“”]/"/g' \
  | sed -e 's/‘//g' \
  | grep -v '^$'

# Remove URLs
# Remove inline backticks and what's inside them
# Remove extraneous whitespace (won't be necessary when tokenizing)
# Has to have at least one alphanumeric character
# Convert 'weird' quotes to normal quotes (and remove weird single quotes)
# Remove empty lines
