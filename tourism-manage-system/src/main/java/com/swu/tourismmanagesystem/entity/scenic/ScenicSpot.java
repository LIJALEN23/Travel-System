package com.swu.tourismmanagesystem.entity.scenic;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class ScenicSpot {
    private Long id;
    private String spotName;
    private Integer maxCapacity;
    private Integer totalParking;
    private String address;
    private Double longitude;
    private Double latitude;
    private String mapUrl;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
