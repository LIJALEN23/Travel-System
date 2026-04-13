package com.swu.tourismmanagesystem.entity.sys;
import lombok.Data;
import java.time.LocalDateTime;
@Data
public class SysUser {
    // 主键ID
    private Long id;

    // 登录账号
    private String account;

    // 登录密码
    private String password;

    // 真实姓名（对应数据库 real_name）
    private String realName;

    // 手机号
    private String phone;

    // 邮箱
    private String email;

    // 角色（对应数据库 role，默认 OPERATOR）
    private String role;

    // 状态（对应数据库 status，tinyint 类型，用 Integer 接收）
    private Integer status;

    // 创建时间（对应数据库 create_time）
    private LocalDateTime createTime;

    // 更新时间（对应数据库 update_time）
    private LocalDateTime updateTime;

    // 备注
    private String remark;
}
