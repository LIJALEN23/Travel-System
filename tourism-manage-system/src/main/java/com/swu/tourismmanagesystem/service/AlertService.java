package com.swu.tourismmanagesystem.service;

import com.swu.tourismmanagesystem.entity.alertmessage.*;
import java.util.List;

public interface AlertService {

    // ====================== 核心：自动监测所有实时数据 → 生成提示/告警 ======================
    void autoCheckAndGenerateMessage();
    // 生成提示/告警信息
    int createMessage(AlertMessage message);
    /**
     * 查询每个景区/酒店的最新未处理告警
     */
    List<AlertMessage> getLatestUnprocessedAlerts();
    // 根据ID查询
    AlertMessage getMessageById(Long id);

    // 查询所有消息
    List<AlertMessage> getMessageList();

    // 值班员审核通过（改为待发布）
    int checkPass(Long id, String operator);

    // 领导审批并发布（改为已发布）
    int publish(Long id, String leader);

    // 直接处置（无需发布，改为已处置 + 登记）
    int handle(Long id, String handleResult, String handler);

    // 查询处置记录
    List<AlertHandle> getHandleList(Long alertId);
}