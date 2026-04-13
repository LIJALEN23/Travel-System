package com.swu.tourismmanagesystem.entity.hotel;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class HotelEmergency {
    private Long id;
    private Long hotelId;
    private String rescuerName;
    private String rescuerPhone;
    private String vehicleNo;
    private LocalDateTime createTime;
}