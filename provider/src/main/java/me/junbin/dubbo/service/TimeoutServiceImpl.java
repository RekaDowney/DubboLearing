package me.junbin.dubbo.service;

import com.alibaba.dubbo.config.annotation.Service;
import org.springframework.stereotype.Component;

import java.io.Serializable;
import java.util.concurrent.TimeUnit;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/17 23:30
 * @description :
 */
@Service
@Component
public class TimeoutServiceImpl implements TimeoutService {

    @Override
    public Serializable timeout(int milliseconds) {
        try {
            TimeUnit.MILLISECONDS.sleep(milliseconds);
        } catch (InterruptedException e) {
            return "线程被请求中断";
        }
        return String.format("休眠%d毫秒完毕", milliseconds);
    }

}
