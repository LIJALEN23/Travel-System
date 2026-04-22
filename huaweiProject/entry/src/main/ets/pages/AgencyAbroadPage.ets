import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import { AbroadTravel, AgencyPageParams, CreateAbroadParams, AuditAbroadParams, AddAbroadForm } from '../utils/Agency';
import { getAbroadList, addAbroad, auditAbroad } from '../api/agencyAPI'

@Entry
@Component
struct AgencyAbroadPage {
  @State agencyId: number = 0;
  @State agencyName: string = "";
  @State list: AbroadTravel[] = [];
  @State message: string = "加载中...";
  // 筛选
  @State teamName: string = "";
  @State visaStatus: string = "all";
  // 弹窗控制变量
  @State dialogShow: boolean = false;
  @State addForm: AddAbroadForm = {
    teamName: "",
    country: "",
    startTime: ""
  };

  // 后端真实状态：全部/待审核/通过/驳回
  statusMap: Record<string, string> = {
    "all": "全部",
    "daishenhe": "待审核",
    "tongguo": "通过",
    "bohui": "驳回"
  };
  statusKeys: string[] = ["all", "daishenhe", "tongguo", "bohui"];

  aboutToAppear(): void {
    const params: AgencyPageParams = router.getParams() as AgencyPageParams;
    this.agencyId = params.agencyId;
    this.agencyName = params.agencyName;
    this.getList();
  }

  // 🔥 极简调用API
  async getList(): Promise<void> {
    try {
      const token = AppStorage.get<string>("token");
      if (!token) { promptAction.showToast({ message: "登录已失效" }); router.replaceUrl({ url: "pages/Login" }); return; }
      const result = await getAbroadList(token, this.agencyId, this.visaStatus === 'all' ? undefined : this.statusMap[this.visaStatus], this.teamName);
      if (result.code === 200) { this.list = result.data; this.message = this.list.length ? "" : "暂无数据"; }
      else { this.message = result.msg; }
    } catch (err) { this.message = "网络请求失败"; console.error(err); }
  }

  // ============== 2. 打开新增弹窗 ==============
  openAddDialog() {
    // 重置表单
    this.addForm = {
      teamName: "",
      country: "",
      startTime: ""
    };
    this.dialogShow = true;
  }

  // ============== 3. 提交新增出境游申请（弹窗表单提交） ==============
  async submitAbroad(): Promise<void> {
    if (!this.addForm.teamName.trim() || !this.addForm.country.trim() || !this.addForm.startTime.trim()) {
      promptAction.showToast({ message: "请填写完整信息" }); return;
    }
    try {
      const token = AppStorage.get<string>("token");
      if (!token) { promptAction.showToast({ message: "请先登录" }); return; }
      const params: CreateAbroadParams = {
        agencyId: this.agencyId, teamName: this.addForm.teamName.trim(), country: this.addForm.country.trim(),
        visaStatus: "待审核", applyTime: new Date().toISOString(), startTime: this.addForm.startTime.trim(), status: "正常"
      };
      const result = await addAbroad(token, params);
      if (result.code === 200) {
        promptAction.showToast({ message: "申请成功" });
        this.dialogShow = false;
        this.getList();
      } else { promptAction.showToast({ message: result.msg }); }
    } catch (err) { promptAction.showToast({ message: "申请失败" }); }
  }

  // ============== 4. 审核：通过 / 驳回 ==============
  async auditAbroad(id: number, status: string): Promise<void> {
    try {
      const token = AppStorage.get<string>("token");
      if (!token) return;
      const result = await auditAbroad(token, { id, visaStatus: status });
      if (result.code === 200) { promptAction.showToast({ message: `${status}成功` }); this.getList(); }
      else { promptAction.showToast({ message: result.msg }); }
    } catch (err) { promptAction.showToast({ message: "操作失败" }); }
  }

  // ============== 弹窗UI封装（和行程单风格一致） ==============
  @Builder
  AddAbroadDialogBuilder() {
    Column({ space: 12 }) {
      Text("新增出境游申请")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 });

