# 6장. 실행 계획

[1. 쿼리 실행 절차 ](#쿼리-실행-절차)

[2. 실행 계획 분석](#6.2-실행-계획-분석)

​	  [2.1 id 컬럼](#6.2.1-id-컬럼)

​	  [2.2 select_type 컬럼](#6.2.2-select-type-컬럼)

​	  [2.3 table 컬럼](#6.2.3-table-컬럼)

​	  [2.4 type 컬럼](#6.2.4-type-컬럼)

<br/>

## 6-1 개요

### 쿼리 실행 절차

MySQL은 어떻게 쿼리를 실행하는가?

1. **SQL 파싱** *by SQL 파서*

   SQL 파서가 사용자로부터 요청된 SQL 문장을 잘게 쪼개서 MySQL 서버가 이해할 수 있는 수준으로 분리한다.

2. **최적화 및 실행 계획 수립** *by 옵티마이저*

   SQL의 파싱 정보(파스 트리)를 확인하면서 어떤 테이블부터 읽고, 어떤 인덱스를 이용해 테이블을 읽을지 선택한다.

   - *불필요한 조건의 제거* 및 *복잡한 연산 단순화*
   - 여러 테이블이 조인된 경우, *어떤 순서로 읽을지 결정*
   - 각 테이블에 사용된 조건과 인덱스 통계 정보를 이용해 *사용할 인덱스 결정*
   - 가져온 레코드들을 *임시 테이블*에 넣고 다시 한 번 가공해야 하는지 결정

3. **레코드 읽어오기 및 조인, 정렬**

   두 번째 단계에서 결정된 테이블의 읽기 순서나 선택된 인덱스를 이용해 *스토리지 엔진*으로부터 데이터를 가져온다. 

</br>

#### 참고 1) MySQL 서버 구성

![image](https://user-images.githubusercontent.com/19922698/99898121-875a3880-2ce2-11eb-831b-f9a5df2800ec.png)

<br/>

### 옵티마이저 종류

- 규칙 기반 최적화 : 옵티마이저에 내장된 우선순위에 따라 실행 계획을 수립하는 방식으로 이제 잘 사용하지 않는다.
- **비용 기반 최적화** *(MySQL 채택)* : 예측된 통계 정보를 이용해 최소 비용이 소요되는 처리방식을 선택하는 현대의 방식이다.

</br>

### 통계 정보

비용 기반 최적화에 사용되는 정보가 통계 정보이다. 부정확한 통계는 0.1초에 끝날 쿼리를 1시간 짜리 쿼리로 만들어 버릴 수 있다.

레코드 건수가 많지 않으면 통계정보가 부정확한 경우가 생기는데 이를 위해 `ANALYZE` 명령어를 사용해서 강제로 통계정보를 갱신하기도 한다. 레코드 건수가 얼마 되지 않는 개발용 MySQL 서버에서 자주 발생한다.

`ANALYZE` 명령어를 사용하면 InnoDB 기반의 테이블은 읽기와 쓰기 모두 불가능해진다. 따라서 서비스 도중에는 실행하지 않는 것이 좋다.

</br>

MySQL의 통계 정보는 레코드 건수, 인덱스의 유니크한 값의 개수 (그렇게 다양하지는 않다), 동적으로 자동으로 변경된다.

이를 `ANALYZE` 명령을 통해 강제적으로 통계 정보를 갱신할 수도 있다. (인덱스 키값의 선택도를 update)

```sql
SHOW INDEX FROM [테이블명];

ANALYZE TABLE [테이블명];
```

- ANALYZE를 실행하는 동안 MyISAM은 읽기 락, InnoDB는 쓰기 락이 걸리므로 서비스 도중엔 실행하지 않는 게 좋다.
- MyISAM은 정확한 키값 분포도를 위해 인덱스 전체 스캔 (시간 오래 걸림), InnoDB는 인덱스 페이지 중 8개 랜덤 선택. 



<br/>

## 6-2 실행 계획 분석

`EXPLAIN` 키워드를 쿼리 앞에 붙여서 쿼리의 실행 계획을 확인할 수 있다.

실행 계획에서 위쪽에 출력된 결과일수록 쿼리의 바깥부분, 혹은 먼저 접근한 테이블이다.

복잡하거나 무거운 쿼리를 실행한다면 실행 계획의 조회 또한 느려질수 있다. 그리고 `UPDATE`, `DELETE`, `INSERT` 의 경우 실행계획을 확인 할 수 없다. 이 경우 `WHERE` 을 적절히 변경해서 `SELECT` 를 이용해서 조회하도록 하자.

<br/>

![image](https://user-images.githubusercontent.com/19922698/99898734-1b2e0380-2ce7-11eb-91d2-491702a6cbcc.png)

- 쿼리 문장에서 사용한 **테이블 개수만큼** 표의 행 *(여기서는 2개)* 이 출력된다. *(❗️SELECT 개수만큼이 아니라 테이블 개수만큼)*
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

- **캐싱이 안 되는 서브쿼리** (원래 서브쿼리는 캐싱을 한다. *≠ 쿼리 캐시, ≠ DERIVED*)

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

> 테이블의 이름(별칭이 있다면 별칭)이 출력된다.

❗️MySQL의 실행 계획은 단위 쿼리 기준이 아니라 테이블 기준으로 표시된다.

![image](https://user-images.githubusercontent.com/19922698/99904595-37459b00-2d0f-11eb-8a0f-f9ac411906d6.png)



<br/>

### 6.2.4 type 컬럼

> 각 테이블의 레코드를 **어떤 방식으로 읽는지**

실행 계획에서 type 컬럼은 반드시 체크해야한다. 다시말하면 테이블의 접근 방식으로 해석하면 된다.

MySQL에서는 **조인 타입**이라고도 한다.

아래는 type 컬럼의 종류로 왼쪽부터 빠른 순으로 정렬하였다.

`system` > `cosnt` > `eq_ref` > `ref` > `fulltext` > `ref_or_null` > `unique_subquery` > `index_subquery` > `range` > `index_merge` > `index` > `ALL`

- `ALL`은 풀 스캔, `ALL` 이외의 나머지는 인덱스를 사용한다.
- `index_merge`를 제외하고는 반드시 하나의 인덱스만 사용한다.
- 옵티마이저는 이런 접근 방식과 비용을 함께 계산해서 최소 비용을 선택한다.



### `system`

- **레코드가 1건 또는 없는 테이블**

- MyISAM이나 MEMORY 테이블에서만 사용된다. (InnoDB는 index로 표현)

<br/>

### `const`

- **반드시 1건을 반환하는 쿼리** (그래서 const, 다른 DBMS에서는 UNIQUE INDEX SCAN이라고도 한다.)
- PK나 UK를 이용해 **WHERE 절에서 동등 조건(= 또는 <=>)**으로 검색한다. (다중 컬럼으로 구성된 PK, UK도 해당 컬럼들을 다 조건에 명시하면 가능)
  - 다중 컬럼을 사용하지 않고 일부만 사용한다면 `ref`로 표기할 것이다.
- ![image](https://user-images.githubusercontent.com/19922698/99905862-f487c100-2d16-11eb-8dd5-a814455f797b.png)



`동등 조건`?

![image](https://user-images.githubusercontent.com/19922698/100316545-15ddfb00-2ffe-11eb-9a63-f0a0bcc457e3.png)

<br/>

### `eq_ref`

- 여러 테이블이 조인되어야 한다.
- ![image](https://user-images.githubusercontent.com/19922698/99906357-0323a780-2d1a-11eb-8865-ddbbbb62a8c0.png)

- **조인에서 처음 읽은 테이블의 컬럼 값을, 그 다음 읽어야 할 테이블의 PK(UK) 검색 조건에 사용할 때**
- 처음 읽은 테이블의 컬럼을 다음 테이블의 PK, UK의 검색 조건에 사용되어야 한다.
  - UK를 사용할 경우 NOT NULL 이어야 한다.
  - 다중 컬럼으로 구성된 PK, UK 라면 모든 컬럼이 비교 조건에 사용되어야 한다.
- 위의 조건을 만족하는 경우 두 번째 이후 읽히는 테이블에서 `type` 에 `eq_ref` 가 나타난다.

<br/>

### `ref`

- 조인 순서, 인덱스 종류 관계 없이 **동등 조건(= 또는 <=>)으로 검색**하면 사용된다.
- PK, UK 등의 제약 조건도 없다.
- ![image](https://user-images.githubusercontent.com/19922698/99906544-09feea00-2d1b-11eb-97ee-e804169ac322.png)

<br/>

### `fulltext`

- **FULLTEXT 인덱스**를 사용해 읽는 방법 (검색에 주로 사용되는 기능이다.)

  - `CREATE FULLTEXT INDEX 인덱스명 ON 테이블명(칼럼명);`

  - 일반적인 인덱스보다 매우 빠르다.

- **`MATCH ... AGAINST ...` 구문으로 실행**한다.

- ![image](https://user-images.githubusercontent.com/19922698/99907358-be027400-2d1f-11eb-9871-7e13f3527ee4.png)

<br/>

### `ref_or_null`

- **ref와 같고, NULL 비교가 추가**된 형태이다.
- ![image](https://user-images.githubusercontent.com/19922698/99907424-0c177780-2d20-11eb-817b-58069746ec40.png)

<br/>

### `unique_subquery`

- IN (subquery) 형태에서 **서브쿼리에서 중복 없는 유니크한 값이 반환될 때**
- WHERE 조건절에서 사용될 수 있는 IN 형태의 쿼리를 위한 접근방식이다.

<br/>

### `index_subquery`

- IN (subquery) 형태에서 **중복 값이 있을 수 있지만 인덱스를 이용해 중복 값을 제거할 때**
- `unique_subquery` vs `index_subquery` : `IN` 절 내의 중복 제거 작업이 필요한가 아닌가

<br/>

### `range`

- **범위**로 검색. ( `<`, `>`, `IS NULL`, `BETWEEN`, `IN`, `LIKE` 등)
- 일반적으로 애플리케이션 쿼리가 가장 많이 사용하는 방법 (얘도 상당히 빠르다.)

<br/>

### `index_merge` :frowning_face:

- **2개 이상의 인덱스를 이용**해 각각의 검색 결과를 만들어낸 후 그 결과를 병합 처리
  - 전문 검색 인덱스 사용 시 적용 불가능.
  - 검색 결과에 대해 부가적인 작업(교집합, 합집합, 중복제거 등)이 필요하다. 
- 비효율적이다.
  1. range 보다 비효율적이다.
  2. 최적화가 되지 않을때가 많다.
  3. 전문 검색 인덱스에 적용되지 않는다.
  4. 집합의 형태로 결과를 반환하는데 중복 제거와 같은 부가 작업이 필요하다.

<br/>

### `index` :frowning_face:

- **= 인덱스 풀스캔을 의미한다. 필요한 부분만을 읽는 효율적인 방법이 아니다.**

- range, const, ref 같은 접근 방식으로 인덱스를 사용하지 못하는 경우이면서 **(WHERE 조건절이 없음)** (1)

- 인덱스에 포함된 칼럼만으로 처리할 수 있는 쿼리일 경우(2) or 인덱스를 이용해 정렬, 그룹핑 작업이 가능한 경우(3)

- ![image](https://user-images.githubusercontent.com/19922698/99938327-e5eae980-2daa-11eb-9e21-d8d05c129043.png)

  이 경우는 (1) + (3)

<br/>

### `all` :frowning_face:

- 우리가 아는 풀 테이블 스캔.
- **테이블을 처음부터 끝까지 다 읽는다.**
- InnoDB는 **Read Ahead**를 제공해 한 번에 여러 페이지를 읽어서 처리하도록 한다. (최대 64개의 페이지씩 한 번에 읽어들인다.)
  - 버퍼에 7번 페이지를 읽어달라고 요청이 오면, 8번 페이지도 곧 읽기 요청이 올 것이라고 예상하고, 미리 7, 8번 페이지를 같이 읽어들이는 기법.



**:arrow_right: 쿼리를 튜닝한다는 것이 무조건 인덱스 풀 스캔이나 테이블 풀 스캔을 벗어나는 것은 아니다.**
