
import http from '@ohos.net.http'

const BASE_URL = "http://192.168.1.100:8080"
export interface RequestData {
  id?: number
  name?: string
  location?: string
}
function request(url: string, method: http.RequestMethod, data?: RequestData): Promise<HttpResponse> {
  let httpRequest = http.createHttp()

  return httpRequest.request(BASE_URL + url, {
    method: method,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: data,
    expectDataType: http.HttpDataType.STRING
  }).then((response: http.HttpResponse) => {
    // 将 http.HttpResponse 转换为自定义的 HttpResponse 接口
    return {
      result: response.result,
      responseCode: response.responseCode,
      header: response.header as Record<string, string>
    } as HttpResponse
  })
}
export interface HttpResponse {
  result: string | Object | ArrayBuffer
  responseCode: number
  header: Record<string, string>
}

export class ScenicApi {
  static getList(): Promise<HttpResponse> {
    return request("/api/scenic/list", http.RequestMethod.GET)
  }

  static add(data: RequestData): Promise<HttpResponse> {
    return request("/api/scenic/add", http.RequestMethod.POST, data)
  }

  static update(data: RequestData): Promise<HttpResponse> {
    return request("/api/scenic/update", http.RequestMethod.POST, data)
  }

  static delete(id: number): Promise<HttpResponse> {
    return request(`/api/scenic/delete/${id}`, http.RequestMethod.DELETE)
  }

  static search(keyword: string): Promise<HttpResponse> {
    return request(`/api/scenic/search?keyword=${keyword}`, http.RequestMethod.GET)
  }
}