import router from '@ohos.router'
import http from '@ohos.net.http'
import { Result, HotelBase, HotelQueryParams } from '../utils/Hotel'

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

  // 核心修复：适配ArkTS标准的响应解析（放弃非标准的data/end事件）
  private arrayBufferToString(buffer: ArrayBuffer): string {
    if (!buffer) return "{}";
    const uint8Array = new Uint8Array(buffer);
    let str = '';
    for (let i = 0; i < uint8Array.length; i++) {
      str += String.fromCharCode(uint8Array[i]);
    }
    return str.trim() || "{}";
  }

  // 获取景区名称选项（完全适配ArkTS HTTP标准）
  async getScenicOptions(): Promise<void> {
    const token: string = AppStorage.get<string>("token") || "";
    if (!token) {
      this.toLogin();
      return;
    }

    const httpRequest = http.createHttp();
    try {
      // 使用ArkTS标准的await方式请求（官方推荐）
      const res: http.HttpResponse = await httpRequest.request(
        "http://192.168.52.143:8080/spot/nameList",
        {
          method: http.RequestMethod.GET,
          header: {
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json;charset=utf-8",
            "Accept-Encoding": "identity" // 禁用压缩，避免解析问题
          },
          // 关键：设置响应类型为文本（避免ArrayBuffer解析问题）
          expectDataType: http.HttpDataType.STRING
        }
      );

      console.info("景区接口响应码：", res.responseCode);
      if (res.responseCode !== 200) {
        throw new Error(`响应码错误：${res.responseCode}`);
      }

      // 直接获取字符串响应（ArkTS标准方式）
      let jsonString: string = "";
      if (typeof res.result === 'string') {
        jsonString = res.result;
      } else if (res.result instanceof ArrayBuffer) {
        jsonString = this.arrayBufferToString(res.result);
      } else {
        jsonString = "{}";
      }
      console.info("景区接口解析后数据：", jsonString);

      // 解析JSON（兜底容错）
      let result: Result<string[]> = { code: 500, msg: "解析失败", data: [] };
      try {
        result = JSON.parse(jsonString);
      } catch (parseErr) {
        console.error("景区JSON解析失败：", (parseErr as Error).message);
      }

      // 处理业务逻辑
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
    } finally {
      httpRequest.destroy(); // 无需延迟，ArkTS标准方式可直接销毁
    }
  }

  // 获取酒店列表（完全适配ArkTS HTTP标准）
  async getHotelList(params?: HotelQueryParams): Promise<void> {
    const token: string = AppStorage.get<string>("token") || "";
    if (!token) {
      this.toLogin();
      return;
    }

    const httpRequest = http.createHttp();
    try {
      // 拼接请求URL
      let url: string = "http://192.168.52.143:8080/hotel/list";
      const queryParams: string[] = [];
      if (params?.hotelName && params.hotelName.trim()) {
        queryParams.push(`hotelName=${encodeURIComponent(params.hotelName.trim())}`);
      }
      if (params?.starLevel && params.starLevel > 0) {
        queryParams.push(`starLevel=${params.starLevel}`);
      }
      if (params?.scenicName && params.scenicName !== "全部") {
        queryParams.push(`scenicName=${encodeURIComponent(params.scenicName)}`);
      }
      if (queryParams.length > 0) {
        url += `?${queryParams.join("&")}`;
      }
      console.info("酒店请求URL：", url);

      // ArkTS标准的await请求（核心修复：指定响应类型为字符串）
      const res: http.HttpResponse = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            "Authorization": "Bearer " + token,
            "Content-Type": "application/json;charset=utf-8",
            "Accept-Encoding": "identity"
          },
          // 关键修复：强制响应为字符串类型，避免ArrayBuffer解析问题
          expectDataType: http.HttpDataType.STRING
        }
      );

      console.info("酒店接口响应码：", res.responseCode);
      if (res.responseCode !== 200) {
        throw new Error(`响应码错误：${res.responseCode}`);
      }

      // 解析响应（ArkTS标准方式）
      let jsonString: string = "";
      if (typeof res.result === 'string') {
        jsonString = res.result; // 直接使用字符串响应
      } else if (res.result instanceof ArrayBuffer) {
        jsonString = this.arrayBufferToString(res.result);
      } else {
        jsonString = "{}";
      }
      console.info("酒店接口解析后数据：", jsonString);

      // 解析JSON（容错处理）
      let result: Result<HotelBase[]> = { code: 500, msg: "解析失败", data: [] };
      try {
        result = JSON.parse(jsonString);
      } catch (parseErr) {
        console.error("酒店JSON解析失败：", (parseErr as Error).message);
      }

      // 处理业务逻辑
      if (result.code === 200) {
        this.hotelList = result.data || [];
        this.message = this.hotelList.length === 0 ? "暂无匹配的酒店" : "";
        console.info("酒店列表加载成功，数量：", this.hotelList.length);
      } else {
        this.message = `酒店加载失败：${result.msg || '未知错误'}`;
        this.hotelList = [];
      }
    } catch (e) {
      const err = e as Error;
      console.error("获取酒店列表错误：", err.message);
      // 区分真实网络异常
      if (err.message.includes("Network") || err.message.includes("Connection")) {
        this.message = "网络异常：请检查网络连接";
      } else {
        this.message = `酒店加载失败：${err.message.substring(0, 20)}`;
      }
      this.hotelList = [];
    } finally {
      httpRequest.destroy();
    }
  }

  // 搜索逻辑
  onSearch(): void {
    const params: HotelQueryParams = {
      hotelName: this.searchText.trim() || undefined,
      starLevel: this.selectedStarLevel === "全部"
        ? undefined
        : Number(this.selectedStarLevel),
      scenicName: this.selectedScenicName === "全部"
        ? undefined
        : this.selectedScenicName
    };
    this.getHotelList(params);
  }

  // 清空筛选条件
  clearSearch(): void {
    this.searchText = "";
    this.selectedStarLevel = "全部";
    this.selectedScenicName = "全部";
    this.getHotelList();
  }

  // 跳转登录页
  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  // 返回首页
  backToHome(): void {
    router.back();
  }

  // 跳转酒店详情页
  goToDetail(id: number): void {
    console.info("点击酒店ID：", id);
    router.pushUrl({
      url: "pages/HotelDetailPage",
      params: { id: id }
    }, (err) => {
      if (err) {
        console.error("跳转详情失败：", (err as Error).message);
      }
    });
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