import router from '@ohos.router'
import prompt from '@ohos.prompt'
import { AlertMessage, AlertHandle } from '../utils/Alert'
import {
  getAlertList,
  getLatestUnprocessedAlerts,
  getAlertById,
  autoCheckAlerts,
  checkPassAlert,
  publishAlert,
  handleAlert,
  getHandleList
} from '../api/alertAPI'

interface ApiResponse {
  code: number
  msg: string
  data: AlertMessage[] | AlertMessage
}

interface AutoCheckResponse {
  code: number
  msg: string
}

interface AlertOperationResponse {
  code: number
  msg: string
}

interface HandleListResponse {
  code: number
  msg: string
  data: AlertHandle[]
}

@Entry
@Component
struct Alert {
  @State alertList: AlertMessage[] = []
  @State latestAlerts: AlertMessage[] = []
  @State currentTab: number = 0
  @State showDetailDialog: boolean = false
  @State showHandleDialog: boolean = false
  @State showPublishDialog: boolean = false
  @State showHandleHistoryDialog: boolean = false
  @State currentAlert: AlertMessage = this.getDefaultAlert()
  @State handleResult: string = ''
  @State operatorName: string = ''
  @State leaderName: string = ''
  @State dialogMessage: string = ''
  @State dialogTitle: string = ''
  @State handleHistory: AlertHandle[] = []

  aboutToAppear() {
    this.loadData()
    this.loadLatestAlerts()
  }

  getDefaultAlert(): AlertMessage {
    return {
      id: 0,
      content: '',
      msgType: 'prompt',
      status: 0,
      extInfo: '',
      createTime: '',
      updateTime: ''
    }
  }

