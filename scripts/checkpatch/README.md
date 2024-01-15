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

kernel中不要使用驼峰命名。

camel_rename.sh用于将驼峰命名更改为下划线命名，例如：

nCount -> n_count

_Format -> _format

GetCount -> get_count

部分重命名规则还不合适，另外checkpatch.pl也会遗漏某些驼峰命名，因此需要手动再检查一下。

正则表达式部分不太熟练，因此命令很冗余，需要后续完善。

---

