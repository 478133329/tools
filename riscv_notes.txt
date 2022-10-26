https://github.com/478133329/cvStudy.git

git@github.com:478133329/cvStudy.git

git remote set-url git@github.com:478133329/cvStudy

In usually, HEAD points to the latest commit, which means it's a attached HEAD,
but if the HEAD point to a commit directly instead of branch, it's a detached HEAD.

git HTTPS访问方式已不支持用户密码直接访问，可生成带有期限的个人令牌来代替密码。
git SSH访问方式步骤：ssh-keygen -t ed22519 -C "478133329qq.com"
-> ssh-add （client）private-key -> 将public-key扔到github上
mytoken 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


shell if

if [-d dir]   // 如果当前目录下存在dir目录
if [-f file]  // 如果当前目录下存在file文件
if [-a -x -r -w ...]

time + 命令 可记录该命令的运行时间

lscpu 查看cpu信息
make -j4 使用四核进行make编译
e.g.
make 单线程编译	1min+
make -j2 双线程编译	30s
使用ccache + make -j2	10s 

which + 命令	which gcc -> /usr/bin/gcc

linux系统环境变量、用户环境变量
/etc/profile
/home/wangsijie/.bash_profile .profile .bashrc
source更新当前会话环境变量，否则需要重启会话。


linux内核 头文件路径 /usr/include  库文件路径 /usr/lib  源文件路径 /usr/src？
内核源码目录 /lib/modules/$(shell uname -r)/build

模块能够调用 printk 是因为, 在 insmod 加载了它之后, 模块被连接到内
核并且可存取内核的公用符号.

/usr/lib - 所有软件的库都安装在这里。但是不包含系统默认库文件和内核库文件


在驱动开发时，可以将驱动设计为内核模块

一、内核模块变成注意事项：
1、不能使用C库和C标准头文件
2、使用GNU C（在标准C上添加了额外一些语法，不多）
3、没有内存保护机制
4、不能处理浮点运算
（上面四点是硬性规定）
5、注意并发互斥性和可以执性

二、内核模块如何编写
#include <linux/init.h>
#include <linux/module.h>
必须实现加载函数和卸载函数
int xxx()
{
	return 0; \\1 means load failed
}

void yyy()
{
}
module_init(xxx);
module_exit(yyy);

内核中的打印函数printk();

三、内核模块的编译
内核模块的编译要用内核的编译方法来进行编译
$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
KERNELDIR选择 /lib/modules/$(uname -r)/build
                     和 /usr/src/$(uname -r)   都编译成功了

四、模块的使用
insmod 加载模块（调用模块加载函数）
rmmod 卸载模块（调用模块卸载函数）

obj-m := <module_name>.o

The kbuild system will build <module_name>.o from <module_name>.c,
and, after linking, will result in the kernel module <module_name>.ko.


Kconfig文件组成

->filename:Kconfig
mainnemu / menu "目录名字"
source "从内核开始的相对路径"       子目录

config 选项名   (选项名为HELLO，保存后则在 .config中生成CONFIG_HELLO变量，保存模块编译形式y/n/m)
	tristate(三种状态)/bool(少了模块状态)  "menuconfig中现时的名称"
	depends on 依赖关系
	select 反向依赖
	default y/n/m (*/ /M)
	help 帮助信息
endmenu


.config文件只在内核源码根目录下存在，包含各种变量

杂项设备，主设备号均为10
cat /prov/misc 查看杂项设备


cat /proc/version 查看linux内核版本
apt-get install linux-source 会安装当前版本的内核源码到/usr/src

linux-source是内核源码，包含了.c、.h等文件，结构上包含了linux-header。
/lib/modules/$(uname -r)/build/include 内核函数头文件
linux-headers-versoin-generic里都是指向linux-headers-version的链接
/usr/src可能没有linux-source-version源文件
lib/modules/version/build/include 
/usr/include 里面的 Linux 内核头文件，是专门编译 libc 用的。不能保证内核模块的编译要求。

C89 C99 C11


