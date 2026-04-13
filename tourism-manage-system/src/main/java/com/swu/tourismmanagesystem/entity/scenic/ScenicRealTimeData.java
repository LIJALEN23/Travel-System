package com.swu.tourismmanagesystem.entity.scenic;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class ScenicRealTimeData {
    private Long id;
    private Long spotId;
    private Integer currentVisitors;
    private Integer remainingParking;
    private Integer cableWaitTime;
    private LocalDateTime updateTime;
}

