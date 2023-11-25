## Linux内核代码规范问题检测

checkpatch对当前内核所有文件进行检测，非常耗时10h+左右。另外，针对最新拉下来的内核源码，checkpatch依旧会检测出非常多的错误，逐个修改是不太现实了。

---

所以检测对象由全部改为戒指目前修改过的文件，即从linux-5.1到linux-5.1-sophgo之间的修改。



git diff 第一次的commit --name-only