apt-get install 命令会下载安装包，并进行安装部署（可能会变动很多目录，对我们是不可见的）
install linux-headers 后,，发现 /lib/modules 目录下linux-headers会更新

apt-get purge   apt-get autoremove

dpkg -l | grep 查看已安装的包


在内核中新增程序需要完成三个操作
1、将源代码放到相应目录下
2、在Kconfig中添加配置项
3、在Makefile中加入编译项


主设备号12位，次设备号20位。
dev_t dev = 0;
int result = 0;
dev = MKDEV(int major, int minor);
result = register_chrdev_region(dev, num, name)

unregister_chrdev_region (dev, num)

cat /proc/devices 查看已加载设备的主设备号


设备编号的注册仅仅是驱动程序代码必须完成的许多工作中的第一件事情而已

模块参数
static int val = 100;
module_param(val, int, 权限控制)
MODULE_PARM_DESC(val, "this is a int val.")
insmod hello.ko val=200;  //insmodm时可指定参数

可在/sys/module/hello/parameters中看到参数的值


驱动设计中三个重要的内核数据结构

file_operations
file  内核在open时创建（打开文件描述符）
inode 中的struct cdev

字符设备注册
cdev初始化 cdev_init
加入内核 cdev_add
从系统中去除一个字符设备 cdev_del

register_chrdev_region(dev_t dev, int num, char *name) 向内核申请一个设备号

struct cdev cdev;
struct file_operations test_ops = {
	.owner = THIS_MODULE,
	.read = read_func,
	.write = write_func
}
cdev_init(&cdev, test_ops);
cdev.owner = THIS_MODULE;
cdev_add(&cdev, dev, 1);
// cdev_del(&cdev);

mknod /dev/hello c 11 0
	
字符设备的缓存大小在驱动中定义？

read(struct file *filp, char *buff, size_t count, loff_t *offp)
将filp中的缓存读入用户空间的buff copy_to_user

write(struct file *filp, const char *buff, size_t count, loff_t *f_pos)
将用户空间的buff写入filp中的缓存 copy_from_user


通常习惯将设备定义为一个设备相关的结构体，其包含该设备所涉及的cdev、私有数据及信号量等信息。
e.g. scull_dev包含了cdev

宏和函数
宏的好处
#define DECODE_R(inst) uint8_t rt = (inst).rtype.rt, rs = (inst).rtype.rs
#define DECODE_M(inst) uint8_t addr = (inst).mtype.addr
在不同条件下调用不同DECODE时，在宏中可以定义所需变量

union自己的理解
对一片内存进行不同的解释；
union和struct混用实现指令结构
typedef union {
	struct {} R;
	struct {} J;
	inst;
}inst;

riscv32
riscv32有哪几种指令格式?
六种指令格式。寄存器操作R指令，短立即数操作和Load操作的I指令，Store操作的S指令，
条件跳转操作的B指令，长立即数操作的U指令，无条件跳转操作的J指令。
LUI指令的行为是什么?
LUI(Load Upper Immediate)
构造一个32为立即数（高20位由立即数字段指定，第12位填充零），最终的结果放到rd寄存器中。
mstatus寄存器的结构是怎么样的?

其他
32个通用寄存器，1个程序计数器，CSR寄存器
PC寄存器对程序员不可见

ISA留有一些保留操作码，e.g.利用保留的操作码实现了退出程序nemu_trap

运行时环境需要向程序提供一种结束运行的方法
运行时环境是直接位于计算机硬件之上的, 因此运行时环境的具体实现, 也是和架构相关的.

运行时系统是对比编译系统这个说法提出来的，诸如编程语言的内存管理，垃圾回收，线程，程序结束等等。

GNU/Linux环境下 .a静态库 .so动态库

grep 文本过滤
sed 结合正则表达式对文本进行增删改查，以行为处理单位，匹配失败默认输出，匹配成功修改后输出
两个常用参数 -n 取消默认输出 -i 修改会影响到原文件（否则只修改内存）
内置命令符  a、d、i、p、s/正则表达式/替换内容/g
sed匹配范围 空地址(全文的行)，单地址，/pattern/被模式匹配到的每一行/范围区间10,20/步长1~2(1,3,5...)

