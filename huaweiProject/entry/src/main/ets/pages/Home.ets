
import router from '@ohos.router'
import { DashboardApi } from '../common/api/dashboard'

interface DashboardData {
  touristCount: number;
  alertCount: number;
  scenicCount: number;
  orderCount: number;
}

interface ApiResponse {
  data: DashboardData;
}

@Entry
@Component
struct Home {

  @State touristCount: number = 0
  @State alertCount: number = 0
  @State scenicCount: number = 0
  @State orderCount: number = 0

  // 页面加载时请求数据
  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {

      Text('全域旅游管理平台')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // ⭐ 数据卡片
      Row({ space: 10 }) {
        this.card('游客数', this.touristCount)
        this.card('告警数', this.alertCount)
      }

      Row({ space: 10 }) {
        this.card('景区数', this.scenicCount)
        this.card('订单数', this.orderCount)
      }
      .margin({ top: 10 })

      // ⭐ 功能入口
      Column() {

        Text('功能模块')
          .fontSize(18)
          .margin({ top: 30, bottom: 10 })

        Row({ space: 10 }) {
          this.menu('景区管理', 'pages/Scenic')
          this.menu('告警调度', 'pages/Alert')
        }

      }

    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
  // =====================
  // 📡 加载首页数据
  // =====================
  loadData() {
    DashboardApi.getData()
      .then((res) => {
        let responseData: ApiResponse = JSON.parse(res.result as string) as ApiResponse
        let data: DashboardData = responseData.data

        this.touristCount = data.touristCount
        this.alertCount = data.alertCount
        this.scenicCount = data.scenicCount
        this.orderCount = data.orderCount
      })
  }

  // =====================
  // UI组件：卡片
  // =====================
  @Builder
  card(title: string, value: number) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor('#666')

      Text(value.toString())
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 5 })
    }
    .width('45%')
    .height(100)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(10)
  }

  // =====================
  // UI组件：菜单
  // =====================
  @Builder
  menu(name: string, url: string) {
    Button(name)
      .width('45%')
      .height(45)
      .backgroundColor('#007DFF')
      .fontColor(Color.White)
      .borderRadius(10)
      .onClick(() => {
        router.push({ url: url })
      })
  }
}