  loadData() {
    const token = AppStorage.get<string>("token") || ""
    if (!token) {
      prompt.showToast({ message: '请先登录' })
      router.replaceUrl({ url: "pages/Login" })
      return
    }

    getAlertList(token)
      .then((data) => {
        if (data.code === 200) {
          this.alertList = data.data as AlertMessage[]
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '加载失败：' + error.message })
      })
  }

  loadLatestAlerts() {
    const token = AppStorage.get<string>("token") || ""
    if (!token) {
      return
    }

    getLatestUnprocessedAlerts(token)
      .then((data) => {
        if (data.code === 200) {
          this.latestAlerts = data.data as AlertMessage[]
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '加载失败：' + error.message })
      })
  }

  autoCheck() {
    const token = AppStorage.get<string>("token") || ""
    if (!token) {
      prompt.showToast({ message: '请先登录' })
      router.replaceUrl({ url: "pages/Login" })
      return
    }

    autoCheckAlerts(token)
      .then((data: AutoCheckResponse) => {
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

  showDetail(item: AlertMessage) {
    const token = AppStorage.get<string>("token") || ""
    if (!token) {
      prompt.showToast({ message: '请先登录' })
      return
    }

    getAlertById(token, item.id)
      .then((data: ApiResponse) => {
        if (data.code === 200) {
          this.currentAlert = data.data as AlertMessage
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

  showHandleHistory(item: AlertMessage) {
    const token = AppStorage.get<string>("token") || ""
    if (!token) {
      prompt.showToast({ message: '请先登录' })
      return
    }

    getHandleList(token, item.id)
      .then((data: HandleListResponse) => {
        if (data.code === 200) {
          this.handleHistory = data.data as AlertHandle[]
          this.currentAlert = item
          this.showHandleHistoryDialog = true
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '获取处置记录失败：' + error.message })
      })
  }

  handleAlert() {
    if (!this.handleResult || !this.operatorName) {
      prompt.showToast({ message: '请填写完整信息' })
      return
    }

    const token = AppStorage.get<string>("token") || ""
    if (!token) {
      prompt.showToast({ message: '请先登录' })
      return
    }

    handleAlert(token, this.currentAlert.id, this.handleResult, this.operatorName)
      .then((data: AlertOperationResponse) => {
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
    const token = AppStorage.get<string>("token") || ""
    if (!token) {
      prompt.showToast({ message: '请先登录' })
      return
    }

    if (this.currentAlert.status === 0) { // 未处理
      if (!this.operatorName) {
        prompt.showToast({ message: '请输入值班员姓名' })
        return
      }

      checkPassAlert(token, this.currentAlert.id, this.operatorName)
        .then((data: AlertOperationResponse) => {
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
    } else { // 待发布
      if (!this.leaderName) {
        prompt.showToast({ message: '请输入领导姓名' })
        return
      }

      publishAlert(token, this.currentAlert.id, this.leaderName)
        .then((data: AlertOperationResponse) => {
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

  getStatusText(status: number): string {
    switch (status) {
      case 0: return '未处理'
      case 1: return '待发布'
      case 2: return '已发布'
      case 3: return '已处置'
      default: return '未知'
    }
  }

  getStatusColor(status: number): Color {
    switch (status) {
      case 0: return Color.Red
      case 1: return Color.Orange
      case 2: return Color.Green
      case 3: return Color.Blue
      default: return Color.Gray
    }
  }

  getStatusBgColor(status: number): string {
    switch (status) {
      case 0: return '#FFF1F0'
      case 1: return '#FFF7E6'
      case 2: return '#F6FFED'
      case 3: return '#F0F5FF'
      default: return '#FAFAFA'
    }
  }

  getTitle(content: string): string {
    // 从内容中提取标题，比如提取景区/酒店名称
    const match = content.match(/^(.*?)[?：]/)
    return match ? match[1] : content.substring(0, 20) + '...'
  }

  getLevel(msgType: string): string {
    return msgType === 'alert' ? '告警' : '提示'
  }

  getDetailMessage(): string {
    let alert = this.currentAlert
    return `内容：${alert.content || ''}
类型：${this.getLevel(alert.msgType)}
状态：${this.getStatusText(alert.status)}
创建时间：${alert.createTime || ''}
更新时间：${alert.updateTime || ''}
扩展信息：${alert.extInfo || ''}
值班员：${alert.operator || '无'}
领导：${alert.leader || '无'}
处置结果：${alert.handleResult || '无'}
处置人：${alert.handler || '无'}`
  }

  build() {
    Column() {
      // 顶部导航栏
      Row({ space: 10 }) {
        Button("返回")
          .width(80)
          .height(40)
          .backgroundColor("#007DFF")
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            router.back()
          })

        Text("告警调度中心")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
      .backgroundColor("#F5F7FA")

      // 选项卡
      Row({ space: 15 }) {
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
      .margin({ bottom: 20, top: 10 })

      // 告警列表
      Scroll() {
        Column() {
          ForEach(this.currentTab === 0 ? this.alertList : this.latestAlerts, (item: AlertMessage) => {
            Column() {
              Row() {
                Column() {
                  Text(this.getTitle(item.content))
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)

                  Text('类型：' + this.getLevel(item.msgType))
                    .fontSize(14)
                    .fontColor('#666')

                  Text('时间：' + (item.createTime || '未知'))
                    .fontSize(12)
                    .fontColor('#999')
                }
                .layoutWeight(1)

                Text(this.getStatusText(item.status))
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

                Button('处置记录')
                  .backgroundColor('#722ED1')
                  .fontColor(Color.White)
                  .fontSize(12)
                  .onClick(() => {
                    this.showHandleHistory(item)
                  })

                if (item.status === 0) {
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
                      this.operatorName = ''
                      this.dialogTitle = '处置告警'
                      this.dialogMessage = '请输入处置信息：'
                    })
                }

                if (item.status === 1) {
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
            .margin({ bottom: 10, left: 10, right: 10 })
          })
        }
      }
      .width('100%')
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

          if (this.currentAlert.status === 0) {
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
            Button(this.currentAlert.status === 0 ? '审核通过' : '发布')
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

      // 处置记录弹窗
      if (this.showHandleHistoryDialog) {
        Column() {
          Text('处置记录 - ' + this.getTitle(this.currentAlert.content))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })

          if (this.handleHistory.length === 0) {
            Text('暂无处置记录')
              .fontSize(14)
              .fontColor('#666')
              .margin({ bottom: 20 })
          } else {
            Scroll() {
              Column() {
                ForEach(this.handleHistory, (handle: AlertHandle) => {
                  Column() {
                    Text('处置人：' + handle.handler)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                    Text('处置结果：' + handle.handleResult)
                      .fontSize(12)
                      .fontColor('#666')
                    Text('处置时间：' + handle.handleTime)
                      .fontSize(12)
                      .fontColor('#999')
                  }
                  .padding(10)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(5)
                  .margin({ bottom: 10 })
                })
              }
            }
            .height(200)
            .margin({ bottom: 20 })
          }

          Button('关闭')
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .onClick(() => {
              this.showHandleHistoryDialog = false
            })
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
