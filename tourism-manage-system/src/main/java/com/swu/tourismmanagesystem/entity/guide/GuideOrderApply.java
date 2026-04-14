package com.swu.tourismmanagesystem.entity.guide;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class GuideOrderApply {
    private Long id;                        // 申领ID
    private Long guideId;                   // 申领导游ID
    private Long agencyId;                  // 旅行社ID
    private Integer applyStatus;            // 0-待审批 1-通过 2-拒绝
    private String applyReason;             // 申领原因
    private LocalDateTime createTime;       // 申请时间
    private LocalDateTime updateTime;       // 审批时间
}