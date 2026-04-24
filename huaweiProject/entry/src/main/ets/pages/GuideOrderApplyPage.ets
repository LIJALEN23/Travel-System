import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { TravelOrder, AgencyPageParams } from '../utils/Agency';
import { getOrderList } from '../api/agencyAPI';
import { applyOrder } from '../api/guideAPI';

// 导入你统一管理的类型
import { GuideOrderApplyRouteParams, GuideOrderApplyRequest } from '../utils/Guide';

@Entry
@Component
struct GuideOrderApplyPage {
  @State agencyId: number = 0;
  @State agencyName: string = "";
  @State orderList: TravelOrder[] = [];
  @State message: string = "加载中...";

  @State dialogShow: boolean = false;
  @State currentOrderId: number = 0;
  @State applyReason: string = "";

  aboutToAppear(): void {
    // 显式路由类型
    const params = router.getParams() as GuideOrderApplyRouteParams;
    this.agencyId = params.agencyId;
    this.agencyName = params.agencyName;
    this.getOrderList();
  }

  async getOrderList(): Promise<void> {
    try {
      const token = AppStorage.get<string>("token");
      if (!token) {
        promptAction.showToast({ message: "登录已失效" });
        router.replaceUrl({ url: "pages/Login" });
        return;
      }

      // 只加载【待确定】的行程单
      const result = await getOrderList(token, this.agencyId, "待确定", "", "");
      if (result.code === 200) {
        this.orderList = result.data;
        this.message = this.orderList.length ? "" : "暂无可申领行程单";
      } else {
        this.message = result.msg || "加载失败";
      }
    } catch {
      this.message = "网络异常";
    }
  }

  openApplyDialog(item: TravelOrder): void {
    this.currentOrderId = item.id!;
    this.applyReason = "";
    this.dialogShow = true;
  }

  async submitApply(): Promise<void> {
    if (!this.applyReason.trim()) {
      promptAction.showToast({ message: "请输入申请原因" });
      return;
    }

    const token = AppStorage.get<string>("token");
    if (!token) return;

    // 100% 类型安全
    const params = router.getParams() as GuideOrderApplyRouteParams;
    const req: GuideOrderApplyRequest = {
      guideId: params.guideId,
      agencyId: this.agencyId,
      orderId: this.currentOrderId,
      applyReason: this.applyReason.trim()
    };

    const res = await applyOrder(token, req);
    if (res.code === 200) {
      promptAction.showToast({ message: "申领成功" });
      this.dialogShow = false;
      this.getOrderList();
    } else {
      promptAction.showToast({ message: res.msg || "申领失败" });
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        Row({ space: 10 }) {
          Button("返回")
            .width(80)
            .height(40)
            .backgroundColor("#007DFF")
            .fontColor(Color.White)
            .borderRadius(8)
            .onClick(() => router.back())

          Text("行程单申领")
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
        }
        .width("100%")
        .padding(15)
        .backgroundColor("#F5F7FA")

        // 空状态
        if (this.message) {
          Text(this.message)
            .fontSize(16)
            .margin(20)
        }

        // 行程单列表
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.orderList, (item: TravelOrder) => {
              Column({ space: 6 }) {
                Text(item.teamName).fontSize(18).fontWeight(FontWeight.Bold)
                Text(`人数：${item.peopleCount} 人`).fontColor("#555")
                Text(`路线：${item.startAddress} → ${item.endAddress}`).fontColor("#555")
                Text(`出发：${item.startTime}`).fontColor("#555")
                Text(`状态：${item.orderStatus}`)
                  .fontColor("#FF7D00")
                  .fontWeight(FontWeight.Bold)
              }
              .width("95%")
              .padding(20)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .shadow({ radius: 6 })
              .onClick(() => this.openApplyDialog(item))
            })
          }
          .padding(10)
        }
        .layoutWeight(1)
      }
      .width("100%")
      .height("100%")
      .backgroundColor("#F5F7FA")

      // 申请弹窗
      if (this.dialogShow) {
        Column()
          .width("100%")
          .height("100%")
          .backgroundColor("rgba(0,0,0,0.4)")
          .onClick(() => this.dialogShow = false)

        this.ApplyDialog()
      }
    }
    .width("100%")
    .height("100%")
  }

  @Builder
  ApplyDialog() {
    Column({ space: 12 }) {
      Text("申请行程单")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: "请输入申请原因", text: this.applyReason })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => {
          this.applyReason = v;
        })

      Row({ space: 20 }) {
        Button("取消")
          .width(100)
          .height(40)
          .backgroundColor("#909399")
          .onClick(() => {
            this.dialogShow = false;
          })

        Button("确认申领")
          .width(100)
          .height(40)
          .backgroundColor("#007DFF")
          .onClick(() => {
            this.submitApply();
          })
      }
    }
    .width("90%")
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8 })
  }
}