### 系统环境

Ubuntu 20.04 LTS 64bit
flex 2.6.4 | bison 3.5.1 | gcc 9.4.0 | Make 4.2.1

### 如何编译运行

提交内容包括以下文件：
- lex.l
- parse.y
- node.c node.h
- Makefile

在目录下运行`make`，会依次执行`flex`，`bison`和`gcc`编译得到`main`。

运行`./main test.txt`（假设`test.txt`是测试的文本）得到输出。

`make clean`可以删除产生的文件，只保留提交的源文件。

### 功能实现

#### 基础要求

完成词法分析和语法分析，按格式要求输出语法树，出错则输出错误信息。

#### 词法分析

可以识别八进制和十六进制数，会转化为十进制输出。

可以识别科学表达式形式的浮点数，转化为一般形式输出。

可以识别注释，不符合要求的注释（比如嵌套或没有`/*`的多行注释）会产生错误信息：

```sh
Error type A at Line [行数]: Invalid comments
```

不过没有`*/`作为结束标志的多行注释会出现问题（直接忽略掉`/*`之后的所有内容）。:sob:

出现未定义字符，不符合词法定义的，会输出错误信息：

```sh
Error type A at Line [行数]: Mystirious character [字符]
```

#### 语法分析

检测到语法错误会调用`yyerror()`函数。进行语法分析的函数`yyparse()`检测到语法错误会停止分析，那么**如何进行错误恢复**，使程序继续分析后续的文本呢？

使用保留的`error`符号，将其放在产生式中，提供新的产生式用于错误恢复。

```c
ExtDef: Specifier ExtDecList SEMI       { $$ = newNode("ExtDef", 3, $1, $2, $3); }
    | Specifier ExtDecList error SEMI   { printf("Missing \';\'\n"); }
```

这里我做的仅仅是在产生式中`;`、`)`、`]`、`}`前面加上`error`，错误信息输出“缺失”相应的符号。输出的语法错误信息类似下述：

```sh
Error type B at Line [行数]: syntax error.Missing ';'
```

#### 语法树定义和实现

语法树节点的定义如下，我采用孩子兄弟节点的形式定义节点之间的连接。

```c
typedef struct node
{
    char *name;                 // 节点名称
    int line;                   // 节点所在行数
    struct node *fchild, *next; // 第一个子节点，下一个兄弟节点
    union                       // 使用union保存值，ID或TYPE保存其名称
    {
        int intval;
        float fltval;
        char *id_type;
    };
} nd;
```

构造函数`nd* newNode(char* name, int num, ...)`创建新节点，`num`表示该节点下有几个子节点，子节点的个数当然是不确定的，这里我使用了变长参数，需要`#include <stdarg.h>`。

节点有若干个不同类型：
1. 非终结符
2. 非终结符，但其对应产生式右部为空，`newNode([name], 0, -1);`
3. 终结符，`newNode([name], 0, yylineno);`

这样在输出语法树时可以根据指针内容和行数值的不同设置不同的输出格式。

我还设置了几个全局变量，方便输出：

```c
int nodeNum;            // 节点总数
nd* nodeList[5000];     // 所有节点指针保存在这
int nodeIsChild[5000];  // 对应节点是否是子节点，输出时便利该数组可以找到根节点
int hasFault;           // 是否有错误，如果有就不能输出语法树
```

### 遇到的问题

1. 算符的优先级，解决移进/归约冲突
2. 注释的处理
3. 输出的格式，缩进对齐以及不同节点需要输出的信息不同
4. 语法树节点数据结构的设计，由于子节点数目不一，我觉得使用以往经验的父子节点的结构不太方便，所以使用了兄弟孩子节点的方式
5. C语言对于字符串的处理，代码中不断出现对字符串字面量、`char*`变量的使用会导致问题，起初我使用`strcpy`导致运行时出现`Segmentation fault(Core dumped)`的错误，后来经过修改解决了
6. 测试的时候发现如果标识符的定义必须在语句块的开始，这是CMINUS的语法定义决定的