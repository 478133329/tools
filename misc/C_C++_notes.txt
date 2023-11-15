typedef struct {
	int a;
	int b;
} Node;

结构体初始化方法
1、参数列表初始化
关于参数列表初始化
C++可以省略等号，而C不可省略
Node n1{11, 22};     Node n2 = {11, 22}; 
2、先声明，后面对每个成员挨个定义

结构体数组的初始化
Node node_list[] = {{1, 2}, {3, 4}, {5, 6}};
Node node_list[3] = {{1, 2}, {3, 4}, {5, 6}};

结构体默认构造函数，拷贝构造函数，重载=运算符

switch(a)
{
//这里的代码不会执行
	case 1:
	case 2:
	default:
}
可以把case:是做一个个标签

数组的首地址
int a[5];
a	or	&a[0]