// api/agencyAPI.ts 旅行社模块所有接口封装
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import {
  ApiResult,
  TravelAgency,
  AgencyManager,
  VehicleDriver,
  TourismVehicle,
  AgencyEmergency,
  AgencyRealTimeData,
  AbroadTravel,
  CreateAbroadParams,
  AuditAbroadParams,
  TravelOrder,
  CreateOrderParams,
  OrderDetailVO
} from '../utils/Agency';
import env from '../utils/env';

/**
 * 1. 获取旅行社列表（支持搜索）
 */
export function getAgencyList(token: string, agencyName?: string): Promise<ApiResult<TravelAgency[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    let url = `${env.BASE_API}/agency/list`;
    if (agencyName && agencyName.trim()) {
      url += `?agencyName=${encodeURIComponent(agencyName.trim())}`;
    }

    httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: {
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json"
      }
    }, (err: BusinessError, data: http.HttpResponse) => {
      if (err) {
        reject(err);
        httpRequest.destroy();
        return;
      }
      try {
        const result: ApiResult<TravelAgency[]> = JSON.parse(data.result as string);
        resolve(result);
      } catch (e) {
        reject(e);
      } finally {
        httpRequest.destroy();
      }
    });
  });
}

// ==================== 旅行社详情接口 ====================
/**
 * 2. 获取旅行社基础信息
 */
export function getAgencyBaseInfo(token: string, agencyId: number): Promise<TravelAgency> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/baseInfo/${agencyId}`, {
      method: http.RequestMethod.GET,
      header: { "Authorization": `Bearer ${token}` }
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try {
        const result: ApiResult<TravelAgency> = JSON.parse(res.result as string);
        resolve(result.data);
      } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

/**
 * 3. 获取管理人员列表
 */
export function getAgencyManagers(token: string, agencyId: number): Promise<AgencyManager[]> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/manager/${agencyId}`, {
      method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` }
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try {
        const result: ApiResult<AgencyManager[]> = JSON.parse(res.result as string);
        resolve(result.data);
      } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

/**
 * 4. 获取驾驶员列表
 */
export function getAgencyDrivers(token: string, agencyId: number): Promise<VehicleDriver[]> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/driver/${agencyId}`, {
      method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` }
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try {
        const result: ApiResult<VehicleDriver[]> = JSON.parse(res.result as string);
        resolve(result.data);
      } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

/**
 * 5. 获取旅游车辆列表
 */
export function getAgencyVehicles(token: string, agencyId: number): Promise<TourismVehicle[]> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/vehicle/${agencyId}`, {
      method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` }
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try {
        const result: ApiResult<TourismVehicle[]> = JSON.parse(res.result as string);
        resolve(result.data);
      } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

/**
 * 6. 获取应急救援信息
 */
export function getAgencyEmergency(token: string, agencyId: number): Promise<AgencyEmergency[]> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/emergency/${agencyId}`, {
      method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` }
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try {
        const result: ApiResult<AgencyEmergency[]> = JSON.parse(res.result as string);
        resolve(result.data);
      } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

/**
 * 7. 获取实时运营数据
 */
export function getAgencyRealData(token: string, agencyId: number): Promise<AgencyRealTimeData> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/realData/${agencyId}`, {
      method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` }
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try {
        const result: ApiResult<AgencyRealTimeData> = JSON.parse(res.result as string);
        resolve(result.data);
      } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

// ==================== 出境游接口 ====================
/**
 * 8. 获取出境游列表（支持筛选）
 */
export function getAbroadList(token: string, agencyId: number, visaStatus?: string, teamName?: string): Promise<ApiResult<AbroadTravel[]>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    let url = `${env.BASE_API}/agency/abroad/list/${agencyId}`;
    const params = [];
    if (visaStatus && visaStatus !== 'all') params.push(`visaStatus=${encodeURIComponent(visaStatus)}`);
    if (teamName?.trim()) params.push(`teamName=${encodeURIComponent(teamName.trim())}`);
    if (params.length) url += '?' + params.join('&');

    req.request(url, { method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` } },
      (err, res) => {
        if (err) { reject(err); req.destroy(); return; }
        try { resolve(JSON.parse(res.result as string)); } catch (e) { reject(e); } finally { req.destroy(); }
      });
  });
}

/**
 * 9. 新增出境游申请
 */
export function addAbroad(token: string, params: CreateAbroadParams): Promise<ApiResult<null>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/abroad/add`, {
      method: http.RequestMethod.POST,
      header: { "Authorization": `Bearer ${token}`, "Content-Type": "application/json" },
      extraData: params
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try { resolve(JSON.parse(res.result as string)); } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

/**
 * 10. 审核出境游（通过/驳回）
 */
export function auditAbroad(token: string, params: AuditAbroadParams): Promise<ApiResult<null>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/abroad/audit`, {
      method: http.RequestMethod.POST,
      header: { "Authorization": `Bearer ${token}`, "Content-Type": "application/json" },
      extraData: params
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try { resolve(JSON.parse(res.result as string)); } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

// ==================== 行程单接口 ====================
/**
 * 11. 获取行程单列表（支持筛选）
 */
export function getOrderList(token: string, agencyId: number, status?: string, teamName?: string, startTime?: string): Promise<ApiResult<TravelOrder[]>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    let url = `${env.BASE_API}/agency/order/list?agencyId=${agencyId}`;
    const params = [];
    if (status && status !== 'all') params.push(`orderStatus=${encodeURIComponent(status)}`);
    if (teamName?.trim()) params.push(`teamName=${encodeURIComponent(teamName.trim())}`);
    if (startTime?.trim()) params.push(`startTime=${encodeURIComponent(startTime.trim())}`);
    if (params.length) url += '&' + params.join('&');

    req.request(url, { method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` } },
      (err, res) => {
        if (err) { reject(err); req.destroy(); return; }
        try { resolve(JSON.parse(res.result as string)); } catch (e) { reject(e); } finally { req.destroy(); }
      });
  });
}

/**
 * 12. 新增行程单
 */
export function addOrder(token: string, params: CreateOrderParams): Promise<ApiResult<null>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/order/add`, {
      method: http.RequestMethod.POST,
      header: { "Authorization": `Bearer ${token}`, "Content-Type": "application/json" },
      extraData: params
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try { resolve(JSON.parse(res.result as string)); } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}

/**
 * 13. 获取行程单详情
 */
export function getOrderDetail(token: string, orderId: number): Promise<ApiResult<OrderDetailVO>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${env.BASE_API}/agency/order/detail/${orderId}`, {
      method: http.RequestMethod.GET, header: { "Authorization": `Bearer ${token}` }
    }, (err, res) => {
      if (err) { reject(err); req.destroy(); return; }
      try { resolve(JSON.parse(res.result as string)); } catch (e) { reject(e); } finally { req.destroy(); }
    });
  });
}