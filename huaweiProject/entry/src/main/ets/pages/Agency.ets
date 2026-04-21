
import { AgencyApi, AgencyItem, AlertMessage } from '../common/api/agency'
import http from '@ohos.net.http'
import prompt from '@ohos.prompt'

interface ApiResponse {
  code: number
  msg: string
  data: AgencyItem[] | AgencyItem | AlertMessage[] | AlertMessage
}

@Entry
@Component
struct Agency {
  @State agencyList: AgencyItem[] = []
  @State alertList: AlertMessage[] = []
  @State currentTab: number = 0
  @State showAgencyDialog: boolean = false
  @State showAlertDialog: boolean = false
  @State showHandleDialog: boolean = false
  @State showPublishDialog: boolean = false
  @State currentAgency: AgencyItem = this.getDefaultAgency()
  @State currentAlert: AlertMessage = this.getDefaultAlert()
  @State handleResult: string = ''
  @State operatorName: string = ''
  @State leaderName: string = ''
  @State dialogMessage: string = ''
  @State dialogTitle: string = ''
  @State isEditMode: boolean = false

  aboutToAppear() {
    this.loadAgencies()
    this.loadAlerts()
  }

  getDefaultAgency(): AgencyItem {
    return {
      id: 0,
      name: '',
      licenseNumber: '',
      address: '',
      contactPerson: '',
      phone: '',
      status: '正常'
    }
  }

  getDefaultAlert(): AlertMessage {
    return {
      id: 0,
      title: '',
      content: '',
      level: '',
      status: '',
      createTime: ''
    }
  }

