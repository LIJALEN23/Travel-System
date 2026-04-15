package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.alertmessage.*;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;
@Mapper
public interface AlertMessageMapper {

    // ====================== 告警/提示信息 ======================
    int insertMessage(AlertMessage message);
    AlertMessage getMessageById(Long id);
    List<AlertMessage> getMessageList();
    int updateMessage(AlertMessage message);

    // ====================== 处置登记 ======================
    int insertHandle(AlertHandle handle);
    List<AlertHandle> getHandlesByAlertId(Long alertId);
}