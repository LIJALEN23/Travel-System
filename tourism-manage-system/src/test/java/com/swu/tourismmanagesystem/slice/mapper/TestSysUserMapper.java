package com.swu.tourismmanagesystem.slice.mapper;

import com.swu.tourismmanagesystem.entity.sys.SysUser;
import com.swu.tourismmanagesystem.mapper.SysUserMapper;
import org.junit.jupiter.api.Test;
import org.mybatis.spring.boot.test.autoconfigure.MybatisTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.test.context.jdbc.Sql;

import java.time.LocalDateTime;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;

@MybatisTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.ANY)
public class TestSysUserMapper {
    @Autowired
    private SysUserMapper sysUserMapper;

    @Test
    void testInsertUser() {
        // 准备一个用户实体
        SysUser user = new SysUser();
        user.setAccount("test001");
        user.setPassword("123456");
        user.setRealName("测试员");
        user.setPhone("13800000000");
        user.setEmail("test@example.com");
        user.setRole("OPERATOR");
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        user.setRemark("测试插入");

        // 执行插入
        int rows = sysUserMapper.insertUser(user);

        // 断言影响行数
        assertThat(rows).isEqualTo(1);
        // 因为 id 是自增的，插入后应该被回填
        assertThat(user.getId()).isNotNull();
    }

//    @Test
//    @Sql("/sql/init_sys_user.sql") // 可选：执行初始化脚本准备数据
//    void testSelectByAccount() {
//        // 假设数据库中已经有一条 account = 'admin' 的记录（通过 init_sys_user.sql 插入）
//        SysUser user = sysUserMapper.selectByAccount("admin");
//
//        assertThat(user).isNotNull();
//        assertThat(user.getAccount()).isEqualTo("admin");
//        assertThat(user.getRealName()).isEqualTo("管理员");
//        // 其他字段也可断言
//    }

    @Test
    void testSelectByAccount_NotFound() {
        SysUser user = sysUserMapper.selectByAccount("not_exist");
        assertThat(user).isNull();
    }

    @Test
    void testInsertAndSelect() {
        // 插入新用户
        SysUser user = new SysUser();
        user.setAccount("unique_test");
        user.setPassword("pwd");
        user.setRealName("张三");
        sysUserMapper.insertUser(user);

        // 查询刚才插入的用户
        SysUser found = sysUserMapper.selectByAccount("unique_test");
        assertThat(found).isNotNull();
        assertThat(found.getRealName()).isEqualTo("张三");
        assertThat(found.getId()).isEqualTo(user.getId()); // id 相同
    }
}

