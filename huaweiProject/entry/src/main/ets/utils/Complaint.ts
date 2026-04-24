/**
 * 投诉实体类 - 与后端Complaint.java对应
 */
export interface Result<T> {
  code: number;
  msg: string;
  data: T;
}
export interface Complaint {
  id?: number;                    // 投诉ID
  complaintNo?: string;           // 投诉编号（自动生成）
  visitorName: string;            // 游客姓名（后端对应字段）
  visitorPhone: string;           // 游客电话（后端对应字段）
  title: string;                  // 投诉标题
  content: string;                // 投诉内容
  agencyId?: number;              // 旅行社ID
  guideId?: number;               // 导游ID
  level?: number;                 // 投诉级别（1-普通，2-严重）
  status: string;                 // 状态（待处理/已办结/已驳回）
  handleUser?: string;            // 处理人
  handleTime?: string;            // 处理时间
  handleResult?: string;          // 处理结果
  createTime?: string;            // 创建时间
  updateTime?: string;            // 更新时间
}

/**
 * 投诉处理请求参数 - 与后端handleComplaint接口对应
 */
export interface HandleComplaintRequest {
  complaintId: number;            // 投诉ID
  handleUser: string;             // 处理人
  handleResult: string;           // 处理结果
  status: string;                 // 状态（已办结/已驳回）
}

/**
 * 投诉查询参数 - 与后端list接口对应
 */
export interface ComplaintQueryParams {
  status?: string;                // 状态筛选
  agencyId?: number;              // 旅行社ID筛选
  guideId?: number;               // 导游ID筛选
}

/**
 * 诚信信息 - 与后端诚信查询接口对应
 */
export interface CreditInfo {
  id?: number;                    // 诚信记录ID
  guideId?: number;               // 导游ID（导游诚信）
  agencyId?: number;              // 旅行社ID（旅行社诚信）
  creditScore: number;            // 诚信评分（0-100）
  totalComplaint: number;         // 总投诉数
  badComplaint: number;           // 严重投诉数
  creditLevel?: string;           // 诚信等级
}

/**
 * 投诉常量定义 - 与后端ComplaintConstant对应
 */
export class ComplaintConstant {
  static readonly STATUS_PENDING = '待处理';
  static readonly STATUS_DONE = '已办结';
  static readonly STATUS_REJECT = '已驳回';

  static readonly COMPLAINT_LEVEL_NORMAL = 1;    // 普通投诉
  static readonly COMPLAINT_LEVEL_SERIOUS = 2;   // 严重投诉
}