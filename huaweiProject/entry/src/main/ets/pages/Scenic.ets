
import { ScenicApi, HttpResponse, RequestData } from '../common/api/scenic'
import router from '@ohos.router'
interface ScenicItem {
  id: number
  name: string
  location: string
}

interface ApiResponse {
  data: ScenicItem[]
  code: number
  message: string
}

interface ScenicFormData {
  id?: number
  name: string
  location: string
}

@Entry
@Component
struct Scenic {

  onBackPress(): boolean {
    router.back()  // 拦截物理返回键/侧滑手势
    return true    // 阻止默认返回行为
  }

  @State scenicList: ScenicItem[] = []

  @State keyword: string = ''

  @State showDialog: boolean = false
  @State newName: string = ''
  @State newLocation: string = ''

  @State isEdit: boolean = false
  @State editId: number = -1

  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {

      Text('景区管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // ➕ 新增
      Button('新增景区')
        .width('90%')
        .margin({ bottom: 10 })
        .onClick(() => {
          this.openAdd()
        })

      // 🔍 查询
      Row() {
        TextInput({ placeholder: '请输入景区名称' })
          .width('70%')
          .onChange((v: string) => {
            this.keyword = v
          })

        Button('查询')
          .onClick(() => {
            this.search()
          })
      }
      .width('90%')

      // 📋 列表
      List() {
        ForEach(this.scenicList, (item: ScenicItem) => {

          ListItem() {
            Row() {

              Column() {
                Text(item.name)
                  .fontSize(18)

                Text(item.location)
                  .fontSize(14)
                  .fontColor('#666')
              }
              .layoutWeight(1)

              Button('编辑')
                .backgroundColor('#FFA500')
                .onClick(() => {
                  this.openEdit(item)
                })

              Button('删除')
                .backgroundColor('#FF4D4F')
                .margin({ left: 5 })
                .onClick(() => {
                  this.deleteItem(item.id)
                })

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

          Text(this.isEdit ? '编辑景区' : '新增景区')
            .fontSize(18)
          TextInput({ placeholder: '名称', text: this.newName })
            .onChange((v: string) => this.newName = v)

          TextInput({ placeholder: '地址', text: this.newLocation })
            .onChange((v: string) => this.newLocation = v)

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
  // 🌐 接口：加载数据
  // =====================
  loadData() {
    ScenicApi.getList()
      .then((res: HttpResponse) => {
        let data: ApiResponse = JSON.parse(res.result as string)
        this.scenicList = data.data
      })
  }

  // =====================
  // 🔍 查询（前端过滤）
  // =====================
  search() {
    if (this.keyword === '') {
      this.loadData()
      return
    }
    ScenicApi.search(this.keyword)
      .then((res: HttpResponse) => {
        let data: ApiResponse = JSON.parse(res.result as string)
        this.scenicList = data.data
      })
  }

  // =====================
  // 🗑 删除
  // =====================
  deleteItem(id: number) {
    ScenicApi.delete(id)
      .then(() => {
        this.loadData()
      })
  }

  // =====================
  // ➕ 新增
  // =====================
  openAdd() {
    this.isEdit = false
    this.showDialog = true
    this.newName = ''
    this.newLocation = ''
  }

  // =====================
  // ✏️ 编辑
  // =====================
  openEdit(item: ScenicItem) {
    this.isEdit = true
    this.showDialog = true

    this.editId = item.id
    this.newName = item.name
    this.newLocation = item.location
  }

  // =====================
  // 💾 保存（新增+修改）
  // =====================
  saveItem() {

    let data: ScenicFormData = {
      id: this.isEdit ? this.editId : undefined,
      name: this.newName,
      location: this.newLocation
    }
    let api = this.isEdit
      ? ScenicApi.update(data as RequestData)
      : ScenicApi.add(data as RequestData)

    api.then(() => {
      this.closeDialog()
      this.loadData()
    })
  }

  // =====================
  // ❌ 关闭弹窗
  // =====================
  closeDialog() {
    this.showDialog = false
    this.newName = ''
    this.newLocation = ''
    this.isEdit = false
    this.editId = -1
  }
}