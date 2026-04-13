package com.swu.tourismmanagesystem.config;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
@Data
@Configuration
@ConfigurationProperties(prefix = "login")
public class LoginConfig {
    // 基础登录配置
    private Integer usernameMinLength;
    private Integer passwordMinLength;
    private Integer maxLoginFailCount;
    private Integer lockMinutes;

    // JWT 配置
    private JwtConfig jwt = new JwtConfig();

    // 密码加密配置
    private PasswordConfig password = new PasswordConfig();

    @Data
    public static class JwtConfig {
        private String secret;
        private Integer expireHours;
        private String tokenHeader;
        private String tokenPrefix;
    }

    @Data
    public static class PasswordConfig {
        private Integer encoderStrength;
    }

    /**
     * 密码加密器
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(password.getEncoderStrength());
    }
}
