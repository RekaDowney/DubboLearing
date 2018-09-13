package me.junbin.dubbo;

import com.alibaba.dubbo.config.spring.context.annotation.EnableDubbo;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/12 23:43
 * @description :
 */
@EnableDubbo // 启动 Dubbo 的注解支持
@SpringBootApplication
public class ProviderApplication {

    public static void main(String[] args) throws Exception {
        new SpringApplicationBuilder(ProviderApplication.class)
                .web(WebApplicationType.NONE).run(args);
    }

}
