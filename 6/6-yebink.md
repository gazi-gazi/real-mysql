# 6장. 실행 계획

`EXPLAIN` 키워드를 쿼리 앞에 붙여서 쿼리의 실행 계획을 확인할 수 있다.

[1. 쿼리 실행 절차 ](#쿼리 실행 절차)

[2. 실행 계획 분석](#6.2 실행 계획 분석)

​	[2.1 id 컬럼](#6.2.1 id 칼럼)

​	[2.2 select_type 컬럼](#6.2.2 select_type 컬럼)

​	[2.3 table 컬럼](#6.2.3 table 컬럼)

## 6.1 개요

### 쿼리 실행 절차

1.  **SQL 파싱** *by SQL 파서*

   SQL 파서가 사용자로부터 요청된 SQL 문장을 잘게 쪼개서 MySQL 서버가 이해할 수 있는 수준으로 분리한다.

2. **최적화 및 실행 계획 수립** *by 옵티마이저*

   SQL의 파싱 정보(파스 트리)를 확인하면서 어떤 테이블부터 읽고, 어떤 인덱스를 이용해 테이블을 읽을지 선택한다.

   - *불필요한 조건의 제거* 및 *복잡한 연산 단순화*
   - 여러 테이블이 조인된 경우, *어떤 순서로 읽을지 결정*
   - 각 테이블에 사용된 조건과 인덱스 통계 정보를 이용해 *사용할 인덱스 결정*
   - 가져온 레코드들을 *임시 테이블*에 넣고 다시 한 번 가공해야 하는지 결정

3. **레코드 읽어오기 및 조인, 정렬**

   두 번째 단계에서 결정된 테이블의 읽기 순서나 선택된 인덱스를 이용해 *스토리지 엔진*으로부터 데이터를 가져온다. 



<br/>

#### 참고 1) MySQL 서버 구성

![image](https://user-images.githubusercontent.com/19922698/99898121-875a3880-2ce2-11eb-831b-f9a5df2800ec.png)

<br/>



#### 참고 2) 옵티마이저의 종류

- **비용 기반 최적화 (Cost-based Optimizer, CBO) 🙂**  (MySQL 채택 ✅)

  쿼리를 처리하기 위한 여러가지 가능한 방법을 뽑아보고, 각각의 단위 작업의 비용 정보, 통계 정보를 이용해 실행 계획별로 비용을 산출한다. 이 중 최소 비용이 소요되는 방식을 선택한다.

- **규칙 기반 최적화 (Rule-based Optimizer, RBO) :frowning_face:**

  쿼리를 칠 테이블의 레코드 수, 선택도 등을 고려하지 않고 옵티마이저에 내장된 우선순위에 따라 처리한다. (비용 정보, 통계 정보 고려 X)

<br/>

MySQL의 통계 정보는 레코드 건수, 인덱스의 유니크한 값의 개수 (그렇게 다양하지는 않다), 동적으로 자동으로 변경된다.

이를 `ANALYZE` 명령을 통해 강제적으로 통계 정보를 갱신할 수도 있다. (인덱스 키값의 선택도를 update)

```sql
SHOW INDEX FROM [테이블명];

ANALYZE TABLE [테이블명];
```

- ANALYZE를 실행하는 동안 MyISAM은 읽기 락, InnoDB는 쓰기 락이 걸리므로 서비스 도중엔 실행하지 않는 게 좋다.
- MyISAM은 정확한 키값 분포도를 위해 인덱스 전체 스캔 (시간 오래 걸림), InnoDB는 인덱스 페이지 중 8개 랜덤 선택. 



<br/>



## 6.2 실행 계획 분석

![image](https://user-images.githubusercontent.com/19922698/99898734-1b2e0380-2ce7-11eb-91d2-491702a6cbcc.png)

[2020-11-22 19:43:16] [HY000][1003] /* select#1 */ select `rms`.`employees`.`emp_no` AS `emp_no`,`rms`.`employees`.`birth_date` AS `birth_date`,`rms`.`s`.`emp_no` AS `emp_no`,`rms`.`s`.`salary` AS `salary`,`rms`.`s`.`from_date` AS `from_date`,`rms`.`s`.`to_date` AS `to_date` from `rms`.`employees` join `rms`.`salaries` `s` where (`rms`.`s`.`emp_no` = `rms`.`employees`.`emp_no`)
[



<br/>

- 쿼리 문장에서 사용한 **테이블 개수만큼** 표의 행*(여기서는 2개)*이 출력된다. *(❗️SELECT 개수만큼이 아니라 테이블 개수만큼)*
- 실행 순서는 위에서 아래로 표시된다. *(❗️UNION이나 상관 서브 쿼리는 아닐 수도 있다.)*
- SELECT만 가능하다. (UPDATE, INSERT, DELETE는 X)



### 6.2.1 id 칼럼

> 단위 쿼리 별로 부여되는 식별자

⭐️ `단위 쿼리` : SELECT 단위로 구분한 것

단, 조인 테이블 간의 id는 같다. 조인되는 테이블 개수만큼 실행 계획 레코드가 출력되지만 id는 같다.

![image](https://user-images.githubusercontent.com/19922698/99900655-4d922d80-2cf4-11eb-85a3-cd60fc2636f9.png)





### 6.2.2 select_type 컬럼

> 각 단위 쿼리가 어떤 타입의 쿼리인지 표시

<br/>

#### `SIMPLE`

- **UNION이나 서브 쿼리를 사용하지 않는 단순 SELECT 쿼리인 경우에 해당한다.**
- 쿼리에 조인이 포함되어도 이에 해당할 수 있다.
- 하나의 실행 계획에서 반드시 하나만 존재한다.

- 보통 가장 바깥 쿼리가 해당한다.

<br/>

#### `PRIMARY`

- **UNION이나 서브 쿼리가 포함된 SELECT 쿼리에서 가장 바깥에 있는 쿼리를 의미한다.**
- 하나의 실행 계획에서 반드시 하나만 존재한다.

<br/>

#### `UNION`

- **UNION 또는 UNION ALL로 결합하는 단위 SELECT 쿼리** 중 첫 번째를 제외한 **두 번째 이후의 단위 SELECT 쿼리**를 의미한다.
- ![image](https://user-images.githubusercontent.com/19922698/99901195-24739c00-2cf8-11eb-93b4-df863eeae407.png)
  - `DERIVED`? FROM 절에 사용한 서브쿼리를 의미함. 임시테이블(`<derived2>`)이 생긴다. *❗️적폐❗️➜ JOIN으로 풀자.*

<br/>



#### `DEPENDENT UNION`

- 마찬가지로 **UNION, UNION ALL로 결합하는 쿼리**에 표시된다.
- **`DEPENDENT`? 외부에게 영향받는 쿼리**를 의미한다. (외부 쿼리의 행이 내부에서 쓰인다.) *❗️외부 쿼리에 의존적이므로, 절대 외부 쿼리보다 먼저 수행될 수 없다. ➜ 비효율적이다.*
- ![image](https://user-images.githubusercontent.com/19922698/99902179-2db43700-2cff-11eb-9304-40f899912042.png)



<br/>

#### `UNION RESULT`

- **UNION (ALL)의 결과를 담아두는 임시 테이블을 의미한다.**
- 실제 쿼리에서 단위 쿼리(하나의 SELECT)가 아니기 때문에 id값은 부여되지 않는다.

<br/>

#### `SUBQUERY`

- **FROM 절 이외에서 사용되는 서브쿼리를 의미한다.**
- ![image](https://user-images.githubusercontent.com/19922698/99902361-aa93e080-2d00-11eb-904d-76e127dcc43a.png)

<br/>

#### `DEPENDENT SUBQUERY`

- **바깥쪽 SELECT에서 정의된 컬럼을 사용하는 경우.**
- ![image](https://user-images.githubusercontent.com/19922698/99902636-994bd380-2d02-11eb-9f3e-80894d3f08ad.png)

<br/>

#### `DERIVED`

- **FROM 절에서 사용되는 서브쿼리**를 의미한다.
- 파생 테이블이 생긴다. ➜ 파생 테이블 간에는 index가 없으므로 조인할 때 성능 상 불리하다. ❗️적폐❗️➜ JOIN으로 풀자.
- 인라인 뷰, 서브 셀렉트라고도 불린다.
- 위의 UNION 예시 참고

<br/>

#### `UNCACHEABLE SUBQUERY`

- 캐싱이 안 되는 서브쿼리 (원래 서브쿼리는 캐싱을 한다. *≠ 쿼리 캐시, ≠ DERIVED*)

- 조건이 똑같은 서브쿼리가 실행될 때는 다시 실행하지 않고 이전의 실행 결과를 그대로 사용할 수 있게 내부 캐시 공간에 담아둔다.

- **uncacheable의 조건**

  - `사용자 변수`가 서브 쿼리에 사용된 경우

    ![image](https://user-images.githubusercontent.com/19922698/99903346-1e38ec00-2d07-11eb-8690-90a8a9db4b55.png)

  - NOT-DETERMINISTIC 속성의 스토어드 루틴이 서브 쿼리 내에 사용된 경우

    - `NOT-DETERMINISTIC`? 입력이 같아도 시점에 따라 결과가 달라질 수도 있음을 의미한다.

    - `스토어드 루틴`? 서버에 저장할 수 있는 SQL 구문을 설정한 것. *아직 나에겐 그냥 함수 느낌..*

    - ```sql
      CREATE FUNCTION print_now() RETURNS DATETIME
      NOT DETERMINISTIC
      BEGIN
      	RETURN NOW();
      END ;;
      
      --아래와 같이 사용한다.
      SELECT print_now();
      ```

  - `UUID()`나 `RAND()`와 같이 결과값을 호출할 때마다 달라지는 함수가 서브 쿼리 내에 사용된 경우

<br/>

#### `UNCACHEABLE UNION`

- 위의 uncacheable의 조건과 UNION이 결합된 쿼리.

<br/>

### 6.2.3 table 컬럼

> 테이블의 이름(별칭이 있다면 별칭)

❗️MySQL의 실행 계획은 단위 쿼리 기준이 아니라 테이블 기준으로 표시된다.









