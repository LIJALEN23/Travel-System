package com.swu.tourismmanagesystem.entity.agency;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AgencyCredit {
    private Long id;
    private Long agencyId;          // 旅行社ID

    private Integer creditScore;    // 诚信分 100
    private Integer totalComplaint; // 总投诉
    private Integer normalComplaint;// 一般投诉
    private Integer badComplaint;   // 严重投诉

    private String creditDesc;      // 诚信评价

    private LocalDateTime updateTime;
}