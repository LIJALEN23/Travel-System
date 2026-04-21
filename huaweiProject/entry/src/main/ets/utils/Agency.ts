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
// 行程单详情完整数据（订单+司机+车辆）
export interface OrderDetailVO {
  order: TravelOrder;
  driver: VehicleDriver;
  vehicle: TourismVehicle;
}
// 定义表单类型
export  interface  AddOrderForm {
  teamName: string;
  peopleCount: number;
  startAddress: string;
  endAddress: string;
  startTime: string;
}
// 定义弹窗表单类型
export interface AddAbroadForm {
  teamName: string;
  country: string;
  startTime: string;
}
// ==================== 路由参数相关 ====================
// 行程单详情页路由参数
export interface OrderDetailParams {
  orderId: number;
}
// 旅行社详情路由参数
export interface AgencyDetailParams {
  id: number;
}
// 出境游详情页路由参数
export interface AbroadDetailParams {
  id: number;
}
// 通用页面路由参数（带旅行社ID/名称）
export interface AgencyPageParams {
  agencyId: number;
  agencyName: string;
}

// ==================== 请求参数相关 ====================
// 创建行程单参数
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

// 创建出境游参数
export interface CreateAbroadParams {
  agencyId: number;
  teamName: string;
  country: string;
  visaStatus: string;
  applyTime: string;
  startTime: string;
  status: string;
}

// 出境游审核参数（审核/驳回 核心接口）
export interface AuditAbroadParams {
  id: number;
  visaStatus: string;
}

// ==================== 通用后端返回结构体 ====================
export interface ApiResult<T> {
  code: number;
  msg: string;
  data: T;
}