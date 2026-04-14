import http from '@ohos.net.http'

const BASE_URL = "http://192.168.1.100:8080"
function request(url: string, method: http.RequestMethod, data?: Object): Promise<http.HttpResponse> {
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
export class GuideApi {
  static getList(): Promise<http.HttpResponse> {
    return request("/api/guide/list", http.RequestMethod.GET)
  }
  static add(data: Object): Promise<http.HttpResponse> {
    return request("/api/guide/add", http.RequestMethod.POST, data)
  }
  static update(data: Object): Promise<http.HttpResponse> {
    return request("/api/guide/update", http.RequestMethod.POST, data)
  }
  static delete(id: number): Promise<http.HttpResponse> {
    return request(`/api/guide/delete/${id}`, http.RequestMethod.DELETE)
  }
  static search(keyword: string): Promise<http.HttpResponse> {
    return request(`/api/guide/search?keyword=${keyword}`, http.RequestMethod.GET)
  }
}