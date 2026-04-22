// utils/Alert.ts - Alert模块相关类型定义

/**
 * 基础响应结果类型
 */
export interface Result<T> {
  code: number;
  msg: string;
  data: T;
}

/**
 * 告警消息实体
 */
export interface AlertMessage {
  id: number;
  content: string;
  msgType: string; // 'alert' | 'prompt'
  status: number; // 0:未处理, 1:待发布, 2:已发布, 3:已处置
  extInfo: string; // 扩展信息，如景区/酒店ID
  createTime: string;
  updateTime: string;
  operator?: string; // 值班员
  leader?: string; // 领导
  handleResult?: string; // 处置结果
  handler?: string; // 处置人
}

/**
 * 告警处置记录实体
 */
export interface AlertHandle {
  id: number;
  alertId: number;
  handleResult: string;
  handler: string;
  handleTime: string;
}

/**
 * 前端展示用的告警项
 */
export interface AlertItem {
  id: number;
  title: string;
  level: string;
  status: string;
  content?: string;
  createTime?: string;
  operator?: string;
  leader?: string;
  handleResult?: string;
  handler?: string;
}