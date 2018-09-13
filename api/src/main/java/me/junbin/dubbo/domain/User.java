package me.junbin.dubbo.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * @author : Zhong Junbin
 * @email : <a href="mailto:rekadowney@gmail.com">发送邮件</a>
 * @createDate : 2018/9/12 23:29
 * @description :
 */
@Data
@NoArgsConstructor
@EqualsAndHashCode
@AllArgsConstructor
@Accessors(chain = true)
public class User implements Serializable {

    private static final long serialVersionUID = 1L;
    private Long id;
    private String username;
    private String password;
    private LocalDate birthday;
    private boolean isMale;

}
