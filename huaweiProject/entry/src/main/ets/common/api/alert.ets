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

export class AlertApi {
  // 获取列表
  static getList(): Promise<http.HttpResponse> {
    return request("/api/alert/list", http.RequestMethod.GET)
  }

  // 处理告警
  static handle(id: number): Promise<http.HttpResponse> {
    return request(`/api/alert/handle/${id}`, http.RequestMethod.POST)
  }

  // 删除/忽略
  static delete(id: number): Promise<http.HttpResponse> {
    return request(`/api/alert/delete/${id}`, http.RequestMethod.DELETE)
  }
}