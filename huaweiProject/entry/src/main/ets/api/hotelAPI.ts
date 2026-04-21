// api/hotelAPI.ts  酒店模块所有接口封装
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import { Result, HotelBase, HotelDetail, HotelQueryParams } from '../utils/Hotel';
import env from '../utils/env';

/**
 * 工具方法：ArrayBuffer转字符串（兼容处理）
 */
function arrayBufferToString(buffer: ArrayBuffer): string {
  if (!buffer) return "{}";
  const uint8Array = new Uint8Array(buffer);
  let str = '';
  for (let i = 0; i < uint8Array.length; i++) {
    str += String.fromCharCode(uint8Array[i]);
  }
  return str.trim() || "{}";
}

/**
 * 1. 获取景区名称列表（筛选用）
 * @param token 用户登录令牌
 * @returns Promise<Result<string[]>>
 */
export function getScenicNameList(token: string): Promise<Result<string[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/spot/nameList`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json;charset=utf-8",
          "Accept-Encoding": "identity"
        },
        expectDataType: http.HttpDataType.STRING
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          // 解析响应数据
          let jsonString = "";
          if (typeof data.result === 'string') {
            jsonString = data.result;
          } else if (data.result instanceof ArrayBuffer) {
            jsonString = arrayBufferToString(data.result);
          }
          const result: Result<string[]> = JSON.parse(jsonString);
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
 * 2. 获取酒店列表（支持多条件筛选）
 * @param token 用户登录令牌
 * @param params 筛选参数
 * @returns Promise<Result<HotelBase[]>>
 */
export function getHotelList(token: string, params?: HotelQueryParams): Promise<Result<HotelBase[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    // 拼接筛选参数
    let url = `${env.BASE_API}/hotel/list`;
    const queryParams: string[] = [];
    if (params?.hotelName?.trim()) {
      queryParams.push(`hotelName=${encodeURIComponent(params.hotelName.trim())}`);
    }
    if (params?.starLevel && params.starLevel > 0) {
      queryParams.push(`starLevel=${params.starLevel}`);
    }
    if (params?.scenicName && params.scenicName !== "全部") {
      queryParams.push(`scenicName=${encodeURIComponent(params.scenicName)}`);
    }
    if (queryParams.length) url += `?${queryParams.join("&")}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json;charset=utf-8",
          "Accept-Encoding": "identity"
        },
        expectDataType: http.HttpDataType.STRING
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          let jsonString = "";
          if (typeof data.result === 'string') {
            jsonString = data.result;
          } else if (data.result instanceof ArrayBuffer) {
            jsonString = arrayBufferToString(data.result);
          }
          const result: Result<HotelBase[]> = JSON.parse(jsonString);
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
 * 3. 获取酒店详情
 * @param token 用户登录令牌
 * @param hotelId 酒店ID
 * @returns Promise<Result<HotelDetail>>
 */
export function getHotelDetail(token: string, hotelId: number): Promise<Result<HotelDetail>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/hotel/detail?id=${hotelId}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json",
          "Accept-Encoding": "identity"
        },
        expectDataType: http.HttpDataType.STRING
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          let jsonString = "";
          if (typeof data.result === 'string') {
            jsonString = data.result;
          } else if (data.result instanceof ArrayBuffer) {
            jsonString = arrayBufferToString(data.result);
          }
          const result: Result<HotelDetail> = JSON.parse(jsonString);
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