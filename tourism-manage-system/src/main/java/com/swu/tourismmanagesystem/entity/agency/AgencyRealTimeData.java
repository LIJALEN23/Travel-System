package com.swu.tourismmanagesystem.entity.agency;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class AgencyRealTimeData {
    private Long id;
    private Long agencyId;
    private Integer todayTeams;
    private Integer todayPeople;
    private Integer onlineVehicles;
    private LocalDateTime updateTime;
}
