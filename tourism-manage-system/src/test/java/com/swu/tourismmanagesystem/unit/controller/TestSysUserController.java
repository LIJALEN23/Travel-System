package com.swu.tourismmanagesystem.unit.controller;

import com.swu.tourismmanagesystem.controller.SysUserController;
import com.swu.tourismmanagesystem.entity.sys.SysUser;
import com.swu.tourismmanagesystem.service.SysUserService;
import com.swu.tourismmanagesystem.utils.Result;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.stubbing.Answer;
import org.mockito.stubbing.Stubbing;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * SysUserController 单元测试
 * 使用 Mock 模拟 SysUserService 服务层，避免数据库依赖
 */
@ExtendWith(MockitoExtension.class)
class TestSysUserController {

    @Mock
    private SysUserService sysUserService;

    private SysUserController sysUserController;

    @BeforeEach
    void setUp() {
        // 创建 Controller 实例
        sysUserController = new SysUserController();
        // 注入 Mock 的服务
        ReflectionTestUtils.setField(sysUserController, "sysUserService", sysUserService);
    }

    /**
     * 测试正常登录场景
     */
    @Test
    @DisplayName("正常登录应成功")
    void testLoginSuccess() {
        SysUser user = new SysUser();
        user.setAccount("testuser");
        user.setPassword("password123");

        // 模拟登录成功
        Map<String, Object> loginResult = new HashMap<>();
        loginResult.put("code", 200);
        loginResult.put("msg", "登录成功");
        loginResult.put("data", user);
        when(sysUserService.login("testuser", "password123")).thenReturn(loginResult);

        // 执行登录
        Result result = sysUserController.login(user);

        // 验证
        assertEquals(200, result.getCode(), "登录应成功");
        assertEquals("登录成功", result.getMsg());
        assertEquals(user, result.getData());
        verify(sysUserService).login("testuser", "password123");
    }

    /**
     * 测试密码错误登录场景
     */
    @Test
    @DisplayName("密码错误应返回失败")
    void testLoginFailedWithWrongPassword() {
        SysUser user = new SysUser();
        user.setAccount("testuser");
        user.setPassword("wrongpassword");

        // 模拟登录失败
        Map<String, Object> loginResult = new HashMap<>();
        loginResult.put("code", 500);
        loginResult.put("msg", "密码错误");
        loginResult.put("data", null);
        when(sysUserService.login("testuser", "wrongpassword")).thenReturn(loginResult);

        // 执行登录
        Result result = sysUserController.login(user);

        // 验证
        assertEquals(500, result.getCode(), "密码错误应返回失败");
        assertEquals("密码错误", result.getMsg());
        verify(sysUserService).login("testuser", "wrongpassword");
    }

    /**
     * 测试空账号登录场景
     */
    @Test
    @DisplayName("空账号应返回失败")
    void testLoginWithEmptyAccount() {
        SysUser user = new SysUser();
        user.setAccount("");
        user.setPassword("password123");

        // 模拟登录失败
        Map<String, Object> loginResult = new HashMap<>();
        loginResult.put("code", 500);
        loginResult.put("msg", "账号不能为空");
        loginResult.put("data", null);
        when(sysUserService.login("", "password123")).thenReturn(loginResult);

        // 执行登录
        Result result = sysUserController.login(user);

        // 验证
        assertEquals(500, result.getCode(), "空账号应返回失败");
        verify(sysUserService).login("", "password123");
    }

    /**
     * 测试空密码登录场景
     */
    @Test
    @DisplayName("空密码应返回失败")
    void testLoginWithEmptyPassword() {
        SysUser user = new SysUser();
        user.setAccount("testuser");
        user.setPassword("");

        // 模拟登录失败
        Map<String, Object> loginResult = new HashMap<>();
        loginResult.put("code", 500);
        loginResult.put("msg", "密码不能为空");
        loginResult.put("data", null);
        when(sysUserService.login("testuser", "")).thenReturn(loginResult);

        // 执行登录
        Result result = sysUserController.login(user);

        // 验证
        assertEquals(500, result.getCode(), "空密码应返回失败");
        verify(sysUserService).login("testuser", "");
    }

    /**
     * 测试正常注册场景
     */
    @Test
    @DisplayName("正常注册应成功")
    void testRegisterSuccess() {
        SysUser user = new SysUser();
        user.setAccount("newuser");
        user.setPassword("password456");

        // 模拟注册成功
        Map<String, Object> registerResult = new HashMap<>();
        registerResult.put("code", 200);
        registerResult.put("msg", "注册成功");
        registerResult.put("data", user);
        when(sysUserService.register(any(SysUser.class))).thenReturn(registerResult);

        // 执行注册
        Result result = sysUserController.register(user);

        // 验证
        assertEquals(200, result.getCode(), "注册应成功");
        assertEquals("注册成功", result.getMsg());
        assertNotNull(user, "应返回用户信息");
        verify(sysUserService).register(any(SysUser.class));
    }

//    /**
//     * 测试重复注册场景
//     */
//    @Test
//    @DisplayName("重复注册应返回失败")
//    void testRegisterDuplicateAccount() {
//        SysUser user = new SysUser();
//        user.setAccount("testuser");
//        user.setPassword("password123");
//
//        // 模拟第一次注册成功，第二次注册失败
//        Map<String, Object> successResult = new HashMap<>();
//        successResult.put("code", 200);
//        successResult.put("msg", "注册成功");
//        successResult.put("data", user);
//
//        Map<String, Object> failResult = new HashMap<>();
//        failResult.put("code", 500);
//        failResult.put("msg", "账号已存在");
//        failResult.put("data", null);
//
//        // 使用 thenAnswer 模拟两次不同的结果
//        Stubbing successStub = when(sysUserService.register(user))
//            .thenAnswer(invocation -> {
//                // 第一次调用返回成功
//                return successResult;
//            });
//
//        Stubbing failStub = when(sysUserService.register(user))
//            .thenAnswer(invocation -> {
//                // 第二次调用返回失败
//                return failResult;
//            });
//
//        // 应用 stubs
//        when(sysUserService.register(user)).thenReturn(successResult);
//        when(sysUserService.register(user)).thenReturn(failResult);
//
//        // 第一次注册
//        Result result1 = sysUserController.register(user);
//        assertEquals(200, result1.getCode(), "第一次注册应成功");
//
//        // 第二次注册
//        Result result2 = sysUserController.register(user);
//        assertEquals(500, result2.getCode(), "重复注册应失败");
//
//        // 验证两次调用
//        verify(sysUserService, times(2)).register(user);
//    }

