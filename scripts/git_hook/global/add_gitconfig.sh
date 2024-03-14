HOOKS_PATH="/media/cvitek/git-config/hooks/"
for user_home in /home/*; do
        user=$(basename "$user_home")
        mypath=$(echo "/home/$user/.gitconfig")
        echo "------------------$mypath"
        cat $mypath|grep "/media/cvitek/git-config/hooks"
        if [ $? -ne 0 ];then
                echo "[core]" >> $mypath
                echo "        hooksPath = /media/cvitek/git-config/hooks/" >> $mypath
        fi
        cat $mypath
done

echo "Global Git hooks path set for all users."