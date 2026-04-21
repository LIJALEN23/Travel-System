// 旅行社基础信息
export interface TravelAgency {
  id: number;
  agencyName: string;
  licenseNo: string;
  creditLevel: string;
  address: string;
  contactPhone: string;
  status: number;
  createTime: string;
  updateTime: string;
}

// 管理人员
export interface AgencyManager {
  id: number;
  agencyId: number;
  workNo: string;
  managerName: string;
  phone: string;
  post: string;
  status: number;
  createTime: string;
}

// 驾驶员
export interface VehicleDriver {
  id: number;
  agencyId: number;
  driverName: string;
  phone: string;
  licenseType: string;
  status: number;
  createTime: string;
  updateTime: string;
}

// 旅游车辆
export interface TourismVehicle {
  id: number;
  agencyId: number;
  plateNo: string;
  vehicleType: string;
  seatCount: number;
  vehicleStatus: string;
  createTime: string;
  updateTime: string;
}

// 应急救援
export interface AgencyEmergency {
  id: number;
  agencyId: number;
  rescuerName: string;
  rescuerPhone: string;
  vehicleNo: string;
  createTime: string;
}

// 实时数据
export interface AgencyRealTimeData {
  id: number;
  agencyId: number;
  todayTeams: number;
  todayPeople: number;
  onlineVehicles: number;
  updateTime: string;
}

// 电子行程单
export interface TravelOrder {
  id: number;
  agencyId: number;
  vehicleId: number;
  driverId: number;
  guideId: number | null;
  teamName: string;
  peopleCount: number;
  startAddress: string;
  endAddress: string;
  startTime: string;
  orderStatus: string;
  createTime: string;
  updateTime: string;
}

// 出境游信息
export interface AbroadTravel {
  id: number;
  agencyId: number;
  teamName: string;
  country: string;
  visaStatus: string;
  applyTime: string;
  createTime: string;
  updateTime: string;
}

// 新增：行程单参数接口（修复报错1）
export interface OrderDetailParams {
  orderId: number;
}

// 新增：创建行程单参数接口（修复报错3）
export interface CreateOrderParams {
  agencyId: number;
  vehicleId: number;
  driverId: number;
  guideId: number | null;
  teamName: string;
  peopleCount: number;
  startAddress: string;
  endAddress: string;
  startTime: string;
  orderStatus: string;
}

// 路由参数类型（详情页专用）
export interface AgencyDetailParams {
  id: number;
}

// 通用路由参数（行程单/出境游跳转专用）
export interface AgencyPageParams {
  agencyId: number;
  agencyName: string;
}

// 统一后端返回
export interface ApiResult<T> {
  code: number;
  msg: string;
  data: T;
}