    /**
     * 测试特殊字符账号注册场景
     */
    @Test
    @DisplayName("特殊字符账号注册应成功")
    void testRegisterWithSpecialCharacters() {
        SysUser user = new SysUser();
        user.setAccount("user_123_test");
        user.setPassword("pass@word#123");

        // 模拟注册成功
        Map<String, Object> registerResult = new HashMap<>();
        registerResult.put("code", 200);
        registerResult.put("msg", "注册成功");
        registerResult.put("data", user);
        when(sysUserService.register(any(SysUser.class))).thenReturn(registerResult);

        // 执行注册
        Result result = sysUserController.register(user);

        // 验证
        assertEquals(200, result.getCode(), "特殊字符账号注册应成功");
        verify(sysUserService).register(any(SysUser.class));
    }

    /**
     * 测试管理员账号注册场景
     */
    @Test
    @DisplayName("管理员账号注册应成功")
    void testRegisterAdminRole() {
        SysUser user = new SysUser();
        user.setAccount("admin");
        user.setPassword("admin123");
        user.setRole("ADMIN");

        // 模拟注册成功
        Map<String, Object> registerResult = new HashMap<>();
        registerResult.put("code", 200);
        registerResult.put("msg", "注册成功");
        registerResult.put("data", user);
        when(sysUserService.register(any(SysUser.class))).thenReturn(registerResult);

        // 执行注册
        Result result = sysUserController.register(user);

        // 验证
        assertEquals(200, result.getCode(), "管理员账号注册应成功");
        assertEquals("ADMIN", user.getRole());
        verify(sysUserService).register(any(SysUser.class));
    }

    /**
     * 测试登录未提供账号场景
     */
    @Test
    @DisplayName("未提供账号应返回失败")
    void testLoginWithoutAccount() {
        SysUser user = new SysUser();
        user.setAccount(null);
        user.setPassword("password123");

        // 模拟登录失败
        Map<String, Object> loginResult = new HashMap<>();
        loginResult.put("code", 500);
        loginResult.put("msg", "账号不能为空");
        loginResult.put("data", null);
        when(sysUserService.login(null, "password123")).thenReturn(loginResult);

        // 执行登录
        Result result = sysUserController.login(user);

        // 验证
        assertEquals(500, result.getCode(), "未提供账号应返回失败");
        verify(sysUserService).login(null, "password123");
    }

    /**
     * 测试登录未提供密码场景
     */
    @Test
    @DisplayName("未提供密码应返回失败")
    void testLoginWithoutPassword() {
        SysUser user = new SysUser();
        user.setAccount("testuser");
        user.setPassword(null);

        // 模拟登录失败
        Map<String, Object> loginResult = new HashMap<>();
        loginResult.put("code", 500);
        loginResult.put("msg", "密码不能为空");
        loginResult.put("data", null);
        when(sysUserService.login("testuser", null)).thenReturn(loginResult);

        // 执行登录
        Result result = sysUserController.login(user);

        // 验证
        assertEquals(500, result.getCode(), "未提供密码应返回失败");
        verify(sysUserService).login("testuser", null);
    }

    /**
     * 测试注册未提供账号场景
     */
    @Test
    @DisplayName("注册未提供账号应返回失败")
    void testRegisterWithoutAccount() {
        SysUser user = new SysUser();
        user.setAccount(null);
        user.setPassword("password123");

        // 模拟注册失败
        Map<String, Object> registerResult = new HashMap<>();
        registerResult.put("code", 500);
        registerResult.put("msg", "账号不能为空");
        registerResult.put("data", null);
        when(sysUserService.register(any(SysUser.class))).thenReturn(registerResult);

        // 执行注册
        Result result = sysUserController.register(user);

        // 验证
        assertEquals(500, result.getCode(), "注册未提供账号应返回失败");
        verify(sysUserService).register(any(SysUser.class));
    }

    /**
     * 测试注册未提供密码场景
     */
    @Test
    @DisplayName("注册未提供密码应返回失败")
    void testRegisterWithoutPassword() {
        SysUser user = new SysUser();
        user.setAccount("testuser");
        user.setPassword(null);

        // 模拟注册失败
        Map<String, Object> registerResult = new HashMap<>();
        registerResult.put("code", 500);
        registerResult.put("msg", "密码不能为空");
        registerResult.put("data", null);
        when(sysUserService.register(any(SysUser.class))).thenReturn(registerResult);

        // 执行注册
        Result result = sysUserController.register(user);

        // 验证
        assertEquals(500, result.getCode(), "注册未提供密码应返回失败");
        verify(sysUserService).register(any(SysUser.class));
    }
}
