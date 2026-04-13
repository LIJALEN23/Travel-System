package com.swu.tourismmanagesystem.entity.scenic;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class ScenicEmergency {
    private Long id;
    private Long spotId;
    private String rescuerName;
    private String rescuerPhone;
    private String vehicleNo;
    private LocalDateTime createTime;

}
