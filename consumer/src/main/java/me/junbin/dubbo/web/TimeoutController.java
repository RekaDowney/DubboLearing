package me.junbin.dubbo.web;

import com.alibaba.dubbo.config.annotation.Reference;
import com.alibaba.dubbo.remoting.TimeoutException;
import me.junbin.dubbo.service.TimeoutService;
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

    @GetMapping("/{milliseconds:\\d+}")
    public Serializable timeout(@PathVariable int milliseconds) {
        try {
            return timeoutService.timeout(milliseconds);
        } catch (Exception e) {
            if (e instanceof TimeoutException) {
                return String.format("%d毫秒超时", milliseconds);
            }
            return "发生异常" + e.getMessage();
        }
    }

}
