import http from '@ohos.net.http'

const BASE_URL = "http://192.168.1.100:8080"

interface RequestData {
  id?: number
  name?: string
  licenseNumber?: string
  address?: string
  contactPerson?: string
  phone?: string
  status?: string
  createTime?: string
  updateTime?: string
  scenicId?: number
  hotelId?: number
  title?: string
  content?: string
  level?: string
  operator?: string
  leader?: string
  handleResult?: string
  handler?: string
}

function request(url: string, method: http.RequestMethod, data?: RequestData) {
  let httpRequest = http.createHttp()

  return httpRequest.request(BASE_URL + url, {
    method: method,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: data,
    expectDataType: http.HttpDataType.STRING
  })
}

interface AgencyItem {
  id: number
  name: string
  licenseNumber: string
  address: string
  contactPerson: string
  phone: string
  status: string
  createTime?: string
  updateTime?: string
}

interface AlertMessage {
  id: number
  scenicId?: number
  hotelId?: number
  title: string
  content: string
  level: string
  status: string
  createTime: string
  operator?: string
  leader?: string
  handleResult?: string
  handler?: string
}

interface ApiResponse {
  code: number
  msg: string
  data: AgencyItem[] | AgencyItem | AlertMessage[] | AlertMessage
}

export class AgencyApi {
  // ========================== 查询所有旅行社 ==========================
  static getList(): Promise<http.HttpResponse> {
    return request("/agency/list", http.RequestMethod.GET)
  }

  // ========================== 查询每个旅行社的最新未处理告警 ==========================
  static getLatestUnprocessedAlerts(): Promise<http.HttpResponse> {
    return request("/agency/latest/unprocessed", http.RequestMethod.GET)
  }

  // ========================== 根据ID查看旅行社详情 ==========================
  static getById(id: number): Promise<http.HttpResponse> {
    return request(`/agency/get/${id}`, http.RequestMethod.GET)
  }

  // ========================== 系统自动生成告警/提示 ==========================
  static autoCheck(): Promise<http.HttpResponse> {
    return request("/agency/autoCheck", http.RequestMethod.GET)
  }

  // ========================== 值班员审核通过 → 改为待发布 ==========================
  static checkPass(id: number, operator: string): Promise<http.HttpResponse> {
    const requestData: RequestData = {
      id: id,
      operator: operator
    }
    return request("/agency/checkPass", http.RequestMethod.POST, requestData)
  }

  // ========================== 领导审批并发布 ==========================
  static publish(id: number, leader: string): Promise<http.HttpResponse> {
    const requestData: RequestData = {
      id: id,
      leader: leader
    }
    return request("/agency/publish", http.RequestMethod.POST, requestData)
  }

  // ========================== 无需发布 → 直接处置并登记 ==========================
  static handle(id: number, handleResult: string, handler: string): Promise<http.HttpResponse> {
    const requestData: RequestData = {
      id: id,
      handleResult: handleResult,
      handler: handler
    }
    return request("/agency/handle", http.RequestMethod.POST, requestData)
  }

  // ========================== 查询处置记录 ==========================
  static getHandleList(alertId: number): Promise<http.HttpResponse> {
    return request(`/agency/handleList/${alertId}`, http.RequestMethod.GET)
  }

  // ========================== 新增旅行社 ==========================
  static create(agency: AgencyItem): Promise<http.HttpResponse> {
    const requestData: RequestData = {
      id: agency.id,
      name: agency.name,
      licenseNumber: agency.licenseNumber,
      address: agency.address,
      contactPerson: agency.contactPerson,
      phone: agency.phone,
      status: agency.status,
      createTime: agency.createTime,
      updateTime: agency.updateTime
    }
    return request("/agency/create", http.RequestMethod.POST, requestData)
  }

  // ========================== 更新旅行社信息 ==========================
  static update(agency: AgencyItem): Promise<http.HttpResponse> {
    const requestData: RequestData = {
      id: agency.id,
      name: agency.name,
      licenseNumber: agency.licenseNumber,
      address: agency.address,
      contactPerson: agency.contactPerson,
      phone: agency.phone,
      status: agency.status,
      createTime: agency.createTime,
      updateTime: agency.updateTime
    }
    return request("/agency/update", http.RequestMethod.PUT, requestData)
  }
  // ========================== 删除旅行社 ==========================
  static delete(id: number): Promise<http.HttpResponse> {
    return request(`/agency/delete/${id}`, http.RequestMethod.DELETE)
  }
}

export { AgencyItem, AlertMessage }