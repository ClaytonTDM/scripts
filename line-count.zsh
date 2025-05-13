printf "<files>" && find . -path './.git' -prune -o -path './node_modules' -prune -o -type f -exec file --mime {} + | \
  grep 'text/' | cut -d: -f1 | while IFS= read -r file; do
  lines=$(wc -l < "$file")
  safe_file=$(echo "$file" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
  printf "<file name=\"%s\" lines=\"%s\" />" "$safe_file" "$lines"
done && printf "</files>"
