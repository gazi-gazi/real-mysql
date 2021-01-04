# 쿼리 작성 및 최적화

- DDL(Data Definition Language): 데이터베이스나 테이블의 구조를 변경하기 위한 문장
- DML(Data Manipulation Language): 테이블의 데이터를 조작(읽고, 쓰기)하기 위한 문장

위 둘을 합쳐서 `SQL`

ANSI 표준에서 -> 데이터를 조회하는 SELECT을 쿼리(Query), 데이터를 변경하는 INSERT와 UPDATE 그리고 DELETE를 스테이트먼트(Statement)로 구분한다.

## 7.1.1. SQL 모드

```mysql
select @@sql_mode;
```

쿼리를 통해 현재 MySQL 버전에 맞는 sql_mode를 살펴볼 수 있다.



[![image](https://user-images.githubusercontent.com/19922698/103475083-880be180-4ded-11eb-89c3-1bc73129702c.png)](https://user-images.githubusercontent.com/19922698/103475083-880be180-4ded-11eb-89c3-1bc73129702c.png)

*<MySQL 5.7에서 기본 설정된 sql_mode 값 목록>*



#### STRICT_ALL_TABLES

이 값이 설정되면 컬럼의 정해진 길이보다 더 큰 값을 저장할 때 (ex. varchar(3)인 컬럼에 'hello'를 저장할 때) 경고가 아닌 오류가 발생하고 쿼리 실행이 중지된다.



#### STRICT_TRANS_TABLES

디폴트로 걸려 있다(버전 5.7). 데이터 타입 변환이 필요할 때 강제 변환하지 않고 에러를 발생시킨다.

라고 책에는 나와 있지만, [공식문서](https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sqlmode_strict_all_tables)를 보면 이 값은 트랜잭션을 지원하는 storage engine에서 [더욱 엄격한 sql_mode](https://dev.mysql.com/doc/refman/5.7/en/sql-mode.html#sql-mode-strict)로 동작하도록 한다.

같은 맥락으로 위의 STRICT_ALL_TABLES는 transactional/nontransactional storage engine 모두에게 적용된다.



#### TRADITIONAL

위 두 값보다 조금 더 엄격한 방법으로 SQL의 작동을 제어한다. (더 ANSI 표준에 가까움)



#### ANSI QUOTES

이 놈이 활성화되면

홑따옴표 -> 문자열 표기

쌍따옴표 -> 칼럼명, 테이블명 등의 식별자 표기



#### ONLY_FULL_GROUP_BY

MySQL에서는 group by절에 포함되지 않은 칼럼이더라도 집합 함수의 사용 없이 그대로 SELECT 절이나 HAVING 절에 사용할 수 있다.

이건 스티치가 정리한 [여기](https://github.com/gazi-gazi/real-mysql/issues/25)에 잘 나와있다.



#### PIPE_AS_CONCAT

`||`는 원래 OR과 같은 의미이지만, 이 값이 활성화되면 오라클처럼 문자열 연결(CONCAT) 연산자로 사용 가능하다. (아래 *7.3.2 AND와 OR* 참고)



#### PAD_CHAR_TO_FULL_LENGTH

MySQL에서는 CHAR 타입이더라도 문자열 뒤의 공백 문자는 제거되어 반환한다. (VARCHAR처럼 동작)

하지만 이 값을 활성화하면 공백 문자를 그대로 포함해 반환한다.



#### NO_BACKSLASH_ESCAPES

이 설정을 활성화하면 `\` 문자를 이스케이프 용도로 사용하지 못한다.



#### IGNORE_SPACE

MySQL에서는 함수명이나 괄호 사이에 있는 공백까지도 스토어드 프로시저나 함수 이름으로 간주한다.

이 설정을 활성화하면 프로시저나 함수명과 괄호 사이의 공백은 무시한다.



#### ANSI

최대한 SQL 표준에 맞게 동작하게 만들어준다.

## 7.1.2 영문 대소문자 구분

MySQL 서버는 테이블의 대소문자를 구분한다.

고 되어 있지만 우리가 사용하는 버전에서는 구분을 안한다. 심지어 `lower_caes_table_names` 변수의 기본 설정된 값이 2인데!

이건 죽어도 모르겠다.

- 0 -> 대소문자 구분 O
- 1 -> 모두 소문자로만 저장. 대소문자 구분 X
- 2 -> 저장은 대소문자 구분, 쿼리에서는 구분 X

![image](https://user-images.githubusercontent.com/39546083/103503980-66683400-4e99-11eb-905b-611c8afb02af.png)

```lower_case_table_names=1``` 일 때 쿼리는 대소문자를 구분하지 않고 대문자로 입력한 값이 소문자로 저장된다.

![image](https://user-images.githubusercontent.com/39546083/103504176-fa3a0000-4e99-11eb-8a92-3c5ac5b86cd4.png)

```lower_case_table_names=2```일 때는 대소문자를 구분해서 입력한 문자 그대로 쿼리가 저장된다. 쿼리 실행시는 대소문자를 구분하지 않는다.

```lower_case_table_names=0```일 때는 도커가 실행되지 않아서 실험해볼 수 없었다.

가능하면 초기 DB나 테이블을 생성할 때 대문자만 또는 소문자만으로 통일해서 사용하는 편이 좋다.

## 7.1.3 예약어

❗️ 항상 테이블을 생성할 때는 테이블(칼럼)의 이름을 역따옴표로 둘러싸지 말자. 그래야 예약어인지 아닌지 MySQL 서버가 에러로 알려준다.

[![image](https://user-images.githubusercontent.com/19922698/103476968-7f230c00-4dfd-11eb-9f01-46afc359f2e2.png)](https://user-images.githubusercontent.com/19922698/103476968-7f230c00-4dfd-11eb-9f01-46afc359f2e2.png)

## 7.2 매뉴얼의 SQL 문법 표기를 읽는 방법

[![image](https://user-images.githubusercontent.com/39546083/103456480-35bdb880-4d3a-11eb-8fcd-97a5c21b0aa4.png)](https://user-images.githubusercontent.com/39546083/103456480-35bdb880-4d3a-11eb-8fcd-97a5c21b0aa4.png)

| 구분     | 이름   | 설명                                                      |
| -------- | ------ | --------------------------------------------------------- |
| 이탤릭체 |        | 사용자가 선택해서 작성하는 토큰                           |
| []       | 대괄호 | 선택 사항. 없어도 있어도 오류가 발생하지 않는다.          |
| \|       | 파이프 | 앞과 뒤의 키워드 중 단 하나만 선택해서 사용할 것.         |
| {}       | 중괄호 | 괄호 내의 아이템 중에서 반드시 1개 사용                   |
| ...      | 반복   | ... 앞에 명시된 키워드나 표현식이 여러 개 반복될 수 있다. |

## 7.3 MySQL 연산자와 내장 함수

MySQL에서만 사용되는 연산자나 표기법이 있다. ANSI 표준 형태가 아닌 연산자가 많이 있다. 가능하다면 SQL의 가독성을 높이기 위해 ANSI 표준 형태의 연산자를 사용하길 권장한다. 각 DBMS의 내장 함수는 거의 같은 기능을 제공하지만 이름이 호환되는 것은 거의 없다.

### 7.3.1 리터럴 표기법

**문자열**

SQL 표준에서 문자열은 항상 `홑따옴표(')`를 사용해서 표시한다. MySQL에서는 `쌍따옴표(")`를 사용해서 문자열을 표기할 수도 있다.

```mysql
SELECT * FROM departments WHERE dept_no='d001';
SELECT * FROM departments WHERE dept_no="d001";
```

SQL 표준에서는 문자열 값에 홑따옴표가 포함돼 있을 때 홑따옴표를 두 번 연속해서 입력하면 된다. MySQL에서는 쌍따옴표와 홑따옴표를 혼합해서 이러한 문제를 피해 가기도 한다. 문자열 값이 쌍따옴표를 가지고 있을 때는 쌍따옴표를 두 번 연속해서 사용할 수 있다.

```mysql
SELECT * FROM departments WHERE dept_no='d''001'; -- // SQL 표준
SELECT * FROM departments WHERE dept_no='d"001'; -- // SQL 표준
SELECT * FROM departments WHERE dept_no="d'001"; -- // MySQL에서만 지원
SELECT * FROM departments WHERE dept_no="d""001"; -- // MySQL에서만 지원
```

SQL에서 사용되는 식별자(테이블이나 칼럼명 등)가 키워드와 충돌할 때 MySQL에서는 역따옴표로 감싸서 예약어와의 충돌을 피할 수 있다.

```mysql
CREATE TABLE tab_test ('table' VARCHAR(20) NOT NULL, ...);
SELECT `column` FROM tab_test;
```

MySQL 서버의 `sql_mode` 시스템 변수 값에 `"ANSI_QUOTES"` 를 설정하면 쌍따옴표는 문자열 리터럴 표기에 사용할 수 없다. 테이블명이나 칼럼명의 충돌을 피하려면 역따옴표(`)가 아니라 쌍따옴표를 사용해야 한다.

```mysql
SELECT * FROM departments WHERE dept_no='d''001';
SELECT * FROM departments WHERE dept_no='d"001';

CREATE TABLE tab_test ("table" VARCHAR(20) NOT NULL, ...);
SELECT "column" FROM tab_test;
```

SQL 표준 표기법만 사용할 수 있게 강제하려면 `sql_mode` 시스템 변수 값에 `"ANSI"`를 설정하면 된다. 쿼리의 작동 방식에 영향을 미치므로 프로젝트 초기에 적용하는 것이 좋다. 운용 중인 애플리케이션에서 sql_mode 설정을 변경하는 것은 상당히 위험하다.



**숫자**

숫자 값을 상수로 SQL에 사용할 때는 따옴표(' 또는 ") 없이 숫자 값을 입력하면 된다. 문자열 형태로 따옴표를 사용하더라도 비교 대상이 숫자 값이거나 숫자 타입의 칼럼이면 MySQL 서버가 문자열 값을 숫자 값으로 자동 변환해준다.

```mysql
SELECT * FROM tab_test WHERE number_column='10001';
SELECT * FROM tab_test WHERE string_column=10001;
```

MySQL은 숫자 타입과 문자열 타입 간의 비교에서 숫자 타입을 우선시하므로 문자열 값을 숫자 값으로 변환한 후 비교를 수행한다.

첫 번째 쿼리의 경우 상수값 하나만 변환하므로 성능과 관련된 문제가 발생하지 않는다.

두 번째 쿼리는 주어진 상수값이 숫자 값인데 비교되는 칼럼은 문자열 값이다. MySQL은 문자열 칼럼을 숫자로 변환해서 비교한다. string_column 칼럼의 모든 문자열 값을 숫자로 변환해서 비교를 수행해야 하므로 string_column에 인덱스가 있다 하더라도 이를 이용하지 못한다. 만약 string_column에 알파벳과 같은 문자가 포함된 경우에는 숫자 값으로 변환할 수 없으므로 쿼리 자체가 실패할 수 있다.

숫자 값은 숫자 타입의 칼럼에만 저장해야 한다.



**날짜**

MySQL에서는 정해진 형태의 날짜 포맷으로 표기하면 MySQL 서버가 자동으로 `DATE`나 `DATETIME` 값으로 변환해서 저장한다.

```mysql
SELECT * FROM dept_emp WHERE from_date='2011-04-29';
SELECT * FROM dept_emp WHERE from_date=STR_TO_DATE('2011-04-29', '%Y-%m-%d');
```

첫 번째 쿼리와 같이 날짜 타입의 칼럼과 문자열 값을 비교하는 경우, MySQL 서버는 문자열 값을 DATE 타입으로 변환해서 비교한다. 두 번째 쿼리는 SQL에서 문자열을 DATE 타입으로 강제 변환해서 비교하는데 차이점은 거의 없다. 첫 번째 쿼리와 같이 비교한다고 해서 from_date 칼럼을 문자열로 변환하지 않기 때문에 인덱스를 이용하는데 문제가 발생하지 않는다.



**불리언**

`BOOL`이나 `BOOLEAN` 타입은 `TINYINT` 타입에 대한 동의어다. MySQL에서는 TRUE 또는 FALSE 형태로 비교하거나 값을 저장할 수 있다. 이는 BOOL 타입뿐 아니라 숫자 타입의 칼럼에도 모두 적용되는 비교 방법이다.

```mysql
CREATE TABLE tb_boolean (bool_value BOOLEAN);
INSERT INTO tb_boolean VALUES (FALSE);
SELECT * FROM tb_boolean WHERE bool_value=FALSE;
SELECT * FROM tb_boolean WHERE bool_value=TRUE;
```

TURE나 FALSE로 비교했지만 실제로는 값을 조회해 보면 0 또는 1 값이 조회된다. MySQL은 불리언 값을 정수로 맵핑해서 사용한다. FALSE는 0을 의미하고 TRUE는 1만을 의미한다.

모든 숫자 값이 TRUE나 FALSE 두 개의 불리언 값으로 매핑되지 않는다는 것은 혼란스럽고 애플리케이션의 버그로 연결될 가능성이 크다. 만약 불리언 타입을 꼭 사용하고 싶다면 ENUM 타입으로 관리하는 것이 조금 더 명확하고, 실수할 가능성도 줄일 수 있다.



### 7.3.2 MySQL 연산자

**동등(Equal) 비교(=, <=>)**

동등 비교는 `"="` 기호를 사용해 비교를 수행하면 된다. MySQL에서는 동등 비교를 위해 `"<=>"` 연산자도 제공한다. <=> 연산자는 = 연산자와 같고 NULL 값에 대한 비교까지 수행한다. NULL-SAFE 연산자라고 한다.

[![image](https://user-images.githubusercontent.com/39546083/103456484-3ce4c680-4d3a-11eb-9488-2ac9ddaaf9dd.png)](https://user-images.githubusercontent.com/39546083/103456484-3ce4c680-4d3a-11eb-9488-2ac9ddaaf9dd.png)

<=> 연산자는 NULL을 하나의 값으로 인식하고 비교하는 방법이다.



**부정(Not-Equal) 비교(<>, !=)**

`같지 않다` 비교를 위한 연산자는 `"<>"`를 일반적으로 많이 사용한다. `"!="` 도 Not-Equal 연산자로 사용할 수 있다. 통일해서 사용하는 방법을 권장한다.



**NOT 연산자(!)**

True 또는 False의 연산의 결과를 반대로(부정) 만드는 연산자로 `"NOT"`을 사용한다. `"!"` 연산자를 같은 목적으로 사용할 수 있다. 불리언 값뿐만 아니라 숫자나 문자열 표현식에서도 사용할 수 있지만 부정의 결과 값을 정확히 예측할 수 없는 경우에는 사용을 자제하는 것이 좋다.

[![image](https://user-images.githubusercontent.com/39546083/103456487-40784d80-4d3a-11eb-9c21-b02aec45db19.png)](https://user-images.githubusercontent.com/39546083/103456487-40784d80-4d3a-11eb-9c21-b02aec45db19.png)



**AND(&&) 와 OR(||) 연산자**

불리언 표현식의 결과를 결합하기 위해 AND나 OR를 사용한다. `"&&"` 와 `"||"` 의 사용도 허용한다. SQL의 가독성을 높이기 위해 다른 용도로 사용될 수 있는 "&&" 연산자와 "||" 연산자는 사용을 자제하는 것이 좋다.

[![image](https://user-images.githubusercontent.com/39546083/103456490-44a46b00-4d3a-11eb-8526-27f2f9d73b79.png)](https://user-images.githubusercontent.com/39546083/103456490-44a46b00-4d3a-11eb-8526-27f2f9d73b79.png)



**나누기(/, DIV) 와 나머지(%, MOD) 연산자**

일반적인 나누기 연산자는 `"/"`이다. 나눈 목의 정수 부분만 가져오려면 `DIV`연산자를 사용하고 나눈 결과 몫이 아닌 나머지를 가져오는 연산자로는 `"%"` 또는 `MOD` 연산자(함수)를 사용한다.

[![image](https://user-images.githubusercontent.com/39546083/103456491-479f5b80-4d3a-11eb-90ab-faa5fa874245.png)](https://user-images.githubusercontent.com/39546083/103456491-479f5b80-4d3a-11eb-90ab-faa5fa874245.png)



**REGEXP 연산자**

문자열 값이 어떤 패턴을 만족하는지 확인한다. RLIKE는 REGEXP와 똑같은 비교를 수행한다. `REGEXP` 연산자의 좌측에 비교 대상 문자열 값 또는 문자열 칼럼, 그리고 우측에 검증하고자 하는 정규 표현식을 사용하면 된다.

[![image](https://user-images.githubusercontent.com/39546083/103456493-4bcb7900-4d3a-11eb-9f33-4087c7908bc9.png)](https://user-images.githubusercontent.com/39546083/103456493-4bcb7900-4d3a-11eb-9f33-4087c7908bc9.png)

REGEXP 연산자의 정규 표현식은 POSIX 표준으로 구현돼 있다.

- ^: 문자열의 시작을 표시한다. 반드시 일치하는 부분이 문자열의 제일 앞쪽에 있어야 함을 의미한다.
- $: 문자열의 끝을 표시한다. 반드시 일치하는 부분이 문자열의 제일 끝에 있어야 함을 의미한다.
- []: 문자 그룹을 표시한다. 대괄호는 문자열이 아니라 문자 하나와 일치하는 지를 확인하는 것이다.
- (): 문자열 그룹을 표시한다. 반드시 'xyz'가 모두 있는지 확인하는 것이다.
- |: "|"로 연결된 문자열 중 하나인지 확인한다.
- .: 어떠한 문자든지 1개의 문자를 표시한다.
- *: 이 기호 앞에 표시된 정규 표현식이 0 또는 1번 이상 반복될 수 있다는 표시다.
- +: 이 기호 앞에 표시된 정규 표현식이 1번 이상 반복될 수 있다는 표시다.
- ?: 이 기호 앞에 표시된 정규 표현식이 0 또는 1번만 올 수 있다는 표시다.

간단한 정규 표현식을 이용해 전화번호나 이메일 주소 처럼 특정한 형태를 갖춰야하는 문자열을 쉽게 검증할 수 있다.

REGEXP 조건의 비교는 인덱스 레인지 스캔을 사용할 수 없다. 따라서 WHERE 조건절에 REGEXP 연산자를 사용한 조건을 단독으로 사용하는 것은 성능상 좋지 않다. 가능하다면 범위를 줄일 수 있는 조건과 함께 REGEXP 연산자를 사용하길 권장한다.

```
REGEXP나 RLIKE 연산자의 경우, 바이트 단위의 비교를 수행하므로 멀티 바이트 문자나 악센트가 포함된 문자에 대한 패턴 검사는 정확하지 않을 수 있다.
알파벳이나 숫자 이외의 문자셋이 저장되는 칼럼에 REGEXP나 RLIKE를 사용할 때는 테스트를 충분히 하는 것이 좋다.
```



**LIKE 연산자**

LIKE 연산자는 인덱스를 이용해 처리할 수도 있다. 어떤 상수 문자열이 있는지 없는지 정도를 판단하는 연산자다.

[![image](https://user-images.githubusercontent.com/39546083/103456494-50902d00-4d3a-11eb-8040-5b4ae4b1f507.png)](https://user-images.githubusercontent.com/39546083/103456494-50902d00-4d3a-11eb-8040-5b4ae4b1f507.png)

LIKE는 항상 비교 대상 문자열의 처음부터 끝까지 일치하는 경우에만 TRUE를 반환한다.

- %: 0 또는 1개 이상의 모든 문자열에 일치(문자의 내용과 관계없이)
- _: 정확히 1개의 문자에 일치(문자의 내용과 관계없이)

와일드카드 문자인 '%'나 '_' 문자 자체를 비교한다면 ESCAPE 절을 LIKE 조건 뒤에 추가해 이스케이프 문자를 설정할 수 있다.

[![image](https://user-images.githubusercontent.com/39546083/103456496-54bc4a80-4d3a-11eb-84b1-7131e6cf902e.png)](https://user-images.githubusercontent.com/39546083/103456496-54bc4a80-4d3a-11eb-84b1-7131e6cf902e.png)

LIKE 연산자는 와일드카드 문자인 (%, _)가 검색어의 뒤쪽에 있다면 인덱스 레인지 스캔으로 사용할 수 있지만 와일드카드가 검색어의 앞쪽에 있다면 인덱스 레인지 스캔을 사용할 수 없으므로 주의해야 한다.

[![image](https://user-images.githubusercontent.com/39546083/103456498-5b4ac200-4d3a-11eb-8222-827037654cb9.png)](https://user-images.githubusercontent.com/39546083/103456498-5b4ac200-4d3a-11eb-8222-827037654cb9.png)

[![image](https://user-images.githubusercontent.com/39546083/103456501-5f76df80-4d3a-11eb-9e45-f168f0137abc.png)](https://user-images.githubusercontent.com/39546083/103456501-5f76df80-4d3a-11eb-9e45-f168f0137abc.png)

두 번째 실행 계획은 인덱스의 Left-most 특성으로 인해 인덱스를 처음부터 끝까지 읽는 인덱스 풀 스캔 방식으로 쿼리가 처리됨을 알 수 있다.



**BETWEEN 연산자**

"크거나 같다"와 "작거나 같다"라는 두 개의 연산자를 하나로 합친 연산자다. 다른 비교 조건과 결합해 하나의 인덱스를 사용할 때 주의해야 할 점이 있다.

```mysql
SELECT * FROM dept_emp
WHERE dept_no='d003' AND emp_no=10001;

SELECT * FROM dept_emp
WHERE dept_no BETWEEN 'd003' AND 'd005' AND emp_no=10001;
```

첫 번째 쿼리는 dept_no와 emp_no 조건 모두 인덱스를 이용해 범위를 줄여주는 방법으로 사용할 수 있다. 하지만 두 번째 쿼리는 범위를 읽어야 하는 연산자라서 모든 인덱스 범위를 검색해야만 한다.

BETWEEN과 IN 연산자의 차이점은 BETWEEN은 크다와 작다 비교를 하나로 묶어둔 것에 가깝다. IN 연산자의 처리 방법은 동등 비교(=) 연산자와 비슷하다. IN 연산자는 여러 개의 동등 비교(=)를 하나로 묶은 것과 같은 연산자라서 IN과 동등 비교 연산자는 같은 형태로 인덱스를 사용하게 된다.

[![image](https://user-images.githubusercontent.com/39546083/103456504-656cc080-4d3a-11eb-82a3-ac63da3e901e.png)](https://user-images.githubusercontent.com/39546083/103456504-656cc080-4d3a-11eb-82a3-ac63da3e901e.png)

BETWEEN 조건을 사용하면 인덱스의 상당히 많은 레코드를 읽지만 IN 연산자는 작업 범위를 줄이는 용도로 인덱스를 사용할 수 있다.

```mysql
SELECT * FROM dept_emp
WHERE dept_no IN ('d003', 'd004', 'd005') AND emp_no=10001;
```

인덱스 앞쪽에 있는 칼럼의 선택도가 떨어질 때는 IN 으로 변경하는 방법으로 쿼리의 성능을 개선할 수 있다.

[![image](https://user-images.githubusercontent.com/39546083/103456507-6bfb3800-4d3a-11eb-9657-589d16d008ef.png)](https://user-images.githubusercontent.com/39546083/103456507-6bfb3800-4d3a-11eb-9657-589d16d008ef.png)

그런데 IN 연산자에 사용할 상수 값을 가져오기 위해 별도의 SELECT 쿼리를 한번 더 실행해야 할 때도 있다. 이때는 적절한 쿼리를 한 번 더 실행해서 IN 으로 변경했을 때 그만큼 효율이 있는지를 테스트해보는 것이 좋다. 그런데 IN 연산자에 채워줄 상수값을 따로 가져오지 않고 다음 처럼 `IN (subquery)` 형태로 쿼리를 변경하면, 더 나쁜 결과를 가져올 수도 있기 때문에 IN (subquery) 형태로는 변경하지 않는 것이 좋다.

```mysql
SELECT * FROM employees WHERE emp_no BETWEEN 10001 AND 400000;
SELECT * FROM employees WHERE emp_no>=10001 AND emp_no<=400000;
WHERE:( 'employees'.'emp_no' between 10001 and 400000)
WHERE:(('employees'.'emp_no' >= 10001) and ('employees'.'emp_no' <= 400000))
```

BETWEEN 비교는 하나의 비교 조건으로 처리하고 크다와 작다의 조합으로 비교하는 경우에는 두 개의 비교 조건으로 처리한다. 하지만 옵티마이저 내부적으로 BETWEEN 연산자를 크다 작다의 연산자로 변환하지 않고 BETWEEN을 그대로 유지한다는 것을 알 수 있다. 이 차이가 디스크로부터 읽어야 하는 레코드의 수가 달라질 정도의 차이를 만들어 내지는 않는다. 읽어온 레코드를 CPU와 메모리 수준에서 비교하는 수준 정도의 차이가 있다고 볼 수 있다.



**IN 연산자**

IN은 여러 개의 값에 대해 동등 비교 연산을 수행하는 연산자다. 여러 번의 동등 비교로 실행하기 때문에 일반적으로 빠르게 처리된다. MySQL에서 IN 연산자는 사용법에 따라 상당히 비효율적으로 처리될 때도 많다.

IN 연산자의 입력이 상수가 아니라 서브 쿼리인 경우에는 상당히 느려질 수 있다. IN의 인자로 `상수`가 사용되면 적절히 인덱스를 이용해 쿼리를 실행한다. 하지만 IN의 입력으로 `서브 쿼리`를 사용할 때는 서브 쿼리가 먼저 실행되어 그 결과값이 IN의 상수 값으로 전달되는 것이 아니라, 서브 쿼리의 외부가 먼저 실행되고 IN (subquery)는 체크 조건으로 사용된다. 일반적으로 IN의 입력으로 상수를 사용한다면 IN의 입력으로 사용되는 상수를 수만 개 수준으로 사용하지 않는다면 문제가 되지 않는다.

```mysql
SELECT *
FROM employees
WHERE emp_no IN (10001, 10002, 10003);
SELECT *
FROM employees
WHERE emp_no IN (10001, 10002, NULL);
```

IN 연산자를 이용해 NULL 값을 검색할 수는 없다. 값이 NULL인 레코드를 검색하려면 NULL-Safe 연산자인 `"<=>"` 또는 `IS NULL` 연산자 등을 이용해야 한다.

NOT IN의 실행 계획은 인덱스 풀 스캔으로 표시되는데, 동등이 아닌 부정형 비교라서 인덱스를 이용해 처리 범위를 줄이는 조건으로 사용할 수 없기 때문이다. NOT IN 연산자가 프라이머리 키와 비교될 때 가끔 쿼리의 실행 계획에 인덱스 레인지 스캔으로 표시될 수도 있다. 하지만 이는 InnoDB 테이블에서 프라이머리 키가 클러스터링 키이기 때문일 뿐 실제 IN과 같이 효율적으로 실행된다는 것을 의미하지는 않는다.



### 7.3.3 MySQL 내장 함수

MySQL의 함수는 MySQL에서 `기본적으로 제공하는 내장 함수`와 사용자가 직접 작성해서 추가할 수 있는 `사용자 정의 함수(UDF)`로 구분된다. MySQL에서 제공하는 C/C++ API를 이용해 사용자가 원하는 기능을 직접 함수로 만들어 추가할 수 있는데, 이를 사용자 정의 함수라고 한다. 이것은 스토어드 프로그램으로 작성되는 프로시저나 스토어드 함수와는 다르므로 혼동하지 않도록 주의하자.



**NULL 값 비교 및 대체(IFNULL, ISNULL)**

- IFNULL(): 칼럼이나 표현식의 값이 NULL인지 비교하고 NULL 이면 다른 값으로 대체하는 용도로 사용한다. 첫 번째 인자는 NULL인지 아닌지 비교하려는 칼럼이나 표현식을, 두 번째 인자로는 첫 번째 인자의 값이 NULL인 경우 대체할 값이나 칼럼을 설정한다. 함수의 반환값은 첫 번째 인자가 NULL이 아니면 첫 번째 인자의 값을, 첫 번째 인자의 값이 NULL이면 두 번째 인자의 값을 반환한다.
- ISNULL(): 표현식이나 칼럼의 값이 NULL 인지 아닌지 비교하는 함수다. NULL 이면 TRUE(1), NULL이 아니면 FALSE(0)를 반환한다.

[![image](https://user-images.githubusercontent.com/39546083/103456511-70275580-4d3a-11eb-96e1-dcbcd79a99be.png)](https://user-images.githubusercontent.com/39546083/103456511-70275580-4d3a-11eb-96e1-dcbcd79a99be.png)



**현재 시각 조회(NOW, SYSDATE)**

현재의 시간을 반환하는 함수다. SQL에서 모든 NOW() 함수는 같은 값을 가지지만 SYSDATE() 함수는 하나의 SQL 내에서도 호출되는 시점에 따라 결과 값이 달라진다.

[![image](https://user-images.githubusercontent.com/39546083/103456513-761d3680-4d3a-11eb-953b-2e2a163a15b9.png)](https://user-images.githubusercontent.com/39546083/103456513-761d3680-4d3a-11eb-953b-2e2a163a15b9.png)

SYSDATE() 함수는 두 가지 큰 잠재적인 문제가 있다.

- 복제가 구축된 MySQL의 슬레이브에서 안정적으로 복제(Replication)되지 못한다.
- SYSDATE() 함수와 비교되는 칼럼은 인덱스를 효율적으로 사용하지 못한다는 것이다.

[![image](https://user-images.githubusercontent.com/39546083/103456519-787f9080-4d3a-11eb-9578-82f0af809d1a.png)](https://user-images.githubusercontent.com/39546083/103456519-787f9080-4d3a-11eb-9578-82f0af809d1a.png)

SYSDATE() 함수는 함수가 호출될 때마다 다른 값을 반환하므로 상수가 아니다. 매번 비교되는 레코드마다 함수를 실행해 다른 값을 반환한다. NOW() 함수는 쿼리가 실행되는 시점에 실행되고 값을 할당받아서 그 값을 SQL 문장의 모든 부분에서 사용해 항상 같은 값을 보장할 수 있다.

SYSDATE() 함수는 꼭 필요한 때가 아니라면 사용하지 않는 편이 좋다. 사용중이라면 MySQL 서버의 설정 파일(my.cnf나 my.ini 파일)에 sysdate-is-now 설정을 넣어 주는 것이 해결책이다. SYSDATE()가 NOW()와 같이 하나의 SQL에서 같은 값을 갖게 된다.



**날짜와 시간의 포맷(DATE_FORMAT, STR_TO_DATE)**

DATETIME 타입의 칼럼이나 값을 원하는 형태의 문자열로 변환해야 할 때는 DATE_FORMAT() 함수를 이용한다. 지정자는 [여기](https://dev.mysql.com/doc/refman/5.7/en/date-and-time-functions.html#function_date-format)에서 확인한다.

[![image](https://user-images.githubusercontent.com/39546083/103456526-7c131780-4d3a-11eb-98c4-5f06e1d7a31b.png)](https://user-images.githubusercontent.com/39546083/103456526-7c131780-4d3a-11eb-98c4-5f06e1d7a31b.png)

SQL 표준 형태(년-월-일 시:분:초)로 입력된 문자열은 필요한 경우 자동적으로 DATETIME 타입으로 변환되어 처리된다. 그렇지 않은 형태는 명시적으로 날짜 타입으로 변환해 주어야 한다. 이때 STR_TO_DATE() 함수를 이용해 문자열을 DATETIME 타입으로 변환할 수 있다.

[![image](https://user-images.githubusercontent.com/39546083/103456530-80d7cb80-4d3a-11eb-9415-944f5e8fffda.png)](https://user-images.githubusercontent.com/39546083/103456530-80d7cb80-4d3a-11eb-9415-944f5e8fffda.png)



**날짜와 시간의 연산(DATE_ADD, DATE_SUB)**

특정 날짜에서 년도나 월일 또는 시간 등을 더하거나 뺄 때는 DATE_ADD() 함수나 DATE_SUB() 함수를 이용한다. 첫 번째 인자는 연산을 수행할 날짜이며, 두 번째 인자는 더하거나 빼고자 하는 월의 수나 일자의 수 등을 입력하면 된다. 두 번째 인자는 INTERVAL n [YEAR, MONTH, DAY, HOUR, MINUTE, SECOND ...] 형태로 입력해야 한다. 여기서 n은 더하거나 빼고자 하는 값이며 그 뒤에 명시되는 단위에 따라 하루를 더할 것인지 한 달을 더할 것인지를 결정한다.

[![image](https://user-images.githubusercontent.com/39546083/103456534-86351600-4d3a-11eb-8d98-5023d994bca8.png)](https://user-images.githubusercontent.com/39546083/103456534-86351600-4d3a-11eb-8d98-5023d994bca8.png)



**타임 스탬프 연산(UNIX_TIMESTAMP, FROM_UNIXTIME)**

UNIX_TIMESTAMP() 함수는 `'1970-01-01 00:00:00'`로부터 경과된 초의 수를 반환하는 함수다. 운영체제나 프로그래밍 언어에서도 같은 방식으로 타임스탬프를 산출하는 경우에는 상호 호환해서 사용할 수 있다. 연산자가 없으면 현재 날짜와 시간의 타임스탬프 값을, 인자로 특정 날짜를 전달하면 그 날짜와 시간의 타임스탬프를 반환한다.

FROM_UNIXTIME() 함수는 인자로 전달한 타임스탬프 값을 DATETIME 타입으로 변환하는 함수다.

[![image](https://user-images.githubusercontent.com/39546083/103456541-8f25e780-4d3a-11eb-97be-d0de6570aa9d.png)](https://user-images.githubusercontent.com/39546083/103456541-8f25e780-4d3a-11eb-97be-d0de6570aa9d.png)

4바이트 숫자 타입으로 저장되기 때문에 실제로 가질 수 있는 값의 범위는 `'1970-01-01 00:00:01' ~ '2038-01-09 03:14:07'`까지의 날짜 값만 가능하다.



**문자열 처리 (RPAD, LPAD / RTRIM, LTRIM, TRIM)**

RPAD()와 LPAD() 함수는 문자열의 좌측 또는 우측에 문자를 덧붙여서 지정된 길이의 문자열로 만드는 함수다. 3개의 인자가 필요하다. 첫 번째 인자는 패딩 처리를 할 문자열이며 두 번째 인자는 몇 바이트까지 패딩할 것인지, 세 번째 인자는 어떤 문자를 패딩할 것인지를 의미한다.

RTRIM() 함수와 LTRIM() 함수는 문자열의 우측 또는 좌측에 연속된 공백 문자(Space, NewLine, Tab 문자)를 제거하는 함수다. TRIM() 함수는 LTRIM()과 RTRIM()을 동시에 수행하는 함수다.

[![image](https://user-images.githubusercontent.com/39546083/103456543-92b96e80-4d3a-11eb-88b9-040cc7fd8754.png)](https://user-images.githubusercontent.com/39546083/103456543-92b96e80-4d3a-11eb-88b9-040cc7fd8754.png)



**문자열 결합(CONCAT)**

여러 개의 문자열을 연결해서 하나의 문자열로 반환하는 함수로 인자의 개수는 제한이 없다. 숫자값을 인자로 전달하면 문자열 타입으로 자동 변환한 후 연결한다. 의도된 결과가 아닌 경우 명시적으로 CAST 함수를 이용해 타입을 문자열로 변환하는 편이 안전하다.

[![image](https://user-images.githubusercontent.com/39546083/103456547-964cf580-4d3a-11eb-8e4c-a73acf320110.png)](https://user-images.githubusercontent.com/39546083/103456547-964cf580-4d3a-11eb-8e4c-a73acf320110.png)

CONCAT_WS() 라는 함수는 각 문자열을 연결할 때 구분자를 넣어준다. 첫 번째 인자를 구분자로 사용할 문자로 인식하고, 두 번째 인자부터는 연결할 문자로 인식한다.

[![image](https://user-images.githubusercontent.com/39546083/103456549-99e07c80-4d3a-11eb-9ba2-f99579e2249b.png)](https://user-images.githubusercontent.com/39546083/103456549-99e07c80-4d3a-11eb-9ba2-f99579e2249b.png)



**GROUP BY 문자열 결합(GROUP_CONCAT)**

COUNT(), MAX(), MIN(), AVG() 등과 같은 그룹함수(Aggregate, 여러 레코드의 값을 병합해서 하나의 값을 만들어 내는 함수) 중 하나다. 주로 GROUP BY와 함께 사용하며, GROUP BY가 없는 SQL에서 사용하면 단 하나의 결과 값만 만들어 낸다. 값들을 먼저 정렬한 후 연결하거나 각 값의 구분자 설정도 가능하며, 여러 값 중에서 중복을 제거하고 연결하는 것도 가능하다.

[![image](https://user-images.githubusercontent.com/39546083/103456550-9cdb6d00-4d3a-11eb-97a6-cc3321434969.png)](https://user-images.githubusercontent.com/39546083/103456550-9cdb6d00-4d3a-11eb-97a6-cc3321434969.png)

- 첫 번째는 테이블의 모든 레코드에서 dept_no 칼럼의 값을 기본 구분자(,)로 연결한 값을 반환한다.
- 두 번째 예제는 dept_no 값들을 연결할 때 사용한 구분자를 "," 에서 "|" 문자로 변경한 것이다.
- 세 번째 예제는 dept_name 칼럼의 값들을 역순으로 정렬해서 dept_no 칼럼의 값을 연결해서 가져오는 쿼리다. 쿼리 전체적으로 설정된 ORDER BY와 무관하게 처리된다.
- 네 번째 쿼리는 중복된 dept_no 값이 있다면 제거하고 유니크한 dept_no 값만을 연결해서 값을 가져오는 예제다.

GROUP_CONCAT() 함수는 지정한 칼럼의 값들을 연결하기 위해 제한적인 메모리 버퍼 공간을 사용한다. GROUP_CONCAT() 함수의 결과가 시스템 변수에 지정된 크기를 초과하면 쿼리에서 경고 메시지가 발생한다. GUI 도구를 이용해 실행하는 경우 단순히 경고만 발생하고 쿼리의 결과를 출력하지만 JDBC로 실행할 때는 에어로 취급되어 SQLException이 발생하므로 지정된 버퍼 크기를 초과하지 않도록 주의해야 한다.

GROUP_CONCAT() 함수가 사용하는 메모리 버퍼의 크기는 `group_concat_max_len` 시스템 변수로 조정할 수 있다. 기본으로 설정된 버퍼의 크기는 1KB밖에 안되기 때문에 필수적으로 점검해 두어야 한다.



**값의 비교와 대체(CASE WHEN .. THEN .. END)**

CASE WHEN은 함수가 아니라 SQL 구문이다. SWITCH 구문과 같은 역할을 한다. CASE로 시작하고 반드시 END로 끝나야 하며 WHEN .. THEN .. 은 필요한 만큼 반복해서 사용할 수 있다.

다음 예제는 코드값을 실제 값으로 변환하는 경우다. 이 방법은 동등 연사자(=)로 비교할 수 있을때 사용한다.

[![image](https://user-images.githubusercontent.com/39546083/103456552-a1078a80-4d3a-11eb-8f14-6184e0c0b54e.png)](https://user-images.githubusercontent.com/39546083/103456552-a1078a80-4d3a-11eb-8f14-6184e0c0b54e.png)

다음 예제는 단순히 두 비교 대상 값의 동등 비교가 아니라 크다 또는 작다 비교와 같이 표현식으로 비교할 때 사용하는 방식이다.

[![image](https://user-images.githubusercontent.com/39546083/103456553-a4027b00-4d3a-11eb-93f4-aa6b39f09b36.png)](https://user-images.githubusercontent.com/39546083/103456553-a4027b00-4d3a-11eb-93f4-aa6b39f09b36.png)

CASE WHEN 절이 일치하는 경우에만 THEN 이하의 표현식이 실행된다.

```mysql
SELECT de.dept_no, e.first_name, e.gender,
(SELECT s.salary FROM salaries s 
WHERE s.emp_no = e.emp_no
ORDER BY from_date DESC LIMIT 1) AS last_salary
FROM dept_emp de, employees e
WHERE e.emp_no = de.emp_no
AND de.dept_no='d001';
```

위 쿼리를 여자인 경우에만 최종 급여 정보가 필요하고 남자이면 그냥 이름만 필요한 경우로 수정해보자. 남자인 경우는 salaries 테이블을 조회할 필요가 없는데 서브 쿼리는 실행되므로 불필요한 작업을 하는 것이다. 이런 불필요한 작업을 제거하기 위해 CASE WHEN 으로 서브 쿼리를 감싸주면 필요한 경우에만 서브 쿼리를 실행할 수 있다.

```mysql
SELECT de.dept_no, e.first_name, e.gender,
CASE WHEN e.gender='F' THEN
(SELECT s.salary FROM salaries s
WHERE s.emp_no = e.emp_no
ORDER BY from_date DESC LIMIT 1)
ELSE 0
END AS last_salary
FROM dept_emp de, employees e
WHERE e.emp_no = de.emp_no
AND de.dept_no='d001';
```



**타입의 변환(CAST, CONVERT)**

프리페어 스테이트먼트를 제외하면 SQL은 텍스트(문자열) 기반으로 작동하기 때문에 SQL에 포함된 모든 입력 값은 문자열처럼 취급된다. 만약 명시적으로 타입의 변환이 필요하다면 CAST() 함수를 이용하면 된다. CONVERT() 함수도 CAST()와 거의 비슷하며, 함수의 인자 사용 규칙만 조금 다르다.

CAST() 함수를 통해 변환할 수 있는 데이터 타입은 `DATE, TIME, DATETIME, BINARY, CHAR, DECIMAL, SIGNED INTEGER, UNSIGNED INTEGER` 다. CAST() 함수는 하나의 인자를 받으며 다시 두 부분으로 나뉘어서 첫 번째 부분에 타입을 변환할 값이나 표현식을, 두 번째 부분에는 변환하고자 하는 데이터 타입을 명시한다. 일반적으로 문자열과 숫자 그리고 날짜의 변환은 명시적으로 해주지 않아도 MySQL이 자동으로 변환하는 경우가 많다. SIGNED나 UNSIGNED와 같은 부호 있는 정수 또는 부호 없는 정수 값의 변환은 그렇지 않을 때가 많다.

[![image](https://user-images.githubusercontent.com/39546083/103456557-a664d500-4d3a-11eb-98f2-6bcf4ffea89e.png)](https://user-images.githubusercontent.com/39546083/103456557-a664d500-4d3a-11eb-98f2-6bcf4ffea89e.png)

CONVERT() 함수는 CAST() 함수와 같이 타입을 변환하는 용도와 문자열의 문자집합을 변환하는 용도 두 가지로 사용할 수 있다.

[![image](https://user-images.githubusercontent.com/39546083/103456558-a8c72f00-4d3a-11eb-881b-b5b0065a6e1a.png)](https://user-images.githubusercontent.com/39546083/103456558-a8c72f00-4d3a-11eb-881b-b5b0065a6e1a.png)

타입 변환은 변환하려는 값이나 표현식을 첫 번째 인자로, 변환하려는 데이터 타입을 두 번째 인자로 적으면 된다. 문자열의 문자집합을 변경하려는 경우는 하나의 인자를 받아들이는데, 다시 두 부분으로 나눠서 첫 번째 부분에는 변환하고자 하는 값이나 표현식, 두 번째 부분에는 문자집합의 이름을 지정하면 된다. 첫 번째와 두 번째 부분의 구분자로 `USING` 키워드를 명시해주면 된다.



**이진값과 16진수(Hex String) 문자열 변환(HEX, UNHEX)**

HEX() 함수는 이진값을 사람이 읽을 수 있는 형태의 16진수의 문자열(Hex-string)로 변환하는 함수다. UNHEX() 함수는 16진수의 문자열을 읽어서 이진값(Binary)로 변환하는 함수다.



**암호화 및 해시 함수(MD5, SHA)**

모두 비대칭형 알고리즘인데, 인자로 전달한 문자열을 각각 지저오딘 비트 수의 해시 값을 만들어내는 함수다. SHA() 함수는 SHA-1 암호화 알고리즘을 사용하며 결과로 160비트(20바이트) 해시 값을 반환한다. MD5는 메시지 다이제스트(Message Digest) 알고리즘을 사용해 128비트(16바이트) 해시 값을 반환한다. 사용자의 비밀번호와 같은 암호화가 필요한 정보를 인코딩하는 데 사용하며 특히 MD5() 함수는 입력된 문자열(Message)의 길이를 줄이는(Digest) 용도로 사용된다. 두 함수의 출력 값은 16진수로 표시되기 때문에 저장하려면 저장 공간이 각각 20바이트와 16바이트의 두 배씩 필요하다. MD5() 함수는 CHAR(32), SHA() 함수는 CHAR(40)의 타입을 필요로 한다.

[![image](https://user-images.githubusercontent.com/39546083/103456562-ac5ab600-4d3a-11eb-8047-ac656ddc7bff.png)](https://user-images.githubusercontent.com/39546083/103456562-ac5ab600-4d3a-11eb-8047-ac656ddc7bff.png)

저장 공간을 원래의 16바이트와 20바이트로 줄이고 싶다면 CHAR나 VARCHAR 타입이 아닌 BINARY 형태의 타입에 저장하면 된다. 칼럼의 타입을 BINARY(16) 또는 BINARY(20)으로 정의하고, MD5() 함수나 SHA() 함수의 결과를 UNHEX() 함수를 이용해 이진값으로 변환해서 저장하면 된다. BINARY 타입에 저장된 이진값을 사람이 읽을 수 있는 16진수 문자열로 다시 되돌릴 때는 HEX() 함수를 사용하면 된다.

[![image](https://user-images.githubusercontent.com/39546083/103456565-b086d380-4d3a-11eb-8f3a-d4c1fb308390.png)](https://user-images.githubusercontent.com/39546083/103456565-b086d380-4d3a-11eb-8f3a-d4c1fb308390.png)

비대칭형 암호화 알고리즘은 결과 값의 중복 가능성이 매우 낮기 때문에 길이가 긴 데이터의 크기를 줄여서 인덱싱(해시)하는 용도로도 사용된다. URL과 같은 값은 1KB를 넘을 때도 있으며 전체적으로 값의 길이가 긴 편이다. 이러한 데이터를 검색하려면 인덱스가 필요하지만, 긴 칼럼에 대해 전체 값으로 인덱스를 생성하는 것은 불가능(Prefix 인덱스 제외)할뿐더러 공간 낭비도 커진다. URL의 값을 MD5() 함수로 단축하면 16바이트로 저장할 수 있고 이 16바이트로 인덱스를 생성하면 되기 때문에 상대적으로 효율적이다.



**처리 대기(SLEEP)**

"sleep" 기능을 수행한다. SQL의 개발이나 디버깅 용도로 잠깐 대기한다거나 쿼리의 실행을 오랜 시간 동안 유지한다거나 할 때 상당히 유용한 함수다.

대기할 시간을 초 단위로 인자를 받으며 어떠한 처리를 하거나 반환값을 넘겨주지 않는다. 지정한 시간만큼 대기할 뿐이다.



**벤치마크(BENCHMARK)**

디버깅이나 간단한 함수의 성능 테스트용으로 아주 유용한 함수다. 2개의 인자를 필요로 한다. 첫 번째 인자는 반복해서 수행할 회수이며, 두 번째 인자로는 반복해서 실행할 표현식을 입력하면 된다. 두 번째 인자의 표현식은 반드시 스칼라 값을 반환하는 표현식이어야 한다. SELECT 쿼리를 BENCHMARK() 함수에 사용하는 것도 가능하지만 반드시 스칼라 값(하나의 칼럼을 가진 하나의 레코드)만 반환하는 SELECT 쿼리만 사용할 수 있다.

BENCHMARK() 함수의 반환값은 중요하지 않으며 단지 지정한 횟수만큼 반복 실행하는 데 얼마나 시간이 소요됐는지가 중요할 뿐이다.

[![image](https://user-images.githubusercontent.com/39546083/103456569-b41a5a80-4d3a-11eb-8d3c-e4cee98f35d9.png)](https://user-images.githubusercontent.com/39546083/103456569-b41a5a80-4d3a-11eb-8d3c-e4cee98f35d9.png)

SQL 문장이나 표현식의 성능을 BECNMARK() 함수로 확인할 때는 주의해야 할 사항이 있다. `"SELECT BENCHMARK(10, expr)"`와 `"SELECT expr"`을 10번 직접 실행하는 것과는 차이가 있다는 것이다. "SELECT expr"을 10번 실행하는 경우에는 매번 쿼리의 파싱이나 최적화, 테이블 락이나 네트워크 비용 등이 소요된다. 하지만 "SELECT BENCHMARK(10, expr)"로 실행하는 경우에는 벤치마크 횟수에 관계없이 단 1번의 네트워크, 쿼리 파싱 및 최적화 비용이 소요된다는 점을 고려해야 한다.

"SELECT BENCHMARK(10, expr)"를 사용하면 한 번의 요청으로 expr 표현식이 10번 실행되는 것이므로 이미 할당받은 메모리 자원까지 공유되고, 메모리 할당도 직접 "SELECT expr" 쿼리로 10번 실해하는 것보다는 1/10 밖에 일어나지 않는다는 것이다. BENCHMARK() 함수로 얻은 쿼리나 함수의 성능은 그 자체로는 별로 의미가 없으며, 두 개의 동일 기능을 상대적으로 비교 분석하는 용도로 사용할 것을 권장한다.



**IP 주소 변환(INET_ATON, INET_NTOA)**

IP 주소는 4바이트의 부호 없는 정수(Unsigned integer)이다. 대부분의 DBMS에서는 IP 정보를 VARCHAR(15) 타입에 '.'으로 구분해서 저장하고 문자열로 저장된 IP 주소는 저장 공간을 훨씬 많이 필요로 한다. 일반적으로 IP 주소를 저장할 때 "127.0.0.1" 형태로 저장하므로 IP 주소 자체를 A, B, C 클래스로 구분하는 것도 불가능하다. 어떠한 DBMS도 IP 주소를 저장하는 타입은 별도로 제공하지 않는다.

INET_ATON() 함수와 INET_NTOA() 함수를 이용해 IP 주소를 문자열이 아닌 부호 없는 정수 타입에 저장할 수 있게 제공한다. INET_ATON() 함수는 문자열로 구성된 IP 주소를 정수형으로 변환하는 함수이며, INET_ATON() 함수는 정수형의 IP 주소를 사람이 읽을 수 있는 형태의 '.' 으로 구ㅜㅂㄴ된 문자열로 변환하는 함수다.

[![image](https://user-images.githubusercontent.com/39546083/103456571-b7ade180-4d3a-11eb-93a2-30865fb36148.png)](https://user-images.githubusercontent.com/39546083/103456571-b7ade180-4d3a-11eb-93a2-30865fb36148.png)



**MySQL 전용 암호화(PASSWORD, OLD_PASSWORD)**

PASSWORD()와 OLD_PASSWORD() 함수는 일반 사용자가 사용해서는 안 될 함수다. MySQL DBMS 사용자의 비밀번호를 암호화하는 기능의 함수다. 함수의 알고리즘이 MySQL 4.1.x 부터 바뀌었고 앞으로도 변경될 가능성이 있다. MySQL 4.0 이하 버전에서 사용되던 PASSWORD() 함수는 MySQL 4.1 이상의 버전에서는 OLD_PASSWORD()로 이름이 바뀌었다. MySQL 4.1 이상 버전의 PASSWORD() 함수는 전혀 다른 알고리즘으로 암호화하는 함수로 대체된 것이다.

[![image](https://user-images.githubusercontent.com/39546083/103456573-bc729580-4d3a-11eb-803f-cd4702dbccf1.png)](https://user-images.githubusercontent.com/39546083/103456573-bc729580-4d3a-11eb-803f-cd4702dbccf1.png)

[MySQL 5.7.5 버전부터 OLD_PASSWORD() 함수는 완전히 삭제되었다.](https://dev.mysql.com/doc/refman/5.7/en/password-hashing.html)

PASSWORD() 함수는 MySQL DBMS 유저의 비밀번호를 관리하기 위한 함수이지 일반 서비스의 고객 정보를 암호화하기 위한 용도로는 적합하지 않다. 서비스용 고객 정보를 암호화해야 할 때는 MD5() 함수나 SHA() 함수를 이용하는 것이 좋다.



**VALUES()**

`INSERT INTO ... ON DUPLICATE KEY UPDATE ... `형태의 SQL 문장에서만 사용할 수 있다. MySQL의 REPLICA와 비슷한 기능의 쿼리 문장인데, 프라이머리 키나 유니크 키가 중복되는 경우에는 UPDATE를 수행하고 그렇지 않으면 INSERT를 실행하는 문장이다.

```mysql
INSERT INTO tab_statistics (member_id, visit_count)
SELECT member_id, COUNT(*) AS cnt
FROM tab_accesslog GROUP BY member_id
ON DUPLICATE KEY
UPDATE visit_count = visit_count + VALUES(visit_count);
```

VALUES() 함수의 인자값으로는 INSERT 문장에서 값을 저장하려고 했던 칼럼의 이름을 입력하면 된다.



**COUNT()**

결과 레코드의 건수를 반환한다. 칼럼이나 표현식을 인자로 받으며 `"*"`를 사용할 수도 있다. 모든 칼럼을 가져오라는 의미가 아니라 그냥 레코드 자체를 의미하는 것이다. COUNT(*)이라고 해서 레코드의 모든 칼럼을 읽는 형태로 처리하지는 않는다.

MyISAM 스토리지 엔진을 사용하는 테이블은 항상 테이블의 메타 정보에 전체 레코드 건수를 관리하고 있다. WHERE 조건이 없는 COUNT(*) 쿼리는 MySQL 서버가 실제 레코드 건수를 세어 보지 않아도 바로 결과를 반환할 수 있기 때문에 빠르게 처리된다. 하지만 WHERE 조건이 있는 COUNT(*) 쿼리는 조건에 일치하는 레코드를 읽어 보지 않는 이상 알 수 없으므로 일반적인 DBMS와 같이 처리된다. MyISAM 이외의 스토리지 엔진을 사용하는 테이블에서는 WHERE 조건이 없는 COUNT(*) 쿼리라 하더라도 직접 데이터나 인덱스를 읽어야만 하므로 레코드 건수를 가져올 수 있기 때문에 큰 테이블에서 COUNT() 함수를 사용하는 작업은 주의해야 한다.

COUNT() 쿼리에 `ORDER BY`가 포함돼 있다거나 별도의 체크 조건을 가지지도 않는 `LEFT JOIN`이 사용된 채로 실행될 때가 많다. 모두 제거하는 것이 성능상 좋다.

일반적으로 칼럼의 값을 SELECT 하는 쿼리보다 COUNT(*) 쿼리가 훨씬 빠르게 실행될 것으로 생각할 때가 많다. 인덱스를 제대로 사용하도록 튜닝하지 못한 COUNT(*) 쿼리는 페이징해서 데이터를 가져오는 쿼리보다 몇 배 또는 몇십 배 더 느리게 실행될 수도 있다. 많은 부하를 일으키기 때문에 주의 깊게 작성해야 한다.

COUNT() 함수에 칼럼명이나 표현식이 인자로 사용되면 그 칼럼이나 표현식의 결과가 NULL이 아닌 레코드 건수만 반환한다. NULL이 될 수 있는 칼럼을 COUNT() 함수에 사용할 때는 의도대로 쿼리가 작동하는지 확인하는 것이 좋다.

### 7.3.4 SQL 주석

```mysql
-- 이 표기법은 한 라인만 주석으로 처리합니다.

/* 이 표기법은 여러 라인을
주석으로 처리합니다. */
```

- 첫 번째 표기법은 하이픈(-) 문자를 연속해서 표기함으로써 그 라인만 주석으로 만드는 방법이다. 연속된 하이픈 문자 뒤에 반드시 공백이 있어야 한다.
- 두 번째 표기법은 "/*" 표시부터 "*/" 표시까지 라인 수에 관계없이 모두 주석으로 만드는 방법이다.

MySQL에서는 유닉스 쉘 스크립트에서처럼 "#" 문자를 사용해서 한 라인을 주석으로 처리할 수 있다. 또한 변형된 C 언어 스타일의 주석 표기법도 사용할 수 있다. "/*" 뒤에 띄어쓰기 없이 "!" 문자를 연속해서 사용하는 것이다. MySQL에서는 사실 주석으로 해석되는 것이 아니라 선택적인 처리나 힌트를 주는 두 가지 용도로 사용된다. "/*!"로 시작하는 주석에는 문법에 일치하지 않는 내용이 들어가면 MySQL에서는 에러를 발생시킨다는 것을 의미한다. MySQL 이외의 DBMS 에서는 순수하게 주석으로 해석될 것이다.

```mysql
SELECT /*! STRAIGHT_JOIN */
FROM employees e, dept_emp de
WHERE de.emp_no=e.emp_no LIMIT 20;
```

STRAIGHT_JOIN 키워드는 조인의 순서를 결정하는 힌트다.

변형된 C 언어 스타일의 주석의 또 다른 사용법은 버전에 따라서 선별적으로 기능이나 옵션을 적용하는 것이다.

```mysql
CREATE /*! 50154 TEMPORARY */ TABLE tb_test ( fd INT, PRIMARY KEY(fd));
```

위 쿼리는 MySQL 버전에 따라 다음과 같이 두 가지 형태로 실행된다.

```mysql
-- // MySQL 5.1.54 이상
CREATE TEMPORARY TABLE tb_test ( fd INT, PRIMARY KEY(fd));

-- // MySQL 5.1.54 미만
CREATE TABLE tb_test ( fd INT, PRIMARY KEY(fd));
```

MySQL 5.0에서 쿼리나 프로시저에 포함된 주석은 모두 삭제되기도 하는데, 변형된 C 언어 스타일의 주석은 이를 막기 위한 트릭으로도 좋다. MySQL의 엔진을 한번 거친 쿼리에서는 주석이 모두 제거된다. 하지만 버전별 주석은 삭제하지 않는다.

```mysql
CREATE FUNCTION sf_getstring()
RETURNS VARCHAR(20) CHARACTER SET utf8
BEGIN
	/*!99999 이 함수는 문자집합 테스트용 프로그램임 */
	RETURN '한글 테스트';
END;;
```