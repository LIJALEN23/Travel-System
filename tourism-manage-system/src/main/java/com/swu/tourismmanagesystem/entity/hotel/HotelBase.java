package com.swu.tourismmanagesystem.entity.hotel;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class HotelBase {
    private Long id;
    private String hotelName;
    private Integer starLevel;
    private Integer maxCapacity;
    private Integer totalParking;
    private String address;
    private Double longitude;
    private Double latitude;
    private String mapUrl;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}