//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

contract SimpleTemperatureOracle is Ownable{
    mapping(address => bool) public candidates;
    mapping(address => uint256) public candidatesPledge;
    uint256 public pledgeThreshold = 1*1e18;

    uint128 public tempMaxLimit = 10000 + 27315;//使用热力学温标，T(K)=t(℃)+273.15，保留两位小数，乘数因子为100。即实际摄氏度为(10000 + 27315 - 27315)/100 = 100摄氏度。
    uint128 public tempMinLimit; // 默认值0，使用热力学温标，开尔文0度，代表-273.15摄氏度
    uint256 private temperature;

    event Pledge(address candidate, uint256 amount);
    event SetTemp(address candidate, uint256 temp, bool valid);
    event Punish(address candidate, uint256 amount, string reasonHash);

    //获取当前温度
    function getTemperature() public view returns (uint256) {
        return temperature;
    }

    //设置温度。供中心化喂数据节点的节点调用。
    function setTemperature(uint256 temp) external {
        require(candidates[msg.sender], "invalid candidate");
        require(candidatesPledge[msg.sender] >= pledgeThreshold, "pledge not enough");

        bool valid = checkTemperatureValid(temp);

        if(valid){
            temperature = temp;
        }
    
        emit SetTemp(msg.sender, temp, valid);
    }

    //设置节点名单，只有在名单类内的节点才有资格更新数据
    function setCandidates(address candidate, bool status)external onlyOwner {
        candidates[candidate] = status;
    }

    //质押平台币。可用于节点低质量数据的处罚
    function pledge() external payable{
        require(candidates[msg.sender] && msg.value > 0,"invalid candidate");
        candidatesPledge[msg.sender] += msg.value;

        emit Pledge(msg.sender, msg.value);
    }

    //是否有效温度，比如是否超过了环境温度的上下限
    function checkTemperatureValid(uint256 temp) private view returns(bool){
        return temp > tempMinLimit && temp < tempMaxLimit;
    }

    //节点处罚
    function punishCandidate(address candidate, uint256 amount, string memory reasonHash) external onlyOwner{
        require(candidatesPledge[candidate] >= amount,"out of balance");
        candidatesPledge[candidate] -= amount;
        
        emit Punish(candidate, amount, reasonHash);
    }

    //提取平台资产
    function withdrawAsset(address payable withdrawAddr, uint256 amount) external onlyOwner {
        require(withdrawAddr != address(0), 'invalid address');
        require(amount <= address(this).balance, 'out of balance');
        withdrawAddr.transfer(amount);
    }
}