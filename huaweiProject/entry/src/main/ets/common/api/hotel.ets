
import http from '@ohos.net.http'

const BASE_URL = "http://192.168.1.100:8080"
export interface CustomHttpResponse {
  result: string | Object | ArrayBuffer
  responseCode: number
  header: Record<string, string>
}

interface HotelItem {
  id: number
  name: string
  address: string
}
function request(url: string, method: http.RequestMethod, data?: Object): Promise<CustomHttpResponse> {
  let httpRequest = http.createHttp()

  return httpRequest.request(BASE_URL + url, {
    method: method,
    header: {
      'Content-Type': 'application/json'
    },
    extraData: data,
    expectDataType: http.HttpDataType.STRING
  }).then((response: http.HttpResponse) => {
    const customResponse: CustomHttpResponse = {
      result: response.result,
      responseCode: response.responseCode,
      header: response.header as Record<string, string>
    }
    return customResponse
  })
}
export class HotelApi {

  static getList(): Promise<CustomHttpResponse> {
    return request("/api/hotel/list", http.RequestMethod.GET)
  }
  static add(data: Partial<HotelItem>): Promise<CustomHttpResponse> {
    return request("/api/hotel/add", http.RequestMethod.POST, data)
  }

  static update(data: Partial<HotelItem>): Promise<CustomHttpResponse> {
    return request("/api/hotel/update", http.RequestMethod.POST, data)
  }

  static delete(id: number): Promise<CustomHttpResponse> {
    return request(`/api/hotel/delete/${id}`, http.RequestMethod.DELETE)
  }

  static search(keyword: string): Promise<CustomHttpResponse> {
    return request(`/api/hotel/search?keyword=${keyword}`, http.RequestMethod.GET)
  }
}