
import { CreditApi, ApiResponse, SubmitData } from '../common/api/credit'
interface CreditItem {
  name: string
  score: number
}
interface JsonResult {
  code: number
  data: CreditItem[]
}

@Entry
@Component
struct Credit {

  // =====================
  // 数据
  // =====================
  @State creditList: CreditItem[] = []

  // 输入框
  @State newName: string = ''
  @State newScore: string = ''

  @State message: string = ''

  // 页面加载
  aboutToAppear() {
    this.loadData()
  }

  build() {
    Column() {

      // 标题
      Text('诚信评价系统')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 20 })

      // =====================
      // ⭐ 输入区域
      // =====================
      Column({ space: 10 }) {
        TextInput({ placeholder: '请输入景区名称', text: this.newName })
          .width('100%')
          .onChange((v: string) => this.newName = v)
        TextInput({ placeholder: '请输入评分（0-100）', text: this.newScore })
          .type(InputType.Number)
          .width('100%')
          .onChange((v: string) => this.newScore = v)

        Button('提交评价')
          .width('100%')
          .height(45)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .borderRadius(10)
          .onClick(() => this.submit())

        // 提示信息
        if (this.message !== '') {
          Text(this.message)
            .fontColor(Color.Red)
            .fontSize(14)
        }

      }
      .width('90%')
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(12)

      // =====================
      // 📊 图表区域
      // =====================
      Column() {

        ForEach(this.creditList, (item: CreditItem) => {

          Column() {

            // 名称 + 分数
            Row() {
              Text(item.name)
                .width('40%')

              Text(item.score.toString())
                .width('20%')
            }

            // 柱状图
            Row() {
              Column()
                .width(item.score + '%')
                .height(20)
                .backgroundColor('#007DFF')
                .borderRadius(10)
            }
            .width('100%')
            .backgroundColor('#E5EAF3')
            .borderRadius(10)

          }
          .margin({ bottom: 15 })

        })

      }
      .width('90%')
      .margin({ top: 20 })

    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  // =====================
  // 📡 获取数据
  // =====================
  loadData() {
    CreditApi.getList()
      .then((res: ApiResponse) => {
        let result = JSON.parse(res.result) as JsonResult

        if (result.code === 200) {
          this.creditList = result.data
        } else {
          this.message = '加载失败'
        }
      })
      .catch(() => {
        this.message = '网络错误'
      })
  }

  // =====================
  // ⭐ 提交评价
  // =====================
  submit() {

    // 校验
    if (this.newName === '' || this.newScore === '') {
      this.message = '请输入完整信息'
      return
    }

    let score = parseInt(this.newScore)

    if (isNaN(score) || score < 0 || score > 100) {
      this.message = '评分必须是0-100'
      return
    }
    this.message = '提交中...'
    let data: SubmitData = {
      name: this.newName,
      score: score
    }

    CreditApi.add(data)
      .then(() => {

        this.message = '提交成功'

        // 清空输入
        this.newName = ''
        this.newScore = ''

        // 刷新数据
        this.loadData()
      })
      .catch(() => {
        this.message = '提交失败'
      })
  }
}