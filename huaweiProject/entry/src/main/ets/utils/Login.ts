/* 后端统一返回类型
  * 对应后端的 Result.java
  */
  export interface Result<T = any> {
  code: number;
  msg: string;
  data: T;
}

/**
 * 登录接口返回 data 是 token 字符串
 */
// 登录返回 data 类型（对象，包含 token）
export interface LoginData {
  token: string;
}
// 登录专用返回类型
export interface LoginResult extends Result<LoginData> {}
// 注册接口返回
export type RegisterResult = Result<string>;
// 用户实体完整字段定义
export interface SysUser {
  account: string;
  password: string;
  realName: string;
  phone: string;
  email: string;
  role: string;
  status: number;
  remark: string;
}