// api/alertAPI.ts - Alert模块所有接口封装
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { Result, AlertMessage, AlertHandle } from '../utils/Alert';
import env from '../utils/env';

interface AutoCheckResult {
  generatedAlerts: number;
  generatedPrompts: number;
}

interface AlertOperationResult {
  success: boolean;
  message: string;
}

/**
 * 获取所有告警/提示列表
 * @param token 用户登录令牌
 * @returns Promise<Result<AlertMessage[]>>
 */
export function getAlertList(token: string): Promise<Result<AlertMessage[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/list`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AlertMessage[]> = JSON.parse(data.result as string);
          resolve(result);
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
 * 查询每个景区/酒店的最新未处理告警
 * @param token 用户登录令牌
 * @returns Promise<Result<AlertMessage[]>>
 */
export function getLatestUnprocessedAlerts(token: string): Promise<Result<AlertMessage[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/latest/unprocessed`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AlertMessage[]> = JSON.parse(data.result as string);
          resolve(result);
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
 * 根据ID查看告警详情
 * @param token 用户登录令牌
 * @param id 告警ID
 * @returns Promise<Result<AlertMessage>>
 */
export function getAlertById(token: string, id: number): Promise<Result<AlertMessage>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/get/${id}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AlertMessage> = JSON.parse(data.result as string);
          resolve(result);
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
 * 系统自动生成告警/提示
 * @param token 用户登录令牌
 * @returns Promise<Result<AutoCheckResult>>
 */
export function autoCheckAlerts(token: string): Promise<Result<AutoCheckResult>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/autoCheck`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AutoCheckResult> = JSON.parse(data.result as string);
          resolve(result);
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
 * 值班员审核通过 → 改为待发布
 * @param token 用户登录令牌
 * @param id 告警ID
 * @param operator 值班员姓名
 * @returns Promise<Result<AlertOperationResult>>
 */
export function checkPassAlert(token: string, id: number, operator: string): Promise<Result<AlertOperationResult>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/checkPass?id=${id}&operator=${encodeURIComponent(operator)}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AlertOperationResult> = JSON.parse(data.result as string);
          resolve(result);
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
 * 领导审批并发布
 * @param token 用户登录令牌
 * @param id 告警ID
 * @param leader 领导姓名
 * @returns Promise<Result<AlertOperationResult>>
 */
export function publishAlert(token: string, id: number, leader: string): Promise<Result<AlertOperationResult>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/publish?id=${id}&leader=${encodeURIComponent(leader)}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AlertOperationResult> = JSON.parse(data.result as string);
          resolve(result);
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
 * 无需发布 → 直接处置并登记
 * @param token 用户登录令牌
 * @param id 告警ID
 * @param handleResult 处置结果
 * @param handler 处置人
 * @returns Promise<Result<AlertOperationResult>>
 */
export function handleAlert(token: string, id: number, handleResult: string, handler: string): Promise<Result<AlertOperationResult>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/handle?id=${id}&handleResult=${encodeURIComponent(handleResult)}&handler=${encodeURIComponent(handler)}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AlertOperationResult> = JSON.parse(data.result as string);
          resolve(result);
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
 * 查询处置记录
 * @param token 用户登录令牌
 * @param alertId 告警ID
 * @returns Promise<Result<AlertHandle[]>>
 */
export function getHandleList(token: string, alertId: number): Promise<Result<AlertHandle[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/alert/handleList/${alertId}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        }
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<AlertHandle[]> = JSON.parse(data.result as string);
          resolve(result);
        } catch (e) {
          reject(e);
        } finally {
          httpRequest.destroy();
        }
      }
    );
  });
}