package com.swu.tourismmanagesystem.entity.scenic;

import lombok.Data;
import java.time.LocalDateTime;
import java.math.BigDecimal;
@Data
public class ScenicSpot {
    private Long id;
    private String spotName;
    private Integer maxCapacity;
    private Integer totalParking;
    private String address;
    private BigDecimal longitude;
    private BigDecimal latitude;
    private String mapUrl;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
