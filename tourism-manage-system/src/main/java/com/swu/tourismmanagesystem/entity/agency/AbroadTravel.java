package com.swu.tourismmanagesystem.entity.agency;
import lombok.Data;
import java.time.LocalDateTime;
@Data
public class AbroadTravel {
    private Long id;
    private Long agencyId;
    private String teamName;
    private String country;
    private String visaStatus;
    private LocalDateTime applyTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
