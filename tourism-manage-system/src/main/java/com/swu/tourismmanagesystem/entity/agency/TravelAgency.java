package com.swu.tourismmanagesystem.entity.agency;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class TravelAgency {
    private Long id;
    private String agencyName;
    private String licenseNo;
    private String creditLevel;
    private String address;
    private String contactPhone;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
