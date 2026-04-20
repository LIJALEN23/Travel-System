package com.swu.tourismmanagesystem.entity.guide;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class GuideCredit {
    private Long id;
    private Long guideId;           // 导游ID

    private Integer creditScore;    // 诚信分
    private Integer totalComplaint; // 总投诉
    private Integer badComplaint;   // 严重投诉数

    private String creditDesc;      // 评价
    private LocalDateTime updateTime;

    // 计算得出的诚信等级，不对应数据库字段
    private String creditLevel;
}
