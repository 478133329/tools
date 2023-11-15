任务管理数据结构
OS_STK *OSTCBStkPtr        //任务堆栈指针，任务运行的CPU环境，代码地址都保存在任务堆栈中
INT8U OSTCBStat        //任务状态，未等待事件且未挂起（0x00，运行或者就绪）/任务等待信号量/任务挂起/······
INT8U OSTCBPrio        //任务优先级，0~63，62和63被统计任务和空闲任务占据
INT8U OSTCBX        //OSTCBPrio低三位
INT8U OSTCBY        //OSTCBPrio向右移动三位
INT8U OSTCBBitX
INT8U OSTCBBitY
struct os_tcb *OSTCBNext
struct os_tcb *OSTCBPrev

OSTCBTbl和OSTCBPrioTbl
OSTCBTbl是任务控制块实体数组
OSTCBPrioTbl以优先级为索引，任务优先级->任务控制块地址。

空闲链表和就绪链表
OSTCBFreeList代表空闲链表，指向第一个空闲任务块/空（单向链表）
创建一个任务
//从空闲链表取走第一个空闲控制块，并用ptcb记录下来
ptcb = OSTCBFreeList 
if (ptcb != (OS_TCB *)0) {
        OSTCBFreeList = ptcb->OSTCBNext
}
//插入到就绪链表中
ptcb->OSTCBNext = OSTCBList
ptcb->OSTCBPrev = (OS_TCB *)0
if (OSTCBFreeList != (OS_TCB *)0) {
        OSTCBList->OSTCBPrev = ptcb
}
OSTCBList = ptcb

INT8U  OSTaskCreate (void   (*task)(void *p_arg),
                     void    *p_arg,
                     OS_STK  *ptos,
                     INT8U    prio)
void (*task)(void *p_arg)函数指针，指向void task(void *p_arg)


一个指针包含两个信息：指针指向的地址，步长
int *a=8  a指向8的地址，步长为4
void*类型指针，步长未定
 
typedef unsigned char UINT8
typedef char INT8

就绪组和就绪表
INT8U OSRdyGrp
INT8U OSRdyTbl[OS_RDY_TBL_SIZE]
给定一个组号，如何获取组号在OSRdyGrp中的位置？
OSMapTbl[3组] = 0000 1000
给定一个OSRdyGrp，如何获取最高优先级所在的组号？
（空间换时间）通过查找表获取 OSUnMapTbl[OSRdyGrp]


OS_Sched
OS_SchedNew        //获取就绪表中最高优先级

OS_TASK_SW        //if OSPrioHighRdy != OSPrioCur 则需调用该函数进行任务切换（上下文的保护）
x86体系结构寄存器
8个通用寄存器
EAX EBX ECX EDX ESI EDI ESP EBP









任务的挂起和恢复
挂起一个任务是将任务切换为阻塞态，阻塞态->就绪态->运行态
当任务由于中断而放弃CPU时，会被切换为挂起态，中断返回时切换为运行态，挂起态->运行态
