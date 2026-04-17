package com.swu.tourismmanagesystem.entity.complaint;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Complaint {
    private Long id;
    private String complaintNo;    // 投诉单号

    // 投诉人
    private String visitorName;    // 游客姓名
    private String visitorPhone;   // 游客电话

    // 投诉内容
    private String title;          // 标题
    private String content;        // 详情

    // 被投诉对象
    private Long agencyId;         // 旅行社ID
    private Long guideId;          // 导游ID

    // 投诉等级
    private String level;          // 一般/较重/严重

    // 首问负责
    private String handleUser;     // 处理人
    private String handleResult;   // 处理结果


    private LocalDateTime handleTime;       // 处理时间

    // 状态
    private String status;         // 待处理/处理中/已办结/驳回


    private LocalDateTime createTime;


    private LocalDateTime updateTime;
}