mkdir -p 递归创建目录，上层目录不存在则创建

Makefile
make 命令后可跟多个目标
.PHONY:
.DEFAULT_GOAL=
$(MAKECMDGOALS)
abspath $(相对路径)   ->   转绝对路径
addprefix 加前缀
addsuffix 加后缀
basename 取前缀  .之前的内容
sort <list> 升序排序并去掉相同的字符串
join <list1> <list2> list1 list2每个项分别连接
wildcard 若存在该目录/文件则返回，不存在则返回空，可与通配符搭配使用

= 将整个Makefile展开后最终的赋值，和赋值语句的位置没有关系
x:=   x的赋值和该赋值语句的位置有关系
?= 是如果没有被赋值过就赋予等号后面的值
+= 是添加等号后面的值
什么时候用 := ?    a := a + 1 这种情况

.mk 文件，Makefile语法

INC 增量 INC_PATH
CFLAGS c编译器的选项
-I 头文件路径 -L 库文件路径 -llib 链接名为lib的库文件
-g 包含标准调试信息 -S 生成汇编代码 -E 只做预处理 -o 略 
-Wall 编译阶段显示所有警告 -Werror 把所有警告当成错误处理，遇到警告就会编译停止 -Ox 编译器优化选项
CXXFLAGS x++编译器的选项

内联汇编
asm或__asm__开开头
asm volatile("asm code":output:input:changed register)；
:changed register没有的话必须省略
"add %0,%1%2\n\t":"=r"(c):"r"(a),"r"(b):"memory"

执行make menuconfig后，编译系统会把所有的配置信息保存到源码顶层目录下的.config文件中，然后将.config中的内容转换为C语言能识别的宏定义更新到include/generated目录下的autoconf.h文件中。


内联函数
若一个函数体量很小，调用时跳转到该函数位置执行，消耗相对较大
编译器会将调用内联函数的地方直接插入内联函数代码
宏是由预处理器处理，内联函数由编译器处理

inline关键字无法决定被关键字所修饰的函数是否最后真正会被内联。我们其实只有建议权，编译器有决定权。
所以inline前面还是加上static才好

do{
	code
}while(0);
宏定义函数常用以上形式，能保证code一定会被执行一次。
#define add(x) do{x++;x++}while(0);

如果 #define add(x) x++;x++
if (y)
	add(i);
else
	...
预处理后为
if (y)
	x++;
	x++;
else
	...
错了

->优先级较高和括号一个等级
&s->v  s结构体成员变量v的地址

riscv32I 两条长立即数U型指令
lui  立即数作为高20位存放寄存器中
auipc  立即数高20位与PC值相加存放寄存器中

nemu两个声明函数的宏
def_EHelper
def_rtl

addi是算数运算
addi的局限性：立即数只有12位，可与lui指令结合使用
li指令（伪指令），li a0 0x00000001
汇编器决定将li转换为哪种指令组合
li x5, 0x80   ->   addi x5, x0, 0x80
li x5, 0x12345001   ->   lui x5, 0x12345    addi x5, x5, 0x001
li x5, 0x12345FFF   ->   lui x5, 0x12346    addi x5, x5, 0xFFF


jal（Jump And Link）


	int i = 0x0fffffff;     
   	printf("%x\n", i);	// fff ffff
	i = i << 4;
	printf("%x\n", i);	// fff ffff0
	i = i >> 4;
	printf("%x\n", i);	// ffff ffff


结构体中的位域
struct{
 int a:5;
 int b:5;
}
a和b两个变量分别占5个bit。

截断
扩展（有符号、无符号）
32位无符号转64位有符号，符号不扩展
32位有符号转64位无符号，符号扩展
    // 32位有符号转64位无符号
    int s = 0xf0000004;
    unsigned long long lu = s;
    // lu = 0xffff ffff f000 0004
s先扩展，因为s是有符号数，所以符号扩展。
扩展后将二进制赋给lu，lu是无符号数，按照无符号数解释这一串二进制。

jal
imm:20|10-1|11|12-19 src:5 opcode:7
jalr

