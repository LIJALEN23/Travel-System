package com.swu.tourismmanagesystem.entity.agency;
import lombok.Data;
import java.time.LocalDateTime;
@Data
public class TravelOrder {
    private Long id;                        // 行程单ID
    private Long agencyId;                  // 旅行社ID
    private Long vehicleId;                 // 车辆ID
    private Long driverId;                  // 驾驶员ID
    private Long guideId;                   // 带团导游ID
    private String teamName;                // 团队名称
    private Integer peopleCount;            // 出游人数
    private String startAddress;            // 出发地
    private String endAddress;              // 目的地
    private LocalDateTime startTime;        // 出发时间
    private String orderStatus;             // 行程状态
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}