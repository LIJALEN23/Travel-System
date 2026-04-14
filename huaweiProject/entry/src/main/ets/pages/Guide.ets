
import { GuideApi } from '../common/api/guide'
import http from '@ohos.net.http'
interface GuideItem {
  id: number
  name: string
  status: string   // 在岗 / 休息
}

interface SaveGuideData {
  id?: number
  name: string
  status: string
}

interface ApiResponse {
  data: GuideItem[]
}

@Entry
@Component
struct Guide {

  @State guideList: GuideItem[] = []

  @State keyword: string = ''

  @State showDialog: boolean = false
  @State newName: string = ''
  @State newStatus: string = '在岗'

  @State isEdit: boolean = false
  @State editId: number = -1

  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {

      Text('导游管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // ➕ 新增
      Button('新增导游')
        .width('90%')
        .margin({ bottom: 10 })
        .onClick(() => this.openAdd())

      // 🔍 查询
      Row() {
        TextInput({ placeholder: '请输入导游姓名' })
          .width('70%')
          .onChange((v: string) => this.keyword = v)

        Button('查询')
          .onClick(() => this.search())
      }
      .width('90%')

      // 📋 列表
      List() {
        ForEach(this.guideList, (item: GuideItem) => {

          ListItem() {
            Row() {

              Column() {
                Text(item.name)
                  .fontSize(18)

                Text('状态：' + item.status)
                  .fontSize(14)
                  .fontColor(item.status === '在岗' ? Color.Green : Color.Gray)
              }
              .layoutWeight(1)

              Button('编辑')
                .backgroundColor('#FFA500')
                .onClick(() => this.openEdit(item))

              Button('删除')
                .backgroundColor('#FF4D4F')
                .margin({ left: 5 })
                .onClick(() => this.deleteItem(item.id))

            }
            .padding(10)
            .backgroundColor(Color.White)
            .borderRadius(10)
            .margin({ bottom: 10 })
          }

        })
      }
      .width('90%')
      .margin({ top: 20 })

      // 🪟 弹窗
      if (this.showDialog) {
        Column() {

          Text(this.isEdit ? '编辑导游' : '新增导游')
            .fontSize(18)
          TextInput({ placeholder: '导游姓名', text: this.newName })
            .onChange((v: string) => this.newName = v)

          Row({ space: 10 }) {
            Button('在岗')
              .backgroundColor(this.newStatus === '在岗' ? '#007DFF' : '#ccc')
              .onClick(() => this.newStatus = '在岗')

            Button('休息')
              .backgroundColor(this.newStatus === '休息' ? '#007DFF' : '#ccc')
              .onClick(() => this.newStatus = '休息')
          }
          .margin({ top: 10 })

          Row({ space: 10 }) {
            Button('取消')
              .onClick(() => this.closeDialog())

            Button('确定')
              .onClick(() => this.saveItem())
          }
          .margin({ top: 10 })

        }
        .width('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(12)
      }

    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  // =====================
  // 接口
  // =====================
  loadData(): void {
    GuideApi.getList()
      .then((res: http.HttpResponse) => {
        let parseResult: ApiResponse = JSON.parse(res.result as string) as ApiResponse
        this.guideList = parseResult.data
      })
  }
  search(): void {
    if (this.keyword === '') {
      this.loadData()
      return
    }
    GuideApi.search(this.keyword)
      .then((res: http.HttpResponse) => {
        let parseResult: ApiResponse = JSON.parse(res.result as string) as ApiResponse
        this.guideList = parseResult.data
      })
  }
  deleteItem(id: number): void {
    GuideApi.delete(id)
      .then(() => this.loadData())
  }
  openAdd(): void {
    this.isEdit = false
    this.showDialog = true
    this.newName = ''
    this.newStatus = '在岗'
  }

  openEdit(item: GuideItem) {
    this.isEdit = true
    this.showDialog = true

    this.editId = item.id
    this.newName = item.name
    this.newStatus = item.status
  }
  saveItem(): void {
    let data: SaveGuideData = {
      id: this.isEdit ? this.editId : undefined,
      name: this.newName,
      status: this.newStatus
    }

    let api = this.isEdit
      ? GuideApi.update(data)
      : GuideApi.add(data)
    api.then(() => {
      this.closeDialog()
      this.loadData()
    })
  }

  closeDialog() {
    this.showDialog = false
    this.newName = ''
    this.newStatus = '在岗'
    this.isEdit = false
    this.editId = -1
  }
}