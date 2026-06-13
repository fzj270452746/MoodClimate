# Mood Climate（情绪气候）

Version 1.0

---

# 一、产品定位

## 产品名称

Mood Climate

中文名称：

情绪气候

副标题：

观察情绪，而不是记录情绪。

---

# 二、产品愿景

市面情绪App主要关注：

今天心情如何？

例如：

* 开心
* 难过
* 焦虑
* 愤怒

本质：

记录情绪。

---

Mood Climate关注：

```text
情绪如何形成
情绪如何变化
情绪如何循环
```

帮助用户发现：

```text
我的情绪季节

我的情绪气候

我的情绪规律
```

---

# 三、核心理念

天气：

短暂变化。

例如：

```text
今天焦虑
```

---

气候：

长期趋势。

例如：

```text
过去三个月持续焦虑
```

---

用户最终获得：

属于自己的：

```text
人生情绪气候图
```

---

# 四、核心特色功能

## 核心特色1

情绪天气系统

每日记录：

```text
晴天 ☀

多云 ☁

小雨 🌦

暴雨 🌧

雷暴 ⛈

大风 🌪

大雪 ❄
```

而不是：

```text
开心
难过
焦虑
```

---

用户更容易记录。

---

## 核心特色2

情绪季节系统

自动分析：

过去90天。

形成：

```text
春季
情绪恢复期

夏季
情绪活跃期

秋季
情绪稳定期

冬季
情绪低潮期
```

---

形成个人情绪四季。

---

## 核心特色3

人生气候图

核心特色功能。

展示：

```text
2025

春

↓

夏

↓

秋

↓

冬

2026

春

↓
...
```

观察长期变化。

---

## 核心特色4

情绪风暴系统

自动识别：

```text
连续7天暴雨

连续14天雷暴
```

生成：

```text
情绪风暴事件
```

---

帮助用户回顾人生低谷。

---

## 核心特色5

情绪晴空系统

自动发现：

```text
连续30天晴天
```

生成：

```text
情绪黄金时期
```

---

形成成长记录。

---

## 核心特色6

情绪气候地图

展示：

```text
焦虑带

平静区

幸福区

压力区
```

形成情绪地图。

---

## 核心特色7

人生事件关联

记录：

* 毕业
* 换工作
* 分手
* 结婚
* 创业

---

自动关联：

情绪变化。

---

# 五、产品结构

```text
情绪观测站

│

├─ 今日天气
├─ 气候长廊
├─ 风暴档案馆
├─ 气候地图
├─ 人生事件簿
├─ 季节报告
└─ 人生气候报告
```

---

# 六、情绪记录系统

## 每日记录

记录时间：

自动。

---

天气类型：

```text
晴天
多云
阴天
小雨
暴雨
雷暴
大风
大雪
```

---

情绪强度：

```text
1~10
```

---

关键词：

例如：

```text
工作
家庭
学习
健康
恋爱
```

---

自由笔记：

可选。

---

# 七、情绪气候系统

自动统计：

## 当前季节

例如：

```text
恢复之春
```

---

## 当前气候

例如：

```text
温和稳定型
```

---

## 当前温度

例如：

```text
78°
```

代表整体情绪状态。

---

# 八、风暴档案馆

核心特色页面。

自动收录：

```text
2026.03

连续10天雷暴
```

---

记录：

* 起因
* 持续时间
* 结束时间

---

形成情绪历史档案。

---

# 九、晴空纪念馆

自动记录：

```text
连续45天晴天
```

---

展示：

人生高光时期。

---

# 十、人生事件簿

记录：

```text
获得Offer

创业

结婚

搬家
```

---

自动关联：

事件前后气候变化。

---

# 十一、年度气候报告

生成：

## 数据

* 晴天比例
* 风暴次数
* 最长晴空期
* 最长低谷期
* 情绪恢复能力
* 气候稳定指数

---

导出：

PNG

PDF

