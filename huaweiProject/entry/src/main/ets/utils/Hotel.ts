/* 后端统一返回类型（复用景区的Result，也可单独定义）
  * 对应后端的 Result.java
  */
export interface Result<T = any> {
  code: number;
  msg: string;
  data: T;
}

// 酒店基础信息（对齐后端实体）
export interface HotelBase {
  id: number;
  hotelName: string;
  starLevel: number;
  maxCapacity: number;
  totalParking: number | null;
  address: string;
  longitude: number;
  latitude: number;
  mapUrl: string | null;
  createTime: string;
  updateTime: string;
}

// 酒店实时数据
export interface HotelRealTimeData {
  id: number;
  hotelId: number;
  currentVisitors: number;
  remainingParking: number | null;
  occupancyRate: number | null;
  updateTime: string;
}

// 酒店管理人员
export interface HotelManager {
  id: number;
  hotelId: number;
  workNo: string;
  managerName: string;
  phone: string;
  post: string;
  status: number;
  createTime: string;
}

// 酒店应急人员
export interface HotelEmergency {
  id: number;
  hotelId: number;
  rescuerName: string;
  rescuerPhone: string;
  vehicleNo: string;
  createTime: string;
}

// 酒店完整详情
export interface HotelDetail {
  baseInfo: HotelBase;
  realTimeData: HotelRealTimeData;
  managerList: HotelManager[];
  emergencyList: HotelEmergency[];
}

// 酒店查询参数
export interface HotelQueryParams {
  hotelName?: string;
  starLevel?: number;
  scenicName?: string;
}