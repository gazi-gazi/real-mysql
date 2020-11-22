#/bin/bash

CONTAINER_NO=$(docker ps -f 'name=real-my-sql'| tail -n 1 | awk '{print $1}')

if [ -z "$CONTAINER_NO" ] || [ "$CONTAINER_NO" == "CONTAINER" ] ; then
    echo ">> real-my-sql 이 실행중이지 않습니다."
    exit 1
fi


echo '>> dump data 압축 풀기'
unzip backup_data.zip -d ./

echo '>> dump data 복구 시작'
cat load_departments.dump | docker exec -i real-my-sql /usr/bin/mysql -u root --password=root rms
cat load_employees.dump | docker exec -i real-my-sql /usr/bin/mysql -u root --password=root rms
cat load_dept_emp.dump | docker exec -i real-my-sql /usr/bin/mysql -u root --password=root rms
cat load_dept_manager.dump | docker exec -i real-my-sql /usr/bin/mysql -u root --password=root rms
cat load_titles.dump | docker exec -i real-my-sql /usr/bin/mysql -u root --password=root rms
cat load_salaries.dump | docker exec -i real-my-sql /usr/bin/mysql -u root --password=root rms
echo '>> dump data 복구 완료'

echo '>> dump data 파일 삭제'
rm *.dump
echo '>> 완료'
