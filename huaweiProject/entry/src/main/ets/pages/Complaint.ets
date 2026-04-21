import router from '@ohos.router'
import http from '@ohos.net.http'
import prompt from '@ohos.prompt'
import { ComplaintApi } from '../common/api/complaint'
import { Complaint as ComplaintEntity, HandleComplaintRequest, ComplaintQueryParams, CreditInfo } from '../utils/Complaint'
import { Result } from '../utils/Login'

@Entry
@Component
struct ComplaintPage {
  @State complaintList: ComplaintEntity[] = []
  @State loading: boolean = false
  @State selectedTab: number = 0 // 0: 投诉列表, 1: 提交投诉, 2: 诚信查询
  @State filterStatus: string = ''
  @State filterAgencyId: number = 0
  @State filterGuideId: number = 0
  @State selectedComplaint: ComplaintEntity | null = null
  @State showDetailDialog: boolean = false
  @State showHandleDialog: boolean = false
  @State showSubmitDialog: boolean = false
  @State showCreditDialog: boolean = false
  @State creditInfo: CreditInfo | null = null
  @State creditType: string = ''
  @State creditId: number = 0

  // 新增投诉表单数据
  @State newComplaint: ComplaintEntity = {
    title: '',
    content: '',
    complaintType: '导游',
    complainant: '',
    contactInfo: '',
    complaintTime: new Date().toISOString().split('T')[0],
    status: '待处理'
  } as ComplaintEntity

  // 处理投诉表单数据
  @State handleRequest: HandleComplaintRequest = {
    complaintId: 0,
    handleUser: '',
    handleResult: '',
    status: '已办结'
  }

  aboutToAppear() {
    this.loadComplaints()
  }

