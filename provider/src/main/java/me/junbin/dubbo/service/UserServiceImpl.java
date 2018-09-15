package me.junbin.dubbo.service;

import com.alibaba.dubbo.config.annotation.Service;
import me.junbin.dubbo.domain.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/12 23:45
 * @description :
 */
// Dubbo 依赖 Spring，必须将服务交由 Spring 容器托管，这样 Dubbo 才能通过 Spring 容器来管理（增强）服务
@Component
@Service(version = "${user.service.v1_0_0}") // 该注解表明当前 Bean 是一个服务提供方
public class UserServiceImpl implements UserService {

    private static final ConcurrentMap<Long, User> DB = new ConcurrentHashMap<>(32);
    private static final AtomicLong idGen = new AtomicLong(0);
    private static final Logger LOGGER = LoggerFactory.getLogger(UserServiceImpl.class);

    static {
        long id = idGen.incrementAndGet();
        DB.put(id, new User(id, "AAA", "aaa", LocalDate.of(1995, 8, 5), true));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "BBB", "bbb", LocalDate.of(1996, 9, 3), false));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "CCC", "ccc", LocalDate.of(1994, 10, 12), false));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "DDD", "ddd", LocalDate.of(1996, 4, 1), true));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "EEE", "eee", LocalDate.of(1997, 4, 6), false));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "FFF", "fff", LocalDate.of(1996, 2, 15), false));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "GGG", "ggg", LocalDate.of(1993, 8, 25), false));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "HHH", "hhh", LocalDate.of(1995, 3, 3), true));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "III", "iii", LocalDate.of(1994, 1, 6), false));
        id = idGen.incrementAndGet();
        DB.put(id, new User(id, "JJJ", "jjj", LocalDate.of(1997, 4, 5), true));
    }

    @Override
    public User save(User user) {
        long id = idGen.incrementAndGet();
        user.setId(id);
        LOGGER.info("新增客户：{}", user);
        DB.put(id, user);
        return user;
    }

    @Override
    public User delete(Long id) {
        LOGGER.warn("删除客户：{}", DB.get(id));
        return DB.remove(id);
    }

    @Override
    public User update(User user) {
        LOGGER.info("更新客户：{} ==> {}", DB.get(user.getId()), user);
        DB.put(user.getId(), user);
        return user;
    }

    @Override
    public User findById(Long id) {
        LOGGER.info("查找客户：{}", id);
        return DB.get(id);
    }

    @Override
    public List<User> findAll() {
        LOGGER.info("查询所有客户");
        return new ArrayList<>(DB.values());
    }

}
