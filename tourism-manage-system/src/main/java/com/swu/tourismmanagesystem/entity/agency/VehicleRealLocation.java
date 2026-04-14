package com.swu.tourismmanagesystem.entity.agency;
import lombok.Data;
import java.time.LocalDateTime;
@Data
public class VehicleRealLocation {
    private Long id;
    private Long vehicleId;
    private Double longitude;  // 经度
    private Double latitude;   // 纬度
    private Integer speed;
    private String vehicleStatus;
    private LocalDateTime updateTime;
}
