import http from '@ohos.net.http'
import { Complaint, HandleComplaintRequest, ComplaintQueryParams, CreditInfo } from '../../utils/Complaint'
import { Result } from '../../utils/Login'

const BASE_URL = "http://192.168.1.100:8080"
const DEFAULT_TIMEOUT = 15000 // 15秒超时

async function request(url: string, method: http.RequestMethod, data?: Object): Promise<http.HttpResponse> {
  let httpRequest = http.createHttp()
  
  try {
    const options: http.HttpRequestOptions = {
      method: method,
      header: {
        'Content-Type': 'application/json'
      },
      extraData: data ? JSON.stringify(data) : undefined,
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: DEFAULT_TIMEOUT,
      readTimeout: DEFAULT_TIMEOUT
    }
    
    const response = await httpRequest.request(BASE_URL + url, options)
    return response
  } finally {
    // 确保释放资源
    httpRequest.destroy()
  }
}

export class ComplaintApi {
  // ================================
  // 1. 提交投诉
  // ================================
  static async submitComplaint(complaint: Complaint): Promise<Result<string>> {
    try {
      const response = await request("/complaint/submit", http.RequestMethod.POST, complaint)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      return {
        code: 500,
        msg: (error as Error).message || '提交投诉失败',
        data: ''
      }
    }
  }

  // ================================
  // 2. 处理投诉（办结/驳回）
  // ================================
  static async handleComplaint(requestData: HandleComplaintRequest): Promise<Result<string>> {
    try {
      const response = await request("/complaint/handle", http.RequestMethod.POST, requestData)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      return {
        code: 500,
        msg: (error as Error).message || '处理投诉失败',
        data: ''
      }
    }
  }

  // ================================
  // 3. 删除投诉
  // ================================
  static async deleteComplaint(id: number): Promise<Result<string>> {
    try {
      const response = await request(`/complaint/${id}`, http.RequestMethod.DELETE)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      return {
        code: 500,
        msg: (error as Error).message || '删除投诉失败',
        data: ''
      }
    }
  }

  // ================================
  // 4. 投诉列表（多条件）
  // ================================
  static async listComplaints(params: ComplaintQueryParams): Promise<Result<Complaint[]>> {
    try {
      let queryString = ''
      if (params.status) {
        queryString += `status=${encodeURIComponent(params.status)}&`
      }
      if (params.agencyId) {
        queryString += `agencyId=${params.agencyId}&`
      }
      if (params.guideId) {
        queryString += `guideId=${params.guideId}&`
      }
      
      if (queryString.length > 0) {
        queryString = '?' + queryString.slice(0, -1) // 移除最后一个&符号
      }
      
      const response = await request(`/complaint/list${queryString}`, http.RequestMethod.GET)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      return {
        code: 500,
        msg: (error as Error).message || '获取投诉列表失败',
        data: []
      }
    }
  }

  // ================================
  // 5. 查询单个投诉
  // ================================
  static async getComplaintById(id: number): Promise<Result<Complaint>> {
    try {
      const response = await request(`/complaint/${id}`, http.RequestMethod.GET)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      return {
        code: 500,
        msg: (error as Error).message || '获取投诉详情失败',
        data: {} as Complaint
      }
    }
  }

  // ================================
  // 6. 查询导游诚信信息
  // ================================
  static async getGuideCredit(guideId: number): Promise<Result<CreditInfo>> {
    try {
      const response = await request(`/complaint/guide/credit/${guideId}`, http.RequestMethod.GET)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      return {
        code: 500,
        msg: (error as Error).message || '获取导游诚信信息失败',
        data: {} as CreditInfo
      }
    }
  }

  // ================================
  // 7. 查询旅行社诚信信息
  // ================================
  static async getAgencyCredit(agencyId: number): Promise<Result<CreditInfo>> {
    try {
      const response = await request(`/complaint/agency/credit/${agencyId}`, http.RequestMethod.GET)
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string)
      } else {
        throw new Error(`HTTP ${response.responseCode}: ${response.result}`)
      }
    } catch (error) {
      return {
        code: 500,
        msg: (error as Error).message || '获取旅行社诚信信息失败',
        data: {} as CreditInfo
      }
    }
  }
}