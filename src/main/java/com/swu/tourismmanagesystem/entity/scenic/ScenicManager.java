package com.swu.tourismmanagesystem.entity.scenic;

import lombok.Data;
import java.time.LocalDateTime;
@Data
public class ScenicManager {
    private Long id;
    private Long spotId;
    private String workNo;
    private String managerName;
    private String phone;
    private String post;
    private Integer status;
    private LocalDateTime createTime;
}
