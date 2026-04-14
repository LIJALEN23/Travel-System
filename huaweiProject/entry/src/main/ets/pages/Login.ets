import router from '@ohos.router'

@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State message: string = ''

  build() {
    Column() {

      // 顶部标题区域
      Column() {
        Text('旅游管理与调度系统')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Text('Tourism Management System')
          .fontSize(14)
          .fontColor('#888')
          .margin({ top: 5 })
      }
      .margin({ top: 100, bottom: 60 })

      // 登录卡片
      Column({ space: 20 }) {

        // 用户名
        TextInput({ placeholder: '请输入用户名' })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((value: string) => {
            this.username = value
          })

        // 密码
        TextInput({ placeholder: '请输入密码' })
          .type(InputType.Password)
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((value: string) => {
            this.password = value
          })

        // 登录按钮
        Button('登录')
          .width('100%')
          .height(50)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.handleLogin()
          })

        // 提示信息
        if (this.message !== '') {
          Text(this.message)
            .fontSize(14)
            .fontColor(Color.Red)
        }

      }
      .width('85%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({
        radius: 10,
        color: '#00000020',
        offsetX: 0,
        offsetY: 4
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EAF2FF')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  // 登录逻辑
  handleLogin() {
    if (this.username === '' || this.password === '') {
      this.message = '请输入用户名和密码'
      return
    }

    this.message = '登录中...'

    // 👉 这里先用模拟登录（后面再换接口）
    setTimeout(() => {
      if (this.username === '1' && this.password === '1') {
        this.message = '登录成功'

        // 保存登录状态
        AppStorage.setOrCreate('token', 'mock-token')

        // 跳转首页
        router.pushUrl({
          url: 'pages/Home'
        })

      } else {
        this.message = '用户名或密码错误'
      }
    }, 1000)
  }
  // 自动登录（有token直接进首页）
  aboutToAppear() {
    let token: string | undefined = AppStorage.get('token')
    if (token) {
      router.replaceUrl({
        url: 'pages/Home'
      })
    }
  }
}