import router from '@ohos.router'
import { registerRequest } from '../api/loginAPI' // 导入封装的注册API
import { RegisterResult } from '../utils/Login'

@Entry
@Component
struct Register {
  // 注册表单绑定字段
  @State account: string = ''
  @State password: string = ''
  @State confirmPwd: string = ''
  @State realName: string = ''
  @State phone: string = ''
  @State email: string = ''
  @State remark: string = ''
  @State message: string = ''

  build() {
    Column() {
      // 顶部标题
      Column() {
        Text('用户注册')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')

        Text('Tourism Management System')
          .fontSize(14)
          .fontColor('#888')
          .margin({ top: 5 })
      }
      .margin({ top: 80, bottom: 40 })

      // 注册表单卡片
      Column({ space: 16 }) {
        TextInput({ placeholder: '请设置登录账号' })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((val: string) => { this.account = val })

        TextInput({ placeholder: '请设置登录密码' })
          .type(InputType.Password)
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((val: string) => { this.password = val })

        TextInput({ placeholder: '请再次确认密码' })
          .type(InputType.Password)
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((val: string) => { this.confirmPwd = val })

        TextInput({ placeholder: '请输入真实姓名' })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((val: string) => { this.realName = val })

        TextInput({ placeholder: '请输入手机号' })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((val: string) => { this.phone = val })

        TextInput({ placeholder: '请输入邮箱（选填）' })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((val: string) => { this.email = val })

        TextInput({ placeholder: '备注信息（选填）' })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 15 })
          .onChange((val: string) => { this.remark = val })

        // 注册按钮
        Button('立即注册')
          .width('100%')
          .height(50)
          .backgroundColor('#28a745')
          .fontColor(Color.White)
          .borderRadius(12)
          .onClick(() => {
            this.handleRegister()
          })

        // 返回登录入口
        Text('已有账号？返回登录')
          .fontSize(14)
          .fontColor('#007DFF')
          .alignSelf(ItemAlign.Center)
          .onClick(() => {
            router.back()
          })

        // 提示信息
        if (this.message !== '') {
          Text(this.message)
            .fontSize(14)
            .fontColor(Color.Red)
            .textAlign(TextAlign.Center)
        }
      }
      .width('85%')
      .padding(24)
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

  // 注册核心逻辑（极简！无网络请求代码）
  async handleRegister(): Promise<void> {
    // 1. 前端表单校验（保留原有逻辑）
    if (!this.account || !this.password || !this.realName) {
      this.message = '账号、密码、姓名为必填项'
      return
    }
    if (this.password !== this.confirmPwd) {
      this.message = '两次输入的密码不一致'
      return
    }
    if (this.password.length < 6) {
      this.message = '密码长度至少6位'
      return
    }

    this.message = '正在注册...'
    try {
      // 2. 调用封装好的注册API ✨
      const res: RegisterResult = await registerRequest(
        this.account,
        this.password,
        this.realName,
        this.phone,
        this.email,
        this.remark
      )

      // 3. 处理返回结果
      if (res.code === 200) {
        this.message = '🎉 注册成功！即将跳转登录'
        setTimeout((): void => { router.back() }, 1200)
      } else {
        this.message = res.msg || '注册失败，请重试'
      }
    } catch (err) {
      // 4. 统一错误处理
      this.message = '服务器连接失败，请检查后端是否启动'
      console.error('注册请求异常', JSON.stringify(err))
    }
  }
}