import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import type { GuideOrderApply, AgencyPageParams } from '../utils/Guide';
import { getOrderApplyList, auditOrder, getGuideInfo } from '../api/guideAPI';
import { getOrderDetail } from '../api/agencyAPI';

@Entry
@Component
struct AgencyOrderApplyAuditPage {
  @State agencyId: number = 0;
  @State agencyName: string = "";
  @State applyList: GuideOrderApply[] = [];
  @State loading: boolean = true;
  @State message: string = "加载中...";

  aboutToAppear(): void {
    const params: AgencyPageParams = router.getParams() as AgencyPageParams;
    if (params) {
      this.agencyId = params.agencyId;
      this.agencyName = params.agencyName;
      void this.loadApplyList();
    }
  }

  // 加载列表 + 匹配姓名
  private async loadApplyList(): Promise<void> {
    this.loading = true;
    this.message = "";
    const token = AppStorage.get<string>("token");
    if (!token) {
      promptAction.showToast({ message: "登录已失效" });
      router.replaceUrl({ url: "pages/Login" });
      return;
    }

    try {
      const res = await getOrderApplyList(token, this.agencyId);
      if (res.code === 200 && res.data) {
        for (const item of res.data) {
          // 填充导游姓名
          try {
            const guideRes = await getGuideInfo(token, item.guideId);
            if (guideRes.code === 200 && guideRes.data?.guideInfo?.name) {
              item.guideName = guideRes.data.guideInfo.name;
            } else {
              item.guideName = "未知导游";
            }
          } catch {
            item.guideName = "未知导游";
          }

          // 填充行程名称
          try {
            const orderRes = await getOrderDetail(token, item.orderId);
            if (orderRes.code === 200 && orderRes.data?.order?.teamName) {
              item.orderTeamName = orderRes.data.order.teamName;
            } else {
              item.orderTeamName = "未知行程";
            }
          } catch {
            item.orderTeamName = "未知行程";
          }
        }

        this.applyList = res.data;
        if (this.applyList.length === 0) {
          this.message = "暂无申领记录";
        }
      } else {
        this.message = res.msg || "获取列表失败";
      }
    } catch {
      this.message = "网络请求失败";
    } finally {
      this.loading = false;
    }
  }

  // 审核操作
  private async doAudit(item: GuideOrderApply, status: number): Promise<void> {
    const token = AppStorage.get<string>("token");
    if (!token || !item.id) return;

    const reason = status === 1
      ? "审核通过，同意分配行程单"
      : "当前导游资质不符，审核驳回";

    try {
      const res = await auditOrder(token, {
        id: item.id,
        applyStatus: status,
        applyReason: reason
      });
      if (res.code === 200) {
        promptAction.showToast({ message: status === 1 ? "✅ 审核通过" : "❌ 已驳回" });
        void this.loadApplyList();
      } else {
        promptAction.showToast({ message: res.msg || "审核失败" });
      }
    } catch {
      promptAction.showToast({ message: "操作异常" });
    }
  }

  // 状态文本
  private getStatusText(status?: number): string {
    switch (status) {
      case 0: return "待审核";
      case 1: return "已通过";
      case 2: return "已驳回";
      default: return "未知";
    }
  }

  // 状态颜色
  private getStatusColor(status?: number): ResourceColor {
    switch (status) {
      case 0: return "#FF9500";
      case 1: return "#00B42A";
      case 2: return "#F53F3F";
      default: return "#666666";
    }
  }

  build() {
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

        Text("行程单申领审核")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding(15)
      .backgroundColor("#F5F7FA")

      // 加载/空状态
      if (this.loading) {
        Text("数据加载中，请稍候...")
          .fontSize(16)
          .margin({ top: 50 })
          .fontColor("#666666")
      } else if (this.message) {
        Text(this.message)
          .fontSize(16)
          .margin({ top: 50 })
          .fontColor("#999999")
      }

      // 列表渲染
      else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.applyList, (item: GuideOrderApply) => {
              // 容器先写 {} 再链式加样式
              Column({ space: 10 }) {
                Text(`导游姓名：${item.guideName ?? "未知导游"}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)

                Text(`行程团队：${item.orderTeamName ?? "未知行程"}`)
                  .fontSize(14)
                  .fontColor("#444444")

                Text(`申请说明：${item.applyReason}`)
                  .fontSize(14)
                  .fontColor("#555555")

                Row() {
                  Text("当前状态：")
                  Text(this.getStatusText(item.applyStatus))
                    .fontColor(this.getStatusColor(item.applyStatus))
                    .fontWeight(FontWeight.Bold)
                    .fontSize(15)
                }

                Text(`申请时间：${item.createTime ?? ""}`)
                  .fontSize(12)
                  .fontColor("#999999")

                // 审核按钮
                if (item.applyStatus === 0) {
                  Row({ space: 15 }) {
                    Button("✅ 通过")
                      .flexGrow(1)
                      .height(40)
                      .backgroundColor("#00B42A")
                      .fontColor(Color.White)
                      .borderRadius(8)
                      .onClick(() => void this.doAudit(item, 1))

                    Button("❌ 驳回")
                      .flexGrow(1)
                      .height(40)
                      .backgroundColor("#F53F3F")
                      .fontColor(Color.White)
                      .borderRadius(8)
                      .onClick(() => void this.doAudit(item, 2))
                  }
                  .margin({ top: 8 })
                }
              }
              // 👉 所有宽高、边距、背景、阴影，全部放到大括号外面！
              .width("95%")
              .padding(18)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .shadow({ radius: 6, color: "#00000015", offsetY: 3 })
            })
          }
          .padding(12)
        }
        .layoutWeight(1)
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F7FA")
  }
}