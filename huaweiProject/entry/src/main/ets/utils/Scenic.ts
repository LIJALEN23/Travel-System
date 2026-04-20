/* 后端统一返回类型
  * 对应后端的 Result.java
  */
export interface Result<T = any> {
  code: number;
  msg: string;
  data: T;
}

// 景区基础信息
export interface ScenicSpot {
  id: number;
  spotName: string;
  maxCapacity: number;
  totalParking: number;
  address: string;
  longitude: number;
  latitude: number;
  mapUrl: string;
  createTime: string;
  updateTime: string;
}

// 景区实时数据
export interface ScenicRealTimeData {
  currentVisitors: number;
  remainingParking: number;
  cableWaitTime: number;
}

// 景区管理人员
export interface ScenicManager {
  id: number;
  spotId: number;
  workNo: string;
  managerName: string;
  phone: string;
  post: string;
  status: number;
  createTime: string;
}

// 景区应急人员
export interface ScenicEmergency {
  id: number;
  spotId: number;
  rescuerName: string;
  rescuerPhone: string;
  vehicleNo: string;
  createTime: string;
}

// 景区完整详情
export interface ScenicDetail {
  baseInfo: ScenicSpot;
  realTimeData: ScenicRealTimeData;
  managerList: ScenicManager[];
  emergencyList: ScenicEmergency[];
}