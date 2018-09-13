package me.junbin.dubbo;

import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/12 23:43
 * @description :
 */
// 在 application.yml 配置文件中添加了 dubbo.scan.base-packages 属性，这里可以不使用 EnableDubbo 注解
// @EnableDubbo
@SpringBootApplication
public class ProviderApplication {

    public static void main(String[] args) throws Exception {
        new SpringApplicationBuilder().web(WebApplicationType.NONE).run(args);
    }

}
