package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.mapper.SysUserMapper;
import com.swu.tourismmanagesystem.entity.sys.SysUser;
import com.swu.tourismmanagesystem.service.SysUserService;
import com.swu.tourismmanagesystem.utils.JwtUtil;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.Map;

@Service
public class SysUserServiceImpl implements SysUserService {

    @Autowired
    private SysUserMapper mapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public Map<String, Object> login(String account, String password) {
        Map<String, Object> resultMap = new HashMap<>();

        // 1. 参数校验
        if (!StringUtils.hasText(account) || !StringUtils.hasText(password)) {
            resultMap.put("code", 500);
            resultMap.put("msg", "账户或密码不能为空");
            resultMap.put("data", null);
            return resultMap;
        }

        // 2. 查询用户
        SysUser sysUser = mapper.selectByAccount(account);
        if (sysUser == null) {
            resultMap.put("code", 500);
            resultMap.put("msg", "账户不存在");
            resultMap.put("data", null);
            return resultMap;
        }

        // 3. 密码校验
        if (!passwordEncoder.matches(password, sysUser.getPassword())) {
            resultMap.put("code", 500);
            resultMap.put("msg", "密码错误");
            resultMap.put("data", null);
            return resultMap;
        }

        // 4. 生成JWT令牌
        String token = jwtUtil.createToken(account);

        // 5. 构建返回数据（隐藏密码）
        sysUser.setPassword(null);
        resultMap.put("code", 200);
        resultMap.put("msg", "登录成功");
        Map<String, Object> data = new HashMap<>();
        data.put("user", sysUser);
        data.put("token", token);
        resultMap.put("data", data);

        return resultMap;
    }

    @Override
    public Map<String, Object> register(SysUser user) {
        Map<String, Object> resultMap = new HashMap<>();

        // 1. 必传参数校验（严格匹配数据库非空约束）
        if (!StringUtils.hasText(user.getAccount()) || !StringUtils.hasText(user.getPassword())
                || !StringUtils.hasText(user.getRealName())) {
            resultMap.put("code", 500);
            resultMap.put("msg", "账号、密码、真实姓名不能为空");
            resultMap.put("data", null);
            return resultMap;
        }

        // 2. 检查账户是否已存在
        SysUser existUser = mapper.selectByAccount(user.getAccount());
        if (existUser != null) {
            resultMap.put("code", 500);
            resultMap.put("msg", "账户已存在");
            resultMap.put("data", null);
            return resultMap;
        }

        // 3. 密码加密
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // 4. 补充默认值（适配数据库默认值，避免空值）
        if (!StringUtils.hasText(user.getRole())) {
            user.setRole("OPERATOR"); // 匹配数据库默认值
        }
        if (user.getStatus() == null) {
            user.setStatus(1); // 匹配数据库默认值 1-正常
        }

        // 5. 插入数据库（create_time/update_time 由数据库自动生成）
        int insertResult = mapper.insertUser(user);
        if (insertResult > 0) {
            resultMap.put("code", 200);
            resultMap.put("msg", "注册成功");
            user.setPassword(null); // 隐藏密码
            resultMap.put("data", user);
        } else {
            resultMap.put("code", 500);
            resultMap.put("msg", "注册失败");
            resultMap.put("data", null);
        }

        return resultMap;
    }
}