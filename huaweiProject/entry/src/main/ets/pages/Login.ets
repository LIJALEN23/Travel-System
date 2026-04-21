import router from '@ohos.router'
import { loginRequest } from '../api/loginAPI' // 导入封装的登录API
import { LoginResult } from '../utils/Login'

@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State message: string = ''

  build() {
    Column() {
      // 顶部标题
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
        TextInput({ placeholder: '请输入账号' })
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

        // 注册入口
        Text('没有账号？立即注册')
          .fontSize(14)
          .fontColor('#007DFF')
          .alignSelf(ItemAlign.Center)
          .onClick(() => {
            this.toRegisterPage()
          })

        // 错误提示
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
      .shadow({ radius: 10, color: '#00000020', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EAF2FF')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  // ================================
  // 登录逻辑（极简！只处理业务逻辑）
  // ================================
  async handleLogin(): Promise<void> {
    if (this.username === '' || this.password === '') {
      this.message = '请输入账号和密码'
      return
    }

    this.message = '登录中...'
    try {
      // 调用封装好的API ✨ 核心简化点
      const res: LoginResult = await loginRequest(this.username, this.password)

      if (res.code === 200) {
        this.message = '登录成功'
        // 存储token
        const token = res.data.token
        AppStorage.setOrCreate('token', token)
        console.log("登录成功，token已保存：" + token)
        // 跳转主页
        setTimeout((): void => {
          router.replaceUrl({ url: 'pages/Home' })
        }, 500)
      } else {
        this.message = res.msg || '登录失败'
      }
    } catch (err) {
      this.message = '网络请求失败，请检查后端服务'
      console.error('登录请求错误：', JSON.stringify(err))
    }
  }

  // 跳注册
  toRegisterPage(): void {
    router.pushUrl({ url: 'pages/Register' })
  }

  // 已登录则直接进入主页
  aboutToAppear(): void {
    const token: string | undefined = AppStorage.get<string>('token')
    if (token !== undefined && token !== '') {
      router.replaceUrl({ url: 'pages/Home' })
    }
  }
}