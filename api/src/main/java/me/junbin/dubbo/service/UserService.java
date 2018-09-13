package me.junbin.dubbo.service;

import me.junbin.dubbo.domain.User;

import java.util.List;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/12 23:31
 * @description :
 */
public interface UserService {

    User save(User user);

    User delete(Long id);

    User update(User user);

    User findById(Long id);

    List<User> findAll();

}
