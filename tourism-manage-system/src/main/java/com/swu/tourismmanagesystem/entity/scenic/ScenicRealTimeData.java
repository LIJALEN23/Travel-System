package com.swu.tourismmanagesystem.entity.scenic;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class ScenicRealTimeData {
    private Long id;
    private Long spotId;                // 景区ID（对应数据库spot_id）
    private Integer currentVisitors;    // 当前游客数（对应数据库current_visitor）
    private Integer remainingParking;   // 剩余车位（对应数据库remain_parking）
    private Integer cableWaitTime;      // 缆车等待时间（对应数据库wait_time）
    private LocalDateTime updateTime;            // 改为Date，匹配NOW()返回值
}

