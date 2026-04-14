package com.swu.tourismmanagesystem.entity.guide;
import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class GuideQualification {
    private Long id;                        // 主键
    private Long guideId;                   // 导游ID
    private String qualificationNo;         // 资格证号
    private LocalDate issueDate;            // 发证日期
    private LocalDate expireDate;           // 到期日期
    private Integer checkStatus;            // 审核状态 0-待审核 1-通过 2-驳回
    private String checkRemark;             // 审核意见
    private LocalDateTime createTime;       // 创建时间
}