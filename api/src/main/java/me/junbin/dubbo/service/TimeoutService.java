package me.junbin.dubbo.service;

import java.io.Serializable;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/17 23:30
 * @description :
 */
public interface TimeoutService {

    Serializable timeout(int seconds);

}
