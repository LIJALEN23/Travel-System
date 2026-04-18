package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.alertmessage.AlertHandle;
import com.swu.tourismmanagesystem.entity.alertmessage.AlertMessage;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AlertMessageMapper {

    // ====================== 基础方法 ======================
    int insertMessage(AlertMessage message);
    AlertMessage getMessageById(Long id);
    List<AlertMessage> getMessageList();
    int updateMessage(AlertMessage message);

    // ====================== 处置登记 ======================
    int insertHandle(AlertHandle handle);
    List<AlertHandle> getHandlesByAlertId(Long alertId);

    // ====================== 支持重复告警管控 ======================
    /**
     * 查询指定内容+类型+关联标识的未处理告警（status=0）
     * @param content 告警内容（如：成都青城山：车位紧张(86%)）
     * @param msgType 消息类型（如：prompt）
     * @param extInfo 关联标识（如：SCENE_1 / HOTEL_1）
     * @return 未处理的告警记录（无则返回null）
     */
    AlertMessage selectUnprocessedAlertByContentAndType(
            @Param("content") String content,
            @Param("msgType") String msgType,
            @Param("extInfo") String extInfo);

    /**
     * 可选：查询每个景区/酒店的最新未处理告警（前端展示用）
     * @return 各景区/酒店的最新告警列表
     */
    List<AlertMessage> selectLatestUnprocessedAlerts();
}