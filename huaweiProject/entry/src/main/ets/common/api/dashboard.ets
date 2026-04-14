import http from '@ohos.net.http'

const BASE_URL = "http://192.168.1.100:8080"

function request(url: string, method: http.RequestMethod) {
  let httpRequest = http.createHttp()

  return httpRequest.request(BASE_URL + url, {
    method: method,
    expectDataType: http.HttpDataType.STRING
  })
}
export class DashboardApi {

  static getData(): Promise<http.HttpResponse> {
    return request("/api/dashboard", http.RequestMethod.GET)
  }

}