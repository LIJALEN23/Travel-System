import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import { TravelOrder, AgencyPageParams, OrderDetailParams, CreateOrderParams, AddOrderForm } from '../utils/Agency';
import { getOrderList, addOrder } from '../api/agencyAPI'


@Entry
@Component
struct AgencyOrderPage {
  @State agencyId: number = 0;
  @State agencyName: string = "";
  @State orderList: TravelOrder[] = [];
  @State message: string = "加载中...";
  // 筛选参数
  @State teamName: string = "";
  @State startTime: string = "";
  @State orderStatus: string = "all";
  // 弹窗控制 + 表单
  @State dialogShow: boolean = false;
  @State addForm: AddOrderForm = {
    teamName: "",
    peopleCount: 20,
    startAddress: "",
    endAddress: "",
    startTime: ""
  };
  // 状态映射
  statusMap: Record<string, string> = {
    "all": "全部",
    "pending": "待确定",
    "ready": "待出发",
    "running": "进行中",
    "finished": "已完成"
  };
  statusKeys: string[] = ["all", "pending", "ready", "running", "finished"];

  aboutToAppear(): void {
    const params: AgencyPageParams = router.getParams() as AgencyPageParams;
    this.agencyId = params.agencyId;
    this.agencyName = params.agencyName;
    this.getOrderList();
  }

  // 获取行程单列表
  async getOrderList(): Promise<void> {
    try {
      const token = AppStorage.get<string>("token");
      if (!token) { promptAction.showToast({ message: "登录已失效" }); router.replaceUrl({ url: "pages/Login" }); return; }
      const result = await getOrderList(token, this.agencyId, this.orderStatus === 'all' ? undefined : this.statusMap[this.orderStatus], this.teamName, this.startTime);
      if (result.code === 200) { this.orderList = result.data; this.message = this.orderList.length ? "" : "暂无行程单数据"; }
      else { this.message = result.msg || "请求失败"; }
    } catch (err) { console.error(err); this.message = "网络请求失败"; }
  }

  // 打开新增弹窗
  openAddDialog() {
    this.addForm = {
      teamName: "",
      peopleCount: 20,
      startAddress: "",
      endAddress: "",
      startTime: ""
    };
    this.dialogShow = true;
  }

  // 提交新增行程单
  async submitAddOrder(): Promise<void> {
    if (!this.addForm.teamName.trim() || !this.addForm.startAddress.trim() || !this.addForm.endAddress.trim() || !this.addForm.startTime.trim()) {
      promptAction.showToast({ message: "请填写完整所有信息" }); return;
    }
    try {
      const token = AppStorage.get<string>("token");
      if (!token) { promptAction.showToast({ message: "请先登录" }); return; }
      const params: CreateOrderParams = {
        agencyId: this.agencyId, vehicleId: 1, driverId: 1, guideId: null,
        teamName: this.addForm.teamName.trim(), peopleCount: this.addForm.peopleCount,
        startAddress: this.addForm.startAddress.trim(), endAddress: this.addForm.endAddress.trim(),
        startTime: this.addForm.startTime.trim(), orderStatus: "待确定"
      };
      const result = await addOrder(token, params);
      if (result.code === 200) {
        promptAction.showToast({ message: "行程单发布成功" });
        this.dialogShow = false;
        this.getOrderList();
      } else { promptAction.showToast({ message: result.msg || "发布失败" }); }
    } catch (err) { promptAction.showToast({ message: "网络异常" }); }
  }

  // 跳转详情
  goToDetail(orderId: number): void {
    router.pushUrl({
      url: "pages/AgencyOrderDetailPage",
      params: { orderId } as OrderDetailParams
    });
  }

  // 状态颜色
  getStatusColor(status: string): string {
    switch (status) {
      case "待确定": return "#FF7D00";
      case "待出发": return "#007DFF";
      case "进行中": return "#00C800";
      case "已完成": return "#909399";
      default: return "#000000";
    }
  }

