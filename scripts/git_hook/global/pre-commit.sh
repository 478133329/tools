#!/bin/bash
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".
#!/bin/bash
err=0
err1=0
# --------------------name err-----------------------
if git rev-parse --verify HEAD >/dev/null 2>&1
then
        against=HEAD

else
        # Initial commit: diff against an empty tree object
        against=4b825dc642cb6eb9a060e54bf8d69288fbee4904

fi
function check_non_ascii()
{
    err1=0
    list_file=$(git diff --cached --name-only |grep -v '\.rst$')
    for file in ${list_file[@]}
    do
        git diff --cached  $file |grep ^+|grep --color='auto' -qP  "[^\x00-\x7F]"
        if [ $? -eq 0 ];then
            err1=1
            git diff --cached  $file |grep "^diff --git|^@@" -E
            git diff --cached  $file |grep ^+|grep --color='auto' -P  "[^\x00-\x7F]"
        fi
    done
    if [ $err1 -eq 1 ];then
        echo "----------------------------------------------------------------------------------------"
        echo -e "         \033[31mnon_ascii err\033[0m: Your changes contain non-ascii characters"
        echo "----------------------------------------------------------------------------------------"
        err=1
    fi
}

function check_python()
{
    # pip3 install vermin==1.3.3 flake8==3.9.0 git diff --cached   $(git diff --cached  --name-only | grep '\.py$')|flake8 --diff  --ignore=F403,F405
    changed_py_files=$(git diff --cached  --name-only | grep '\.py$')
    flake8_result=0
    # 检查每个文件是否能在 Python 3.5 下运行
    git diff --cached   *.py| flake8 --diff  --ignore=F403,F405
    if [ $? -ne 0 ]; then
        echo "----------------------------------------------------------------------------------------"
        echo -e "     \033[31mflake8 err\033[0m:Python code failed flake8’s style detection and syntax detection"
        echo "----------------------------------------------------------------------------------------"
        err=1
    fi
}



function check_patch()
{

    checkpatch="/media/cvitek/git-config/scripts/checkpatch.pl"
    ubootcheckpatch="/media/cvitek/git-config/uboot/checkpatch.pl"
    ignore="BAD_SIGN_OFF,GERRIT_CHANGE_ID,FILE_PATH_CHANGES,REDUNDANT_CODE,GCC_BINARY_CONSTANT,MACRO_ARG_REUSE"
    ignore="$ignore,GIT_COMMIT_ID,BRACES,SPDX_LICENSE_TAG,TYPO_SPELLING,MISSING_EOF_NEWLINE,LINUX_VERSION_CODE,NOT_UNIFIED_DIFF"
    name=$(git remote get-url origin 2>/dev/null)
    echo $name |grep "bootloader|u-boot" -qE
    if [ $? -eq 0 ];then
        checkpatch=$ubootcheckpatch
    fi
        list_file=$(git diff --cached --name-only |grep -v '\.rst$')
    echo $name |grep "fsbl|osdrv|u-boot|linux" -qE
    if [ $? -eq 0 ];then
        git diff --cached -- '*.c' '*.h' ':!*.rst' | "$checkpatch" --strict -q --max-line-length=120 --no-tree --ignore "FILE_PATH_CHANGES,MACRO_ARG_REUSE"
        if [ $? -ne 0 ];then
            echo "----------------------------------------------------------------------------------------"
            echo -e "         \033[31m checkpatch.pl err\033[0m: Your code failed checkpatch.pl's inspection"
            echo -e "         \033[31m $(git remote get-url origin |grep "fsbl|osdrv|u-boot|linux" -oE)\033[0m folder uses the strictest inspection"
            echo "----------------------------------------------------------------------------------------"
            err=1
        fi
    else
        git diff --cached -- '*.c' '*.h' ':!*.rst'|perl $checkpatch  --no-signoff -q  --max-line-length=120 --no-tree --ignore "$ignore"
        if [ $? -ne 0 ];then
            echo "----------------------------------------------------------------------------------------"
            echo -e "         \033[31mcheckpatch.pl err\033[0m: Your code failed checkpatch.pl's inspection"
            echo "----------------------------------------------------------------------------------------"
            err=1
        fi
    fi

}

function check_name_non-ASCII()
{

    err1=0
    changed_files=$(git diff --cached --name-only --diff-filter=ACMR -z| tr '\0' '\n' )
    for file in ${changed_files[@]}
    do
        if LC_ALL=C grep --color='auto' -qP '[^\x00-\x7F]' <<< "$file"; then
            echo "filename $file err"
            err1=1
        fi
    done

    if [ $err1 -eq 1 ];then
        echo "----------------------------------------------------------------------------------------"
        echo -e "         \033[31mnon_ascii err\033[0m: Your filename contain non-ascii characters"
        echo "----------------------------------------------------------------------------------------"
        err=1
    fi

}

function check_whitespace()
{
    # --------------------whitespace errors-----------------------
    # If there are whitespace errors, print the offending file names and fail.
    err1=0
    git diff-index --check --cached $against --
    status=$?
    if [ $status -eq 0 ]; then
        :
    else
        echo "----------------------------------------------------------------------------------------"
        echo -e "      \033[31mWhitespace err\033[0m: Your changes contain extra spaces and tabs,Or An error occurred."
        echo "----------------------------------------------------------------------------------------"
        err1=1
        err=1
    fi
}


# check_whitespace

check_name_non-ASCII
check_non_ascii
check_python
check_patch
if [ $err -eq 1 ];then
        echo "If you have any questions, please visit https://wiki.sophgo.com/pages/viewpage.action?pageId=116913701"
    exit 1
fi
