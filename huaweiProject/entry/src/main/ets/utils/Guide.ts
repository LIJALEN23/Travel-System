// 导游基础信息
export interface GuideBase {
  id: number;
  agencyId: number;
  name: string;
  gender: string;
  age: number;
  idCard: string;
  phone: string;
  guideLevel: string;
  workStatus: number;
  createTime?: string;
  updateTime?: string;
}

// 导游诚信档案
export interface GuideCredit {
  id: number;
  guideId: number;
  creditScore: number;
  totalComplaint: number;
  badComplaint: number;
  creditDesc: string | null;
  creditLevel: string | null;
  updateTime: string;
}

// 导游详情返回结构体
export interface GuideDetailVO {
  guideInfo: GuideBase;
  creditInfo: GuideCredit;
}

// 导游资格信息
export interface GuideQualification {
  id?: number;
  guideId: number;
  qualificationNo: string;
  issueDate: string;
  expireDate: string;
  checkStatus: number;
  checkRemark: string;
  createTime?: string;
}

// 求职申请
export interface GuideJobApply {
  id?: number;
  guideId: number;
  agencyId: number;
  applyStatus: number;
  applyRemark: string;
  createTime?: string;
  updateTime?: string;
}

// 行程单申领
export interface GuideOrderApply {
  id?: number;
  guideId: number;
  agencyId: number;
  orderId: number;
  applyReason: string;
  applyStatus?: number;
  createTime?: string;
  updateTime?: string;
}

// 实时位置信息
export interface GuideRealTime {
  id?: number;
  guideId: number;
  orderId: number;
  teamSize: number;
  longitude: number;
  latitude: number;
  workStatus: string;
  updateTime?: string;
}

// 投诉信息
export interface Complaint {
  id: number;
  guideId: number;
  level: string;
  content: string;
  status: string;
  createTime: string;
}

// 通用返回结果
export interface ApiResult<T> {
  code: number;
  msg: string;
  data: T;
  total?: number;
}

// 路由参数
export interface GuideDetailParams {
  id: number;
}
export interface AgencyPageParams {
  agencyId: number;
  agencyName: string;
}