package com.swu.tourismmanagesystem.entity.agency;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class AgencyManager {
    private Long id;
    private Long agencyId;
    private String workNo;
    private String managerName;
    private String phone;
    private String post;
    private Integer status;
    private LocalDateTime createTime;
}
