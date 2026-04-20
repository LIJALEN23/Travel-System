import router from '@ohos.router'
import http from '@ohos.net.http'
import { Result, ScenicSpot } from '../utils/Scenic'

@Entry
@Component
struct Scenic {
  @State spotList: ScenicSpot[] = [];
  @State message: string = "加载中...";
  @State searchText: string = "";

  aboutToAppear(): void {
    this.getSpotList();
  }

  async getSpotList(spotName?: string): Promise<void> {
    const token = AppStorage.get<string>("token") || "";
    if (!token) {
      this.toLogin();
      return;
    }

    const httpRequest = http.createHttp();
    try {
      let url = "http://192.168.52.143:8080/spot/list";
      if (spotName && spotName.trim()) {
        url += `?spotName=${encodeURIComponent(spotName.trim())}`;
      }

      const res = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json"
          }
        }
      );

      const jsonString = res.result as string;
      console.info("景区列表返回数据：", jsonString);
      const result: Result<ScenicSpot[]> = JSON.parse(jsonString);

      if (result.code === 200) {
        this.spotList = result.data;
        this.message = result.data.length === 0 ? "暂无匹配的景区" : "";
      } else {
        this.message = "加载失败：" + result.msg;
      }
    } catch (e) {
      console.error("请求异常：", e);
      this.message = "网络异常";
    }
  }

  onSearch(): void {
    this.getSpotList(this.searchText);
  }

  clearSearch(): void {
    this.searchText = "";
    this.getSpotList();
  }

  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  backToHome(): void {
    router.back();
    // 若back无效，替换为：router.replaceUrl({ url: "pages/Home" });
  }

  goToDetail(id: number): void {
    console.info("点击景区ID：", id);
    router.pushUrl({
      url: "pages/ScenicDetailPage", // 确认路径正确
      params: { id: id }
    }, (err) => {
      if (err) {
        console.error("跳转详情失败：", err);
        // 调试：打印完整路径错误
        console.error("详情页路径应为：pages/ScenicDetailPage");
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Row({ space: 10 }) {
        // 返回按钮
        Button("返回")
          .width(80)
          .height(40) // 调整高度更协调
          .backgroundColor("#007DFF") // 蓝色背景（替代透明）
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White) // 白色文字
          .borderRadius(8) // 圆角
          .onClick(() => this.backToHome())

        Text("旅游景区管理")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 15, bottom: 15 }) // 增加上下padding
      .backgroundColor("#F5F7FA")

      // 搜索框区域（优化间距+对齐）
      Row({ space: 8 }) { // 缩小按钮间距更紧凑
        TextInput({
          placeholder: "请输入景区名称搜索",
          text: this.searchText
        })
          .width("70%") // 微调宽度，给按钮更多空间
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
      .width("95%") // 加宽搜索区域，更贴合屏幕
      .margin({ left: 10, top: 10, bottom: 20 }) // 减少左间距，增加下间距

      // 提示文字（优化样式）
      if (this.message !== "") {
        Text(this.message)
          .fontSize(16)
          .fontColor("#666666")
          .margin({ left: 15, bottom: 5 })
      }

      // 景区列表（优化间距+卡片样式）
      Scroll() {
        Column({ space: 12 }) { // 缩小卡片间距更紧凑
          ForEach(
            this.spotList,
            (item: ScenicSpot) => {
              Column(){
                Text(item.spotName)
                  .fontSize(22) // 加大标题字号
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 10 })

                Text(`地址：${item.address}`)
                  .fontSize(15)
                  .fontColor("#555555")
                  .margin({ bottom: 6 })

                Text(`最大容量：${item.maxCapacity} 人 | 总车位：${item.totalParking} 个`)
                  .fontSize(15)
                  .fontColor("#555555")
              }
              .width("95%") // 加宽卡片，更贴合屏幕
              .padding(25) // 增加内边距更大气
              .backgroundColor(Color.White)
              .borderRadius(16) // 加大圆角更美观
              .shadow({ radius: 6, color: "#00000015", offsetY: 3 }) // 加深阴影
              .onClick(() => {
                this.goToDetail(item.id);
              })
              .margin({ left: 0 }) // 确保卡片完全靠左
            },
            (item: ScenicSpot) => item.id.toString()
          )
        }
        .width("100%")
        .margin({ left: 10, bottom: 30, top: 0 }) // 减少左间距，和搜索框对齐
      }
      .layoutWeight(1)
      .width("100%")
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F7FA")
    .padding({ bottom: 15 }) // 底部加padding，避免卡片贴底
  }
}