  loadAgencies() {
    AgencyApi.getList()
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        if (data.code === 200) {
          this.agencyList = data.data as AgencyItem[]
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '加载旅行社列表失败：' + error.message })
      })
  }

  loadAlerts() {
    AgencyApi.getLatestUnprocessedAlerts()
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        if (data.code === 200) {
          this.alertList = data.data as AlertMessage[]
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '加载告警列表失败：' + error.message })
      })
  }

  autoCheck() {
    AgencyApi.autoCheck()
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        prompt.showToast({ message: data.msg })
        if (data.code === 200) {
          this.loadAlerts()
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '自动检测失败：' + error.message })
      })
  }

  showAgencyDetail(item: AgencyItem) {
    AgencyApi.getById(item.id)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        if (data.code === 200) {
          this.currentAgency = data.data as AgencyItem
          this.dialogTitle = '旅行社详情'
          this.dialogMessage = this.getAgencyDetailMessage()
          this.showAgencyDialog = true
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '获取详情失败：' + error.message })
      })
  }

  showAlertDetail(item: AlertMessage) {
    AgencyApi.getById(item.id)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        if (data.code === 200) {
          this.currentAlert = data.data as AlertMessage
          this.dialogTitle = '告警详情'
          this.dialogMessage = this.getAlertDetailMessage()
          this.showAlertDialog = true
        } else {
          prompt.showToast({ message: data.msg })
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '获取告警详情失败：' + error.message })
      })
  }

  handleAlert() {
    if (!this.handleResult || !this.operatorName) {
      prompt.showToast({ message: '请填写完整信息' })
      return
    }

    AgencyApi.handle(this.currentAlert.id, this.handleResult, this.operatorName)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        prompt.showToast({ message: data.msg })
        if (data.code === 200) {
          this.showHandleDialog = false
          this.loadAlerts()
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

      AgencyApi.checkPass(this.currentAlert.id, this.operatorName)
        .then((res: http.HttpResponse) => {
          let responseText: string = res.result as string
          let data: ApiResponse = JSON.parse(responseText) as ApiResponse
          prompt.showToast({ message: data.msg })
          if (data.code === 200) {
            this.showPublishDialog = false
            this.loadAlerts()
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

      AgencyApi.publish(this.currentAlert.id, this.leaderName)
        .then((res: http.HttpResponse) => {
          let responseText: string = res.result as string
          let data: ApiResponse = JSON.parse(responseText) as ApiResponse
          prompt.showToast({ message: data.msg })
          if (data.code === 200) {
            this.showPublishDialog = false
            this.loadAlerts()
          }
        })
        .catch((error: Error) => {
          prompt.showToast({ message: '发布失败：' + error.message })
        })
    }
  }

  saveAgency() {
    if (!this.currentAgency.name || !this.currentAgency.licenseNumber || 
        !this.currentAgency.address || !this.currentAgency.contactPerson || 
        !this.currentAgency.phone) {
      prompt.showToast({ message: '请填写完整信息' })
      return
    }

    if (this.isEditMode) {
      this.updateAgency()
    } else {
      this.createAgency()
    }
  }
  updateAgency() {
    AgencyApi.update(this.currentAgency)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        prompt.showToast({ message: data.msg })
        if (data.code === 200) {
          this.showAgencyDialog = false
          this.loadAgencies()
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '更新失败：' + error.message })
      })
  }
  createAgency() {
    AgencyApi.create(this.currentAgency)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        prompt.showToast({ message: data.msg })
        if (data.code === 200) {
          this.showAgencyDialog = false
          this.loadAgencies()
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '创建失败：' + error.message })
      })
  }

  deleteAgency(id: number) {
    AgencyApi.delete(id)
      .then((res: http.HttpResponse) => {
        let responseText: string = res.result as string
        let data: ApiResponse = JSON.parse(responseText) as ApiResponse
        prompt.showToast({ message: data.msg })
        if (data.code === 200) {
          this.loadAgencies()
        }
      })
      .catch((error: Error) => {
        prompt.showToast({ message: '删除失败：' + error.message })
      })
  }

  getStatusColor(status: string): Color {
    switch (status) {
      case '未处理': return Color.Red
      case '待发布': return Color.Orange
      case '已发布': return Color.Green
      case '已处置': return Color.Blue
      case '正常': return Color.Green
      case '异常': return Color.Red
      default: return Color.Gray
    }
  }

  getStatusBgColor(status: string): string {
    switch (status) {
      case '未处理': return '#FFF1F0'
      case '待发布': return '#FFF7E6'
      case '已发布': return '#F6FFED'
      case '已处置': return '#F0F5FF'
      case '正常': return '#F6FFED'
      case '异常': return '#FFF1F0'
      default: return '#FAFAFA'
    }
  }

  getAgencyDetailMessage(): string {
    let agency = this.currentAgency
    return `旅行社名称：${agency.name || ''}
许可证号：${agency.licenseNumber || ''}
地址：${agency.address || ''}
联系人：${agency.contactPerson || ''}
电话：${agency.phone || ''}
状态：${agency.status || ''}
创建时间：${agency.createTime || ''}
更新时间：${agency.updateTime || ''}`
  }

  getAlertDetailMessage(): string {
    let alert = this.currentAlert
    return `标题：${alert.title || ''}
内容：${alert.content || ''}
等级：${alert.level || ''}
状态：${alert.status || ''}
时间：${alert.createTime || ''}
操作人：${alert.operator || ''}
领导：${alert.leader || ''}
处置结果：${alert.handleResult || ''}
处置人：${alert.handler || ''}`
  }

  build() {
    Column() {
      Text('旅行社管理系统')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // 选项卡
      Row({ space: 20 }) {
        Button('旅行社列表')
          .backgroundColor(this.currentTab === 0 ? '#007DFF' : '#F5F5F5')
          .fontColor(this.currentTab === 0 ? Color.White : '#333')
          .onClick(() => {
            this.currentTab = 0
            this.loadAgencies()
          })

        Button('告警管理')
          .backgroundColor(this.currentTab === 1 ? '#007DFF' : '#F5F5F5')
          .fontColor(this.currentTab === 1 ? Color.White : '#333')
          .onClick(() => {
            this.currentTab = 1
            this.loadAlerts()
          })

        Button('自动检测')
          .backgroundColor(this.currentTab === 2 ? '#007DFF' : '#F5F5F5')
          .fontColor(this.currentTab === 2 ? Color.White : '#333')
          .onClick(() => {
            this.autoCheck()
          })
      }
      .margin({ bottom: 20 })

      // 旅行社列表
      if (this.currentTab === 0) {
        Column() {
          Row({ space: 10 }) {
            Button('新增旅行社')
              .backgroundColor('#52C41A')
              .fontColor(Color.White)
              .onClick(() => {
                this.currentAgency = this.getDefaultAgency()
                this.isEditMode = false
                this.dialogTitle = '新增旅行社'
                this.showAgencyDialog = true
              })
          }
          .margin({ bottom: 20 })

          List() {
            ForEach(this.agencyList, (item: AgencyItem) => {
              ListItem() {
                Column() {
                  Row() {
                    Column() {
                      Text(item.name)
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)

                      Text('许可证：' + item.licenseNumber)
                        .fontSize(14)
                        .fontColor('#666')

                      Text('联系人：' + item.contactPerson + ' ' + item.phone)
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
                      .backgroundColor('#1890FF')
                      .fontColor(Color.White)
                      .fontSize(12)
                      .onClick(() => {
                        this.showAgencyDetail(item)
                      })

                    Button('编辑')
                      .backgroundColor('#FF7D00')
                      .fontColor(Color.White)
                      .fontSize(12)
                      .onClick(() => {
                        this.currentAgency = item
                        this.isEditMode = true
                        this.dialogTitle = '编辑旅行社'
                        this.showAgencyDialog = true
                      })

                    Button('删除')
                      .backgroundColor('#FF4D4F')
                      .fontColor(Color.White)
                      .fontSize(12)
                      .onClick(() => {
                        this.deleteAgency(item.id)
                      })
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
        }
        .width('100%')
      }

      // 告警管理
      if (this.currentTab === 1) {
        List() {
          ForEach(this.alertList, (item: AlertMessage) => {
            ListItem() {
              Column() {
                Row() {
                  Column() {
                    Text(item.title)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)

                    Text('内容：' + item.content)
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
                      this.showAlertDetail(item)
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
      }

      // 旅行社弹窗
      if (this.showAgencyDialog) {
        Column() {
          Text(this.dialogTitle)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 15 })

          if (this.isEditMode) {
            Text(this.dialogMessage)
              .fontSize(14)
              .margin({ bottom: 20 })

            Button('关闭')
              .backgroundColor('#007DFF')
              .fontColor(Color.White)
              .onClick(() => {
                this.showAgencyDialog = false
              })
          } else {
            TextInput({ placeholder: '旅行社名称' })
              .width('100%')
              .margin({ bottom: 10 })
              .onChange((value: string) => {
                this.currentAgency.name = value
              })

            TextInput({ placeholder: '许可证号' })
              .width('100%')
              .margin({ bottom: 10 })
              .onChange((value: string) => {
                this.currentAgency.licenseNumber = value
              })

            TextInput({ placeholder: '地址' })
              .width('100%')
              .margin({ bottom: 10 })
              .onChange((value: string) => {
                this.currentAgency.address = value
              })

            TextInput({ placeholder: '联系人' })
              .width('100%')
              .margin({ bottom: 10 })
              .onChange((value: string) => {
                this.currentAgency.contactPerson = value
              })

            TextInput({ placeholder: '电话' })
              .width('100%')
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.currentAgency.phone = value
              })

            Row({ space: 10 }) {
              Button('保存')
                .backgroundColor('#52C41A')
                .fontColor(Color.White)
                .onClick(() => {
                  this.saveAgency()
                })

              Button('取消')
                .backgroundColor('#F5F5F5')
                .fontColor('#333')
                .onClick(() => {
                  this.showAgencyDialog = false
                })
            }
          }
        }
        .width('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .shadow({ radius: 10, color: '#00000020', offsetX: 0, offsetY: 2 })
      }

      // 告警详情弹窗
      if (this.showAlertDialog) {
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
              this.showAlertDialog = false
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