  // 弹窗UI封装
  @Builder
  AddOrderDialogBuilder() {
    Column({ space: 12 }) {
      Text("新增电子行程单")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 10 });

      TextInput({ placeholder: "请输入团队名称", text: this.addForm.teamName })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => this.addForm.teamName = v);

      TextInput({ placeholder: "请输入出行人数", text: this.addForm.peopleCount.toString() })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .type(InputType.Number)
        .onChange((v: string) => this.addForm.peopleCount = parseInt(v) || 20);

      TextInput({ placeholder: "请输入出发地", text: this.addForm.startAddress })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => this.addForm.startAddress = v);

      TextInput({ placeholder: "请输入目的地", text: this.addForm.endAddress })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => this.addForm.endAddress = v);

      TextInput({ placeholder: "出发时间(yyyy-MM-ddTHH:mm)", text: this.addForm.startTime })
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 10 })
        .onChange((v: string) => this.addForm.startTime = v);

      Row({ space: 20 }) {
        Button("取消")
          .width(100)
          .height(40)
          .backgroundColor("#909399")
          .onClick(() => this.dialogShow = false);

        Button("确认发布")
          .width(100)
          .height(40)
          .backgroundColor("#FF7D00")
          .onClick(() => this.submitAddOrder());
      }.margin({ top:10 })
    }
    .width("90%")
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8 });
  }

  build() {
    Stack() {
      // 主页面内容
      Column() {
        // 顶部导航（彻底删除溢出代码，无任何报错）
        Row({ space: 10 }) {
          // 返回按钮
          Button("返回")
            .width(80).height(40)
            .backgroundColor("#007DFF").fontColor(Color.White).borderRadius(8)
            .onClick(() => router.back())

          // 标题（删除所有报错代码）
          Text(`电子行程单`)
            .fontSize(18).fontWeight(FontWeight.Bold)
            .layoutWeight(1)

          // 发布按钮（永久可见）
          Button("发布")
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
                .width(70).height(30)
                .backgroundColor(this.orderStatus === key ? "#007DFF" : "#fff")
                .fontColor(this.orderStatus === key ? "#fff" : "#000")
                .border({ width: 1, color: "#007DFF" })
                .onClick(() => {
                  this.orderStatus = key;
                  this.getOrderList();
                })
            })
          }

          TextInput({ placeholder: "搜索团队名称", text: this.teamName })
            .height(40).backgroundColor(Color.White).borderRadius(20).padding({ left: 15 })
            .onChange((v: string) => this.teamName = v)

          TextInput({ placeholder: "出发时间(yyyy-MM-ddTHH:mm)", text: this.startTime })
            .height(40).backgroundColor(Color.White).borderRadius(20).padding({ left: 15 })
            .onChange((v: string) => this.startTime = v)

          Button("查询")
            .width("100%").height(40)
            .backgroundColor("#007DFF").fontColor(Color.White).borderRadius(8)
            .onClick(() => this.getOrderList())
        }
        .padding(10)

        // 空状态提示
        if (this.message) {
          Text(this.message).fontSize(16).margin(20)
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
                  .fontColor(this.getStatusColor(item.orderStatus)).fontWeight(FontWeight.Medium)
              }
              .width("95%").padding(20).backgroundColor(Color.White).borderRadius(16)
              .shadow({ radius: 6, color: "#00000015" })
              .onClick(() => this.goToDetail(item.id))
            }, (item: TravelOrder) => item.id.toString())
          }
          .padding(10)
        }
        .layoutWeight(1)
      }
      .width("100%").height("100%").backgroundColor("#F5F7FA")

      // 新增弹窗
      if (this.dialogShow) {
        Column()
          .width("100%").height("100%")
          .backgroundColor("rgba(0,0,0,0.4)")
          .onClick(() => this.dialogShow = false)
        this.AddOrderDialogBuilder()
      }
    }
    .width("100%").height("100%")
  }
}