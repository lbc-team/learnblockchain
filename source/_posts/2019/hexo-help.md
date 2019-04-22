---
title: Hexo 一些高级用法
permalink: hexo_help
mathjax: true
date: 2019-04-21 20:48:34
categories: Tips
tags: Hexo
author: Tiny熊
---

大部分时候使用 markdown 语法就可以，如果需要一些高级用法，可以参考这篇文章.

<!-- more -->

## 文字颜色 
用法：
```
{% label info @ 文字 %}
或
<mark>esse</mark>
```

标签颜色除了  `info` , 还可以为空，或者为：`default` `primary` `warning` `success` `danger`， [参考文档可了解更多](https://theme-next.org/docs/tag-plugins/label) 效果如下：

{% label @颜色 %}
{% label info @ info ：信息 %}
{% label primary @ primary： 主要 %}
{% label warning @ warning： 警告 %}
{% label success @ success：成功 %}
{% label danger @ danger： 危险 %} <mark>Mark</mark>


## 引入信息

用法：
```
{% note info %}
 引入一段信息
{% endnote %}
```

标签除了  `info` , 还可以为空，或者为： `primary` `warning` `success` `danger`，[参考文档可了解更多](https://theme-next.org/docs/tag-plugins/note), 效果如下：

{% note %}
引入一段 信息
{% endnote %}

{% note info %}
引入一段 info 信息
{% endnote %}

{% note primary %}
引入一段 primary  信息
{% endnote %}

{% note warning %}
引入一段 warning  信息
{% endnote %}

{% note success %}
引入一段 success  信息：
{% endnote %}

{% note danger %}
引入一段 danger  信息
{% endnote %}

### 引用名言

用法：
```
{% cq %}Something{% endcq %}
```

标签 cq 是 centerquote的 简写，效果如：

{% cq %} 深入浅出区块链是个好博客 {% endcq %}
 


## 使用Tab

可以表达几个平列的内容或递进的内容， 用法：
```
{% tabs %}
<!-- tab Tab a -->
Tab a 信息
<!-- endtab -->
<!-- tab <code>Tab b 引用</code> -->
第二个Tab下的信息
<!-- endtab -->
{% endtabs %}
```

[参考文档](https://theme-next.org/docs/tag-plugins/tabs)可了解更多.


{% tabs learngblockchain %}
<!-- tab 比特币 -->
比特币 信息
<!-- endtab -->

<!-- tab <code>以太坊</code> -->
以太坊介绍
<!-- endtab -->

<!-- tab <strong><code>DAPP开发</code></strong> -->
**`DAPP开发`** ,  或  <strong><code>加粗引用</code></strong>.
<!-- endtab -->
{% endtabs %}


## 代码显示

两个中用法：

```
    ```java classA.ava
    public classA extends Base {
        private long a = 1;
    }
    ``` 
    
    {% code lang:bash %}
    $ cd project
    $ git clone https://github.com/xilibi2003/Upchain-wallet
    {% endcode %}
    
```

支持文件名显示（可选），支持语法高亮，语法支持有： java js cpp html bash yml 等等, 所有支持的语言可以在[这里, Available Lexers](http://pygments.org/docs/lexers/)参看
效果如下:

```java classA.java
public classA extends Base {
    private long a = 1;
}
```

{% code lang:bash %}
$ cd hexo
$ git clone https://github.com/theme-next/hexo-theme-next themes/next
{% endcode %}

还有右上角加上文件链接，

{% codeblock code.js lang:js https://github.com/lbc-team/learnblockchain  查看代码 %}
var a = 1;
{% endcodeblock %}

## 图片显示百分比

两个方式：
1. 通过图库URL作图方式修改图片大小
> 如何使用图库，请联系Tiny熊（微信：xlbxiong)
2. 使用
```md
{% fi url [alt], [title], [size] %}
```

fi 是FullImage的简写，可[参考文档](https://theme-next.org/docs/tag-plugins/full-image)，库URL作图 和 fi 这两个方式也可以混合使用，效果如：

![](https://img.learnblockchain.cn/2019/15558608460463.jpg)

用url等比例缩小图片, 如缩小一半，添加`/scale/50%`（如果图片太大可以使用）

![缩小一半示例图](https://img.learnblockchain.cn/2019/15558608460463.jpg!/scale/50%)

当然也可以固定宽度，如宽度为500px： `/fw/500`。



使用fi，图片占用35%，效果如：
{% fi https://img.learnblockchain.cn/2019/15558608460463.jpg, 图片占用35图, 35%, 35% %}


## 使用 mermaid 显示 流程图、序列图

使用[Mermaid](https://github.com/knsv/mermaid), 用法如下：

```
{% mermaid type %}
{% endmermaid %}
```


### 流程图


流程图的 type  `graph TD`, 效果如下：


{% mermaid graph TD %}
A[开发] -->|学习| B(区块链)
B --> C{投入时间多不多}
C -->|少| D[一头雾水]
C -->|多| F[人生巅峰]
{% endmermaid %}

### 序列图

流程图的 type  `sequenceDiagram`, 效果如下：


{% mermaid sequenceDiagram %}
Title: 学习区块链
Alice ->> Tim: Tim 你该学学区块链了。
Tim->>John: 区块链难学么？
John->>Tim: 不难，去深入浅出区块链
Tim->>John: 谢谢
loop 深入浅出区块链
    Tim ->> Tim: hard work 
end
Tim->>Alice: 我学好了
{% endmermaid %}



## 数据公式显示

在文章头部加上： `mathjax: true`， 用法：
行内公式使用 `$ 公式 $`，效果如：$e=mc^2$。

单独一行使用：
```
$$
e=mc^2
$$
```

效果如：
$$
e=mc^2
$$


$$\frac{\partial u}{\partial t}
= h^2 \left( \frac{\partial^2 u}{\partial x^2} +
\frac{\partial^2 u}{\partial y^2} +
\frac{\partial^2 u}{\partial z^2}\right)$$

