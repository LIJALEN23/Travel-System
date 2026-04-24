import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ApiResult, GuideDetailVO, GuideJobApply } from '../utils/Guide';
import { getGuideInfo, applyJob } from '../api/guideAPI';
import { TravelAgency } from '../utils/Agency';
import { getAgencyBaseInfo, getAgencyList } from '../api/agencyAPI';

interface GuideDetailRouteParams {
  id: number
}

@Entry
@Component
struct GuideDetailPage {
  private guideId: number = 0;
  @State detailData: GuideDetailVO | null = null;
  @State agencyInfo: TravelAgency | null = null;
  @State agencyList: TravelAgency[] = [];
  @State loading: boolean = true;
  @State message: string = "加载中...";
  @State sheetOpen: boolean = false;
  @State selectedAgencyId: number = 0;

  aboutToAppear(): void {
    const params: GuideDetailRouteParams = router.getParams() as GuideDetailRouteParams;
    this.guideId = params?.id ?? 0;

    if (this.guideId <= 0) {
      this.message = "页面参数错误";
      this.loading = false;
      return;
    }
    void this.loadPageData();
  }

  async loadPageData(): Promise<void> {
    const token: string | undefined = AppStorage.get<string>("token");
    if (!token) {
      promptAction.showToast({ message: "登录已失效，请重新登录" });
      this.goLogin();
      return;
    }

    try {
      const guideRes: ApiResult<GuideDetailVO> = await getGuideInfo(token, this.guideId);
      if (guideRes.code === 200 && guideRes.data) {
        this.detailData = guideRes.data;
        const agencyId = this.detailData.guideInfo.agencyId;
        if (agencyId && agencyId > 0) {
          this.agencyInfo = await getAgencyBaseInfo(token, agencyId);
        }
      }

      const listRes: ApiResult<TravelAgency[]> = await getAgencyList(token);
      if (listRes.code === 200 && listRes.data) {
        this.agencyList = listRes.data;
      }

      this.message = "";
    } catch {
      this.message = "网络加载异常";
    } finally {
      this.loading = false;
    }
  }

  async submitApply(): Promise<void> {
    if (this.selectedAgencyId <= 0) {
      promptAction.showToast({ message: "请先选择旅行社" });
      return;
    }
    const token = AppStorage.get<string>("token");
    if (!token) return;

    const reqBody: GuideJobApply = {
      guideId: this.guideId,
      agencyId: this.selectedAgencyId,
      applyStatus: 0,
      applyRemark: "申请加入旅行社"
    };

    const res: ApiResult<null> = await applyJob(token, reqBody);
    promptAction.showToast({
      message: res.code === 200 ? "求职申请投递成功！" : res.msg || "投递失败"
    });

    if (res.code === 200) {
      this.sheetOpen = false;
      this.selectedAgencyId = 0;
      void this.loadPageData();
    }
  }

  // ====================== ✅ 新增：跳转申领行程单 ======================
  goToApplyOrderPage() {
    router.pushUrl({
      url: "pages/GuideOrderApplyPage",
      params: {
        guideId: this.guideId,
        agencyId: this.agencyInfo!.id!,
        agencyName: this.agencyInfo!.agencyName
      }
    });
  }

  goBack(): void { router.back(); }
  goLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Button("返回")
          .width(80).height(40).backgroundColor(Color.White).fontColor("#007DFF").borderRadius(8)
          .onClick(() => { this.goBack(); })

