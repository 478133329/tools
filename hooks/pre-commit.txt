#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=$(git hash-object -t tree /dev/null)
fi

# If you want to allow non-ASCII filenames set this variable to true.
allownonascii=$(git config --bool hooks.allownonascii)

# Redirect output to stderr.
exec 1>&2

# Cross platform projects tend to avoid non-ASCII filenames; prevent
# them from being added to the repository. We exploit the fact that the
# printable range starts at the space character and ends with tilde.
if [ "$allownonascii" != "true" ] &&
	# Note that the use of brackets around a tr range is ok here, (it's
	# even required, for portability to Solaris 10's /usr/bin/tr), since
	# the square bracket bytes happen to fall in the designated range.
	test $(git diff --cached --name-only --diff-filter=A -z $against |
	  LC_ALL=C tr -d '[ -~]\0' | wc -c) != 0
then
	cat <<\EOF
Error: Attempt to add a non-ASCII file name.

This can cause problems if you want to work with people on other platforms.

To be portable it is advisable to rename the file.

If you know what you are doing you can disable this check using:

  git config hooks.allownonascii true
EOF
	exit 1
fi

# If there are whitespace errors, print the offending file names and fail.
# exec git diff-index --check --cached $against --


work_tree=$(git rev-parse --show-toplevel)

python="python3"
checkpatch_cmd="$work_tree/checktools/.checkpatch.pl"
cppcheck_cmd="$work_tree/checktools/.cppcheck"
cpplint_cmd="$work_tree/checktools/.cpplint.py"
flake8_cmd="$work_tree/checktools/.flake8"
shellcheck_cmd="$work_tree/checktools/.shellcheck"

exit_flag=0

info_buffer=$(mktemp)

files=$(git diff --name-only --diff-filter=AMCRTU $against)


for file in $files; do
	extension="${file##*.}"
	case "$extension" in
		c)
			$cppcheck_cmd $file > "$info_buffer" 2>&1
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
			$shellcheck_cmd $file < "$info_buffer" 2>&1
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

if [ $exit_flag -eq "1" ]; then
	exit 1
fi











