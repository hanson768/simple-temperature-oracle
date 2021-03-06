# A Simple Oracle Contract

### 简介：实现一个简单的预言机智能合约，获取当前温度。    
&nbsp;
### 基本功能：  
1、获取当前温度  
2、设置更新当前温度  
&nbsp;

### 实现思路：  
&emsp; 预言机的实现，可以采用 请求/响应（request–response）模式 或 立即读取（immediate-read）模式。前者相对复杂度高一些，本工程采用后者。 设计过程考虑以下因素：
- 如何确保去中心化的并且没有单点故障？  
  ：*从节点角度，多节点喂数据，天然就是分布式的。从oracle合约角度，管理员角色是中心化的，可以考虑交给治理委员会，通过多签和提案机制进行去中心化，类似compound的治理机制。*

- 如何确定谁可以提交温度？  
  ：*使用授权机制，只有在授权名单内的节点才可以提交数据。*

- 如何确保没有人提交错误的值？  
   ：*1、数据筛选，比如取最近一个周期的数据集，取其中位值。  
    2、质押资产，对于恶意或错误的数据进行处罚，这部分逻辑可以链下去做，但相关记录都留在链上。*

- 如何检测异常值？  
  ：*在更新数据之前，加入检测异常的逻辑，比如环境温度限定在 -273.15 ～ 100.00 摄氏度之间。*  
&nbsp;
### 待改进：
1、节点激励和处罚。比如某个节点的数据是中位数，则此数据被有效采纳，给予节点相关token激励; 关于处罚，可以直接用合约实现处罚逻辑，或者链下分析处罚，将处罚记录写在链上。  

2、节点数据筛选逻辑。比如取最近一个周期的数据集，取其中位值作为有效数据进行实际更新。  

3、oracle合约owner的权限管理。考虑交给治理委员会，通过多签和提案机制进行去中心化，类似compound的治理机制。