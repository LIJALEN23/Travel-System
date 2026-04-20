import { HotelApi } from '../common/api/hotel'

interface HotelItem {
  id: number
  name: string
  address: string
}

@Entry
@Component
struct Hotel {

  @State hotelList: HotelItem[] = []

  @State keyword: string = ''

  @State showDialog: boolean = false
  @State newName: string = ''
  @State newAddress: string = ''
  @State isEdit: boolean = false
  @State editId: number | undefined = undefined

  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {

      Text('饭店管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // ➕ 新增
      Button('新增饭店')
        .width('90%')
        .margin({ bottom: 10 })
        .onClick(() => {
          this.openAdd()
        })

      // 🔍 查询
      Row() {
        TextInput({ placeholder: '请输入饭店名称' })
          .width('70%')
          .onChange((v: string) => this.keyword = v)

        Button('查询')
          .onClick(() => this.search())
      }
      .width('90%')

      // 📋 列表
      List() {
        ForEach(this.hotelList, (item: HotelItem) => {

          ListItem() {
            Row() {

              Column() {
                Text(item.name)
                  .fontSize(18)

                Text(item.address)
                  .fontSize(14)
                  .fontColor('#666')
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

          Text(this.isEdit ? '编辑饭店' : '新增饭店')
            .fontSize(18)
          TextInput({ placeholder: '饭店名称', text: this.newName })
            .onChange((v: string) => this.newName = v)
          TextInput({ placeholder: '地址', text: this.newAddress })
            .onChange((v: string) => this.newAddress = v)

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
    HotelApi.getList()
      .then(res => {
        interface ResponseData {
          data: HotelItem[]
        }
        let data: ResponseData = JSON.parse(res.result as string)
        this.hotelList = data.data
      })
  }
  search(): void {
    if (this.keyword === '') {
      this.loadData()
      return
    }
    HotelApi.search(this.keyword)
      .then(res => {
        interface ResponseData {
          data: HotelItem[]
        }
        let data: ResponseData = JSON.parse(res.result as string)
        this.hotelList = data.data
      })
  }
  deleteItem(id: number): void {
    HotelApi.delete(id)
      .then(() => this.loadData())
  }
  openAdd(): void {
    this.isEdit = false
    this.showDialog = true
    this.newName = ''
    this.newAddress = ''
  }
  openEdit(item: HotelItem): void {
    this.isEdit = true
    this.showDialog = true

    this.editId = item.id
    this.newName = item.name
    this.newAddress = item.address
  }
  saveItem() {
    let data: Partial<HotelItem> = {
      id: this.isEdit ? this.editId : undefined,
      name: this.newName,
      address: this.newAddress
    }

    let api = this.isEdit
      ? HotelApi.update(data)
      : HotelApi.add(data)

    api.then(() => {
      this.closeDialog()
      this.loadData()
    })
  }

  closeDialog() {
    this.showDialog = false
    this.newName = ''
    this.newAddress = ''
    this.isEdit = false
    this.editId = -1
  }
}