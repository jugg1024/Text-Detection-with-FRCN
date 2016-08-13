for entry in $1/formatted_dataset/Annotations/*
do
   tail -n +2 "$entry" > "$entry.tmp" && mv "$entry.tmp" "$entry"
done

