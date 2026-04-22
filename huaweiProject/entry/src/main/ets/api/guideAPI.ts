import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import {
  ApiResult, GuideBase, GuideDetailVO, GuideQualification,
  GuideJobApply, GuideOrderApply, GuideRealTime, Complaint
} from '../utils/Guide';
import env from '../utils/env';

const BASE_URL = env.BASE_API + '/guide';

function handleResponse<T>(
  req: http.HttpRequest, err: BusinessError<void> | null, res: http.HttpResponse,
  resolve: (value: T) => void, reject: (reason: Error) => void
): void {
  try {
    if (err) { reject(new Error(err.message)); return; }
    const result = JSON.parse(res.result as string) as T;
    resolve(result);
  } catch (e) {
    reject(new Error('服务器响应异常'));
  } finally {
    req.destroy();
  }
}

function apiGet<T>(token: string, url: string): Promise<ApiResult<T>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(BASE_URL + url, {
      method: http.RequestMethod.GET,
      header: { Authorization: `Bearer ${token}` }
    }, (err, res) => {
      handleResponse<ApiResult<T>>(req, err, res, resolve, reject);
    });
  });
}

function apiPost<T, D>(token: string, url: string, data: D): Promise<ApiResult<T>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(BASE_URL + url, {
      method: http.RequestMethod.POST,
      header: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
      extraData: data
    }, (err, res) => {
      handleResponse<ApiResult<T>>(req, err, res, resolve, reject);
    });
  });
}

// ==================== 导游基础 ====================
export function addGuide(token: string, guide: GuideBase): Promise<ApiResult<null>> {
  return apiPost(token, '/add', guide);
}
export function updateGuide(token: string, guide: GuideBase): Promise<ApiResult<null>> {
  return apiPost(token, '/update', guide);
}
export function deleteGuide(token: string, id: number): Promise<ApiResult<null>> {
  return apiGet(token, `/delete/${id}`);
}
export function getGuideInfo(token: string, id: number): Promise<ApiResult<GuideDetailVO>> {
  return apiGet(token, `/info/${id}`);
}
export function getGuideList(
  token: string, name?: string, phone?: string, idCard?: string
): Promise<ApiResult<GuideBase[]>> {
  let url = '/list';
  const p: string[] = [];
  if (name) p.push(`name=${encodeURIComponent(name)}`);
  if (phone) p.push(`phone=${encodeURIComponent(phone)}`);
  if (idCard) p.push(`idCard=${encodeURIComponent(idCard)}`);
  if (p.length > 0) url += '?' + p.join('&');
  return apiGet(token, url);
}
export function publicSearchGuide(name: string): Promise<ApiResult<GuideBase[]>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    const url = `${BASE_URL}/public/search?name=${encodeURIComponent(name)}`;
    req.request(url, { method: http.RequestMethod.GET }, (err, res) => {
      handleResponse<ApiResult<GuideBase[]>>(req, err, res, resolve, reject);
    });
  });
}

// ==================== 资格 ====================
export function submitQualification(token: string, data: GuideQualification): Promise<ApiResult<null>> {
  return apiPost(token, '/qualification/submit', data);
}
export function auditQualification(token: string, data: GuideQualification): Promise<ApiResult<null>> {
  return apiPost(token, '/qualification/audit', data);
}
export function getQualification(token: string, guideId: number): Promise<ApiResult<GuideQualification>> {
  return apiGet(token, `/qualification/${guideId}`);
}

// ==================== 求职 ====================
export function applyJob(token: string, data: GuideJobApply): Promise<ApiResult<null>> {
  return apiPost(token, '/job/apply', data);
}
export function getJobApplyList(token: string, agencyId: number): Promise<ApiResult<GuideJobApply[]>> {
  return apiGet(token, `/job/applyList/${agencyId}`);
}
export function auditJob(token: string, data: GuideJobApply): Promise<ApiResult<null>> {
  return apiPost(token, '/job/audit', data);
}

// ==================== ✅ 行程单申领（你提供的接口） ====================
export function applyOrder(token: string, data: {
  guideId: number;
  agencyId: number;
  orderId: number;
  applyReason: string;
}): Promise<ApiResult<null>> {
  return apiPost(token, '/order/apply', data);
}

export function getOrderApplyList(token: string, agencyId: number): Promise<ApiResult<GuideOrderApply[]>> {
  return apiGet(token, `/order/applyList/${agencyId}`);
}

export function auditOrder(token: string, data: {
  id: number;
  applyStatus: number;
  applyReason: string;
}): Promise<ApiResult<null>> {
  return apiPost(token, '/order/audit', data);
}

// ==================== 实时位置 ====================
export function uploadRealTime(token: string, data: GuideRealTime): Promise<ApiResult<null>> {
  return apiPost(token, '/realTime/upload', data);
}
export function getRealTime(token: string, guideId: number): Promise<ApiResult<GuideRealTime>> {
  return apiGet(token, `/realTime/${guideId}`);
}

// ==================== 投诉 ====================
export function getGuideComplaints(
  token: string, guideId: number, status?: string
): Promise<ApiResult<Complaint[]>> {
  let url = `/complaint/list/${guideId}`;
  if (status) url += `?status=${encodeURIComponent(status)}`;
  return apiGet(token, url);
}