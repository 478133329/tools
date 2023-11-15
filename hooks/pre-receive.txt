#!/bin/bash

GERRIT_REPO="/home/gerrit/gerrit_repo"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project)
            project="$2"
            shift 2
            ;;
        --refname)
            refname="$2"
            shift 2
            ;;
        --uploader)
            uploader="$2"
            shift 2
            ;;
	--oldrev)
	    oldrev="$2"
	    shift 2
	    ;;
	--newrev)
	    newrev="$2"
	    shift 2
	    ;;
	--cmdref)
	    cmdref="$2"
	    shift 2
	    ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

mkdir -p $GERRIT_REPO/$project.git/temp
cd $GERRIT_REPO/$project.git/temp
git clone $GERRIT_REPO/$project.git . > /dev/null 2>&1
git archive "$newrev" | tar -xf -

files=$(git diff --name-only --diff-filter=AMCRTU $refname $newrev)

review_site="/home/gerrit/review_site"
python="python3"
checkpatch_cmd="$review_site/tools/checkpatch.pl"
cppcheck_cmd="$review_site/tools/cppcheck"
cpplint_cmd="$review_site/tools/cpplint.py"
flake8_cmd="$review_site/tools/flake8"
shellcheck_cmd="$review_site/tools/shellcheck"

exit_flag="0"

info_buffer=$(mktemp)

echo "Code style checking..."

for file in $files; do
    extension="${file##*.}"
    case "$extension" in
	c)
	    ($cppcheck_cmd $file) > "$info_buffer" 2>&1
	    if [ $? -ne 0 ]; then
		echo -e "\e[31m[cppcheck]\e[0m"
		cat "$info_buffer"
		exit_flag="1"
	    fi
	    ;;
       cpp)
	    $python $cpplint_cmd $file > "$info_buffer" 2>&1
	    if [ $? -ne 0 ]; then
		echo -e "\e[31m[cpplint]\e[0m"
		cat "$info_buffer"
		exit_flag="1"
	    fi
	    ;;	
	py)
            $flake8_cmd $file > "$info_buffer" 2>&1
            if [ $? -ne 0 ]; then
		echo -e "\e[31m[flake8]\e[0m"
		cat "$info_buffer"
                exit_flag="1"
            fi
            ;;
        sh)
            $shellcheck_cmd $file > "$info_buffer" 2>&1
            if [ $? -ne 0 ]; then
		echo -e "\e[31m[shellcheck]\e[0m"
		cat "$info_buffer"
		exit_flag="1"
	    fi
            ;;
	*)
	    ;;
    esac
done

rm "$info_buffer"

rm -rf $GERRIT_REPO/$project.git/temp

if [ $exit_flag -eq "1" ]; then
    exit 1
fi
