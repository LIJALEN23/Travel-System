import router from '@ohos.router'
import http from '@ohos.net.http'
import web_webview from '@ohos.web.webview';
import {
  Result,
  HotelDetail,
  HotelBase,
  HotelRealTimeData,
  HotelManager,
  HotelEmergency
} from '../utils/Hotel';

import env from '../utils/env';
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
            // 基础信息卡片
            this.Card("基础信息", [
              `名称：${this.detail.baseInfo.hotelName}`,
              `星级：${this.detail.baseInfo.starLevel} 星`,
              `最大容量：${this.detail.baseInfo.maxCapacity} 人`,
              `总车位：${this.detail.baseInfo.totalParking ?? 0} 个`,
              `地址：${this.detail.baseInfo.address}`,
              `经纬度：${this.detail.baseInfo.longitude}, ${this.detail.baseInfo.latitude}`
            ]);

            // 查看地图按钮（mapUrl为null时禁用）
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

            // 实时数据卡片
            this.Card("实时数据", [
              `当前游客数：${this.detail.realTimeData.currentVisitors} 人`,
              `剩余车位数：${this.detail.realTimeData.remainingParking ?? 0} 个`,
              `入住率：${this.detail.realTimeData.occupancyRate} %`
            ]);

            // 管理人员卡片
            this.Card("管理人员", this.detail.managerList.map((m: HotelManager): string =>
            `${m.managerName} | 工号：${m.workNo} | 岗位：${m.post} | 电话：${m.phone} | 状态：${m.status === 1 ? '在岗' : '离岗'}`
            ));

            // 应急救援卡片
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
          // 遮罩层（点击关闭）
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(0x00000066)
            .onClick(() => this.showMapDialog = false);

          // 弹窗内容
          Column() {
            // 弹窗标题栏
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

            // WebView加载地图（默认百度地图）
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

  // 页面初始化：获取路由参数并加载详情
  aboutToAppear(): void {
    const params: Record<string, number> = router.getParams() as Record<string, number>;
    this.hotelId = params['id'] ?? 0;
    this.getDetail();
  }

  // 返回酒店列表页
  backToHotel(): void {
    router.back();
  }

  // 获取酒店详情数据（核心简化：直接解析为HotelDetail类型）
  async getDetail(): Promise<void> {
    const token: string | undefined = AppStorage.get<string>("token");

    // 无token/无酒店ID 跳登录页
    if (!token || this.hotelId <= 0) {
      this.toLogin();
      return;
    }

    const httpRequest = http.createHttp();
    try {
      // 发送GET请求
      const res: http.HttpResponse = await httpRequest.request(
        `${env.BASE_API}/hotel/detail?id=${this.hotelId}`,
        {
          method: http.RequestMethod.GET,
          header: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json",
            "Accept-Encoding": "identity" // 禁用压缩，避免解析问题
          },
          expectDataType: http.HttpDataType.STRING // 强制返回字符串
        }
      );

      // 校验响应码
      if (res.responseCode !== 200) {
        throw new Error(`请求失败，响应码：${res.responseCode}`);
      }

      // 解析响应数据（无any，严格类型）
      let responseStr: string = "";
      if (typeof res.result === 'string') {
        responseStr = res.result;
      } else if (res.result instanceof ArrayBuffer) {
        responseStr = this.arrayBufferToString(res.result);
      }

      // 解析为Result<HotelDetail>类型
      const result: Result<HotelDetail> = JSON.parse(responseStr) as Result<HotelDetail>;

      // 业务逻辑处理
      if (result.code === 200 && result.data) {
        this.detail = result.data; // 直接赋值，无需转换
      } else if (result.code === 401) {
        this.toLogin(); // 401未授权跳登录
      } else {
        console.error("获取详情失败：", result.msg);
      }
    } catch (e) {
      console.error("请求详情异常：", (e as Error).message);
    } finally {
      httpRequest.destroy(); // 销毁请求实例
    }
  }

  // 跳转登录页
  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  // 通用卡片Builder（抽离复用）
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

  // ArrayBuffer转字符串（兼容处理）
  private arrayBufferToString(buffer: ArrayBuffer): string {
    if (!buffer) return "{}";
    const uint8Array: Uint8Array = new Uint8Array(buffer);
    let str: string = '';
    for (let i: number = 0; i < uint8Array.length; i++) {
      str += String.fromCharCode(uint8Array[i]);
    }
    return str.trim() || "{}";
  }
}