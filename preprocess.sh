#!/bin/sh

# Reads JSON from Slack dump in stdin, normalized messages go to stdout

jq -r '.[] | select(.type == "message") | select(has("subtype")==false) | .text | gsub("\n"; " ") | gsub("&gt;";" ") | gsub("&lt;";"") | gsub("&amp;";" ")' \
  | sed -e 's/<.*>/ /g' \                                         # Remove URLs
  | sed -e 's/`/ /g' \                                            # Remove inline quotes
  | sed -E 's/[[:space:]]+/ /g' \                                 # Remove extraneous whitespace (won't be necessary when tokenizing)
  | ruby -pe '$_ = $_.lstrip.downcase' \
  | ruby -pe '$_ = if $_ =~ /[[:alpha:]]/ then $_ else "" end' \  # Has to have at least one alphanumeric character
  | sed -e 's/[“""]//g' \                                         # Remove weird quotes
  | grep -v '^$'                                                  # Remove empty lines
