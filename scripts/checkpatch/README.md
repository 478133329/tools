## Linux内核代码规范问题检测

---

checkpatch对当前内核所有文件进行检测，非常耗时10h+左右。另外，针对最新拉下来的内核源码，checkpatch依旧会检测出非常多的错误，逐个修改是不太现实了。

---

所以检测对象由全部改为戒指目前修改过的文件，即从linux-5.1到linux-5.1-sophgo之间的修改。

git diff 第一次的commit --name-only

---

直接把脚本复制到linux运行会出现报错，原因是复制过去后每行的末尾都多出了^M$。

sed -i "s/\r//" xxx.sh

---

u-boot的提交记录包含了很多不是公司进行的改动，并且同样存在检测时间过长问题。

使用 git log --author="sophgo\\|cvitek" 对提交的对象进行约束。

---

