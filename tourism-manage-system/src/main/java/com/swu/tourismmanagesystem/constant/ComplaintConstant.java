package com.swu.tourismmanagesystem.constant;

/**
 * 投诉/诚信相关常量（最终版：适配你的Mapper+实体）
 */
public class ComplaintConstant {
    // 投诉等级（对应你的Complaint实体level字段：一般/较重/严重）
    public static final String COMPLAINT_LEVEL_NORMAL = "一般";    // 扣10分
    public static final String COMPLAINT_LEVEL_HEAVY = "较重";     // 扣30分
    public static final String COMPLAINT_LEVEL_SERIOUS = "严重";   // 扣50分

    // 投诉状态（对应你的Complaint实体status字段）
    public static final String STATUS_PENDING = "待处理";    // 初始状态
    public static final String STATUS_HANDLING = "处理中";   // 处理中
    public static final String STATUS_DONE = "已办结";       // 处理完成（扣分）
    public static final String STATUS_REJECT = "驳回";       // 驳回（不扣分）

    // 诚信分初始值
    public static final int INIT_CREDIT_SCORE = 100;

    // 旅行社诚信等级（对应你的TravelAgency实体creditLevel字段）
    public static final String CREDIT_LEVEL_A = "A"; // 90-100分
    public static final String CREDIT_LEVEL_B = "B"; // 70-89分
    public static final String CREDIT_LEVEL_C = "C"; // 50-69分
    public static final String CREDIT_LEVEL_D = "D"; // <50分

    // 导游执业状态（对应你的Guide实体workStatus字段：2=冻结）
    public static final int GUIDE_STATUS_FREEZE = 2;
    public static final int GUIDE_STATUS_NORMAL = 0;
}