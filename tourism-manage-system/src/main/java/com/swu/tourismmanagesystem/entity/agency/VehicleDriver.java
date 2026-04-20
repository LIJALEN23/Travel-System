package com.swu.tourismmanagesystem.entity.agency;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class VehicleDriver {
    private Long id;
    private Long agencyId;
    private String driverName;
    private String phone;
    private String licenseType;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
