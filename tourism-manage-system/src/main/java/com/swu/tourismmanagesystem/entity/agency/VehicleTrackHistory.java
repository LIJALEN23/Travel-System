package com.swu.tourismmanagesystem.entity.agency;
import lombok.Data;
import java.time.LocalDateTime;
@Data
public class VehicleTrackHistory {
    private Long id;
    private Long vehicleId;
    private Double longitude;
    private Double latitude;
    private LocalDateTime createTime;
}
