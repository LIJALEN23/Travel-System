package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.sys.SysUser;
import org.apache.ibatis.annotations.Mapper;
@Mapper
public interface SysUserMapper {
    //根据账户 登录
    SysUser selectByAccount(String account);

    //注册
    int insertUser(SysUser user);
}
