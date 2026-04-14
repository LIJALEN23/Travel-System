package com.swu.tourismmanagesystem.entity.guide;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class GuideJobApply {
    private Long id;
    private Long guideId;
    private Long agencyId;
    private Integer applyStatus;    // 0-待审核 1-录用 2-未录用
    private String applyRemark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}