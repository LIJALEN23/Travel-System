package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.sys.SysUser;
import com.swu.tourismmanagesystem.service.SysUserService;
import com.swu.tourismmanagesystem.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
@RestController
@RequestMapping("/user")
public class SysUserController {
    @Autowired
    private SysUserService sysUserService;

    // 登录接口
    @PostMapping("/login")
    public Result login(@RequestBody SysUser user) {
        Map<String, Object> loginResult = sysUserService.login(user.getAccount(), user.getPassword());
        if ((Integer) loginResult.get("code") == 200) {
            return Result.success((String) loginResult.get("msg"), loginResult.get("data"));
        } else {
            return Result.error((String) loginResult.get("msg"));
        }
    }

    // 注册接口
    @PostMapping("/register")
    public Result register(@RequestBody SysUser user) {
        Map<String, Object> registerResult = sysUserService.register(user);
        if ((Integer) registerResult.get("code") == 200) {
            return Result.success((String) registerResult.get("msg"), registerResult.get("data"));
        } else {
            return Result.error((String) registerResult.get("msg"));
        }
    }
}