      // 团队名称
      TextInput({ placeholder: "请输入团队名称", text: this.addForm.teamName })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => this.addForm.teamName = v);

      // 目的地国家
      TextInput({ placeholder: "请输入目的地国家", text: this.addForm.country })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => this.addForm.country = v);

      // 出发时间
      TextInput({ placeholder: "出发时间(yyyy-MM-ddTHH:mm)", text: this.addForm.startTime })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => this.addForm.startTime = v);

      // 按钮组
      Row({ space: 20 }) {
        Button("取消")
          .width(100)
          .height(40)
          .backgroundColor("#909399")
          .onClick(() => this.dialogShow = false);

        Button("确认提交")
          .width(100)
          .height(40)
          .backgroundColor("#FF7D00")
          .onClick(() => this.submitAbroad());
      }.margin({ top: 10 })
    }
    .width("90%")
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8 });
  }

  build() {
    // 使用Stack布局实现弹窗（和行程单一致）
    Stack() {
      Column() {
        // 顶部导航（修复按钮可见性，无报错）
        Row({ space: 10 }) {
          Button("返回")
            .width(80).height(40)
            .backgroundColor("#007DFF").fontColor(Color.White).borderRadius(8)
            .onClick(() => router.back())

          Text(`出境游管理`)
            .fontSize(20).fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          // 新增按钮 → 打开弹窗
          Button("新增")
            .width(80).height(40)
            .backgroundColor("#FF7D00").fontColor(Color.White).borderRadius(8)
            .onClick(() => this.openAddDialog())
        }
        .width("100%").padding(15).backgroundColor("#F5F7FA")
        .justifyContent(FlexAlign.SpaceBetween)

        // 筛选栏
        Column({ space: 8 }) {
          Row({ space: 5 }) {
            ForEach(this.statusKeys, (key: string) => {
              Button(this.statusMap[key])
                .width(75).height(30)
                .backgroundColor(this.visaStatus === key ? "#007DFF" : "#fff")
                .fontColor(this.visaStatus === key ? "#fff" : "#000")
                .border({ width: 1, color: "#007DFF" })
                .onClick(() => {
                  this.visaStatus = key;
                  this.getList();
                })
            })
          }

          TextInput({ placeholder: "搜索团队名称", text: this.teamName })
            .height(40).backgroundColor(Color.White).borderRadius(20).padding({ left: 15 })
            .onChange((v: string) => this.teamName = v)

          Button("查询")
            .width("100%").height(40)
            .backgroundColor("#007DFF").fontColor(Color.White).borderRadius(8)
            .onClick(() => this.getList())
        }
        .padding(10)

        // 空状态
        if (this.message) {
          Text(this.message).fontSize(16).margin(20)
        }

        // 出境游列表 + 操作按钮
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.list, (item: AbroadTravel) => {
              Column({ space: 8 }) {
                Text(item.teamName).fontSize(18).fontWeight(FontWeight.Bold)
                Text(`目的地：${item.country}`).fontColor("#555")
                Text(`签证状态：${item.visaStatus}`)
                  .fontColor(
                    item.visaStatus === "待审核" ? "#FF7D00" :
                      item.visaStatus === "通过" ? "#00C800" : "#F56C6C"
                  )
                Text(`申请时间：${item.applyTime}`).fontColor("#555")

                if (item.visaStatus === "待审核") {
                  Row({ space: 10 }) {
                    Button("审核通过")
                      .width(120).height(35)
                      .backgroundColor("#00C800").fontColor(Color.White).borderRadius(8)
                      .onClick(() => this.auditAbroad(item.id, "通过"))

                    Button("驳回")
                      .width(120).height(35)
                      .backgroundColor("#F56C6C").fontColor(Color.White).borderRadius(8)
                      .onClick(() => this.auditAbroad(item.id, "驳回"))
                  }
                  .margin({ top: 10 })
                }
              }
              .width("95%").padding(20).backgroundColor(Color.White).borderRadius(16).shadow({ radius: 6 })
            }, (item: AbroadTravel) => item.id.toString())
          }
          .padding(10)
        }
        .layoutWeight(1)
      }
      .width("100%").height("100%").backgroundColor("#F5F7FA")

      // 弹窗显示逻辑
      if (this.dialogShow) {
        Column()
          .width("100%").height("100%")
          .backgroundColor("rgba(0,0,0,0.4)")
          .onClick(() => this.dialogShow = false)
        this.AddAbroadDialogBuilder()
      }
    }
    .width("100%").height("100%")
  }
}