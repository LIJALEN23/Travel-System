package com.swu.tourismmanagesystem.entity.hotel;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class HotelRealTimeData {
    private Long id;
    private Long hotelId;
    private Integer currentVisitors;
    private Integer remainingParking;
    private Double occupancyRate;
    private LocalDateTime updateTime;
}
