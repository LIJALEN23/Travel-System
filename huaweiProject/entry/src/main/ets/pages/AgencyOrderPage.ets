import router from '@ohos.router'
import http from '@ohos.net.http'
import {
  TravelOrder,
  ApiResult,
  AgencyPageParams,
  OrderDetailParams,
  CreateOrderParams
} from '../utils/Agency';
import env from '../utils/env';
import Prompt from '@ohos.prompt';

@Entry
@Component
struct AgencyOrderPage {
  @State agencyId: number = 0;
  @State agencyName: string = "";
  @State orderList: TravelOrder[] = [];
  @State message: string = "加载中...";


  @State teamName: string = "";
  @State startTime: string = "";
  @State orderStatus: string = "all";
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

  async getOrderList(): Promise<void> {
    try {
      // 安全获取Token
      const token = AppStorage.get<string>("token");
      if (!token) {
        Prompt.showToast({ message: "登录已失效，请重新登录" });
        router.replaceUrl({ url: "pages/Login" });
        return;
      }

      let url = `${env.BASE_API}/agency/order/list?agencyId=${this.agencyId}`;
      if (this.orderStatus !== "all") {
        // 映射后端接收的中文值
        const backendStatus = this.statusMap[this.orderStatus];
        url += `&orderStatus=${encodeURIComponent(backendStatus)}`;
      }
      if (this.teamName.trim()) {
        url += `&teamName=${encodeURIComponent(this.teamName.trim())}`;
      }
      if (this.startTime.trim()) {
        url += `&startTime=${encodeURIComponent(this.startTime.trim())}`;
      }

      const req = http.createHttp();
      const res = await req.request(url, {
        method: http.RequestMethod.GET,
        header: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        readTimeout: 10000,
        connectTimeout: 10000
      });


      console.info("接口响应：", res.result);
      const result: ApiResult<TravelOrder[]> = JSON.parse(res.result as string);

      if (result.code === 200) {
        this.orderList = result.data;
        this.message = this.orderList.length === 0 ? "暂无行程单数据" : "";
      } else {
        this.message = result.msg || "请求失败";
      }
      req.destroy();
    } catch (err) {
      console.error("获取行程单失败：", err);
      this.message = "网络请求失败，请检查后端服务";
    }
  }

  // 发布行程单
  async addOrder(): Promise<void> {
    try {
      const token = AppStorage.get<string>("token");
      if (!token) {
        Prompt.showToast({ message: "请先登录" });
        return;
      }

      const params: CreateOrderParams = {
        agencyId: this.agencyId,
        vehicleId: 1,
        driverId: 1,
        guideId: null,
        teamName: "新建行程单",
        peopleCount: 20,
        startAddress: "请填写出发地",
        endAddress: "请填写目的地",
        startTime: "2026-04-21T08:00:00",
        orderStatus: "待确定"
      };

      const req = http.createHttp();
      await req.request(`${env.BASE_API}/agency/order/add`, {
        method: http.RequestMethod.POST,
        header: {
          "Authorization": `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        extraData: params
      });

      Prompt.showToast({ message: "发布成功" });
      this.getOrderList();
      req.destroy();
    } catch (err) {
      Prompt.showToast({ message: "发布失败" });
    }
  }

  // 跳转到详情页
  goToDetail(orderId: number): void {
    router.pushUrl({
      url: "pages/AgencyOrderDetailPage",
      params: { orderId } as OrderDetailParams
    });
  }

  build() {
    Column() {
      // 顶部导航
      Row({ space: 10 }) {
        Button("返回")
          .width(80).height(40)
          .backgroundColor("#007DFF").fontColor(Color.White).borderRadius(8)
          .onClick(() => router.back())

        Text(`${this.agencyName} - 电子行程单`)
          .fontSize(22).fontWeight(FontWeight.Bold)
          .flexGrow(1).textAlign(TextAlign.Center)

        Button("发布")
          .width(80).height(40)
          .backgroundColor("#FF7D00").fontColor(Color.White).borderRadius(8)
          .onClick(() => this.addOrder())
      }
      .width("100%").padding(15).backgroundColor("#F5F7FA")

      Column({ space: 8 }) {
        // 状态切换
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

        // 团队名称搜索
        TextInput({ placeholder: "搜索团队名称", text: this.teamName })
          .height(40).backgroundColor(Color.White).borderRadius(20).padding({ left: 15 })
          .onChange(v => this.teamName = v)

        // 出发时间
        TextInput({ placeholder: "出发时间(yyyy-MM-ddTHH:mm)", text: this.startTime })
          .height(40).backgroundColor(Color.White).borderRadius(20).padding({ left: 15 })
          .onChange(v => this.startTime = v)

        // 查询按钮
        Button("查询")
          .width("100%").height(40)
          .backgroundColor("#007DFF").fontColor(Color.White).borderRadius(8)
          .onClick(() => this.getOrderList())
      }
      .padding(10)

      // 空状态
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
                .fontColor(item.orderStatus === "待确定" ? "#FF7D00" : "#007DFF")
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
  }
}