DJFPSKit
===============

介绍
===============
DJFPSKit是用于测app各页面fps值的工具，整个面板使用挂载的方式，对原应用不产生影响(当然crash的话是影响了.)，也不需要在原项目中插入代码。(除了一个开关.)<br/>目前只支持通过pod安装你的项目中使用，例子后续补上一个。
安装
===============

### CocoaPods
1. 在 Podfile 中添加  `pod 'DJFPSKit','0.0.3'`。
2. 执行 `pod install` 或 `pod update`。

使用
===============
1. 引入#import "DJFPSManager.h"
2. 打开面板 `[DJFPSManager sharedManager].mainSwitch = YES;`
之后再面板中有开启记录和查看按钮，使用比较简单。可以查看已经记录的页面fps情况。

截图
===============
 ![image](https://github.com/ldhlfzysys/DJFPSKit/blob/master/screenshot/1.png)
 ![image](https://github.com/ldhlfzysys/DJFPSKit/blob/master/screenshot/2.png)
 ![image](https://github.com/ldhlfzysys/DJFPSKit/blob/master/screenshot/3.png)
