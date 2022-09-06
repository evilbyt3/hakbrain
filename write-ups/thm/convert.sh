#!/bin/bash
title: convert
tags:
- writeups
  # Update frontmatter
  title=${file::-3}
  sed -i 2,5d "$file" && sed -i "1a title: $title\ntags:\n- writeups" "$file"

  # Replace with space
  sed -i 's/ / /g' "$file"

  # Update image paths
  sed -i 's|write-ups/images/|write-ups/images/|g' "$file"

  # Convert imgs from markdown to obsidian
  sed -i 's|!\[.*](\(.*\.png\))|![[\1]]|g' "$file"
done