        Text("导游详情").fontSize(24).fontWeight(FontWeight.Bold).fontColor(Color.White).layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(80)
      }
      .width("100%").padding(15).backgroundColor("#007DFF")

      if (this.loading || this.message) {
        Text(this.message).fontSize(18).fontColor("#666").margin({ top: 50 })
      }

      if (this.detailData) {
        Scroll() {
          Column({ space: 15 }) {
            this.buildBaseInfoCard()
            this.buildCreditCard()
            this.buildAgencyCard()

            // ====================== ✅ 新增：行程单申领功能区 ======================
            if (this.agencyInfo) {
              this.buildOrderApplyCard()
            }
          }
          .padding(10)
        }
        .layoutWeight(1)
      }
    }
    .width("100%").height("100%").backgroundColor("#F5F7FA")
    .bindSheet($$this.sheetOpen, this.agencySelectSheet(), { height: "60%", dragBar: true })
  }

  @Builder buildBaseInfoCard() {
    Column({ space: 10 }) {
      Text("基础信息").fontSize(20).fontWeight(FontWeight.Bold)
      Text(`姓名：${this.detailData!.guideInfo.name}`)
      Text(`性别：${this.detailData!.guideInfo.gender}`)
      Text(`年龄：${this.detailData!.guideInfo.age} 岁`)
      Text(`电话：${this.detailData!.guideInfo.phone}`)
      Text(`身份证号：${this.detailData!.guideInfo.idCard}`)
      Text(`导游等级：${this.detailData!.guideInfo.guideLevel}`)
      Text(`在职状态：${this.detailData!.guideInfo.workStatus ? "在职" : "离职"}`)
        .fontColor(this.detailData!.guideInfo.workStatus ? "#00B42A" : "#F53F3F")
    }
    .width("95%").padding(20).backgroundColor(Color.White).borderRadius(16).shadow({ radius: 6 })
  }

  @Builder buildCreditCard() {
    Column({ space: 10 }) {
      Text("诚信档案").fontSize(20).fontWeight(FontWeight.Bold)
      Text(`信用评分：${this.detailData!.creditInfo.creditScore} 分`).fontColor("#007DFF")
      Text(`总投诉记录：${this.detailData!.creditInfo.totalComplaint}`)
      Text(`不良投诉：${this.detailData!.creditInfo.badComplaint}`)
      Text(`信用等级：${this.detailData!.creditInfo.creditLevel || "暂无评级"}`)
    }
    .width("95%").padding(20).backgroundColor(Color.White).borderRadius(16).shadow({ radius: 6 })
  }

  @Builder buildAgencyCard() {
    Column({ space: 10 }) {
      Text("所属旅行社").fontSize(20).fontWeight(FontWeight.Bold)

      if (this.agencyInfo) {
        Text(`旅行社名称：${this.agencyInfo.agencyName}`)
        Text(`许可证号：${this.agencyInfo.licenseNo}`)
        Text(`地址：${this.agencyInfo.address}`)
      } else {
        Text("未入职任何旅行社").fontColor("#FF6600")
        Button("提交求职申请")
          .width(220).height(42).backgroundColor("#007DFF")
          .onClick(() => { this.selectedAgencyId = 0; this.sheetOpen = true; })
      }
    }
    .width("95%").padding(20).backgroundColor(Color.White).borderRadius(16).shadow({ radius: 6 })
  }

  // ====================== ✅ 新增：行程单申领卡片 ======================
  @Builder buildOrderApplyCard() {
    Column({ space: 10 }) {
      Text("行程单申领").fontSize(20).fontWeight(FontWeight.Bold)
      Button("前往申领行程单")
        .width("100%").height(45).backgroundColor("#007DFF").fontColor(Color.White)
        .onClick(() => this.goToApplyOrderPage())
    }
    .width("95%").padding(20).backgroundColor(Color.White).borderRadius(16).shadow({ radius: 6 })
  }

  @Builder agencySelectSheet() {
    Column({ space: 15 }) {
      Text("选择意向旅行社").fontSize(22).fontWeight(FontWeight.Bold)
      Divider()

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.agencyList, (item: TravelAgency) => {
            Text(item.agencyName)
              .width("100%").padding(14)
              .backgroundColor(this.selectedAgencyId === item.id ? "#007DFF" : "#F5F7FA")
              .fontColor(this.selectedAgencyId === item.id ? Color.White : "#333")
              .borderRadius(8)
              .onClick(() => { this.selectedAgencyId = item.id; })
          })
        }
      }
      .layoutWeight(1)

      Row({ space: 20 }) {
        Button("取消").layoutWeight(1).onClick(() => { this.sheetOpen = false; })
        Button("确认投递").layoutWeight(1).backgroundColor("#007DFF")
          .onClick(() => { void this.submitApply(); })
      }
    }
    .width("100%").padding(15)
  }
}