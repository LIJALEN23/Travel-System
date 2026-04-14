
import { AlertApi } from '../common/api/alert'
import http from '@ohos.net.http'
interface AlertItem {
  id: number
  title: string
  level: string
  status: string
}

interface ApiResponse {
  data: AlertItem[]
}

@Entry
@Component
struct Alert {

  @State alertList: AlertItem[] = []

  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {

      Text('告警调度中心')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      List() {
        ForEach(this.alertList, (item: AlertItem) => {

          ListItem() {
            Column() {

              Row() {

                Column() {
                  Text(item.title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)

                  Text('等级：' + item.level)
                    .fontSize(14)
                    .fontColor('#666')
                }
                .layoutWeight(1)

                Text(item.status)
                  .fontColor(item.status === '未处理' ? Color.Red : Color.Green)
                  .fontWeight(FontWeight.Bold)

              }

              Row({ space: 10 }) {

                Button('处理')
                  .backgroundColor('#007DFF')
                  .fontColor(Color.White)
                  .onClick(() => {
                    this.handle(item.id)
                  })

                Button('忽略')
                  .backgroundColor('#FF4D4F')
                  .fontColor(Color.White)
                  .onClick(() => {
                    this.remove(item.id)
                  })

              }
              .margin({ top: 10 })

            }
            .padding(15)
            .backgroundColor(item.status === '未处理' ? '#FFF1F0' : '#F6FFED')
            .borderRadius(10)
            .margin({ bottom: 10 })
          }

        })
      }
      .width('90%')

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center)
  }

  // =====================
  // 📡 加载数据
  // =====================
  loadData() {
    AlertApi.getList()
      .then((res: http.HttpResponse) => {
        let data: ApiResponse = JSON.parse(res.result as string)
        this.alertList = data.data
      })
  }

  // =====================
  // ✅ 处理告警
  // =====================
  handle(id: number) {
    AlertApi.handle(id)
      .then(() => {
        this.loadData()
      })
  }

  // =====================
  // ❌ 删除/忽略
  // =====================
  remove(id: number) {
    AlertApi.delete(id)
      .then(() => {
        this.loadData()
      })
  }
}