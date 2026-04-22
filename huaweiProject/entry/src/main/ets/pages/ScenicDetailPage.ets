import router from '@ohos.router'
import { ScenicDetail, ScenicManager, ScenicEmergency } from '../utils/Scenic'
import web_webview from '@ohos.web.webview';
// 导入封装的景区API
import { getScenicDetail } from '../api/scenicAPI'

@Entry
@Component
struct ScenicDetailPage {
  @State detail: ScenicDetail | null = null;
  private spotId: number = 0;
  @State showMapDialog: boolean = false;
  @State mapUrl: string = "";
  private webviewController: web_webview.WebviewController = new web_webview.WebviewController();

  build() {
    Column() {
      // 顶部导航栏
      Row({ space: 10 }) {
        Button("返回")
          .width(80)
          .height(40)
          .backgroundColor("#007DFF")
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => this.backToScenic())

        Text("景区详情")
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
      .backgroundColor("#F5F7FA")

      // 加载状态/数据展示
      if (this.detail === null) {
        Text("加载中...").margin(10);
      } else {
        Scroll() {
          Column({ space: 10 }) {
            this.Card("基础信息", [
              `名称：${this.detail.baseInfo.spotName ?? ''}`,
              `最大容量：${this.detail.baseInfo.maxCapacity ?? 0} 人`,
              `总车位：${this.detail.baseInfo.totalParking ?? 0} 个`,
              `地址：${this.detail.baseInfo.address ?? ''}`,
              `经纬度：${this.detail.baseInfo.longitude ?? 0}, ${this.detail.baseInfo.latitude ?? 0}`
            ]);

            Button("查看地图")
              .width("92%")
              .height(44)
              .backgroundColor("#007DFF")
              .fontColor(Color.White)
              .borderRadius(8)
              .margin({ bottom: 10 })
              .onClick(() => {
                this.mapUrl = this.detail?.baseInfo?.mapUrl ?? "";
                this.showMapDialog = true;
              });

            this.Card("实时数据", [
              `当前游客数：${this.detail.realTimeData.currentVisitors ?? 0} 人`,
              `剩余车位数：${this.detail.realTimeData.remainingParking ?? 0} 个`,
              `缆车等待时间：${this.detail.realTimeData.cableWaitTime ?? 0} 分钟`
            ]);

            this.Card("管理人员", this.detail.managerList.map((m: ScenicManager): string =>
            `${m.managerName ?? ''} | 工号：${m.workNo ?? ''} | 岗位：${m.post ?? ''} | 电话：${m.phone ?? ''} | 状态：${m.status === 1 ? '在岗' : '离岗'}`
            ));

            this.Card("应急救援", this.detail.emergencyList.map((e: ScenicEmergency): string =>
            `${e.rescuerName ?? ''} | 救援电话：${e.rescuerPhone ?? ''} | 救援车辆：${e.vehicleNo ?? ''}`
            ));
          }
          .padding(10)
        }
        .layoutWeight(1)
      }

      // 地图弹窗
      if (this.showMapDialog) {
        Stack() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(0x00000066)
            .onClick(() => this.showMapDialog = false);

          Column() {
            Row({ space: 10 }) {
              Text("景区地图")
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .flexGrow(1);
              Button("×")
                .width(30)
                .height(30)
                .backgroundColor(Color.Grey)
                .fontColor(Color.White)
                .borderRadius(15)
                .onClick(() => this.showMapDialog = false);
            }
            .width("100%")
            .padding(10);

            Web({ src: this.mapUrl || "https://map.baidu.com", controller: this.webviewController })
              .width("100%")
              .height(500)
              .backgroundColor(Color.White);
          }
          .width("95%")
          .height(500)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: '10%' });
        }
        .width('100%')
        .height('100%')
        .position({ top: 0, left: 0 })
        .zIndex(999);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  aboutToAppear(): void {
    const params: Record<string, number> = router.getParams() as Record<string, number>;
    this.spotId = params['id'] ?? 0;
    this.getDetail();
  }

  backToScenic(): void {
    router.back();
  }

  // 🔥 极简：仅调用封装API
  async getDetail(): Promise<void> {
    const token: string | undefined = AppStorage.get<string>("token");

    if (!token || this.spotId <= 0) {
      this.toLogin();
      return;
    }

    try {
      // 调用封装的详情接口
      const result = await getScenicDetail(token, this.spotId);

      if (result.code === 401) {
        this.toLogin();
        return;
      }

      if (result.code === 200) {
        this.detail = result.data;
      } else {
        console.error("获取详情失败：", result.msg);
      }
    } catch (e) {
      console.error("请求异常：", e.message);
    }
  }

  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  // 通用卡片Builder
  @Builder
  Card(title: string, items: string[]): void {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold);
      ForEach(items, (item: string) => {
        Text(item).fontSize(15);
      });
    }
    .width("92%")
    .backgroundColor("#fff")
    .padding(15)
    .borderRadius(12)
    .shadow({ radius: 2, color: "#00000010" })
  }
}