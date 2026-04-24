// api/loginAPI.ts
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { LoginResult, RegisterResult } from '../utils/Login'; // 导入两个类型
import env from '../utils/env';

/**
 * 登录接口请求封装
 * @param account 账号
 * @param password 密码
 * @returns Promise<LoginResult> 登录返回结果
 */
export function loginRequest(account: string, password: string): Promise<LoginResult> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/user/login`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: { account, password }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const res: LoginResult = JSON.parse(data.result as string);
          resolve(res);
        } catch (e) {
          reject(e);
        } finally {
          httpRequest.destroy();
        }
      }
    );
  });
}

/**
 * 注册接口请求封装（新增）
 * @param userData 注册表单数据
 * @returns Promise<RegisterResult> 注册返回结果
 */
export function registerRequest(
  account: string,
  password: string,
  realName: string,
  phone: string,
  email: string,
  remark: string
): Promise<RegisterResult> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/user/register`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: {
          account: account,
          password: password,
          realName: realName,
          phone: phone,
          email: email,
          role: 'OPERATOR',
          status: 1,
          remark: remark
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const res: RegisterResult = JSON.parse(data.result as string);
          resolve(res);
        } catch (e) {
          reject(e);
        } finally {
          httpRequest.destroy();
        }
      }
    );
  });
}