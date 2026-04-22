import router from '@ohos.router'
import { HotelBase, HotelQueryParams } from '../utils/Hotel'
// 导入封装的酒店API
import { getScenicNameList, getHotelList } from '../api/hotelAPI'

export interface SelectOption {
  value: string;
  label: string;
}

@Entry
@Component
struct Hotel {
  @State hotelList: HotelBase[] = [];
  @State message: string = "加载中...";
  @State searchText: string = "";
  @State selectedStarLevel: string = "全部";
  @State selectedScenicName: string = "全部";
  @State scenicOptions: SelectOption[] = [];
  @State starLevelOptions: SelectOption[] = [
    { value: "全部", label: "全部" },
    { value: "1", label: "1星" },
    { value: "2", label: "2星" },
    { value: "3", label: "3星" },
    { value: "4", label: "4星" },
    { value: "5", label: "5星" }
  ];

  aboutToAppear(): void {
    setTimeout(() => {
      this.getScenicOptions();
      this.getHotelList();
    }, 100);
  }

  // 🔥 极简：仅调用封装API
  async getScenicOptions(): Promise<void> {
    const token: string = AppStorage.get<string>("token") || "";
    if (!token) {
      this.toLogin();
      return;
    }

    try {
      const result = await getScenicNameList(token);
      if (result.code === 200 && result.data) {
        this.scenicOptions = result.data.map((name: string): SelectOption => ({
          value: name,
          label: name
        }));
        this.scenicOptions.unshift({ value: "全部", label: "全部" });
        this.message = "";
      } else {
        this.message = `景区加载失败：${result.msg || '未知错误'}`;
        this.scenicOptions = [{ value: "全部", label: "全部" }];
      }
    } catch (e) {
      const err = e as Error;
      console.error("获取景区选项错误：", err.message);
      this.message = `景区加载失败：${err.message.substring(0, 20)}`;
      this.scenicOptions = [{ value: "全部", label: "全部" }];
    }
  }

  // 🔥 极简：仅调用封装API
  async getHotelList(params?: HotelQueryParams): Promise<void> {
    const token: string = AppStorage.get<string>("token") || "";
    if (!token) {
      this.toLogin();
      return;
    }

    try {
      const result = await getHotelList(token, params);
      if (result.code === 200) {
        this.hotelList = result.data || [];
        this.message = this.hotelList.length === 0 ? "暂无匹配的酒店" : "";
      } else {
        this.message = `酒店加载失败：${result.msg || '未知错误'}`;
        this.hotelList = [];
      }
    } catch (e) {
      const err = e as Error;
      console.error("获取酒店列表错误：", err.message);
      this.message = err.message.includes("Network") ? "网络异常：请检查网络连接" : `酒店加载失败：${err.message.substring(0, 20)}`;
      this.hotelList = [];
    }
  }

  // 搜索逻辑（不变）
  onSearch(): void {
    const params: HotelQueryParams = {
      hotelName: this.searchText.trim() || undefined,
      starLevel: this.selectedStarLevel === "全部" ? undefined : Number(this.selectedStarLevel),
      scenicName: this.selectedScenicName === "全部" ? undefined : this.selectedScenicName
    };
    this.getHotelList(params);
  }

  // 清空筛选（不变）
  clearSearch(): void {
    this.searchText = "";
    this.selectedStarLevel = "全部";
    this.selectedScenicName = "全部";
    this.getHotelList();
  }

  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  backToHome(): void {
    router.back();
  }

  goToDetail(id: number): void {
    console.info("点击酒店ID：", id);
    router.pushUrl({
      url: "pages/HotelDetailPage",
      params: { id: id }
    }, (err) => {
      if (err) console.error("跳转详情失败：", (err as Error).message);
    });
  }

  // ======================
  // 【UI 渲染代码完全不变】
  // ======================
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
          .onClick(() => this.backToHome())

        Text("酒店管理")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
      .backgroundColor("#F5F7FA")

      // 筛选区域
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          TextInput({
            placeholder: "请输入酒店名称搜索",
            text: this.searchText
          })
            .width("70%")
            .height(48)
            .backgroundColor(Color.White)
            .borderRadius(24)
            .padding({ left: 20, right: 20 })
            .fontSize(16)
            .onChange((value: string) => {
              this.searchText = value;
            })

          Button("搜索")
            .width("18%")
            .height(48)
            .backgroundColor("#007DFF")
            .fontColor(Color.White)
            .borderRadius(24)
            .onClick(() => this.onSearch())

          Button("清空")
            .width("10%")
            .height(48)
            .backgroundColor("#EEEEEE")
            .fontColor(Color.Black)
            .borderRadius(24)
            .onClick(() => this.clearSearch())
        }

        Row({ space: 8 }) {
          Text("星级：")
            .fontSize(16)
            .fontColor("#666")
            .margin({ left: 5 })
          Select(this.starLevelOptions)
            .value(this.selectedStarLevel)
            .width("25%")
            .height(40)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .onSelect((index: number, value: string) => {
              this.selectedStarLevel = value;
            })

          Text("所属景区：")
            .fontSize(16)
            .fontColor("#666")
            .margin({ left: 10 })
          Select(this.scenicOptions)
            .value(this.selectedScenicName)
            .width("40%")
            .height(40)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .onSelect((index: number, value: string) => {
              this.selectedScenicName = value;
            })
        }
      }
      .width("95%")
      .margin({ left: 10, top: 10, bottom: 20 })

      // 提示文字
      if (this.message !== "") {
        Text(this.message)
          .fontSize(16)
          .fontColor("#666666")
          .margin({ left: 15, bottom: 5 })
      }

      // 酒店列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(
            this.hotelList,
            (item: HotelBase) => {
              Column(){
                Text(item.hotelName)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 10 })

                Text(`地址：${item.address}`)
                  .fontSize(15)
                  .fontColor("#555555")
                  .margin({ bottom: 6 })

                Text(`星级：${item.starLevel}星 | 最大容量：${item.maxCapacity} 人 | 总车位：${item.totalParking || 0} `)
                  .fontSize(15)
                  .fontColor("#555555")
              }
              .width("95%")
              .padding(25)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .shadow({ radius: 6, color: "#00000015", offsetY: 3 })
              .onClick(() => {
                this.goToDetail(item.id);
              })
              .margin({ left: 0 })
            },
            (item: HotelBase) => item.id.toString()
          )
        }
        .width("100%")
        .margin({ left: 10, bottom: 30, top: 0 })
      }
      .layoutWeight(1)
      .width("100%")
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#F5F7FA")
    .padding({ bottom: 15 })
  }
}