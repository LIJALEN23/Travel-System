import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

import { AgencyPageParams, GuideJobApply, ApiResult, GuideDetailVO } from '../utils/Guide';
import { getJobApplyList, auditJob, getGuideInfo } from '../api/guideAPI';

@Entry
@Component
struct AgencyJobAuditPage {
  @State agencyId: number = 0;
  @State agencyName: string = "";
  @State applyList: GuideJobApply[] = [];
  @State loading: boolean = true;

  aboutToAppear(): void {
    const params: AgencyPageParams = router.getParams() as AgencyPageParams;
    if (params) {
      this.agencyId = params.agencyId;
      this.agencyName = params.agencyName;
      void this.loadApplyListData();
    }
  }

  // 加载数据 + 手动逐个赋值（彻底弃用...扩展运算符）
  private async loadApplyListData(): Promise<void> {
    const token: string | undefined = AppStorage.get<string>("token");
    if (!token) {
      router.replaceUrl({ url: "pages/Login" });
      return;
    }
    try {
      const res: ApiResult<GuideJobApply[]> = await getJobApplyList(token, this.agencyId);
      if (res.code === 200 && res.data) {
        const tempList: GuideJobApply[] = [];

        // 手动构造对象，完全规避 spread 语法
        for (let i = 0; i < res.data.length; i++) {
          const origin = res.data[i];
          const newItem: GuideJobApply = {
            id: origin.id,
            guideId: origin.guideId,
            agencyId: origin.agencyId,
            applyStatus: origin.applyStatus,
            applyRemark: origin.applyRemark,
            createTime: origin.createTime,
            updateTime: origin.updateTime,
            guideName: "未知导游"
          };

          // 单独请求导游姓名
          try {
            const guideRes: ApiResult<GuideDetailVO> = await getGuideInfo(token, origin.guideId);
            if (guideRes.code === 200 && guideRes.data?.guideInfo?.name) {
              newItem.guideName = guideRes.data.guideInfo.name;
            }
          } catch {}

          tempList.push(newItem);
        }

        this.applyList = tempList;
      }
    } catch {
      promptAction.showToast({ message: "申请列表加载失败" });
    } finally {
      this.loading = false;
    }
  }

  // 审核操作
  private async doAuditOperate(item: GuideJobApply, passStatus: number): Promise<void> {
    const token: string | undefined = AppStorage.get<string>("token");
    if (!token) return;

    const reqData: GuideJobApply = {
      id: item.id,
      guideId: item.guideId,
      agencyId: item.agencyId,
      applyStatus: passStatus,
      applyRemark: passStatus === 1 ? "审核通过，同意录用" : "审核未通过，不予录用"
    };

    try {
      const res: ApiResult<null> = await auditJob(token, reqData);
      if (res.code === 200) {
        promptAction.showToast({
          message: passStatus === 1 ? "录用成功" : "驳回成功"
        });
        void this.loadApplyListData();
      } else {
        promptAction.showToast({ message: res.msg || "审核操作失败" });
      }
    } catch {
      promptAction.showToast({ message: "网络异常，请重试" });
    }
  }

  // 状态文本
  private getStatusText(status: number): string {
    switch (status) {
      case 0: return "待审核";
      case 1: return "已录用";
      case 2: return "已驳回";
      default: return "未知状态";
    }
  }

  // 状态颜色
  private getStatusColor(status: number): ResourceColor {
    switch (status) {
      case 0: return "#FF9500";
      case 1: return "#00B42A";
      case 2: return "#F53F3F";
      default: return "#666666";
    }
  }

  // ✅ build唯一根容器、纯UI、无任何非法逻辑
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button("返回")
          .width(70)
          .height(36)
          .backgroundColor("#007DFF")
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => router.back())

        Text(`${this.agencyName} - 导游求职审核`)
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(70)
      }
      .width("100%")
      .padding(15)
      .backgroundColor(Color.White)

      // 加载提示
      if (this.loading) {
        Text("数据加载中...")
          .margin({ top: 40 })
          .fontSize(16)
          .fontColor("#666666")
      }

      // 空数据
      else if (this.applyList.length === 0) {
        Text("暂无导游求职申请")
          .margin({ top: 40 })
          .fontSize(16)
          .fontColor("#999999")
      }

      // 申请列表渲染
      else {
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.applyList, (item: GuideJobApply) => {
              Column({ space: 8 }) {
                Text(`导游姓名：${item.guideName ?? "未知导游"}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)

                Text(`申请备注：${item.applyRemark}`)
                  .fontSize(14)

                Row() {
                  Text("当前状态：")
                  Text(this.getStatusText(item.applyStatus))
                    .fontColor(this.getStatusColor(item.applyStatus))
                    .fontWeight(FontWeight.Bold)
                }

                Text(`提交时间：${item.createTime ?? ""}`)
                  .fontSize(13)
                  .fontColor("#999999")

                // 审核按钮
                if (item.applyStatus === 0) {
                  Row({ space: 15 }) {
                    Button("录用通过")
                      .flexGrow(1)
                      .height(38)
                      .backgroundColor("#00B42A")
                      .onClick(() => void this.doAuditOperate(item, 1))

                    Button("驳回申请")
                      .flexGrow(1)
                      .height(38)
                      .backgroundColor("#F53F3F")
                      .onClick(() => void this.doAuditOperate(item, 2))
                  }
                  .margin({ top: 10 })
                }
              }
              .width("95%")
              .padding(18)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .shadow({ radius: 6, color: "#00000015", offsetY: 3 })
            })
          }
          .padding(10)
        }
        .layoutWeight(1)
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F7FA")
  }
}