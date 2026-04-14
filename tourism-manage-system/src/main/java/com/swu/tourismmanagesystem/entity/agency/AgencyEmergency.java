package com.swu.tourismmanagesystem.entity.agency;
import lombok.Data;
import java.time.LocalDateTime;
@Data
public class AgencyEmergency {
    private Long id;
    private Long agencyId;
    private String rescuerName;
    private String rescuerPhone;
    private String vehicleNo;
    private LocalDateTime createTime;
}
