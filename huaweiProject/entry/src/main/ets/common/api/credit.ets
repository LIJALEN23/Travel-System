
import http from '@ohos.net.http'

const BASE_URL = "http://192.168.1.100:8080"
export interface ApiResponse {
  code: number;
  message: string;
  data: CreditItem[];
  result: string;
}

export interface CreditItem {
  name: string;
  score: number;
}

export interface SubmitData {
  name: string;
  score: number;
}
function request(url: string, method: http.RequestMethod, data?: SubmitData): Promise<ApiResponse> {
  let httpRequest = http.createHttp()

  return new Promise((resolve, reject) => {
    httpRequest.request(BASE_URL + url, {
      method: method,
      header: {
        'Content-Type': 'application/json'
      },
      extraData: data,
      expectDataType: http.HttpDataType.STRING
    })
    .then((response: http.HttpResponse) => {
      // 将HttpResponse转换为ApiResponse
      const apiResponse: ApiResponse = {
        code: response.responseCode,
        message: '',
        data: [],
        result: JSON.stringify(response.result)
      }
      resolve(apiResponse)
    })
    .catch((error: Error) => {
      reject(error)
    })
  })
}
export class CreditApi {
  // 获取列表
  static getList(): Promise<ApiResponse> {
    return request("/api/credit", http.RequestMethod.GET)
  }

  // 提交评价
  static add(data: SubmitData): Promise<ApiResponse> {
    return request("/api/credit/add", http.RequestMethod.POST, data)
  }
}