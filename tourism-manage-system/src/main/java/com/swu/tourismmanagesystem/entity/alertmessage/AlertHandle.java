package com.swu.tourismmanagesystem.entity.alertmessage;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AlertHandle {

    private Long id;

    // 关联告警/提示消息ID（逻辑关联，无物理外键）
    private Long alertId;

    // 处理结果
    private String handleResult;

    // 处理人
    private String handler;

    // 处理时间
    private LocalDateTime handleTime;
}