  build() {
    Column() {
      // 标题和选项卡
      this.Header()

      // 内容区域
      if (this.selectedTab === 0) {
        this.ComplaintListPage()
      } else if (this.selectedTab === 1) {
        this.SubmitComplaintPage()
      } else {
        this.CreditQueryPage()
      }

      // 对话框
      this.Dialogs()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  // ================================
  // 头部标题和选项卡
  // ================================
  @Builder
  Header() {
    Column() {
      Text('游客投诉管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      // 选项卡
      Row() {
        this.TabItem('投诉列表', 0)
        this.TabItem('提交投诉', 1)
        this.TabItem('诚信查询', 2)
      }
      .width('90%')
      .height(50)
      .backgroundColor(Color.White)
      .borderRadius(10)
      .margin({ bottom: 15 })
    }
    .width('100%')
  }

  @Builder
  TabItem(text: string, index: number) {
    Button(text)
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(this.selectedTab === index ? '#007DFF' : Color.White)
      .fontColor(this.selectedTab === index ? Color.White : '#333')
      .borderRadius(10)
      .onClick(() => {
        this.selectedTab = index
      })
  }

  // ================================
  // 投诉列表页面
  // ================================
  @Builder
  ComplaintListPage() {
    Column() {
      // 筛选条件
      this.FilterSection()

      // 投诉列表
      if (this.loading) {
        this.LoadingIndicator()
      } else {
        if (this.complaintList.length === 0) {
          this.EmptyState()
        } else {
          this.ComplaintList()
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  FilterSection() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        TextInput({ placeholder: '状态筛选（待处理/已办结/已驳回）' })
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.filterStatus = value
          })

        Button('搜索')
          .width(80)
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.loadComplaints()
          })
      }

      Row({ space: 10 }) {
        TextInput({ placeholder: '旅行社ID' })
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.filterAgencyId = parseInt(value) || 0
          })

        TextInput({ placeholder: '导游ID' })
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.filterGuideId = parseInt(value) || 0
          })
      }
    }
    .width('90%')
    .margin({ bottom: 15 })
  }

  @Builder
  LoadingIndicator() {
    Column() {
      Progress({ value: 0, total: 100, type: ProgressType.Ring })
      Text('加载中...')
        .fontSize(14)
        .margin({ top: 10 })
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  EmptyState() {
    Column() {
      Text('暂无投诉数据')
        .fontSize(16)
        .fontColor('#666')
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ComplaintList() {
    Scroll() {
      Column({ space: 10 }) {
        ForEach(this.complaintList, (complaint: ComplaintEntity) => {
          this.ComplaintCard(complaint)
        })
      }
      .width('100%')
      .padding(10)
    }
    .layoutWeight(1)
  }

  @Builder
  ComplaintCard(complaint: ComplaintEntity) {
    Column({ space: 8 }) {
      Row() {
        Text(complaint.title || '无标题')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        
        Text(this.getStatusText(complaint.status))
          .fontSize(12)
          .fontColor(this.getStatusColor(complaint.status))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.getStatusBgColor(complaint.status))
          .borderRadius(4)
      }

      Text((complaint.content || '').substring(0, 100) + '...')
        .fontSize(14)
        .fontColor('#666')

      Row() {
        Text(`投诉人: ${complaint.complainant}`)
          .fontSize(12)
          .fontColor('#999')
          .layoutWeight(1)
        
        Text((complaint.complaintTime || '').split('T')[0])
          .fontSize(12)
          .fontColor('#999')
      }

      // 操作按钮
      Row({ space: 10 }) {
        Button('查看详情')
          .width(80)
          .height(30)
          .fontSize(12)
          .onClick(() => {
            this.selectedComplaint = complaint
            this.showDetailDialog = true
          })

        if (complaint.status === '待处理') {
          Button('处理')
            .width(60)
            .height(30)
            .fontSize(12)
            .backgroundColor('#FF9500')
            .fontColor(Color.White)
            .onClick(() => {
              this.selectedComplaint = complaint
              this.handleRequest.complaintId = complaint.id || 0
              this.showHandleDialog = true
            })
        }

        Button('删除')
          .width(60)
          .height(30)
          .fontSize(12)
          .backgroundColor('#FF3B30')
          .fontColor(Color.White)
          .onClick(() => {
            this.deleteComplaint(complaint.id || 0)
          })
      }
      .margin({ top: 5 })
    }
    .width('100%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  // ================================
  // 提交投诉页面
  // ================================
  @Builder
  SubmitComplaintPage() {
    Scroll() {
      Column({ space: 15 }) {
        Text('提交新投诉')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 10, bottom: 10 })

        this.FormField('投诉标题', (value: string) => {
          this.newComplaint.title = value
        })

        this.FormField('投诉内容', (value: string) => {
          this.newComplaint.content = value
        }, true)

        this.FormField('投诉人', (value: string) => {
          this.newComplaint.complainant = value
        })

        this.FormField('联系方式', (value: string) => {
          this.newComplaint.contactInfo = value
        })

        // 投诉类型选择
        Row() {
          Text('投诉类型:')
            .fontSize(16)
            .width(80)
          
          Radio({ value: '导游', group: 'complaintType' })
            .checked(this.newComplaint.complaintType === '导游')
            .onChange((value: boolean) => {
              if (value) this.newComplaint.complaintType = '导游'
            })
          Text('导游')
            .margin({ left: 5 })
          
          Radio({ value: '旅行社', group: 'complaintType' })
            .checked(this.newComplaint.complaintType === '旅行社')
            .onChange((value: boolean) => {
              if (value) this.newComplaint.complaintType = '旅行社'
            })
          Text('旅行社')
            .margin({ left: 5 })
        }
        .width('90%')

        Button('提交投诉')
          .width('90%')
          .height(50)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .margin({ top: 20 })
          .onClick(() => {
            this.submitComplaint()
          })
      }
      .width('100%')
      .padding({ bottom: 20 })
    }
    .layoutWeight(1)
  }

  @Builder
  FormField(label: string, onChange: (value: string) => void, multiline: boolean = false) {
    Column({ space: 5 }) {
      Text(label)
        .fontSize(16)
        .alignSelf(ItemAlign.Start)
      
      if (multiline) {
        TextArea({ text: '' })
          .width('90%')
          .height(120)
          .onChange(onChange)
      } else {
        TextInput({ placeholder: `请输入${label}` })
          .width('90%')
          .height(40)
          .onChange(onChange)
      }
    }
    .width('100%')
  }

  // ================================
  // 诚信查询页面
  // ================================
  @Builder
  CreditQueryPage() {
    Column({ space: 15 }) {
      Text('诚信信息查询')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })

      Row({ space: 10 }) {
        Button('查询导游诚信')
          .layoutWeight(1)
          .height(45)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.creditType = 'guide'
            this.showCreditDialog = true
          })
        
        Button('查询旅行社诚信')
          .layoutWeight(1)
          .height(45)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.creditType = 'agency'
            this.showCreditDialog = true
          })
      }
      .width('90%')

      // 诚信信息展示
      if (this.creditInfo) {
        this.CreditInfoDisplay()
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  CreditInfoDisplay() {
    Column({ space: 10 }) {
      Text('诚信信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Row() {
        Text('诚信评分:')
          .fontSize(16)
        Text(`${this.creditInfo?.creditScore}分`)
          .fontSize(16)
          .fontColor(this.getCreditColor(this.creditInfo?.creditScore || 0))
          .fontWeight(FontWeight.Bold)
      }

      Row() {
        Text('诚信等级:')
          .fontSize(16)
        Text(this.creditInfo?.creditLevel || '')
          .fontSize(16)
          .fontColor(this.getCreditColor(this.creditInfo?.creditScore || 0))
          .fontWeight(FontWeight.Bold)
      }

      Row() {
        Text('总投诉数:')
          .fontSize(14)
        Text(`${this.creditInfo?.totalComplaints}`)
          .fontSize(14)
      }

      Row() {
        Text('待处理:')
          .fontSize(14)
        Text(`${this.creditInfo?.pendingComplaints}`)
          .fontSize(14)
          .fontColor('#FF9500')
      }

      Row() {
        Text('已办结:')
          .fontSize(14)
        Text(`${this.creditInfo?.resolvedComplaints}`)
          .fontSize(14)
          .fontColor('#34C759')
      }

      Row() {
        Text('已驳回:')
          .fontSize(14)
        Text(`${this.creditInfo?.rejectedComplaints}`)
          .fontSize(14)
          .fontColor('#FF3B30')
      }
    }
    .width('90%')
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })
  }

  // ================================
  // 对话框
  // ================================
  @Builder
  Dialogs() {
    if (this.showDetailDialog && this.selectedComplaint) {
      this.ComplaintDetailDialog()
    }

    if (this.showHandleDialog) {
      this.HandleComplaintDialog()
    }

    if (this.showCreditDialog) {
      this.CreditQueryDialog()
    }
  }

  @Builder
  ComplaintDetailDialog() {
    Column({ space: 15 }) {
      Text('投诉详情')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Scroll() {
        Column({ space: 8 }) {
          Text(`标题: ${this.selectedComplaint?.title}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)

          Text(`内容: ${this.selectedComplaint?.content}`)
            .fontSize(14)
            .fontColor('#666')

          Text(`投诉类型: ${this.selectedComplaint?.complaintType}`)
            .fontSize(14)

          Text(`投诉人: ${this.selectedComplaint?.complainant}`)
            .fontSize(14)

          Text(`联系方式: ${this.selectedComplaint?.contactInfo}`)
            .fontSize(14)

          Text(`投诉时间: ${(this.selectedComplaint?.complaintTime || '').split('T')[0]}`)
            .fontSize(14)

          Text(`状态: ${this.getStatusText(this.selectedComplaint?.status || '')}`)
            .fontSize(14)
            .fontColor(this.getStatusColor(this.selectedComplaint?.status || ''))

          if (this.selectedComplaint?.handleResult) {
            Text(`处理结果: ${this.selectedComplaint.handleResult}`)
              .fontSize(14)
          }

          if (this.selectedComplaint?.handleUser) {
            Text(`处理人: ${this.selectedComplaint.handleUser}`)
              .fontSize(14)
          }

          if (this.selectedComplaint?.handleTime) {
            Text(`处理时间: ${(this.selectedComplaint.handleTime || '').split('T')[0]}`)
              .fontSize(14)
          }
        }
      }
      .layoutWeight(1)

      Button('关闭')
        .width('100%')
        .height(40)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .onClick(() => {
          this.showDetailDialog = false
        })
    }
    .width('80%')
    .height('70%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder
  HandleComplaintDialog() {
    Column({ space: 15 }) {
      Text('处理投诉')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: '处理人' })
        .width('100%')
        .height(40)
        .onChange((value: string) => {
          this.handleRequest.handleUser = value
        })

      TextArea({ placeholder: '处理结果' })
        .width('100%')
        .height(80)
        .onChange((value: string) => {
          this.handleRequest.handleResult = value
        })

      Row({ space: 10 }) {
        Text('处理状态:')
          .fontSize(14)
        
        Radio({ value: '已办结', group: 'handleStatus' })
          .checked(this.handleRequest.status === '已办结')
          .onChange((value: boolean) => {
            if (value) this.handleRequest.status = '已办结'
          })
        Text('已办结')
          .fontSize(14)
          .margin({ right: 10 })

        Radio({ value: '已驳回', group: 'handleStatus' })
          .checked(this.handleRequest.status === '已驳回')
          .onChange((value: boolean) => {
            if (value) this.handleRequest.status = '已驳回'
          })
        Text('已驳回')
          .fontSize(14)
      }

      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#E5E5EA')
          .fontColor('#333')
          .onClick(() => {
            this.showHandleDialog = false
          })

        Button('确认处理')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.handleComplaint()
          })
      }
    }
    .width('80%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  @Builder
  CreditQueryDialog() {
    Column({ space: 15 }) {
      Text(`查询${this.creditType === 'guide' ? '导游' : '旅行社'}诚信信息`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      TextInput({ placeholder: `请输入${this.creditType === 'guide' ? '导游' : '旅行社'}ID` })
        .width('100%')
        .height(40)
        .onChange((value: string) => {
          this.creditId = parseInt(value) || 0
        })

      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#E5E5EA')
          .fontColor('#333')
          .onClick(() => {
            this.showCreditDialog = false
          })

        Button('查询')
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.queryCredit()
          })
      }
    }
    .width('80%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(10)
  }

  // ================================
  // 工具方法
  // ================================
  getStatusText(status: string): string {
    const statusMap: Record<string, string> = {
      '待处理': '待处理',
      '已办结': '已办结',
      '已驳回': '已驳回'
    }
    return statusMap[status] || status
  }

  getStatusColor(status: string): ResourceColor {
    const colorMap: Record<string, ResourceColor> = {
      '待处理': '#FF9500',
      '已办结': '#34C759',
      '已驳回': '#FF3B30'
    }
    return colorMap[status] || '#666'
  }

  getStatusBgColor(status: string): ResourceColor {
    const colorMap: Record<string, ResourceColor> = {
      '待处理': '#FFF4E5',
      '已办结': '#E8F7EB',
      '已驳回': '#FFEBEE'
    }
    return colorMap[status] || '#F5F5F5'
  }

  getCreditColor(score: number): ResourceColor {
    if (score >= 90) return '#34C759'
    if (score >= 70) return '#007DFF'
    if (score >= 60) return '#FF9500'
    return '#FF3B30'
  }

  // ================================
  // API调用方法（优化版）
  // ================================
  async loadComplaints() {
    this.loading = true
    try {
      const params: ComplaintQueryParams = {
        status: this.filterStatus || undefined,
        agencyId: this.filterAgencyId || undefined,
        guideId: this.filterGuideId || undefined
      }
      
      const result = await ComplaintApi.listComplaints(params)
      if (result.code === 200) {
        this.complaintList = result.data || []
      } else {
        prompt.showToast({ message: `加载失败: ${result.msg}`, duration: 3000 })
      }
    } catch (error) {
      prompt.showToast({ message: '网络错误，请检查连接', duration: 3000 })
      console.error('加载投诉列表失败:', error)
    }
    this.loading = false
  }

  async submitComplaint() {
    // 表单验证
    if (!this.newComplaint.title.trim()) {
      prompt.showToast({ message: '请输入投诉标题', duration: 3000 })
      return
    }
    if (!this.newComplaint.content.trim()) {
      prompt.showToast({ message: '请输入投诉内容', duration: 3000 })
      return
    }
    if (!this.newComplaint.complainant.trim()) {
      prompt.showToast({ message: '请输入投诉人', duration: 3000 })
      return
    }

    try {
      const result = await ComplaintApi.submitComplaint(this.newComplaint)
      if (result.code === 200) {
        prompt.showToast({ message: '投诉提交成功', duration: 3000 })
        this.loadComplaints()
        // 重置表单
        this.newComplaint = {
          title: '',
          content: '',
          complaintType: '导游',
          complainant: '',
          contactInfo: '',
          complaintTime: new Date().toISOString().split('T')[0],
          status: '待处理'
        } as ComplaintEntity
        this.selectedTab = 0 // 切换到列表页
      } else {
        prompt.showToast({ message: `提交失败: ${result.msg}`, duration: 3000 })
      }
    } catch (error) {
      prompt.showToast({ message: '提交失败，请重试', duration: 3000 })
      console.error('提交投诉失败:', error)
    }
  }

  async handleComplaint() {
    if (!this.handleRequest.handleUser.trim()) {
      prompt.showToast({ message: '请输入处理人', duration: 3000 })
      return
    }
    if (!this.handleRequest.handleResult.trim()) {
      prompt.showToast({ message: '请输入处理结果', duration: 3000 })
      return
    }

    try {
      const result = await ComplaintApi.handleComplaint(this.handleRequest)
      if (result.code === 200) {
        prompt.showToast({ message: '投诉处理成功', duration: 3000 })
        this.showHandleDialog = false
        this.loadComplaints()
      } else {
        prompt.showToast({ message: `处理失败: ${result.msg}`, duration: 3000 })
      }
    } catch (error) {
      prompt.showToast({ message: '处理失败，请重试', duration: 3000 })
      console.error('处理投诉失败:', error)
    }
  }

  async deleteComplaint(id: number) {
    try {
      const result = await ComplaintApi.deleteComplaint(id)
      if (result.code === 200) {
        prompt.showToast({ message: '删除成功', duration: 3000 })
        this.loadComplaints()
      } else {
        prompt.showToast({ message: `删除失败: ${result.msg}`, duration: 3000 })
      }
    } catch (error) {
      prompt.showToast({ message: '删除失败，请重试', duration: 3000 })
      console.error('删除投诉失败:', error)
    }
  }

  async queryCredit() {
    if (!this.creditId) {
      prompt.showToast({ message: '请输入ID', duration: 3000 })
      return
    }

    try {
      let result: Result<CreditInfo>
      if (this.creditType === 'guide') {
        result = await ComplaintApi.getGuideCredit(this.creditId)
      } else {
        result = await ComplaintApi.getAgencyCredit(this.creditId)
      }

      if (result.code === 200) {
        this.creditInfo = result.data
        this.showCreditDialog = false
      } else {
        prompt.showToast({ message: `查询失败: ${result.msg}`, duration: 3000 })
      }
    } catch (error) {
      prompt.showToast({ message: '查询失败，请重试', duration: 3000 })
      console.error('查询诚信信息失败:', error)
    }
  }
}