import { AlertApi } from '../common/api/alert'
import http from '@ohos.net.http'
import prompt from '@ohos.prompt'

interface AlertItem {
  id: number
  title: string
  level: string
  status: string
  content?: string
  createTime?: string
  operator?: string
  leader?: string
  handleResult?: string
  handler?: string
}

interface ApiResponse {
  code: number
  msg: string
  data: AlertItem[] | AlertItem
}

@Entry
@Component
struct Alert {
  @State alertList: AlertItem[] = []
  @State latestAlerts: AlertItem[] = []
  @State currentTab: number = 0
  @State showDetailDialog: boolean = false
  @State showHandleDialog: boolean = false
  @State showPublishDialog: boolean = false
  @State currentAlert: AlertItem = this.getDefaultAlert()
  @State handleResult: string = ''
  @State operatorName: string = ''
  @State leaderName: string = ''
  @State dialogMessage: string = ''
  @State dialogTitle: string = ''

  aboutToAppear() {
    this.loadData()
    this.loadLatestAlerts()
  }

  getDefaultAlert(): AlertItem {
    return {
      id: 0,
      title: '',
      level: '',
      status: ''
    }
  }

  loadData() {
    AlertApi.getList()
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        if (data.code === 200) {
          this.alertList = data.data as AlertItem[]
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '加载失败：' + error.message })
      })
  }

  loadLatestAlerts() {
    AlertApi.getLatestUnprocessedAlerts()
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        if (data.code === 200) {
          this.latestAlerts = data.data as AlertItem[]
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '加载失败：' + error.message })
      })
  }

  autoCheck() {
    AlertApi.autoCheck()
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        prompt.showToast({ message: data.msg })
        if (data.code === 200) {
          this.loadData()
          this.loadLatestAlerts()
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '自动检测失败：' + error.message })
      })
  }

  showDetail(item: AlertItem) {
    AlertApi.getById(item.id)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        if (data.code === 200) {
          this.currentAlert = data.data as AlertItem
          this.dialogTitle = '告警详情'
          this.dialogMessage = this.getDetailMessage()
          this.showDetailDialog = true
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '获取详情失败：' + error.message })
      })
  }

  handleAlert() {
    if (!this.handleResult || !this.operatorName) {
      prompt.showToast({ message: '请填写完整信息' })
      return
    }

    AlertApi.handle(this.currentAlert.id, this.handleResult, this.operatorName)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        prompt.showToast({ message: data.msg })
        if (data.code === 200) {
          this.showHandleDialog = false
          this.loadData()
          this.loadLatestAlerts()
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '处置失败：' + error.message })
      })
  }

  publishAlert() {
    if (this.currentAlert.status === '未处理') {
      if (!this.operatorName) {
        prompt.showToast({ message: '请输入值班员姓名' })
        return
      }

      AlertApi.checkPass(this.currentAlert.id, this.operatorName)
        .then((res: http.HttpResponse) => {
          let responseText: string = res.result as string
          let data: ApiResponse = JSON.parse(responseText) as ApiResponse
          prompt.showToast({ message: data.msg })
          if (data.code === 200) {
            this.showPublishDialog = false
            this.loadData()
            this.loadLatestAlerts()
          }
        })
        .catch((error: Error) => {
          prompt.showToast({ message: '审核失败：' + error.message })
        })
    } else {
      if (!this.leaderName) {
        prompt.showToast({ message: '请输入领导姓名' })
        return
      }

      AlertApi.publish(this.currentAlert.id, this.leaderName)
        .then((res: http.HttpResponse) => {
          let responseText: string = res.result as string
          let data: ApiResponse = JSON.parse(responseText) as ApiResponse
          prompt.showToast({ message: data.msg })
          if (data.code === 200) {
            this.showPublishDialog = false
            this.loadData()
            this.loadLatestAlerts()
          }
        })
        .catch((error: Error) => {
          prompt.showToast({ message: '发布失败：' + error.message })
        })
    }
  }

  getStatusColor(status: string): Color {
    switch (status) {
      case '未处理': return Color.Red
      case '待发布': return Color.Orange
      case '已发布': return Color.Green
      case '已处置': return Color.Blue
      default: return Color.Gray
    }
  }

  getStatusBgColor(status: string): string {
    switch (status) {
      case '未处理': return '#FFF1F0'
      case '待发布': return '#FFF7E6'
      case '已发布': return '#F6FFED'
      case '已处置': return '#F0F5FF'
      default: return '#FAFAFA'
    }
  }

  getDetailMessage(): string {
    let alert = this.currentAlert
    return `标题：${alert.title || ''}
等级：${alert.level || ''}
状态：${alert.status || ''}
内容：${alert.content || ''}
时间：${alert.createTime || ''}
操作人：${alert.operator || ''}
领导：${alert.leader || ''}
处置结果：${alert.handleResult || ''}
处置人：${alert.handler || ''}`
  }

  build() {
    Column() {
      Text('告警调度中心')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // 选项卡
      Row({ space: 20 }) {
        Button('全部告警')
          .backgroundColor(this.currentTab === 0 ? '#007DFF' : '#F5F5F5')
          .fontColor(this.currentTab === 0 ? Color.White : '#333')
          .onClick(() => {
            this.currentTab = 0
            this.loadData()
          })

        Button('最新未处理')
          .backgroundColor(this.currentTab === 1 ? '#007DFF' : '#F5F5F5')
          .fontColor(this.currentTab === 1 ? Color.White : '#333')
          .onClick(() => {
            this.currentTab = 1
            this.loadLatestAlerts()
          })

        Button('自动检测')
          .backgroundColor(this.currentTab === 2 ? '#007DFF' : '#F5F5F5')
          .fontColor(this.currentTab === 2 ? Color.White : '#333')
          .onClick(() => {
            this.autoCheck()
          })
      }
      .margin({ bottom: 20 })

      // 告警列表
      List() {
        ForEach(this.currentTab === 0 ? this.alertList : this.latestAlerts, (item: AlertItem) => {
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

                  Text('时间：' + (item.createTime || '未知'))
                    .fontSize(12)
                    .fontColor('#999')
                }
                .layoutWeight(1)

                Text(item.status)
                  .fontColor(this.getStatusColor(item.status))
                  .fontWeight(FontWeight.Bold)
              }

              Row({ space: 10 }) {
                Button('详情')
                  .backgroundColor('#52C41A')
                  .fontColor(Color.White)
                  .fontSize(12)
                  .onClick(() => {
                    this.showDetail(item)
                  })

                if (item.status === '未处理') {
                  Button('审核通过')
                    .backgroundColor('#1890FF')
                    .fontColor(Color.White)
                    .fontSize(12)
                    .onClick(() => {
                      this.showPublishDialog = true
                      this.currentAlert = item
                      this.operatorName = ''
                      this.dialogTitle = '审核通过'
                      this.dialogMessage = '请输入值班员姓名：'
                    })

                  Button('直接处置')
                    .backgroundColor('#FF7D00')
                    .fontColor(Color.White)
                    .fontSize(12)
                    .onClick(() => {
                      this.showHandleDialog = true
                      this.currentAlert = item
                      this.handleResult = ''
                      this.dialogTitle = '处置告警'
                      this.dialogMessage = '请输入处置结果：'
                    })
                }

                if (item.status === '待发布') {
                  Button('发布')
                    .backgroundColor('#722ED1')
                    .fontColor(Color.White)
                    .fontSize(12)
                    .onClick(() => {
                      this.showPublishDialog = true
                      this.currentAlert = item
                      this.leaderName = ''
                      this.dialogTitle = '发布告警'
                      this.dialogMessage = '请输入领导姓名：'
                    })
                }
              }
              .margin({ top: 10 })
            }
            .padding(15)
            .backgroundColor(this.getStatusBgColor(item.status))
            .borderRadius(10)
            .margin({ bottom: 10 })
          }
        })
      }
      .width('90%')
      .layoutWeight(1)

      // 详情弹窗
      if (this.showDetailDialog) {
        Column() {
          Text(this.dialogTitle)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })

          Text(this.dialogMessage)
            .fontSize(14)
            .margin({ bottom: 20 })

          Button('关闭')
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .onClick(() => {
              this.showDetailDialog = false
            })
        }
        .width('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .shadow({ radius: 10, color: '#00000020', offsetX: 0, offsetY: 2 })
      }

      // 处置弹窗
      if (this.showHandleDialog) {
        Column() {
          Text(this.dialogTitle)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })

          Text(this.dialogMessage)
            .fontSize(14)
            .margin({ bottom: 10 })

          TextInput({ placeholder: '处置人姓名' })
            .width('100%')
            .margin({ bottom: 10 })
            .onChange((value: string) => {
              this.operatorName = value
            })

          TextInput({ placeholder: '处置结果描述' })
            .width('100%')
            .margin({ bottom: 20 })
            .onChange((value: string) => {
              this.handleResult = value
            })

          Row({ space: 10 }) {
            Button('确认处置')
              .backgroundColor('#FF7D00')
              .fontColor(Color.White)
              .onClick(() => {
                this.handleAlert()
              })

            Button('取消')
              .backgroundColor('#F5F5F5')
              .fontColor('#333')
              .onClick(() => {
                this.showHandleDialog = false
              })
          }
        }
        .width('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .shadow({ radius: 10, color: '#00000020', offsetX: 0, offsetY: 2 })
      }

      // 发布弹窗
      if (this.showPublishDialog) {
        Column() {
          Text(this.dialogTitle)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })

          Text(this.dialogMessage)
            .fontSize(14)
            .margin({ bottom: 10 })

          if (this.currentAlert.status === '未处理') {
            TextInput({ placeholder: '值班员姓名' })
              .width('100%')
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.operatorName = value
              })
          } else {
            TextInput({ placeholder: '领导姓名' })
              .width('100%')
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.leaderName = value
              })
          }

          Row({ space: 10 }) {
            Button(this.currentAlert.status === '未处理' ? '审核通过' : '发布')
              .backgroundColor('#1890FF')
              .fontColor(Color.White)
              .onClick(() => {
                this.publishAlert()
              })

            Button('取消')
              .backgroundColor('#F5F5F5')
              .fontColor('#333')
              .onClick(() => {
                this.showPublishDialog = false
              })
          }
        }
        .width('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .shadow({ radius: 10, color: '#00000020', offsetX: 0, offsetY: 2 })
      }

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center)
  }
}