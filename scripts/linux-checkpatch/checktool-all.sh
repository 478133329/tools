#!/bin/bash

WORKTREE=$(cd $(dirname $0); pwd)
CHECKPATCH=$WORKTREE/scripts/checkpatch.pl
CHECKARGS=" --no-tree --terse -f "


DIRS=$(find $WORKTREE -maxdepth 1 -type d -printf "%p\n")
FILES=""
ERRNUMS=0

RECORD=""
OUTFILE1=$WORKTREE/report.txt
OUTFILE2=$WORKTREE/errors.txt

touch $OUTFILE1 && echo > $OUTFILE1
touch $OUTFILE2 && echo > $OUTFILE2

for dir in $DIRS; do
		echo "Check [$(basename $dir)]"
		ERRNUMS=0
		if [ $dir == $WORKTREE ]
		then
			FILES=$(find $dir -maxdepth 1 -type f -regex ".*\.c\|.*\.h\|.*\.sh\|.*\.mk\|.*Kconfig\|.*Makefile" -printf "%p\n")
		else
			FILES=$(find $dir -type f -regex ".*\.c\|.*\.h\|.*\.sh\|.*\.mk\|.*Kconfig\|.*Makefile" -printf "%p\n")
		fi
		for file in $FILES; do
				$CHECKPATCH $CHECKARGS $file > /dev/null
				if [ $? -eq 1 ]; then
						echo "Error: $file"
						ERRNUMS=$((ERRNUMS+1))
				fi
		done
		echo "Find error: $ERRNUMS"
		echo "$(basename $dir): $ERRNUMS error files." >> $OUTFILE1
done

