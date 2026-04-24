import router from '@ohos.router'
import http from '@ohos.net.http'
import { TravelAgency } from '../utils/Agency'
import { getAgencyList } from '../api/agencyAPI'

@Entry
@Component
struct Agency {
  @State agencyList: TravelAgency[] = [];
  @State message: string = "加载中...";
  @State searchText: string = "";

  aboutToAppear(): void {
    this.getAgencyList();
  }

  async getAgencyList(agencyName?: string): Promise<void> {
    const token = AppStorage.get<string>("token") || "";
    if (!token) {
      this.toLogin();
      return;
    }
    try {
      const result = await getAgencyList(token, agencyName);
      if (result.code === 200) {
        this.agencyList = result.data;
        this.message = result.data.length === 0 ? "暂无匹配的旅行社" : "";
      } else {
        this.message = "加载失败：" + result.msg;
      }
    } catch (e) {
      console.error("请求异常：", e);
      this.message = "网络异常";
    }
  }

  // 搜索（复刻景区）
  onSearch(): void {
    this.getAgencyList(this.searchText);
  }

  // 清空（复刻景区）
  clearSearch(): void {
    this.searchText = "";
    this.getAgencyList();
  }

  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  backToHome(): void {
    router.back();
  }

  // 跳转详情（复刻景区，带错误日志）
  goToDetail(id: number): void {
    console.info("点击旅行社ID：", id);
    router.pushUrl({
      url: "pages/AgencyDetailPage",
      params: { id: id }
    }, (err) => {
      if (err) {
        console.error("跳转详情失败：", err);
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏（和景区完全一致）
      Row({ space: 10 }) {
        Button("返回")
          .width(80)
          .height(40)
          .backgroundColor("#007DFF")
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => this.backToHome())

        Text("旅行社管理")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
      .backgroundColor("#F5F7FA")

      // 搜索框区域（和景区完全一致，无布局挤压，按钮可点击）
      Row({ space: 8 }) {
        TextInput({
          placeholder: "请输入旅行社名称搜索",
          text: this.searchText
        })
          .width("70%")
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .padding({ left: 20, right: 20 })
          .fontSize(16)
          .onChange((value: string) => {
            this.searchText = value;
          })

        Button("搜索")
          .width("18%")
          .height(48)
          .backgroundColor("#007DFF")
          .fontColor(Color.White)
          .borderRadius(24)
          .onClick(() => this.onSearch())

        Button("清空")
          .width("10%")
          .height(48)
          .backgroundColor("#EEEEEE")
          .fontColor(Color.Black)
          .borderRadius(24)
          .onClick(() => this.clearSearch())
      }
      .width("95%")
      .margin({ left: 10, top: 10, bottom: 20 })

      // 提示文字
      if (this.message !== "") {
        Text(this.message)
          .fontSize(16)
          .fontColor("#666666")
          .margin({ left: 15, bottom: 5 })
      }

      // 旅行社列表（和景区卡片样式完全一致，点击灵敏）
      Scroll() {
        Column({ space: 12 }) {
          ForEach(
            this.agencyList,
            (item: TravelAgency) => {
              Column(){
                Text(item.agencyName)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 10 })

                Text(`资质：${item.licenseNo}`)
                  .fontSize(15)
                  .fontColor("#555555")
                  .margin({ bottom: 6 })

                Text(`诚信等级：${item.creditLevel}`)
                  .fontSize(15)
                  .fontColor("#555555")
                  .margin({ bottom: 6 })

                Text(`地址：${item.address}`)
                  .fontSize(15)
                  .fontColor("#555555")
                  .margin({ bottom: 6 })

                Text(`电话：${item.contactPhone}`)
                  .fontSize(15)
                  .fontColor("#555555")
              }
              .width("95%")
              .padding(25)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .shadow({ radius: 6, color: "#00000015", offsetY: 3 })
              .onClick(() => {
                this.goToDetail(item.id);
              })
              .margin({ left: 0 })
            },
            (item: TravelAgency) => item.id.toString()
          )
        }
        .width("100%")
        .margin({ left: 10, bottom: 30, top: 0 })
      }
      .layoutWeight(1)
      .width("100%")
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F7FA")
    .padding({ bottom: 15 })
  }
}