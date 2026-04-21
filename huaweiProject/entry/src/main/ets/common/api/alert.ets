import http from '@ohos.net.http'

const BASE_URL = "http://192.168.1.100:8080"

function request(url: string, method: http.RequestMethod, data?: Object) {
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

interface CheckPassRequest {
  id: number
  operator: string
}

interface PublishRequest {
  id: number
  leader: string
}

interface HandleRequest {
  id: number
  handleResult: string
  handler: string
}

export class AlertApi {
  // ========================== 查询所有告警/提示 ==========================
  static getList(): Promise<http.HttpResponse> {
    return request("/alert/list", http.RequestMethod.GET)
  }

  // ========================== 查询每个景区/酒店的最新未处理告警 ==========================
  static getLatestUnprocessedAlerts(): Promise<http.HttpResponse> {
    return request("/alert/latest/unprocessed", http.RequestMethod.GET)
  }

  // ========================== 根据ID查看详情 ==========================
  static getById(id: number): Promise<http.HttpResponse> {
    return request(`/alert/get/${id}`, http.RequestMethod.GET)
  }

  // ========================== 系统自动生成告警/提示 ==========================
  static autoCheck(): Promise<http.HttpResponse> {
    return request("/alert/autoCheck", http.RequestMethod.GET)
  }

  // ========================== 值班员审核通过 → 改为待发布 ==========================
  static checkPass(id: number, operator: string): Promise<http.HttpResponse> {
    const requestData: CheckPassRequest = {
      id: id,
      operator: operator
    }
    return request("/alert/checkPass", http.RequestMethod.POST, requestData)
  }

  // ========================== 领导审批并发布 ==========================
  static publish(id: number, leader: string): Promise<http.HttpResponse> {
    const requestData: PublishRequest = {
      id: id,
      leader: leader
    }
    return request("/alert/publish", http.RequestMethod.POST, requestData)
  }

  // ========================== 无需发布 → 直接处置并登记 ==========================
  static handle(id: number, handleResult: string, handler: string): Promise<http.HttpResponse> {
    const requestData: HandleRequest = {
      id: id,
      handleResult: handleResult,
      handler: handler
    }
    return request("/alert/handle", http.RequestMethod.POST, requestData)
  }

  // ========================== 查询处置记录 ==========================
  static getHandleList(alertId: number): Promise<http.HttpResponse> {
    return request(`/alert/handleList/${alertId}`, http.RequestMethod.GET)
  }
}