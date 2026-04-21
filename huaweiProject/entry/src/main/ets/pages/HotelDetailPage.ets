import router from '@ohos.router'
import web_webview from '@ohos.web.webview';
import { HotelDetail, HotelManager, HotelEmergency } from '../utils/Hotel';
// 导入封装的酒店API
import { getHotelDetail } from '../api/hotelAPI'

@Entry
@Component
struct HotelDetailPage {
  @State detail: HotelDetail | null = null;
  private hotelId: number = 0;
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
          .onClick(() => this.backToHotel())

        Text("酒店详情")
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
              `名称：${this.detail.baseInfo.hotelName}`,
              `星级：${this.detail.baseInfo.starLevel} 星`,
              `最大容量：${this.detail.baseInfo.maxCapacity} 人`,
              `总车位：${this.detail.baseInfo.totalParking ?? 0} 个`,
              `地址：${this.detail.baseInfo.address}`,
              `经纬度：${this.detail.baseInfo.longitude}, ${this.detail.baseInfo.latitude}`
            ]);

            Button("查看地图")
              .width("92%")
              .height(44)
              .backgroundColor(this.detail.baseInfo.mapUrl ? "#007DFF" : "#CCCCCC")
              .fontColor(Color.White)
              .borderRadius(8)
              .margin({ bottom: 10 })
              .enabled(!!this.detail.baseInfo.mapUrl)
              .onClick(() => {
                if(this.detail){
                  this.mapUrl = this.detail.baseInfo.mapUrl || "";
                  this.showMapDialog = true;
                }
              });

            this.Card("实时数据", [
              `当前游客数：${this.detail.realTimeData.currentVisitors} 人`,
              `剩余车位数：${this.detail.realTimeData.remainingParking ?? 0} 个`,
              `入住率：${this.detail.realTimeData.occupancyRate} %`
            ]);

            this.Card("管理人员", this.detail.managerList.map((m: HotelManager): string =>
            `${m.managerName} | 工号：${m.workNo} | 岗位：${m.post} | 电话：${m.phone} | 状态：${m.status === 1 ? '在岗' : '离岗'}`
            ));

            this.Card("应急救援", this.detail.emergencyList.map((e: HotelEmergency): string =>
            `${e.rescuerName} | 救援电话：${e.rescuerPhone} | 救援车辆：${e.vehicleNo}`
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
              Text("酒店地图")
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

            Web({
              src: this.mapUrl || "https://map.baidu.com",
              controller: this.webviewController
            })
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
    this.hotelId = params['id'] ?? 0;
    this.getDetail();
  }

  backToHotel(): void {
    router.back();
  }

  // 🔥 极简：仅调用封装API
  async getDetail(): Promise<void> {
    const token: string | undefined = AppStorage.get<string>("token");
    if (!token || this.hotelId <= 0) {
      this.toLogin();
      return;
    }

    try {
      const result = await getHotelDetail(token, this.hotelId);
      if (result.code === 401) {
        this.toLogin();
        return;
      }
      if (result.code === 200 && result.data) {
        this.detail = result.data;
      } else {
        console.error("获取详情失败：", result.msg);
      }
    } catch (e) {
      console.error("请求详情异常：", (e as Error).message);
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