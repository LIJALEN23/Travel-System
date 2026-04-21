import router from '@ohos.router'
import http from '@ohos.net.http'
import {
  TravelAgency, AgencyManager, VehicleDriver, TourismVehicle,
  AgencyEmergency, AgencyRealTimeData, AgencyDetailParams, AgencyPageParams
} from '../utils/Agency';
import { getAgencyBaseInfo, getAgencyManagers, getAgencyDrivers, getAgencyVehicles, getAgencyEmergency, getAgencyRealData } from '../api/agencyAPI'

@Entry
@Component
struct AgencyDetailPage {
  @State agencyId: number = 0;
  @State agencyName: string = "";
  @State detail: TravelAgency | null = null;
  @State managers: AgencyManager[] = [];
  @State drivers: VehicleDriver[] = [];
  @State vehicles: TourismVehicle[] = [];
  @State emergencyList: AgencyEmergency[] = [];
  @State realData: AgencyRealTimeData | null = null;

  aboutToAppear(): void {
    const params: AgencyDetailParams = router.getParams() as AgencyDetailParams;
    this.agencyId = params.id;
    this.agencyId > 0 && this.loadAllData();
  }

  // 统一请求封装
  // 极简调用API
  async loadAllData(): Promise<void> {
    const token = AppStorage.get<string>("token") ?? "";
    if (!token) { this.toLogin(); return; }
    try {
      this.detail = await getAgencyBaseInfo(token, this.agencyId);
      this.agencyName = this.detail?.agencyName || "";
      this.managers = await getAgencyManagers(token, this.agencyId);
      this.drivers = await getAgencyDrivers(token, this.agencyId);
      this.vehicles = await getAgencyVehicles(token, this.agencyId);
      this.emergencyList = await getAgencyEmergency(token, this.agencyId);
      this.realData = await getAgencyRealData(token, this.agencyId);
    } catch (err) {
      console.error("加载详情失败", err);
    }
  }

  // 跳转电子行程单
  goToOrderPage(): void {
    router.pushUrl({
      url: "pages/AgencyOrderPage",
      params: { agencyId: this.agencyId, agencyName: this.agencyName } as AgencyPageParams
    });
  }

  // 跳转出境游管理
  goToAbroadPage(): void {
    router.pushUrl({
      url: "pages/AgencyAbroadPage",
      params: { agencyId: this.agencyId, agencyName: this.agencyName } as AgencyPageParams
    });
  }

  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

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
          .onClick(() => router.back())

        Text("旅行社详情")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
      .backgroundColor("#F5F7FA")

      // 加载状态
      if (this.detail === null) {
        Text("加载中...")
          .fontSize(16)
          .margin({ top: 30 })
      } else {
        Scroll() {
          Column({ space: 12 }) {
            // 1. 基础信息卡片
            Column({ space: 8 }) {
              Text("基础信息").fontSize(18).fontWeight(FontWeight.Bold)
              Text(`名称：${this.detail.agencyName}`)
              Text(`资质编号：${this.detail.licenseNo}`)
              Text(`诚信等级：${this.detail.creditLevel}`)
              Text(`地址：${this.detail.address}`)
              Text(`电话：${this.detail.contactPhone}`)

              // ====================== 新增功能按钮 ======================
              Row({ space: 10 }) {
                Button("电子行程单")
                  .flexGrow(1)
                  .height(40)
                  .backgroundColor("#007DFF")
                  .fontColor(Color.White)
                  .borderRadius(8)
                  .onClick(() => this.goToOrderPage())

                Button("出境游管理")
                  .flexGrow(1)
                  .height(40)
                  .backgroundColor("#FF7D00")
                  .fontColor(Color.White)
                  .borderRadius(8)
                  .onClick(() => this.goToAbroadPage())
              }
              .margin({ top: 15 })
              // ==========================================================
            }
            .width("95%")
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 6, color: "#00000015", offsetY: 3 })

            // 2. 实时数据卡片
            if (this.realData) {
              Column({ space: 8 }) {
                Text("实时运营数据").fontSize(18).fontWeight(FontWeight.Bold)
                Text(`今日团队：${this.realData.todayTeams} 个`)
                Text(`今日人数：${this.realData.todayPeople} 人`)
                Text(`在线车辆：${this.realData.onlineVehicles} 台`)
              }
              .width("95%")
              .padding(20)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .shadow({ radius: 6, color: "#00000015", offsetY: 3 })
            }

            // 3. 管理人员卡片
            Column({ space: 8 }) {
              Text("管理人员").fontSize(18).fontWeight(FontWeight.Bold)
              ForEach(this.managers, (m: AgencyManager) => {
                Text(`${m.managerName}｜${m.post}｜${m.phone}`)
              }, (item: AgencyManager) => item.id.toString())
            }
            .width("95%")
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 6, color: "#00000015", offsetY: 3 })

            // 4. 驾驶员卡片
            Column({ space: 8 }) {
              Text("驾驶员信息").fontSize(18).fontWeight(FontWeight.Bold)
              ForEach(this.drivers, (d: VehicleDriver) => {
                Text(`${d.driverName}｜${d.licenseType}｜${d.phone}`)
              }, (item: VehicleDriver) => item.id.toString())
            }
            .width("95%")
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 6, color: "#00000015", offsetY: 3 })

            // 5. 旅游车辆卡片
            Column({ space: 8 }) {
              Text("旅游车辆").fontSize(18).fontWeight(FontWeight.Bold)
              ForEach(this.vehicles, (v: TourismVehicle) => {
                Text(`${v.plateNo}｜${v.vehicleType}｜${v.seatCount}座`)
              }, (item: TourismVehicle) => item.id.toString())
            }
            .width("95%")
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 6, color: "#00000015", offsetY: 3 })

            // 6. 应急救援卡片
            Column({ space: 8 }) {
              Text("应急救援").fontSize(18).fontWeight(FontWeight.Bold)
              ForEach(this.emergencyList, (e: AgencyEmergency) => {
                Text(`${e.rescuerName}｜${e.rescuerPhone}｜${e.vehicleNo}`)
              }, (item: AgencyEmergency) => item.id.toString())
            }
            .width("95%")
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 6, color: "#00000015", offsetY: 3 })
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