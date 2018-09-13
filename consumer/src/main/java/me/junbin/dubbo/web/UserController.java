package me.junbin.dubbo.web;

import com.alibaba.dubbo.config.annotation.Reference;
import me.junbin.dubbo.domain.User;
import me.junbin.dubbo.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/13 23:23
 * @description :
 */
@RestController
@RequestMapping("/user")
public class UserController {

    @Reference(version = "${user.service.v1_0_0}")
    private UserService userService;

    private static final Logger LOGGER = LoggerFactory.getLogger(UserController.class);

    @GetMapping("/{id:\\d+}")
    public Object query(@PathVariable long id) {
        return userService.findById(id);
    }

    @GetMapping("/list")
    public Object list() {
        return userService.findAll();
    }

    @PostMapping("/append")
    public Object append(@RequestBody User user) {
        return userService.save(user);
    }

    @DeleteMapping("/{id:\\d+}")
    public Object delete(@PathVariable long id) {
        return userService.delete(id);
    }

    @PutMapping({"/update/{id:\\d+}", "/update"})
    @PatchMapping({"/update/{id:\\d+}", "/update"})
    public Object update(User user, @PathVariable(required = false) Long id) {
        LOGGER.info("请求体：{}，路径参数id={}", user, id);
        if (id != null && user.getId() == null) {
            user.setId(id);
        }
        return userService.update(user);
    }

}