Markdown

---

# 十二、视觉设计

禁止：

* 日记风
* 备忘录风
* 心理测试风
* ToDo风

---

采用：

```text
气象站

天气地图

气候中心

卫星观测
```

主题。

---

# 十三、Objective-C领域模型

禁止：

```objective-c
MoodRecord
EmotionItem
DiaryEntry
```

---

采用：

```objective-c
MCWeatherSnapshot

MCClimatePeriod

MCStormArchive

MCSunnyEpoch

MCAtmosphereNode

MCSeasonCycle

MCClimateAtlas
```

---

# 十四、Objective-C架构设计

禁止：

```text
Manager

Service

Repository

ViewModel
```

统一结构。

---

推荐：

```text
ClimateDomain

│

├─ MCAtmosphereEngine
├─ MCSeasonAnalyzer
├─ MCStormDetector
├─ MCClimateAtlas
├─ MCChronicleVault
└─ MCReportForge
```

---

所有代码围绕：

```text
气候
季节
天气
风暴
大气层
```

组织。

---

# 十五、目录结构规范

禁止：

```text
Models
Managers
Services
ViewModels
```

---

推荐：

```text
Atmosphere

Weather

Climate

Storms

Seasons

Chronicles

Reports

Storage

FoundationKit
```

---

# 十六、调用链规范

避免：

```text
ViewController

↓

Manager

↓

Database
```

---

采用：

```text
WeatherScene

↓

MCAtmosphereEngine

↓

MCClimateAtlas

↓

MCChronicleVault
```

---

或：

```text
StormScene

↓

MCStormDetector

↓

MCSeasonAnalyzer

↓

MCClimateAtlas
```

---

# 十七、状态管理规范

禁止：

```objective-c
Singleton Everywhere
```

---

推荐：

```objective-c
MCWeatherEvent

MCStormEvent

MCSeasonEvent

MCClimateEvent
```

事件驱动。

---

# 十八、第三方库建议

## 数据存储

### WCDB

推荐指数：

★★★★★

腾讯数据库框架。

---

### FMDB

轻量级SQLite封装。

---

## AutoLayout

### Masonry

Objective-C经典布局框架。

---

## 模型转换

### YYModel

高性能。

---

### Mantle

复杂模型映射。

---

## 图表

### AAChartKit

适合OC项目。

---

### Charts

统计图展示。

---

## 图形渲染

### Texture

异步UI框架。

适用于气候地图。

---

## 动画

### POP

Facebook动画库。

---

### Lottie

天气动画。

---

## 图片处理

### SDWebImage

本地缓存。

---

## 路径与关系图

### PocketSVG

气候路径图。

---

### CoreGraphics

自定义天气轨迹绘制。

---

# 十九、反AI模板化开发规范

## 命名规范

禁止：

```objective-c
AppManager
DataManager
UserManager
CommonUtil
```

---

采用：

```objective-c
MCStormDetector

MCAtmosphereEngine

MCSeasonAnalyzer

MCClimateAtlas

MCChronicleVault
```

---

## 页面规范

禁止：

```text
首页
记录
统计
我的
设置
```

---

采用：

```text
情绪观测站

天气长廊

风暴档案馆

季节中心

气候地图
```

---

## 数据规范

禁止：

```objective-c
Record

Item

Data

Model
```

泛化命名。

---

采用：

```objective-c
Atmosphere

Climate

Season

Storm

Weather
```

领域命名。

---

## UI规范

禁止：

TabBar + List + Detail

标准工具App结构。

---

推荐：

卫星观测中心结构。

---

# 二十、产品护城河

随着使用时间增长：

用户获得：

* 情绪天气库
* 情绪季节史
* 风暴档案馆
* 人生气候地图
* 年度气候报告

最终形成：

```text
个人情绪气候宇宙
```

而不是普通情绪记录工具。

数据沉淀越久。

价值越高。

形成长期使用动力。
