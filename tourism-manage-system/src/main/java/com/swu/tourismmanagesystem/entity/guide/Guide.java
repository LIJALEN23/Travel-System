package com.swu.tourismmanagesystem.entity.guide;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Guide {
    private Long id;                    // 导游ID
    private Long agencyId;              // 所属旅行社ID（NULL=待业）
    private String name;                // 姓名
    private String gender;              // 性别
    private Integer age;                // 年龄
    private String idCard;              // 身份证号
    private String phone;               // 联系电话
    private String guideLevel;          // 导游等级
    private Integer workStatus;         // 执业状态 0-待业 1-在职 2-冻结
    private LocalDateTime createTime;   // 创建时间
    private LocalDateTime updateTime;   // 更新时间
}
