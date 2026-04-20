import router from '@ohos.router'
import http from '@ohos.net.http'
import {
  Result,
  ScenicDetail,
  ScenicManager,
  ScenicEmergency,
  ScenicSpot,
  ScenicRealTimeData
} from '../utils/Scenic'
import web_webview from '@ohos.web.webview';

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
      // 顶部导航栏（返回按钮 + 标题）
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
            // 基础信息卡片（匹配ScenicSpot类型）
            this.Card("基础信息", [
              `名称：${this.detail.baseInfo.spotName ?? ''}`,
              `最大容量：${this.detail.baseInfo.maxCapacity ?? 0} 人`,
              `总车位：${this.detail.baseInfo.totalParking ?? 0} 个`,
              `地址：${this.detail.baseInfo.address ?? ''}`,
              `经纬度：${this.detail.baseInfo.longitude ?? 0}, ${this.detail.baseInfo.latitude ?? 0}`
            ]);

            // 查看地图按钮（匹配mapUrl字段）
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

            // 实时数据卡片（匹配ScenicRealTimeData类型）
            this.Card("实时数据", [
              `当前游客数：${this.detail.realTimeData.currentVisitors ?? 0} 人`,
              `剩余车位数：${this.detail.realTimeData.remainingParking ?? 0} 个`,
              `缆车等待时间：${this.detail.realTimeData.cableWaitTime ?? 0} 分钟`
            ]);

            // 管理人员卡片（匹配ScenicManager类型）
            this.Card("管理人员", this.detail.managerList.map((m: ScenicManager): string =>
            `${m.managerName ?? ''} | 工号：${m.workNo ?? ''} | 岗位：${m.post ?? ''} | 电话：${m.phone ?? ''} | 状态：${m.status === 1 ? '在岗' : '离岗'}`
            ));

            // 应急救援卡片（匹配ScenicEmergency类型）
            this.Card("应急救援", this.detail.emergencyList.map((e: ScenicEmergency): string =>
            `${e.rescuerName ?? ''} | 救援电话：${e.rescuerPhone ?? ''} | 救援车辆：${e.vehicleNo ?? ''}`
            ));
          }
          .padding(10)
        }
        .layoutWeight(1)
      }

      // 地图弹窗（兼容低版本ArkTS）
      if (this.showMapDialog) {
        Stack() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(0x00000066)
            .onClick(() => this.showMapDialog = false);

          // 弹窗内容（margin居中）
          Column() {
            // 弹窗标题栏
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

            // WebView加载百度地图URL
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

  // 页面初始化
  aboutToAppear(): void {
    const params: Record<string, number> = router.getParams() as Record<string, number>;
    this.spotId = params['id'] ?? 0;
    this.getDetail();
  }

  // 返回景区列表页
  backToScenic(): void {
    router.back();

  }

  // 获取景区详情数据
  async getDetail(): Promise<void> {
    const token: string | undefined = AppStorage.get<string>("token");

    // 无token/无景区ID 跳登录
    if (!token || this.spotId <= 0) {
      this.toLogin();
      return;
    }

    const httpRequest = http.createHttp();
    try {
      const res: http.HttpResponse = await httpRequest.request(
        `http://192.168.52.143:8080/spot/detail?id=${this.spotId}`,
        {
          method: http.RequestMethod.GET,
          header: {
            "Authorization": token,
            "Content-Type": "application/json"
          }
        }
      );

      // 解析返回结果（匹配Result<ScenicDetail>类型）
      const result: Result<ScenicDetail> = JSON.parse(res.result as string);

      // 401未授权 跳登录
      if (result.code === 401) {
        this.toLogin();
        return;
      }

      // 200成功 赋值数据
      if (result.code === 200) {
        this.detail = result.data;
      } else {
        console.error("获取详情失败：", result.msg);
      }
    } catch (e) {
      console.error("请求异常：", e.message);
    }
  }

  // 跳登录页
  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  // 通用卡片Builder（类型严格匹配）
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