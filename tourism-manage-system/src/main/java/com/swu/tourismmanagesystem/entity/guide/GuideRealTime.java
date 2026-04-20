package com.swu.tourismmanagesystem.entity.guide;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class GuideRealTime {
    private Long id;                        // 主键
    private Long guideId;                   // 导游ID
    private Long orderId;                   // 当前行程单ID
    private Integer teamSize;               // 当前带团人数
    private BigDecimal longitude;           // 经度
    private BigDecimal latitude;            // 纬度
    private String workStatus;              // 工作状态 空闲/带团中/休息
    private LocalDateTime updateTime;       // 更新时间
}