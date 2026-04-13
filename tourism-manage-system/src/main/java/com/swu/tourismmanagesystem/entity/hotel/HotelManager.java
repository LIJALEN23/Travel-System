package com.swu.tourismmanagesystem.entity.hotel;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class HotelManager {
    private Long id;
    private Long hotelId;
    private String workNo;
    private String managerName;
    private String phone;
    private String post;
    private Integer status;
    private LocalDateTime createTime;
}