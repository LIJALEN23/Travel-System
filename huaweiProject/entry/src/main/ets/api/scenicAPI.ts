// api/scenicAPI.ts  景区模块所有接口封装
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { Result, ScenicSpot, ScenicDetail } from '../utils/Scenic';
import env from '../utils/env';

/**
 * 1. 获取景区列表（支持搜索）
 * @param token 用户登录令牌
 * @param spotName 搜索关键词（可选）
 * @returns Promise<Result<ScenicSpot[]>>
 */
export function getScenicSpotList(token: string, spotName?: string): Promise<Result<ScenicSpot[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    // 拼接接口地址（支持搜索参数）
    let url = `${env.BASE_API}/spot/list`;
    if (spotName && spotName.trim()) {
      url += `?spotName=${encodeURIComponent(spotName.trim())}`;
    }

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token, // 统一规范请求头
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
          // 解析数据
          const result: Result<ScenicSpot[]> = JSON.parse(data.result as string);
          resolve(result);
        } catch (e) {
          reject(e);
        } finally {
          httpRequest.destroy(); // 必须销毁请求实例
        }
      }
    );
  });
}

/**
 * 2. 获取景区详情
 * @param token 用户登录令牌
 * @param spotId 景区ID
 * @returns Promise<Result<ScenicDetail>>
 */
export function getScenicDetail(token: string, spotId: number): Promise<Result<ScenicDetail>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/spot/detail?id=${spotId}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token, // 统一请求头格式
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
          const result: Result<ScenicDetail> = JSON.parse(data.result as string);
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