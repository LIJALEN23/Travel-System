package com.swu.tourismmanagesystem.utils;

import com.swu.tourismmanagesystem.config.LoginConfig;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
@Slf4j
@RequiredArgsConstructor // 构造器注入，替代 @Autowired
public class JwtUtil {

    private final LoginConfig loginConfig; // 干净注入

    /**
     * 生成 Token
     */
    public String createToken(String username) {
        String secret = loginConfig.getJwt().getSecret();
        int hour = loginConfig.getJwt().getExpireHours();
        long expireMillis = (long) hour * 3600 * 1000;

        return Jwts.builder()
                .setSubject(username)
                .setExpiration(new Date(System.currentTimeMillis() + expireMillis))
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }

    /**
     * 解析 Token
     */
    public Claims getClaims(String token) {
        try {
            return Jwts.parser()
                    .setSigningKey(loginConfig.getJwt().getSecret())
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            log.warn("JWT 解析失败：{}", e.getMessage());
            return null;
        }
    }

    /**
     * 验证 Token 是否有效（包含过期校验）
     */
    public boolean validateToken(String token) {
        Claims claims = getClaims(token); // 复用已有方法
        if (claims == null) {
            return false;
        }
        // 校验是否过期
        return !claims.getExpiration().before(new Date());
    }
}