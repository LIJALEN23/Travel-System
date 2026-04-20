package com.swu.tourismmanagesystem.entity.agency;
import lombok.Data;
import java.time.LocalDateTime;
import java.math.BigDecimal;
@Data
public class VehicleRealLocation {
    private Long id;
    private Long vehicleId;
    private BigDecimal longitude;  // 经度
    private BigDecimal latitude;   // 纬度
    private Integer speed;
    private String vehicleStatus;
    private LocalDateTime updateTime;
}
