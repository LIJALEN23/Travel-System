package com.swu.tourismmanagesystem.entity.agency;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class TourismVehicle {
    private Long id;
    private Long agencyId;
    private String plateNo;
    private String vehicleType;
    private Integer seatCount;
    private String vehicleStatus;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
