import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import {
  Result,
  Complaint,
  HandleComplaintRequest,
  ComplaintQueryParams
} from '../utils/Complaint';
import env from '../utils/env';

/**
 * 1. 提交投诉
 */
export function submitComplaint(token: string, complaint: Complaint): Promise<Result<null>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/complaint/submit`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        },
        extraData: complaint
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result:Result<null> = JSON.parse(data.result as string);
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
 * 2. 处理投诉
 */
export function handleComplaint(token: string, request: HandleComplaintRequest): Promise<Result<null>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/complaint/handle`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          "Authorization": "Bearer " + token,
          "Content-Type": "application/json"
        },
        extraData: request
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (err) {
          reject(err);
          httpRequest.destroy();
          return;
        }
        try {
          const result: Result<null> = JSON.parse(data.result as string);
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
 * 3. 删除投诉
 */
export function deleteComplaint(token: string, id: number): Promise<Result<null>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/complaint/${id}`;

    httpRequest.request(
      url,
      {
        method: http.RequestMethod.DELETE,
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
          const result: Result<null> = JSON.parse(data.result as string);
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
 * 4. 投诉列表
 */
export function listComplaints(token: string, params: ComplaintQueryParams): Promise<Result<Complaint[]>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    let url = `${env.BASE_API}/complaint/list`;

    const queryParams = [];
    if (params.status) queryParams.push(`status=${encodeURIComponent(params.status)}`);
    if (params.agencyId) queryParams.push(`agencyId=${params.agencyId}`);
    if (params.guideId) queryParams.push(`guideId=${params.guideId}`);

    if (queryParams.length > 0) {
      url += `?${queryParams.join('&')}`;
    }

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
          const result: Result<Complaint[]> = JSON.parse(data.result as string);
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
 * 5. 单个投诉
 */
export function getComplaint(token: string, id: number): Promise<Result<Complaint>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/complaint/${id}`;

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
          const result: Result<Complaint> = JSON.parse(data.result as string);
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
 * 6. 导游诚信
 */
export function getGuideCredit(token: string, guideId: number): Promise<Result<any>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/complaint/guide/credit/${guideId}`;

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
          const result: Result<any> = JSON.parse(data.result as string);
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
 * 7. 旅行社诚信
 */
export function getAgencyCredit(token: string, agencyId: number): Promise<Result<any>> {
  return new Promise((resolve, reject) => {
    const httpRequest = http.createHttp();
    const url = `${env.BASE_API}/complaint/agency/credit/${agencyId}`;

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
          const result: Result<any> = JSON.parse(data.result as string);
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

export const ComplaintApi = {
  submitComplaint,
  handleComplaint,
  deleteComplaint,
  listComplaints,
  getComplaint,
  getGuideCredit,
  getAgencyCredit
};