import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import {
  ApiResult, GuideBase, GuideDetailVO, GuideQualification,
  GuideJobApply, GuideOrderApply, GuideRealTime, Complaint
} from '../utils/Guide';
import env from '../utils/env';

// 基础URL
const BASE_URL = env.BASE_API + '/guide';

/**
 * 1. 新增导游
 */
export function addGuide(token: string, guide: GuideBase): Promise<ApiResult<null>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${BASE_URL}/add`, {
      method: http.RequestMethod.POST,
      header: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      extraData: guide
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse(req, err, res, resolve, reject);
    });
  });
}

/**
 * 2. 修改导游
 */
export function updateGuide(token: string, guide: GuideBase): Promise<ApiResult<null>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${BASE_URL}/update`, {
      method: http.RequestMethod.POST,
      header: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      extraData: guide
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse(req, err, res, resolve, reject);
    });
  });
}

/**
 * 3. 删除导游
 */
export function deleteGuide(token: string, id: number): Promise<ApiResult<null>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${BASE_URL}/delete/${id}`, {
      method: http.RequestMethod.GET,
      header: { Authorization: `Bearer ${token}` }
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse(req, err, res, resolve, reject);
    });
  });
}

/**
 * 4. 查询导游详情（含诚信档案）
 */
export function getGuideInfo(token: string, id: number): Promise<ApiResult<GuideDetailVO>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(`${BASE_URL}/info/${id}`, {
      method: http.RequestMethod.GET,
      header: { Authorization: `Bearer ${token}` }
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse(req, err, res, resolve, reject);
    });
  });
}

/**
 * 5. 模糊查询导游列表（管理员接口，需token）
 */
export function getGuideList(
  token: string,
  name?: string,
  phone?: string,
  idCard?: string
): Promise<ApiResult<GuideBase[]>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    const params: string[] = [];

    // 中文参数编码
    if (name) params.push(`name=${encodeURIComponent(name)}`);
    if (phone) params.push(`phone=${encodeURIComponent(phone)}`);
    if (idCard) params.push(`idCard=${encodeURIComponent(idCard)}`);

    const url = `${BASE_URL}/list${params.length ? '?' + params.join('&') : ''}`;

    req.request(url, {
      method: http.RequestMethod.GET,
      header: { Authorization: `Bearer ${token}` }
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse(req, err, res, resolve, reject);
    });
  });
}

/**
 * 6. 游客公开查询导游（无需token，仅姓名搜索）
 */
export function publicSearchGuide(name: string): Promise<ApiResult<GuideBase[]>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    // 中文编码 + 无Token
    const url = `${BASE_URL}/public/search?name=${encodeURIComponent(name)}`;

    req.request(url, {
      method: http.RequestMethod.GET
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse(req, err, res, resolve, reject);
    });
  });
}

// ==================== 资格审核 ====================
export function submitQualification(token: string, data: GuideQualification): Promise<ApiResult<null>> {
  return apiPost(token, '/qualification/submit', data);
}
export function auditQualification(token: string, data: GuideQualification): Promise<ApiResult<null>> {
  return apiPost(token, '/qualification/audit', data);
}
export function getQualification(token: string, guideId: number): Promise<ApiResult<GuideQualification>> {
  return apiGet(token, `/qualification/${guideId}`);
}

// ==================== 求职申请 ====================
export function applyJob(token: string, data: GuideJobApply): Promise<ApiResult<null>> {
  return apiPost(token, '/job/apply', data);
}
export function getJobApplyList(token: string, agencyId: number): Promise<ApiResult<GuideJobApply[]>> {
  return apiGet(token, `/job/applyList/${agencyId}`);
}
export function auditJob(token: string, data: GuideJobApply): Promise<ApiResult<null>> {
  return apiPost(token, '/job/audit', data);
}

// ==================== 行程单申领 ====================
export function applyOrder(token: string, data: GuideOrderApply): Promise<ApiResult<null>> {
  return apiPost(token, '/order/apply', data);
}
export function getOrderApplyList(token: string, agencyId: number): Promise<ApiResult<GuideOrderApply[]>> {
  return apiGet(token, `/order/applyList/${agencyId}`);
}
export function auditOrder(token: string, data: GuideOrderApply): Promise<ApiResult<null>> {
  return apiPost(token, '/order/audit', data);
}

// ==================== 实时位置 ====================
export function uploadRealTime(token: string, data: GuideRealTime): Promise<ApiResult<null>> {
  return apiPost(token, '/realTime/upload', data);
}
export function getRealTime(token: string, guideId: number): Promise<ApiResult<GuideRealTime>> {
  return apiGet(token, `/realTime/${guideId}`);
}

// ==================== 投诉查询 ====================
export function getGuideComplaints(
  token: string,
  guideId: number,
  status?: string
): Promise<ApiResult<Complaint[]>> {
  let url = `/complaint/list/${guideId}`;
  if (status) url += `?status=${encodeURIComponent(status)}`;
  return apiGet(token, url);
}

// ==================== 核心修复：统一响应处理 ====================
/**
 * 统一处理HTTP响应 + 安全销毁请求对象
 * @param req 请求对象
 * @param err 错误信息
 * @param res 响应对象
 * @param resolve 成功回调
 * @param reject 失败回调
 */
function handleResponse<T>(
  req: http.HttpRequest,
  err: BusinessError<void> | null,
  res: http.HttpResponse,
  resolve: (value: T) => void,
  reject: (reason: Error) => void
): void {
  try {
    // 处理请求错误
    if (err) {
      reject(new Error(`请求异常: ${err.message}`));
      return;
    }

    // 安全解析响应数据
    const responseStr: string = res.result as string;
    const result: T = JSON.parse(responseStr);
    resolve(result);
  } catch (e) {
    // 统一错误处理
    reject(new Error('登录已失效或服务器响应异常'));
  } finally {
    // ✅ 唯一正确写法：销毁请求对象（修复所有destroy报错）
    req.destroy();
  }
}

// ==================== 通用请求封装（严格泛型 + 类型安全） ====================
/**
 * 通用GET请求
 */
function apiGet<T>(token: string, url: string): Promise<ApiResult<T>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(BASE_URL + url, {
      method: http.RequestMethod.GET,
      header: { Authorization: `Bearer ${token}` }
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse<ApiResult<T>>(req, err, res, resolve, reject);
    });
  });
}

/**
 * 通用POST请求（泛型类型，无any）
 */
function apiPost<T, D>(token: string, url: string, data: D): Promise<ApiResult<T>> {
  return new Promise((resolve, reject) => {
    const req = http.createHttp();
    req.request(BASE_URL + url, {
      method: http.RequestMethod.POST,
      header: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      extraData: data
    }, (err: BusinessError<void>, res: http.HttpResponse) => {
      handleResponse<ApiResult<T>>(req, err, res, resolve, reject);
    });
  });
}