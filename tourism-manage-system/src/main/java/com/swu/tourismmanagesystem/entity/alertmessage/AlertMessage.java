package com.swu.tourismmanagesystem.entity.alertmessage;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AlertMessage {

    private Long id;

    // 消息类型：prompt=提示信息（景区/车位/酒店/缆车），alert=告警信息（轨迹偏离）
    private String msgType;

    // 当前问题描述（你要的：显示当前问题）
    private String content;

    // 状态：0=待审核 1=待发布 2=已发布 3=已处置
    private Integer status;

    // 值班员
    private String operator;

    // 审批领导
    private String leader;

    // 创建时间 & 更新时间
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}