#!/bin/bash


FILES=$(cat temp.txt)

CHECK="./scripts/checkpatch.pl --terse -f "

for FILE in $FILES; do
	SOURCES=$($CHECK $FILE | grep -o "<\w*>" | sed "s/>//" | sed "s/<//")
	for SOURCE in $SOURCES; do
		TARGET=$(echo $SOURCE | sed "s/_\(\w*\)/---\1/g" | sed 's/\([[:upper:]][[:lower:]]\+\)/_\1/g' | sed 's/\([[:upper:]]\+\)/_\1/g' | sed 's/^_\+//g' |tr [[:upper:]] [[:lower:]] | sed "s/---/_/g" | sed "s/_\+/_/g")
		echo "$SOURCE" "$TARGET"
		sed -i "s/$SOURCE/$TARGET/g" $FILE
	done
done

