---
title: markdown语法的学习(1)
date: 2016-4-19
categories:
  - markdown
  - Atom
tags:
  - markdown
  - Atom
---
##### 最近有学习到一个开源的博客工具Hexo,了解到它利用Markdown来编写博客内容然后生成静态的网页,而Markdown的结构比较简单,编写起来非常的方便.
#### 现在是我在学习Markdown时做的笔记

##### 首先编写工具的选择,最近在玩Atom,貌似该开发工具对Markdown支持的不错,各种预览功能和语法提示等等,同时Atom也是一个很强大的编辑工具,所以选择它来编写Markdown
Atom相关介绍和各版本下载地址[https://github.com/atom/atom](https://github.com/atom/atom "Atom")


#### 标题设置
标题主要用==、--和#来表示，#数量越多表示标题字体越小
=
```
一级标题
==
```
结果预览：
一级标题
==


```
二级标题
--
```
结果预览：
二级标题
--
#
```
# title 1
## title 2
### title 3
#### title 4
##### title 5
###### title 6
```
结果预览：
# title 1
## title 2
### title 3
#### title 4
##### title 5
###### title 6
```
*斜体*
```
*斜体*
```
**粗体**
```
**粗体**

有序列表
```
1.  item1
2.  item2
3.  item3
或者
2.  item1
1.  item2
3.  item3
```
预览结果
2.  item1
1.  item2
3.  item3

无序列表
```markdown
* item1
* item2
* item3
```
结果预览
* item1
* item2
* item3

嵌套
```
1.  第一级别1
  1. 第二级别1
  2. 第二级别2
2.  第一级别
```
1.  第一级别1
  1. 第二级别1
  2. 第二级别2
2.  第一级别

链接

引用式
```
I get 10 times more traffic from [Google][1] than from [Yahoo][2] or [MSN][3].  

[1]: http://google.com/        "Google"
[2]: http://search.yahoo.com/  "Yahoo Search"
[3]: http://search.msn.com/    "MSN Search"
```

I get 10 times more traffic from [Google][1] than from [Yahoo][2] or [MSN][3].  

[1]: http://google.com/        "Google"
[2]: http://search.yahoo.com/  "Yahoo Search"
[3]: http://search.msn.com/    "MSN Search"

内联式
```
[Google](http://www.google.com "Google")
```
[Google](http://www.google.com "Google")

表格
```
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
```

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
```
dog | bird | cat
----|------|----
foo | foo  | foo
bar | bar  | bar
baz | baz  | baz
```
dog | bird | cat
----|------|----
foo | foo  | foo
bar | bar  | bar
baz | baz  | baz
未完待续
