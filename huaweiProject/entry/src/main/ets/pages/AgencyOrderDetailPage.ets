import router from '@ohos.router';
import http from '@ohos.net.http';
import { OrderDetailVO, OrderDetailParams } from '../utils/Agency';
import { getOrderDetail } from '../api/agencyAPI'
import Prompt from '@ohos.prompt';

@Entry
@Component
struct AgencyOrderDetailPage {
  @State orderId: number = 0;
  @State detail: OrderDetailVO | null = null;
  @State message: string = "加载中...";

  aboutToAppear(): void {
    const params: OrderDetailParams = router.getParams() as OrderDetailParams;
    this.orderId = params.orderId;
    this.getOrderDetail();
  }

  // 获取行程单详情
  async getOrderDetail(): Promise<void> {
    try {
      const token = AppStorage.get<string>("token");
      if (!token) { Prompt.showToast({ message: "登录已失效" }); router.replaceUrl({ url: "pages/Login" }); return; }
      const result = await getOrderDetail(token, this.orderId);
      if (result.code === 200) { this.detail = result.data; this.message = ""; }
      else { this.message = result.msg || "获取详情失败"; }
    } catch (err) { this.message = "网络请求失败"; console.error(err); }
  }
  build() {
    Column() {
      // 顶部导航
      Row({ space: 10 }) {
        Button("返回")
          .width(80).height(40)
          .backgroundColor("#007DFF").fontColor(Color.White).borderRadius(8)
          .onClick(() => router.back())

        Text("行程单详情")
          .fontSize(22).fontWeight(FontWeight.Bold)
          .flexGrow(1).textAlign(TextAlign.Center)
      }
      .width("100%").padding(15).backgroundColor("#F5F7FA")

      // 加载/错误状态
      if (this.message) {
        Text(this.message).fontSize(16).margin(50)
      }

      // 详情展示
      if (this.detail) {
        Scroll() {
          Column({ space: 15 }) {
            // 行程单信息
            this.CardView("行程单信息", [
              `团队名称：${this.detail.order.teamName}`,
              `出行人数：${this.detail.order.peopleCount} 人`,
              `出发地：${this.detail.order.startAddress}`,
              `目的地：${this.detail.order.endAddress}`,
              `出发时间：${this.detail.order.startTime}`,
              `订单状态：${this.detail.order.orderStatus}`,
              `创建时间：${this.detail.order.createTime}`
            ])

            // 司机信息
            this.CardView("司机信息", [
              `司机姓名：${this.detail.driver.driverName}`,
              `联系电话：${this.detail.driver.phone}`,
              `驾照类型：${this.detail.driver.licenseType}`,
              `创建时间：${this.detail.driver.createTime}`
            ])

            // 车辆信息
            this.CardView("车辆信息", [
              `车牌号码：${this.detail.vehicle.plateNo}`,
              `车辆类型：${this.detail.vehicle.vehicleType}`,
              `核定座位：${this.detail.vehicle.seatCount} 座`,
              `车辆状态：${this.detail.vehicle.vehicleStatus}`,
              `创建时间：${this.detail.vehicle.createTime}`
            ])
          }
          .padding(15)
        }
        .layoutWeight(1)
      }
    }
    .width("100%").height("100%").backgroundColor("#F5F7FA")
  }

  // 通用卡片组件
  @Builder
  CardView(title: string, content: string[]) {
    Column({ space: 8 }) {
      Text(title).fontSize(18).fontWeight(FontWeight.Bold).width("100%")
      Column({ space: 6 }) {
        ForEach(content, (item: string) => {
          Text(item).fontSize(14).fontColor("#333").width("100%")
        })
      }
      .width("100%").padding(15)
    }
    .width("100%").padding(20).backgroundColor(Color.White).borderRadius(16)
    .shadow({ radius: 6, color: "#00000015" })
  }
}