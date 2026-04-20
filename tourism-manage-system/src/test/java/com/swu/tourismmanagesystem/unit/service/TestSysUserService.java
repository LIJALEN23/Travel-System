package com.swu.tourismmanagesystem.unit.service;

import com.swu.tourismmanagesystem.entity.sys.SysUser;
import com.swu.tourismmanagesystem.mapper.SysUserMapper;
import com.swu.tourismmanagesystem.service.impl.SysUserServiceImpl;
import com.swu.tourismmanagesystem.utils.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TestSysUserService {

    @Mock
    private SysUserMapper mapper;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private SysUserServiceImpl sysUserService;

    private SysUser testUser;

    @BeforeEach
    void setUp() {
        testUser = new SysUser();
        testUser.setId(1L);
        testUser.setAccount("testuser");
        testUser.setPassword("encodedPassword");
        testUser.setRealName("测试用户");
        testUser.setRole("OPERATOR");
        testUser.setStatus(1);
    }

    // ==================== login 方法测试 ====================

    @Test
    void login_ShouldReturnError_WhenAccountOrPasswordIsEmpty() {
        // 账号为空
        Map<String, Object> result1 = sysUserService.login("", "123");
        assertThat(result1.get("code")).isEqualTo(500);
        assertThat(result1.get("msg")).isEqualTo("账号或密码不能为空");

        // 密码为空
        Map<String, Object> result2 = sysUserService.login("test", "");
        assertThat(result2.get("code")).isEqualTo(500);
        assertThat(result2.get("msg")).isEqualTo("账号或密码不能为空");

        // 两个都为空
        Map<String, Object> result3 = sysUserService.login(null, null);
        assertThat(result3.get("code")).isEqualTo(500);

        // 确保没有调用 mapper 和 encoder
        verifyNoInteractions(mapper, passwordEncoder, jwtUtil);
    }

    @Test
    void login_ShouldReturnError_WhenUserNotFound() {
        when(mapper.selectByAccount("unknown")).thenReturn(null);

        Map<String, Object> result = sysUserService.login("unknown", "pwd");

        assertThat(result.get("code")).isEqualTo(500);
        assertThat(result.get("msg")).isEqualTo("账号不存在");
        verify(mapper).selectByAccount("unknown");
        verify(passwordEncoder, never()).matches(anyString(), anyString());
        verify(jwtUtil, never()).createToken(anyString());
    }

    @Test
    void login_ShouldReturnError_WhenPasswordMismatch() {
        when(mapper.selectByAccount("testuser")).thenReturn(testUser);
        when(passwordEncoder.matches("wrong", testUser.getPassword())).thenReturn(false);

        Map<String, Object> result = sysUserService.login("testuser", "wrong");

        assertThat(result.get("code")).isEqualTo(500);
        assertThat(result.get("msg")).isEqualTo("密码错误");
        verify(mapper).selectByAccount("testuser");
        verify(passwordEncoder).matches("wrong", testUser.getPassword());
        verify(jwtUtil, never()).createToken(anyString());
    }

    @Test
    void login_ShouldReturnSuccess_WhenCredentialsAreValid() {
        when(mapper.selectByAccount("testuser")).thenReturn(testUser);
        when(passwordEncoder.matches("correct", testUser.getPassword())).thenReturn(true);
        when(jwtUtil.createToken("testuser")).thenReturn("fake-jwt-token");

        Map<String, Object> result = sysUserService.login("testuser", "correct");

        assertThat(result.get("code")).isEqualTo(200);
        assertThat(result.get("msg")).isEqualTo("登录成功");
        assertThat(result.get("data")).isNotNull();

        Map<String, Object> data = (Map<String, Object>) result.get("data");
        assertThat(data.get("token")).isEqualTo("fake-jwt-token");
        SysUser returnedUser = (SysUser) data.get("user");
        assertThat(returnedUser.getPassword()).isNull();  // 密码应该被清空
        assertThat(returnedUser.getAccount()).isEqualTo("testuser");

        verify(mapper).selectByAccount("testuser");
        verify(passwordEncoder).matches("correct", testUser.getPassword());
        verify(jwtUtil).createToken("testuser");
    }

    // ==================== register 方法测试 ====================

    @Test
    void register_ShouldReturnError_WhenRequiredFieldsMissing() {
        SysUser invalidUser = new SysUser();
        // 缺少账号
        invalidUser.setPassword("123");
        invalidUser.setRealName("张三");
        Map<String, Object> result1 = sysUserService.register(invalidUser);
        assertThat(result1.get("code")).isEqualTo(500);
        assertThat(result1.get("msg")).isEqualTo("账号、密码、真实姓名不能为空");

        // 缺少密码
        invalidUser = new SysUser();
        invalidUser.setAccount("test");
        invalidUser.setRealName("张三");
        Map<String, Object> result2 = sysUserService.register(invalidUser);
        assertThat(result2.get("code")).isEqualTo(500);

        // 缺少真实姓名
        invalidUser = new SysUser();
        invalidUser.setAccount("test");
        invalidUser.setPassword("123");
        Map<String, Object> result3 = sysUserService.register(invalidUser);
        assertThat(result3.get("code")).isEqualTo(500);

        verifyNoInteractions(mapper, passwordEncoder, jwtUtil);
    }

    @Test
    void register_ShouldReturnError_WhenAccountAlreadyExists() {
        when(mapper.selectByAccount("existing")).thenReturn(testUser);

        SysUser newUser = new SysUser();
        newUser.setAccount("existing");
        newUser.setPassword("pwd");
        newUser.setRealName("李四");

        Map<String, Object> result = sysUserService.register(newUser);

        assertThat(result.get("code")).isEqualTo(500);
        assertThat(result.get("msg")).isEqualTo("账号已存在");
        verify(mapper).selectByAccount("existing");
        verify(mapper, never()).insertUser(any());
        verify(passwordEncoder, never()).encode(anyString());
    }

    @Test
    void register_ShouldSetDefaultRoleAndStatus_WhenNotProvided() {
        when(mapper.selectByAccount("newuser")).thenReturn(null);
        when(passwordEncoder.encode("rawPassword")).thenReturn("encodedPwd");
        when(mapper.insertUser(any(SysUser.class))).thenAnswer(invocation -> {
            SysUser user = invocation.getArgument(0);
            user.setId(2L);  // 模拟自增 ID 回填
            return 1;
        });

        SysUser newUser = new SysUser();
        newUser.setAccount("newuser");
        newUser.setPassword("rawPassword");
        newUser.setRealName("新用户");
        // 不设置 role 和 status

        Map<String, Object> result = sysUserService.register(newUser);

        assertThat(result.get("code")).isEqualTo(200);
        assertThat(result.get("msg")).isEqualTo("注册成功");
        SysUser savedUser = (SysUser) result.get("data");
        assertThat(savedUser.getPassword()).isNull();  // 返回时密码清空
        assertThat(savedUser.getRole()).isEqualTo("OPERATOR");
        assertThat(savedUser.getStatus()).isEqualTo(1);
        assertThat(savedUser.getId()).isEqualTo(2L);

        verify(mapper).selectByAccount("newuser");
        verify(passwordEncoder).encode("rawPassword");
        verify(mapper).insertUser(any(SysUser.class));
    }

    @Test
    void register_ShouldKeepProvidedRoleAndStatus() {
        when(mapper.selectByAccount("newuser2")).thenReturn(null);
        when(passwordEncoder.encode("pwd")).thenReturn("encoded");
        when(mapper.insertUser(any(SysUser.class))).thenReturn(1);

        SysUser newUser = new SysUser();
        newUser.setAccount("newuser2");
        newUser.setPassword("pwd");
        newUser.setRealName("用户2");
        newUser.setRole("ADMIN");
        newUser.setStatus(0);

        Map<String, Object> result = sysUserService.register(newUser);

        assertThat(result.get("code")).isEqualTo(200);
        SysUser savedUser = (SysUser) result.get("data");
        assertThat(savedUser.getRole()).isEqualTo("ADMIN");
        assertThat(savedUser.getStatus()).isEqualTo(0);
    }

    @Test
    void register_ShouldReturnError_WhenInsertFails() {
        when(mapper.selectByAccount("failuser")).thenReturn(null);
        when(passwordEncoder.encode("pwd")).thenReturn("encoded");
        when(mapper.insertUser(any(SysUser.class))).thenReturn(0);  // 插入失败

        SysUser newUser = new SysUser();
        newUser.setAccount("failuser");
        newUser.setPassword("pwd");
        newUser.setRealName("失败用户");

        Map<String, Object> result = sysUserService.register(newUser);

        assertThat(result.get("code")).isEqualTo(500);
        assertThat(result.get("msg")).isEqualTo("注册失败");
        assertThat(result.get("data")).isNull();
    }
}