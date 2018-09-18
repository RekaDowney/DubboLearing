package me.junbin.dubbo.web;

import com.alibaba.dubbo.config.annotation.Reference;
import com.alibaba.dubbo.remoting.TimeoutException;
import me.junbin.dubbo.service.TimeoutService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.Serializable;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/17 23:32
 * @description :
 */
@RestController
@RequestMapping("/timeout")
public class TimeoutController {

    @Reference
    private TimeoutService timeoutService;
    private static final Logger LOGGER = LoggerFactory.getLogger(TimeoutController.class);

    @GetMapping("/{milliseconds:\\d+}")
    public Serializable timeout(@PathVariable int milliseconds) {
        try {
            return timeoutService.timeout(milliseconds);
        } catch (Exception e) {
            LOGGER.error(String.format("发生异常 --> %s", e.getClass()), e);
            if (e instanceof TimeoutException) {
                return String.format("%d毫秒超时", milliseconds);
            }
            return "发生异常" + e.getMessage();
        }
    }

}
