package com.swu.tourismmanagesystem.entity.agency;
import lombok.Data;
import java.time.LocalDateTime;
@Data
public class TravelOrder {
    private Long id;
    private Long agencyId;
    private Long vehicleId;
    private Long driverId;
    private String teamName;
    private Integer peopleCount;
    private String startAddress;
    private String endAddress;
    private LocalDateTime startTime;
    private String orderStatus;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
