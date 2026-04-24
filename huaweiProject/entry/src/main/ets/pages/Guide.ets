import router from '@ohos.router'
import promptAction from '@ohos.promptAction';

import { ApiResult, GuideBase } from '../utils/Guide'
import { getGuideList, deleteGuide } from '../api/guideAPI'

// 选项类型（和酒店页面保持一致）
export interface SelectOption {
  value: string;
  label: string;
}

@Entry
@Component
struct Guide {
  @State guideList: GuideBase[] = [];
  @State message: string = "加载中...";
  @State searchText: string = "";
  @State searchType: string = "name";
  @State searchTypeOptions: SelectOption[] = [
    { value: "name", label: "姓名" },
    { value: "phone", label: "电话" }
  ];

  aboutToAppear(): void {
    setTimeout(() => {
      this.getGuideList();
    }, 100);
  }

  // 🔥 修复：所有变量使用显式类型，无 any/unknown
  async getGuideList(): Promise<void> {
    const token: string = AppStorage.get<string>("token") ?? "";
    if (!token) {
      this.toLogin();
      return;
    }

    try {
      // 🔥 核心修复：显式声明 result 类型，替代隐式 any
      let result: ApiResult<GuideBase[]>;

      // 根据搜索类型调用接口
      if (this.searchType === "name") {
        result = await getGuideList(token, this.searchText.trim() || undefined);
      } else {
        result = await getGuideList(token, undefined, this.searchText.trim() || undefined);
      }

      if (result.code === 200) {
        this.guideList = result.data ?? [];
        this.message = this.guideList.length === 0 ? "暂无匹配的导游" : "";
      } else {
        this.message = `导游加载失败：${result.msg || '未知错误'}`;
        this.guideList = [];
      }
    } catch (error) {
      // 🔥 修复：unknown 类型显式转换
      const err: Error = error as Error;
      console.error("获取导游列表错误：", err.message);
      this.message = "网络异常，请检查连接";
      this.guideList = [];
    }
  }

  // 搜索
  onSearch(): void {
    this.getGuideList();
  }

  // 清空搜索
  clearSearch(): void {
    this.searchText = "";
    this.searchType = "name";
    this.getGuideList();
  }

  // 删除导游
  async delGuide(id: number): Promise<void> {
    const token: string = AppStorage.get<string>("token") ?? "";
    try {
      const res: ApiResult<null> = await deleteGuide(token, id);
      promptAction.showToast({ message: res.msg });
      if (res.code === 200) {
        this.getGuideList();
      }
    } catch (error) {
      promptAction.showToast({ message: "删除失败" });
    }
  }

  toLogin(): void {
    AppStorage.delete("token");
    router.replaceUrl({ url: "pages/Login" });
  }

  backToHome(): void {
    router.back();
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

        Text("导游管理")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
          .textAlign(TextAlign.Center)

        Blank().width(80)
      }
      .width("100%")
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
      .backgroundColor("#F5F7FA")

      // 搜索栏（完全对齐酒店页面）
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          TextInput({
            placeholder: "请输入搜索内容",
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
          Text("搜索类型：")
            .fontSize(16)
            .fontColor("#666")
            .margin({ left: 5 })
          Select(this.searchTypeOptions)
            .value(this.searchType)
            .width("30%")
            .height(40)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .onSelect((index: number, value: string) => {
              this.searchType = value;
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

      // 导游列表
      Scroll() {
        Column({ space: 12 }) {
          ForEach(
            this.guideList,
            (item: GuideBase) => {
              Column() {
                Text(`${item.name}｜${item.guideLevel}｜${item.gender}${item.age}岁`)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 10 })

                Text(`电话：${item.phone}`)
                  .fontSize(15)
                  .fontColor("#555555")
                  .margin({ bottom: 6 })

                Text(`身份证：${item.idCard}`)
                  .fontSize(15)
                  .fontColor("#555555")
                  .margin({ bottom: 6 })

                Text(`状态：${item.workStatus ? '在职' : '离职'}`)
                  .fontSize(15)
                  .fontColor(item.workStatus ? "#00C800" : "#F56C6C")

                Row({ space: 10 }) {
                  Button("详情")
                    .width(80)
                    .backgroundColor("#007DFF")
                    .fontColor(Color.White)
                    .onClick(() => router.pushUrl({
                      url: "pages/GuideDetailPage",
                      params: { id: item.id }
                    }))
                  Button("删除")
                    .width(80)
                    .backgroundColor("#F56C6C")
                    .fontColor(Color.White)
                    .onClick(() => this.delGuide(item.id))
                }.margin({ top: 10 })
              }
              .width("95%")
              .padding(25)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .shadow({ radius: 6, color: "#00000015", offsetY: 3 })
            },
            (item: GuideBase) => item.id.toString()
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