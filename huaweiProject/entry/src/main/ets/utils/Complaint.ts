/**
 * 投诉实体类
 */
export interface Complaint {
  id?: number;
  title: string;           // 投诉标题
  content: string;         // 投诉内容
  complaintType: string;   // 投诉类型（导游/旅行社/景区/酒店）
  targetId?: number;       // 投诉对象ID（导游ID/旅行社ID/景区ID/酒店ID）
  targetName?: string;     // 投诉对象名称
  complainant: string;     // 投诉人
  contactInfo: string;     // 联系方式
  complaintTime: string;   // 投诉时间
  status: string;          // 状态（待处理/已办结/已驳回）
  handleUser?: string;     // 处理人
  handleTime?: string;     // 处理时间
  handleResult?: string;   // 处理结果
  remark?: string;         // 备注
}

/**
 * 投诉处理请求参数
 */
export interface HandleComplaintRequest {
  complaintId: number;
  handleUser: string;
  handleResult: string;
  status: string;
}

/**
 * 投诉查询参数
 */
export interface ComplaintQueryParams {
  status?: string;    // 状态筛选
  agencyId?: number;  // 旅行社ID筛选
  guideId?: number;   // 导游ID筛选
}

/**
 * 诚信信息
 */
export interface CreditInfo {
  totalComplaints: number;      // 总投诉数
  pendingComplaints: number;    // 待处理投诉数
  resolvedComplaints: number;   // 已办结投诉数
  rejectedComplaints: number;   // 已驳回投诉数
  creditScore: number;          // 诚信评分（0-100）
  creditLevel: string;          // 诚信等级（优秀/良好/一般/差）
  recentComplaints: Complaint[]; // 近期投诉列表
}