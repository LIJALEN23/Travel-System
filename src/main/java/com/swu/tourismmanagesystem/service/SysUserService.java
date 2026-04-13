package com.swu.tourismmanagesystem.service;

import com.swu.tourismmanagesystem.entity.sys.SysUser;
import org.springframework.stereotype.Service;
import java.util.Map;
@Service
public interface SysUserService {
    // 注册
    Map<String, Object> register(SysUser user);

    // 登录
    Map<String, Object> login(String account, String password);
}
