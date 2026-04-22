import router from '@ohos.router'
import { BusinessError } from '@ohos.base'

@Entry
@Component
struct Home {
  // 底部导航：0=功能界面 1=用户中心
  @State selectedIndex: number = 0

  build() {
    Column() {
      // 内容区域
      if (this.selectedIndex === 0) {
        this.FunctionPage()
      } else {
        this.UserCenterPage()
      }

      // 底部导航栏
      this.NavBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  // ==========================
  // 功能界面（7大模块 + 系统管理）
  // ==========================
  @Builder
  FunctionPage() {
    Scroll() {
      Column({ space: 14 }) {
        Text("旅游管理系统")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 25, bottom: 10 })

        Text("功能模块列表")
          .fontSize(16)
          .fontColor("#666")
          .margin({ bottom: 10 })

        // 👇 完全用你的真实页面路径！
        this.FuncItem("🏞️ 旅游景区管理", "pages/Scenic")
        this.FuncItem("🏨 星级饭店管理", "pages/Hotel")
        this.FuncItem("🚌 旅行社管理", "pages/Agency")
        this.FuncItem("🧑‍✈️ 导游管理", "pages/Guide")
        this.FuncItem("🚨 告警信息管理", "pages/Alert")
        this.FuncItem("📢 游客投诉管理", "pages/Complaint")

      }
      .width('100%')
      .padding({ bottom: 40 })
    }
    .width('100%')
    .layoutWeight(1)
  }

  // 功能按钮
  @Builder
  FuncItem(name: string, url: string) {
    Button(name)
      .width('90%')
      .height(58)
      .backgroundColor(Color.White)
      .fontColor('#333')
      .fontSize(16)
      .borderRadius(14)
      .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
      .onClick(() => {
        router.pushUrl({ url: url })
      })
  }

  // ==========================
  // 用户中心界面
  // ==========================
  @Builder
  UserCenterPage() {
    Column({ space: 22 }) {
      Text("个人中心")
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60 })

      Button("个人信息")
        .width(220)
        .height(52)
        .backgroundColor('#007DFF')
        .borderRadius(12)

      Button("修改密码")
        .width(220)
        .height(52)
        .backgroundColor('#007DFF')
        .borderRadius(12)

      Button("退出登录")
        .width(220)
        .height(52)
        .backgroundColor('#FF3333')
        .borderRadius(12)
        .onClick(() => {
          // 清除token
          AppStorage.delete("token")
          // 返回登录页
          router.replaceUrl({ url: "pages/Login" })
        })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  // ==========================
  // 底部导航栏
  // ==========================
  @Builder
  NavBar() {
    Row() {
      this.NavItem("功能界面", 0)
      this.NavItem("用户中心", 1)
    }
    .width('100%')
    .height(65)
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceAround)
    .shadow({ radius: 10, color: '#00000010' })
  }

  @Builder
  NavItem(text: string, index: number) {
    Column() {
      Text(text)
        .fontColor(this.selectedIndex === index ? '#007DFF' : '#777')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
    }
    .onClick(() => {
      this.selectedIndex = index
    })
  }
}